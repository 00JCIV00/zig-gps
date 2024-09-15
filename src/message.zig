//! GPSD Message Classes
//! Source: https://gpsd.gitlab.io/gpsd/gpsd_json.html

/// A Generic Message from GPSD 
pub const Generic = union {
    TPV: TPV,
    SKY: SKY,
    GST: GST,
    ATT: ATT,
    TOFF: TOFF,
    PPS: PPS,
};

/// A TPV object is a time-position-velocity report. The "class" and "mode" fields will reliably be present. When "mode" is 0 (Unknown) there is likely no usable data in the sentence. The remaining fields are optional, their presence depends on what data the GNSS receiver has sent, and what gpsd may calculate from that data.
/// 
/// A TPV object will usually be sent at least once for every measurement epoch as determined by the "time" field. Unless the receiver has a solid fix, and knows the current leap second, the time may be random.
/// 
/// Multiple TPV objects are often sent per epoch. When the receiver dribbles data to gpsd, then gpsd has no choice but to dribble it to the client in multiple TPV messages.
/// 
/// The optional "status" field (aka fix type), is a modifier (adjective) to mode. It is not a replacement for, or superset of, the "mode" field. It is almost, but not quite, the same as the NMEA 4.x xxGGA GPS Quality Indicator Values. Many GNSS receivers do not supply it. Those that do interpret the specification in various incompatible ways. To save space in the output, and avoid confusion, the JSON never includes status values of 0 or 1.
/// 
/// All error estimates (epc, epd, epe, eph, ept, epv, epx, epy) are guessed to be 95% confidence, may also be 50%, one sigma, or two sigma confidence. Many GNSS receivers do not specify a confidence level. None specify how the value is calculated. Use error estimates with caution, and only as relative "goodness" indicators. If the GPS reports a value to gpsd, then gpsd will report that value. Otherwise gpsd will try to compute the value from the skyview.
pub const TPV = struct {
    /// Always "TPV"
    class: []const u8 = "TPV",
    /// Name of the originating device.
    device: ?[]const u8 = null,
    /// NMEA mode:
    /// 0 = unknown,
    /// 1 = no fix,
    /// 2 = 2D,
    /// 3 = 3D.
    mode: u8,
    /// **Deprecated. Undefined. Use altHAE or altMSL.**
    alt: ?f64 = null,
    /// Altitude, height above ellipsoid, in meters. Probably WGS84.
    altHAE: ?f64 = null,
    /// MSL Altitude in meters.
    /// The geoid used is rarely specified and is often inaccurate.
    /// See the comments below on geoidSep.
    /// `altMSL` is `altHAE` minus `geoidSep`.
    altMSL: ?f64 = null,
    /// Antenna Status:
    /// 2 = Short,
    /// 3 = Open.
    ant: ?u8 = null,
    /// Climb (positive) or sink (negative) rate, meters per second.
    climb: ?f64 = null,
    /// Offset of local GNSS clock relative to UTC, in nanoseconds.
    /// Also known as Clock Offset. Sometimes given as Parts Per Billion (ppb), which is the same as nanoseconds.
    clockbias: ?f64 = null,
    /// The rate at which the local clock is drifting, in nanoseconds per second.
    clockdrift: ?f64 = null,
    /// Current datum. Hopefully WGS84.
    datum: ?[]const u8 = null,
    /// Depth in meters. Probably depth below the keel.
    depth: ?f64 = null,
    /// Age of DGPS data in seconds.
    dgpsAge: ?f64 = null,
    /// Station ID of DGPS data.
    dgpsSta: ?u16 = null,
    /// ECEF X position in meters.
    ecefx: ?f64 = null,
    /// ECEF Y position in meters.
    ecefy: ?f64 = null,
    /// ECEF Z position in meters.
    ecefz: ?f64 = null,
    /// ECEF position error in meters. Certainty unknown.
    ecefpAcc: ?f64 = null,
    /// ECEF X velocity in meters per second.
    ecefvx: ?f64 = null,
    /// ECEF Y velocity in meters per second.
    ecefvy: ?f64 = null,
    /// ECEF Z velocity in meters per second.
    ecefvz: ?f64 = null,
    /// ECEF velocity error in meters per second. Certainty unknown.
    ecefvAcc: ?f64 = null,
    /// Estimated climb error in meters per second. Certainty unknown.
    epc: ?f64 = null,
    /// Estimated track (direction) error in degrees. Certainty unknown.
    epd: ?f64 = null,
    /// Estimated horizontal position (2D) error in meters.
    /// Also known as Estimated Position Error (epe). Certainty unknown.
    eph: ?f64 = null,
    /// Estimated speed error in meters per second. Certainty unknown.
    eps: ?f64 = null,
    /// Estimated timestamp error in seconds. Certainty unknown.
    ept: ?f64 = null,
    /// Longitude error estimate in meters. Certainty unknown.
    epx: ?f64 = null,
    /// Latitude error estimate in meters. Certainty unknown.
    epy: ?f64 = null,
    /// Estimated vertical error in meters. Certainty unknown.
    epv: ?f64 = null,
    /// Geoid separation: the difference between the WGS84 reference ellipsoid and the geoid (Mean Sea Level) in meters.
    /// The computed `geoidSep` is usually within one meter of the "true" value but can be off by as much as 12 meters.
    geoidSep: ?f64 = null,
    /// Jamming Indicator:
    /// 0 (no jamming) to 255 (severe jamming). -1 means unset.
    jam: ?i16 = null,
    /// Latitude in degrees; positive indicates North, negative indicates South.
    lat: ?f64 = null,
    /// Current leap seconds.
    leapseconds: ?i16 = null,
    /// Longitude in degrees; positive indicates East, negative indicates West.
    lon: ?f64 = null,
    /// Course over ground, degrees magnetic.
    magtrack: ?f64 = null,
    /// Magnetic variation in degrees.
    /// Also known as the magnetic declination—the direction of the horizontal component of the magnetic field measured clockwise from north.
    /// Positive is West variation; negative is East variation.
    magvar: ?f64 = null,
    /// Down component of relative position vector in meters.
    relD: ?f64 = null,
    /// East component of relative position vector in meters.
    relE: ?f64 = null,
    /// North component of relative position vector in meters.
    relN: ?f64 = null,
    /// Estimated spherical (3D) position error in meters.
    /// Guessed to be 95% confidence, but many GNSS receivers do not specify, so certainty is unknown.
    sep: ?f64 = null,
    /// Speed over ground, meters per second.
    speed: ?f64 = null,
    /// GPS fix status:
    /// 0 = Unknown,
    /// 1 = Normal,
    /// 2 = DGPS,
    /// 3 = RTK Fixed,
    /// 4 = RTK Floating,
    /// 5 = DR,
    /// 6 = GNSSDR,
    /// 7 = Time (surveyed),
    /// 8 = Simulated,
    /// 9 = P(Y)
    status: ?u8 = null,
    /// Receiver temperature in degrees Celsius.
    temp: ?f64 = null,
    /// Time/date stamp in ISO8601 format, UTC.
    /// May have a fractional part of up to .001-second precision.
    /// May be absent if the mode is not 2D or 3D.
    /// May be present but invalid if there is no fix.
    /// Verify 3 consecutive 3D fixes before believing it is UTC.
    /// Even then, it may be off by several seconds until the current leap seconds are known.
    time: ?[]const u8 = null,
    /// Course over ground, degrees from true north.
    track: ?f64 = null,
    /// Down velocity component in meters per second.
    velD: ?f64 = null,
    /// East velocity component in meters per second.
    velE: ?f64 = null,
    /// North velocity component in meters per second.
    velN: ?f64 = null,
    /// Wind angle magnetic in degrees.
    wanglem: ?f64 = null,
    /// Wind angle relative in degrees.
    wangler: ?f64 = null,
    /// Wind angle true in degrees.
    wanglet: ?f64 = null,
    /// Wind speed relative in meters per second.
    wspeedr: ?f64 = null,
    /// Wind speed true in meters per second.
    wspeedt: ?f64 = null,
    /// Water temperature in degrees Celsius.
    wtemp: ?f64 = null,
};

/// A SKY object reports a sky view of the GPS satellite positions. If there is no GPS device available, or no skyview has been reported yet, only the "class" field will reliably be present.
pub const SKY = struct {
    /// Always "SKY"
    class: []const u8 = "SKY",
    /// Name of originating device.
    device: ?[]const u8 = null,
    /// Number of satellite objects in "satellites" array.
    nSat: ?u16 = null,
    /// Geometric (hyperspherical) dilution of precision.
    /// A dimensionless factor which should be multiplied by a base UERE to get an error estimate.
    gdop: ?f64 = null,
    /// Horizontal dilution of precision.
    /// A dimensionless factor which should be multiplied by a base UERE to get a circular error estimate.
    hdop: ?f64 = null,
    /// Position (spherical/3D) dilution of precision.
    /// A dimensionless factor which should be multiplied by a base UERE to get an error estimate.
    pdop: ?f64 = null,
    /// Pseudorange, in meters.
    pr: ?f64 = null,
    /// Pseudorange Rate of Change, in meters per second.
    prRate: ?f64 = null,
    /// Pseudorange residue, in meters.
    prRes: ?f64 = null,
    /// Quality Indicator.
    /// 0 = no signal
    /// 1 = searching signal
    /// 2 = signal acquired
    /// 3 = signal detected but unusable
    /// 4 = code locked and time synchronized
    /// 5, 6, 7 = code and carrier locked and time synchronized
    qual: ?u8 = null,
    /// List of satellite objects in skyview.
    satellites: ?[]Satellite = null,
    /// Time dilution of precision.
    /// A dimensionless factor which should be multiplied by a base UERE to get an error estimate.
    tdop: ?f64 = null,
    /// Time/date stamp in ISO8601 format, UTC.
    /// May have a fractional part of up to .001 second precision.
    time: ?[]const u8 = null,
    /// Number of satellites used in navigation solution.
    uSat: ?u16 = null,
    /// Vertical (altitude) dilution of precision.
    /// A dimensionless factor which should be multiplied by a base UERE to get an error estimate.
    vdop: ?f64 = null,
    /// Longitudinal dilution of precision.
    /// A dimensionless factor which should be multiplied by a base UERE to get an error estimate.
    /// Also known as Northing DOP.
    xdop: ?f64 = null,
    /// Latitudinal dilution of precision.
    /// A dimensionless factor which should be multiplied by a base UERE to get an error estimate.
    /// Also known as Easting DOP.
    ydop: ?f64 = null,

    const Satellite = struct {
        /// PRN ID of the satellite. See "PRN, GNSS id, SV id, and SIG id"
        PRN: u16,
        /// Used in current solution? (SBAS/WAAS/EGNOS satellites may be flagged used if the solution has corrections from them, but not all drivers make this information available.)
        used: bool,
        /// Azimuth, degrees from true north.
        az: ?f64 = null,
        /// Elevation in degrees.
        el: ?f64 = null,
        /// For GLONASS satellites only: the frequency ID of the signal. As defined by u-blox, range 0 to 13. The freqid is the frequency slot plus 7.
        freqid: ?u8 = null,
        /// The GNSS ID. See "PRN, GNSS id, SV id, and SIG id"
        gnssid: ?u8 = null,
        /// The health of this satellite. 0 is unknown, 1 is OK, and 2 is unhealthy.
        health: ?u8 = null,
        /// Signal to Noise ratio in dBHz.
        ss: ?f64 = null,
        /// The signal ID of this signal. See "PRN, GNSS id, SV id, and SIG id" u-blox, not NMEA. See u-blox doc for details.
        sigid: ?u8 = null,
        /// The satellite ID (PRN) within its constellation. See "<<PRNs>>"
        svid: ?u16 = null,
    };
};

/// A GST object is a pseudorange noise report.
pub const GST = struct {
    /// Always "GST"
    class: []const u8 = "GST",
    /// Name of originating device.
    device: ?[]const u8 = null,
    /// Time/date stamp in ISO8601 format, UTC. May have a fractional part of up to .001sec precision.
    time: ?[]const u8 = null,
    /// Value of the standard deviation of the range inputs to the navigation process (range inputs include pseudoranges and DGPS corrections).
    rms: ?f64 = null,
    /// Standard deviation of semi-major axis of error ellipse, in meters.
    major: ?f64 = null,
    /// Standard deviation of semi-minor axis of error ellipse, in meters.
    minor: ?f64 = null,
    /// Orientation of semi-major axis of error ellipse, in degrees from true north.
    orient: ?f64 = null,
    /// Standard deviation of altitude error, in meters.
    alt: ?f64 = null,
    /// Standard deviation of latitude error, in meters.
    lat: ?f64 = null,
    /// Standard deviation of longitude error, in meters.
    lon: ?f64 = null,
    /// Standard deviation of East velocity error, in meters per second.
    ve: ?f64 = null,
    /// Standard deviation of North velocity error, in meters per second.
    vn: ?f64 = null,
    /// Standard deviation of Up velocity error, in meters per second.
    vu: ?f64 = null,
};

/// An ATT object is a vehicle-attitude report. It is returned by digital-compass and gyroscope sensors; depending on device, it may include: heading, pitch, roll, yaw, gyroscope, and magnetic-field readings. Because such sensors are often bundled as part of marine-navigation systems, the ATT response may also include water depth.
///
/// The "class" and "mode" fields will reliably be present. Others may be reported or not depending on the specific device type.
///
/// The ATT object is synchronous to the GNSS epoch. Some devices report attitude information with arbitrary, even out of order, time scales. gpsd reports those in an IMU object. The ATT and IMU objects have the same fields, but IMU objects are output as soon as possible. Some devices output both types with arbitrary interleaving.
pub const ATT = struct {
    /// Always "ATT"
    class: []const u8 = "ATT",
    /// Name of originating device.
    device: []const u8,
    /// Time/date stamp in ISO8601 format, UTC. May have a fractional part of up to .001sec precision.
    time: ?[]const u8 = null,
    /// Arbitrary time tag of measurement.
    timeTag: ?[]const u8 = null,
    /// Heading, degrees from true north.
    heading: ?f64 = null,
    /// Magnetometer status.
    mag_st: ?[]const u8 = null,
    /// Heading, degrees from magnetic north.
    mheading: ?f64 = null,
    /// Pitch in degrees.
    pitch: ?f64 = null,
    /// Pitch sensor status.
    pitch_st: ?[]const u8 = null,
    /// Rate of Turn in degrees per minute.
    rot: ?f64 = null,
    /// Yaw in degrees.
    yaw: ?f64 = null,
    /// Yaw sensor status.
    yaw_st: ?[]const u8 = null,
    /// Roll in degrees.
    roll: ?f64 = null,
    /// Roll sensor status.
    roll_st: ?[]const u8 = null,
    /// Local magnetic inclination, degrees, positive when the magnetic field points downward (into the Earth).
    dip: ?f64 = null,
    /// Scalar magnetic field strength.
    mag_len: ?f64 = null,
    /// X component of magnetic field strength.
    mag_x: ?f64 = null,
    /// Y component of magnetic field strength.
    mag_y: ?f64 = null,
    /// Z component of magnetic field strength.
    mag_z: ?f64 = null,
    /// Scalar acceleration.
    acc_len: ?f64 = null,
    /// X component of acceleration (m/s²).
    acc_x: ?f64 = null,
    /// Y component of acceleration (m/s²).
    acc_y: ?f64 = null,
    /// Z component of acceleration (m/s²).
    acc_z: ?f64 = null,
    /// X component of angular rate (deg/s).
    gyro_x: ?f64 = null,
    /// Y component of angular rate (deg/s).
    gyro_y: ?f64 = null,
    /// Z component of angular rate (deg/s).
    gyro_z: ?f64 = null,
    /// Water depth in meters.
    depth: ?f64 = null,
    /// Temperature at the sensor, degrees centigrade.
    temp: ?f64 = null,
};

/// This message is emitted on each cycle and reports the offset between the host’s clock time and the GPS time at top of the second (actually, when the first data for the reporting cycle is received).
/// 
/// This message exactly mirrors the PPS message.
/// 
/// The TOFF message reports the GPS time as derived from the GPS serial data stream. The PPS message reports the GPS time as derived from the GPS PPS pulse.
pub const TOFF = struct {
    /// Always "TOFF"
    class: []const u8 = "TOFF",
    /// Name of the originating device
    device: []const u8,
    /// Seconds from the GPS clock
    real_sec: i64,
    /// Nanoseconds from the GPS clock
    real_nsec: i32,
    /// Seconds from the system clock
    clock_sec: i64,
    /// Nanoseconds from the system clock
    clock_nsec: i32,
};

/// This message is emitted each time the daemon sees a valid PPS (Pulse Per Second) strobe from a device.
/// 
/// This message exactly mirrors the TOFF message.
/// 
/// The TOFF message reports the GPS time as derived from the GPS serial data stream. The PPS message reports the GPS time as derived from the GPS PPS pulse.
/// 
/// There are various sources of error in the reported clock times. The speed of the serial connection between the GPS and the system adds a delay to the start of cycle detection. An even bigger error is added by the variable computation time inside the GPS. Taken together the time derived from the start of the GPS cycle can have offsets of 10 milliseconds to 700 milliseconds and combined jitter and wander of 100 to 300 milliseconds.
/// 
/// See the NTP documentation for their definition of precision.
pub const PPS = struct {
    /// Always "PPS"
    class: []const u8 = "PPS",
    /// Name of the originating device
    device: []const u8,
    /// seconds from the PPS source
    real_sec: i64,
    /// nanoseconds from the PPS source
    real_nsec: i32,
    /// seconds from the system clock
    clock_sec: i64,
    /// nanoseconds from the system clock
    clock_nsec: i32,
    /// NTP style estimate of PPS precision
    precision: i64,
    /// shm key of this PPS
    shm: []const u8,
    /// Quantization error of the PPS, in picoseconds. Sometimes called the "sawtooth" error.
    qErr: ?i64 = null,
};

