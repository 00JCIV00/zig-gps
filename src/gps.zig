const std = @import("std");
const json = std.json;
const mem = std.mem;
const meta = std.meta;
const net = std.net;
const testing = std.testing;

pub const message = @import("message.zig");
pub const response = @import("response.zig");

/// Basic GPS Location
pub const Location = struct{
    time: []const u8,
    lat: f64,
    lon: f64,
    alt: ?f64 = null,
};

/// Client Config
pub const ClientConfig = struct {
    /// IP Address and Port for the GPSD TCP Connection.
    gpsd_addr: net.Address = net.Address.parseIp("127.0.0.1", 2947) catch unreachable,
    /// Ignore unknown JSON fields.
    ignore_unknown_fields: bool = true,
    /// Ignore corrupted JSON Messages.
    ignore_corrupted_msgs: bool = true,
    /// Max Read Size for JSON Messages.
    max_size: usize = 8096
};

/// A Client connection to GPSD
pub const Client = struct {
    alloc: mem.Allocator,
    conn: *net.Stream,
    msg_buf: std.ArrayList(u8),
    config: ClientConfig,
    json_config: json.ParseOptions,
    gpsd_error: ?[]const u8 = null,
    cur_loc: ?Location = null,

    /// Open a connection to GPSD's TCP Socket using the provided Client Config (`config`) and receive JSON Messages.
    pub fn open(alloc: mem.Allocator, config: ClientConfig) !@This() {
        var conn = try alloc.create(net.Stream);
        errdefer alloc.destroy(conn);
        conn.* = try net.tcpConnectToAddress(config.gpsd_addr);
        const ver_json = try conn.reader().readUntilDelimiterAlloc(alloc, '\n', config.max_size);
        defer alloc.free(ver_json);
        try conn.writeAll("?WATCH={\"enable\":true, \"json\":true}");
        const watch_json = try conn.reader().readUntilDelimiterAlloc(alloc, '\n', config.max_size);
        defer alloc.free(watch_json);
        errdefer conn.close();
        return .{
            .alloc = alloc,
            .conn = conn,
            .msg_buf = std.ArrayList(u8).init(alloc),
            .config = config,
            .json_config = .{
                .duplicate_field_behavior = .use_last,
                .ignore_unknown_fields = config.ignore_unknown_fields,
                .allocate = .alloc_always,
            },
        };
    }

    /// Close the client and cleanup resources.
    pub fn close(self: *@This()) void {
        if (self.cur_loc) |loc| self.alloc.free(loc.time);
        if (self.gpsd_error) |err| self.alloc.free(err);
        self.conn.close();
        self.alloc.destroy(self.conn);
        self.msg_buf.deinit();
    }

    /// Tell GPSD that the connection is ready to receive Messages using GPSD's `?WATCH;` command. This is done by default.
    pub fn start(self: *@This()) !json.Parsed(response.Watch) {
        try self.conn.writeAll("?WATCH={\"enable\":true, \"json\":true}");
        const response_json = try self.conn.reader().readUntilDelimiterAlloc(self.alloc, '\n', self.config.max_size);
        defer self.alloc.free(response_json);
        return json.parseFromSlice(
            response.Watch,
            self.alloc,
            response_json,
            self.json_config,
        ) catch {
            const err_response = try json.parseFromSlice(
                response.Error,
                self.alloc,
                response_json,
                self.json_config,
            );
            defer err_response.deinit();
            self.gpsd_error = try self.alloc.dupe(u8, err_response.value.message);
            return error.GPSDCommandError;
        };
    }

    /// Tell GPSD that the connection is NOT ready to receive Messages.
    pub fn stop(self: *@This()) !void {
        try self.conn.writeAll("?WATCH={\"enable\":false}");
    }

    /// Get the current Time and Position in a simple Location format using GPSD's `?POLL;` command.
    pub fn getLoc(self: *@This()) ?Location {
        const poll_response = self.poll() catch return null;
        defer poll_response.deinit();
        const tpv_len = poll_response.value.tpv.len;
        if (tpv_len == 0) return null;
        const tpv = poll_response.value.tpv[tpv_len - 1];
        if (
            tpv.time == null or
            tpv.lat == null or
            tpv.lon == null
        ) return null;
        self.cur_loc = .{
            .time = self.alloc.dupe(u8, tpv.time.?) catch return null,
            .lat = tpv.lat.?,
            .lon = tpv.lon.?,
            .alt = tpv.altMSL,
        };
        return self.cur_loc;
    }

    /// Read the latest available Messages. This is blocking.
    /// Both the returned Message list and each individual JSON Message will need to be freed.
    pub fn read(self: *@This()) ![]const json.Parsed(message.Generic) {
        try self.msg_buf.appendSlice(try self.conn.readAll());
        var end = mem.lastIndexOf(u8, self.msg_buf.items, '\n') orelse return error.NoCompleteMessages;
        var msg_iter = mem.splitScalar(u8, self.msg_buf.items[0..end], '\n');
        var msg_list = std.ArrayList(message.Generic).init(self.alloc);
        defer { for (0..end) |idx| _ = self.msg_buf.orderedRemove(idx); }
        while (msg_iter.next()) |msg_json| {
            end = mem.indexOfScalarPos(u8, msg_json, end, '\n') orelse end;
            const msg = json.parseFromSlice(
                message.Generic,
                self.alloc,
                msg_json,
                self.json_config,
            ) catch |err| {
                if (self.config.ignore_corrupted_msgs) continue;
                return err;
            };
            try msg_list.append(msg);
        }
        return msg_list;
    }

    /// Poll for the latest available TPV and SKY Messages using GPSD's `?POLL;` command.
    /// This is technically blocking, but GPSD typically replies immediately.
    pub fn poll(self: *@This()) !json.Parsed(response.Poll) {
        try self.conn.writeAll("?POLL;");
        const response_json = try self.conn.reader().readUntilDelimiterAlloc(self.alloc, '\n', self.config.max_size);
        defer self.alloc.free(response_json);
        return self.parseJSON(response.Poll);
    }

    /// Get the GPSD Version using GPSD's `?VERSION;` command.
    /// This is technically blocking, but GPSD typically replies immediately.
    pub fn version(self: *@This()) !json.Parsed(response.Version) {
        try self.conn.writeAll("?VERSION;");
        const response_json = try self.conn.reader().readUntilDelimiterAlloc(self.alloc, '\n', self.config.max_size);
        defer self.alloc.free(response_json);
        return self.parseJSON(response.Version);
    }

    /// Get the GPSD Devices using GPSD's `?DEVICES;` command.
    /// This is technically blocking, but GPSD typically replies immediately.
    pub fn devices(self: *@This()) !json.Parsed(response.Devices) {
        try self.conn.writeAll("?DEVICES;");
        const response_json = try self.conn.reader().readUntilDelimiterAlloc(self.alloc, '\n', self.config.max_size);
        defer self.alloc.free(response_json);
        return self.parseJSON(response.Devices);
    }

    /// Device Config for setting Device parameters.
    pub const DeviceConfig = struct {
        path: ?[]const u8 = null,
        bps: ?u32 = null,
        cycle: ?f64 = null,
        hexdata: ?[]const u8 = null,
        parity: ?[]const u8 = null,
    };

    /// Get or Set a GPSD Device using GPSD's `?DEVICE` command.
    /// This is technically blocking, but GPSD typically replies immediately.
    pub fn device(self: *@This(), set: bool, config: DeviceConfig) !json.Parsed(response.Device) {
        var cmd_buf = std.ArrayList(u8).init(self.alloc);
        defer cmd_buf.deinit();
        try cmd_buf.appendSlice("?DEVICE");
        if (!set) try cmd_buf.append(';')
        else {
            try cmd_buf.appendSlice("={");
            var add_sep = false;
            inline for (meta.fields(DeviceConfig)) |field| cont: {
                if (field.type == bool) break :cont;
                if (@field(config, field.name)) |param| {
                    if (add_sep) try cmd_buf.append(',');
                    add_sep = true;
                    switch (@TypeOf(param)) {
                        []const u8 => try cmd_buf.writer().print("\"{s}\":\"{s}\"", .{ field.name, param }),
                        else => try cmd_buf.writer().print("\"{s}\":{any}", .{ field.name, param }),
                    }
                }
            }
            try cmd_buf.append('}');
            //std.log.debug("Device Set JSON:\n{s}", .{ cmd_buf.items });
        }
        try self.conn.writeAll(cmd_buf.items);
        const watch_response = try self.parseJSON(response.Watch);
        defer watch_response.deinit();
        return self.parseJSON(response.Device);
    }

    /// Parse a JSON Message or Response
    fn parseJSON(self: *@This(), T: type) !json.Parsed(T) {
        const response_json = try self.conn.reader().readUntilDelimiterAlloc(self.alloc, '\n', self.config.max_size);
        defer self.alloc.free(response_json);
        //std.log.debug("{s}", .{ response_json });
        return json.parseFromSlice(
            T,
            self.alloc,
            response_json,
            self.json_config,
        ) catch {
            const err_response = try json.parseFromSlice(
                response.Error,
                self.alloc,
                response_json,
                self.json_config,
            );
            defer err_response.deinit();
            self.gpsd_error = try self.alloc.dupe(u8, err_response.value.message);
            return error.GPSDCommandError;
        };
    }
};
