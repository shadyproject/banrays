import Foundation

struct DiscoveredDevice: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String?
    let rssi: Int
    let manufacturerData: Data?
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
}
