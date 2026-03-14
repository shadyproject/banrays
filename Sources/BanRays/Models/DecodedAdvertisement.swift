import Foundation

/// A decoded BLE advertising frame.
///
/// Represents manufacturer-specific data parsed into a human-readable format.
enum DecodedAdvertisement: Sendable, Equatable {
    /// Apple iBeacon proximity beacon.
    ///
    /// - Parameters:
    ///   - uuid: The 128-bit proximity UUID identifying the beacon's region.
    ///   - major: The major value for grouping related beacons.
    ///   - minor: The minor value for identifying individual beacons.
    ///   - txPower: The calibrated TX power at 1 meter, in dBm.
    case iBeacon(uuid: UUID, major: UInt16, minor: UInt16, txPower: Int8)

    /// Unknown or unsupported manufacturer data format.
    ///
    /// - Parameters:
    ///   - manufacturerName: The name of the manufacturer, if the company ID is known.
    ///   - rawData: The raw manufacturer data bytes.
    case unknown(manufacturerName: String?, rawData: Data)
}
