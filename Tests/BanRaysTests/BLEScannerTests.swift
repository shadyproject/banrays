import Foundation
import Testing
@testable import BanRays

struct DiscoveredDeviceTests {
    @Test("Display name returns name when available")
    func displayNameWithName() {
        let device = DiscoveredDevice(
            id: .init(),
            name: "Test Device",
            rssi: -50,
            manufacturerData: nil,
            timestamp: .now
        )
        #expect(device.displayName == "Test Device")
    }

    @Test("Display name returns UUID when name is nil")
    func displayNameWithoutName() {
        let id = UUID()
        let device = DiscoveredDevice(
            id: id,
            name: nil,
            rssi: -50,
            manufacturerData: nil,
            timestamp: .now
        )
        #expect(device.displayName == id.uuidString)
    }

    @Test("Manufacturer data hex formatting")
    func manufacturerDataHex() {
        let data = Data([0x4C, 0x00, 0x02, 0x15, 0xFF])
        let device = DiscoveredDevice(
            id: .init(),
            name: nil,
            rssi: -60,
            manufacturerData: data,
            timestamp: .now
        )
        #expect(device.manufacturerDataHex == "4C 00 02 15 FF")
    }

    @Test("Manufacturer data hex returns nil when no data")
    func manufacturerDataHexNil() {
        let device = DiscoveredDevice(
            id: .init(),
            name: nil,
            rssi: -60,
            manufacturerData: nil,
            timestamp: .now
        )
        #expect(device.manufacturerDataHex == nil)
    }
}
