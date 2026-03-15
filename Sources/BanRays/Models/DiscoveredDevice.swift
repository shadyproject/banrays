import Foundation

struct DiscoveredDevice: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String?
    let rssi: Int
    let manufacturerData: Data?
    let serviceUUIDs: [UUID]?
    let timestamp: Date

    var displayName: String {
        name ?? id.uuidString
    }

    var manufacturerDataHex: String? {
        guard let data = manufacturerData else { return nil }
        return data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    /// The decoded advertisement data, if available.
    var decodedAdvertisement: DecodedAdvertisement? {
        guard let data = manufacturerData else { return nil }
        return AdvertisementDecoder.decode(data)
    }

    /// The manufacturer ID extracted from the manufacturer data, if available.
    var manufacturerID: UInt16? {
        guard let data = manufacturerData, data.count >= 2 else { return nil }
        return UInt16(data[0]) | (UInt16(data[1]) << 8)
    }

    /// Whether this device is from a smart glasses manufacturer.
    var isSmartGlasses: Bool {
        guard let id = manufacturerID else { return false }
        return ManufacturerIDs.isSmartGlassesManufacturer(id)
    }
}
