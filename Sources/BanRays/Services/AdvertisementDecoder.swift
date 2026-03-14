import Foundation

/// Decodes BLE manufacturer-specific advertising data into structured formats.
struct AdvertisementDecoder {
    // MARK: - Constants

    private enum AppleSubtype: UInt8 {
        case iBeacon = 0x02
    }

    private static let iBeaconDataLength = 23

    // MARK: - Public Interface

    /// Decodes manufacturer data into a structured advertisement.
    ///
    /// Attempts to parse known formats (iBeacon, etc.) and falls back to
    /// displaying the manufacturer name with raw hex for unknown formats.
    ///
    /// - Parameter data: The manufacturer-specific data from the advertisement.
    /// - Returns: A decoded advertisement, or nil if the data is empty.
    static func decode(_ data: Data) -> DecodedAdvertisement? {
        guard data.count >= 2 else { return nil }

        let companyID = extractCompanyID(from: data)
        let manufacturerName = ManufacturerIDs.name(for: companyID)
        let payload = data.dropFirst(2)

        if companyID == ManufacturerIDs.apple, let iBeacon = decodeIBeacon(from: payload) {
            return iBeacon
        }

        return .unknown(manufacturerName: manufacturerName, rawData: data)
    }

    // MARK: - Private Methods

    /// Extracts the 16-bit company identifier from manufacturer data.
    ///
    /// Company IDs are stored in little-endian byte order per Bluetooth spec.
    private static func extractCompanyID(from data: Data) -> UInt16 {
        UInt16(data[data.startIndex]) | (UInt16(data[data.startIndex + 1]) << 8)
    }

    /// Attempts to decode Apple iBeacon data.
    ///
    /// iBeacon format (after company ID):
    /// - Byte 0: Subtype (0x02 for iBeacon)
    /// - Byte 1: Data length (0x15 = 21)
    /// - Bytes 2-17: Proximity UUID (16 bytes, big-endian)
    /// - Bytes 18-19: Major (big-endian)
    /// - Bytes 20-21: Minor (big-endian)
    /// - Byte 22: TX Power (signed)
    private static func decodeIBeacon(from payload: Data) -> DecodedAdvertisement? {
        guard payload.count >= iBeaconDataLength else { return nil }

        let payloadArray = Array(payload)
        guard payloadArray[0] == AppleSubtype.iBeacon.rawValue else { return nil }
        guard payloadArray[1] == 0x15 else { return nil }

        let uuidBytes = Array(payloadArray[2..<18])
        guard let uuid = uuid(from: uuidBytes) else { return nil }

        let major = UInt16(payloadArray[18]) << 8 | UInt16(payloadArray[19])
        let minor = UInt16(payloadArray[20]) << 8 | UInt16(payloadArray[21])
        let txPower = Int8(bitPattern: payloadArray[22])

        return .iBeacon(uuid: uuid, major: major, minor: minor, txPower: txPower)
    }

    /// Creates a UUID from a 16-byte array.
    private static func uuid(from bytes: [UInt8]) -> UUID? {
        guard bytes.count == 16 else { return nil }

        let uuidString = String(
            format: "%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5],
            bytes[6], bytes[7],
            bytes[8], bytes[9],
            bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
        )

        return UUID(uuidString: uuidString)
    }
}
