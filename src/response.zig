//! GPSD Command Response Classes
//! Source: https://gpsd.gitlab.io/gpsd/gpsd_json.html

const message = @import("message.zig");


/// Version `?VERSION;` Command Response
pub const Version = struct {
    /// Always "VERSION"
    class: []const u8 = "VERSION",
    /// Public release level
    release: []const u8,
    /// Internal revision-control level.
    rev: []const u8,
    /// API major revision level.
    proto_major: u8,
    /// API minor revision level.
    proto_minor: u8,
    /// URL of the remote daemon reporting this version. If empty, this is the version of the local daemon.
    remote: ?[]const u8 = null,
};


/// Devices `?DEVICES;` Command Response
pub const Devices = struct {
    /// Always "DEVICES"
    class: []const u8 = "DEVICES",
    /// List of device descriptions
    devices: []Device,
    /// URL of the remote daemon reporting the device set. If empty, this is a DEVICES response from the local daemon.
    remote: ?[]const u8 = null,
};

/// And individual Device
pub const Device = struct {
    /// Always "DEVICE"
    class: []const u8 = "DEVICE",
    /// Time the device was activated as an ISO8601 time stamp. If the device is inactive this attribute is absent.
    activated: ?[]const u8 = null,
    /// Device speed in bits per second.
    bps: ?u32 = null,
    /// Device cycle time in seconds.
    cycle: ?f64 = null,
    /// GPSD’s name for the device driver type. Won’t be reported before gpsd has seen identifiable packets from the device.
    driver: ?[]const u8 = null,
    /// Bit vector of property flags. Currently defined flags are: describe packet types seen so far (GPS, RTCM2, RTCM3, AIS). Won’t be reported if empty, e.g., before gpsd has seen identifiable packets from the device.
    ///
    /// Flags:
    /// - 0x01: SEEN_GPS
    /// - 0x02: SEEN_RTCM2
    /// - 0x04: SEEN_RTCM3
    /// - 0x08: SEEN_AIS
    flags: ?u4 = null,
    /// Data, in bare hexadecimal, to send to the GNSS receiver.
    hexdata: ?[]const u8 = null,
    /// Device minimum cycle time in seconds. Reported from ?DEVICE when (and only when) the rate is switchable. It is read-only and not settable.
    mincycle: ?f64 = null,
    /// 0 means NMEA mode and 1 means alternate mode (binary if it has one, for SiRF and Evermore chipsets in particular). Attempting to set this mode on a non-GPS device will yield an error.
    native: ?u8 = null,
    /// N, O, or E for no parity, odd, or even.
    parity: ?[]const u8 = null,
    /// Name the device for which the control bits are being reported, or for which they are to be applied. This attribute may be omitted only when there is exactly one subscribed channel.
    path: ?[]const u8 = null,
    /// True if device is read-only.
    readonly: ?bool = null,
    /// Hardware serial number (if the device driver returns that value).
    sernum: ?[]const u8 = null,
    /// Stop bits (1 or 2).
    stopbits: u8,
    /// Whatever version information the device driver returned.
    subtype: ?[]const u8 = null,
    /// More version information the device driver returned.
    subtype1: ?[]const u8 = null,
};

/// Watch `?WATCH;` Command Response
pub const Watch = struct {
    /// Always "WATCH"
    class: []const u8 = "WATCH",
    /// Enable (true) or disable (false) watcher mode. Default is true.
    enable: ?bool = null,
    /// Enable (true) or disable (false) dumping of JSON reports. Default is false.
    json: ?bool = null,
    /// Enable (true) or disable (false) dumping of binary packets as pseudo-NMEA. Default is false.
    nmea: ?bool = null,
    /// Controls 'raw' mode. When set to 1, gpsd reports the unprocessed NMEA or AIVDM data stream. When set to 2, gpsd reports the received data verbatim without hex-dumping.
    raw: ?u8 = null,
    /// If true, apply scaling divisors to output before dumping; default is false.
    scaled: ?bool = null,
    /// If true, aggregate AIS type24 sentence parts. If false, report each part as a separate JSON object. Default is false.
    split24: ?bool = null,
    /// If true, emit the TOFF JSON message on each cycle and a PPS JSON message when the device issues 1PPS. Default is false.
    pps: ?bool = null,
    /// If present, enable watching only of the specified device rather than all devices.
    device: ?[]const u8 = null,
    /// URL of the remote daemon reporting the watch set. If empty, this is a WATCH response from the local daemon.
    remote: ?[]const u8 = null,
};

/// Poll `?POLL;` Command Response
pub const Poll = struct {
    /// Always "POLL"
    class: []const u8 = "POLL",
    /// Timestamp in ISO 8601 format. May have a fractional part of up to .001sec precision.
    time: []const u8,
    /// Count of active devices.
    active: u32,
    /// List of TPV objects.
    tpv: []message.TPV,
    /// List of SKY objects.
    sky: []message.SKY,
};

/// Error Response to a syntactically invalid command line or unknown command
pub const Error = struct {
    /// Always "ERROR"
    class: []const u8 = "ERROR",
    /// Textual error message
    message: []const u8,
};

