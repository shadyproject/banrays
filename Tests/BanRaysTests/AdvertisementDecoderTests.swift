import Foundation
import Testing
@testable import BanRays

struct AdvertisementDecoderTests {
    // MARK: - iBeacon Tests

    @Test("Decodes valid iBeacon data")
    func decodeIBeacon() {
        // Apple company ID (0x004C) + iBeacon subtype (0x02) + length (0x15)
        // + UUID + Major (0x0001) + Minor (0x0002) + TX Power (-59 dBm)
        let data = Data([
            0x4C, 0x00,                                     // Apple company ID (little-endian)
            0x02, 0x15,                                     // iBeacon subtype and length
            0xFD, 0xA5, 0x06, 0x93, 0xA4, 0xE2, 0x4F, 0xB1, // UUID first 8 bytes
            0xAF, 0xCF, 0xC6, 0xEB, 0x07, 0x64, 0x78, 0x25, // UUID last 8 bytes
            0x00, 0x01,                                     // Major
            0x00, 0x02,                                     // Minor
            0xC5,                                           // TX Power (-59)
        ])

        let decoded = AdvertisementDecoder.decode(data)
        guard case let .iBeacon(uuid, major, minor, txPower) = decoded else {
            Issue.record("Expected iBeacon, got \(String(describing: decoded))")
            return
        }

        #expect(uuid.uuidString == "FDA50693-A4E2-4FB1-AFCF-C6EB07647825")
        #expect(major == 1)
        #expect(minor == 2)
        #expect(txPower == -59)
    }

    @Test("Decodes iBeacon with high major/minor values")
    func decodeIBeaconHighValues() {
        let data = Data([
            0x4C, 0x00,
            0x02, 0x15,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0xFF, 0xFF,                                     // Major: 65535
            0xFF, 0xFE,                                     // Minor: 65534
            0x00,                                           // TX Power: 0
        ])

        let decoded = AdvertisementDecoder.decode(data)
        guard case let .iBeacon(_, major, minor, txPower) = decoded else {
            Issue.record("Expected iBeacon")
            return
        }

        #expect(major == 65535)
        #expect(minor == 65534)
        #expect(txPower == 0)
    }

    // MARK: - Manufacturer ID Tests

    @Test("Extracts manufacturer name for known company ID")
    func knownManufacturer() {
        // Google company ID: 0x00E0
        let data = Data([0xE0, 0x00, 0x01, 0x02, 0x03])

        let decoded = AdvertisementDecoder.decode(data)
        guard case let .unknown(manufacturerName, _) = decoded else {
            Issue.record("Expected unknown advertisement")
            return
        }

        #expect(manufacturerName == "Google")
    }

    @Test("Returns nil manufacturer name for unknown company ID")
    func unknownManufacturer() {
        // Unknown company ID: 0xFFFF
        let data = Data([0xFF, 0xFF, 0x01, 0x02, 0x03])

        let decoded = AdvertisementDecoder.decode(data)
        guard case let .unknown(manufacturerName, _) = decoded else {
            Issue.record("Expected unknown advertisement")
            return
        }

        #expect(manufacturerName == nil)
    }

    @Test("Preserves raw data in unknown advertisement")
    func unknownPreservesRawData() {
        let originalData = Data([0xFF, 0xFF, 0xAA, 0xBB, 0xCC])

        let decoded = AdvertisementDecoder.decode(originalData)
        guard case let .unknown(_, rawData) = decoded else {
            Issue.record("Expected unknown advertisement")
            return
        }

        #expect(rawData == originalData)
    }

    // MARK: - Edge Cases

    @Test("Returns nil for empty data")
    func emptyData() {
        let decoded = AdvertisementDecoder.decode(Data())
        #expect(decoded == nil)
    }

    @Test("Returns nil for single byte data")
    func singleByteData() {
        let decoded = AdvertisementDecoder.decode(Data([0x4C]))
        #expect(decoded == nil)
    }

    @Test("Returns unknown for Apple data with non-iBeacon subtype")
    func appleNonIBeacon() {
        // Apple company ID with AirPods subtype (not iBeacon)
        let data = Data([0x4C, 0x00, 0x07, 0x19, 0x01, 0x02])

        let decoded = AdvertisementDecoder.decode(data)
        guard case let .unknown(manufacturerName, _) = decoded else {
            Issue.record("Expected unknown advertisement")
            return
        }

        #expect(manufacturerName == "Apple")
    }

    @Test("Returns unknown for truncated iBeacon data")
    func truncatedIBeacon() {
        // Apple iBeacon header but truncated payload
        let data = Data([0x4C, 0x00, 0x02, 0x15, 0x00, 0x00])

        let decoded = AdvertisementDecoder.decode(data)
        guard case let .unknown(manufacturerName, _) = decoded else {
            Issue.record("Expected unknown advertisement")
            return
        }

        #expect(manufacturerName == "Apple")
    }
}

struct ManufacturerIDsTests {
    @Test(
        "Returns correct names for common manufacturers",
        arguments: [
            (UInt16(0x004C), "Apple"),
            (UInt16(0x00E0), "Google"),
            (UInt16(0x0006), "Microsoft"),
            (UInt16(0x0075), "Samsung Electronics"),
            (UInt16(0x0059), "Nordic Semiconductor"),
        ]
    )
    func commonManufacturers(id: UInt16, expectedName: String) {
        #expect(ManufacturerIDs.name(for: id) == expectedName)
    }

    @Test("Returns nil for unknown manufacturer ID")
    func unknownManufacturer() {
        #expect(ManufacturerIDs.name(for: 0xFFFF) == nil)
    }
}
