import Foundation

/// Bluetooth SIG assigned company identifiers.
///
/// Company IDs are 16-bit values assigned by the Bluetooth SIG.
/// In advertising data, they appear in little-endian byte order.
///
/// - SeeAlso: [Bluetooth SIG Assigned Numbers](https://www.bluetooth.com/specifications/assigned-numbers/)
enum ManufacturerIDs {
    // MARK: - Company ID Constants

    static let apple: UInt16 = 0x004C

    // MARK: - Name Lookup

    /// Dictionary mapping company ID to company name.
    static let names: [UInt16: String] = [
        0x0001: "Nokia",
        0x0002: "Intel",
        0x0003: "IBM",
        0x0004: "Toshiba",
        0x0006: "Microsoft",
        0x000A: "Qualcomm",
        0x000D: "Texas Instruments",
        0x000F: "Broadcom",
        0x0010: "Motorola",
        0x0013: "Atmel",
        0x001D: "Qualcomm Technologies",
        0x002D: "Bose",
        0x0030: "ST Microelectronics",
        0x0031: "Synopsys",
        0x004C: "Apple",
        0x0057: "Harman International",
        0x0059: "Nordic Semiconductor",
        0x005D: "Realtek Semiconductor",
        0x0075: "Samsung Electronics",
        0x0078: "Nike",
        0x0087: "Garmin",
        0x008A: "Pioneer",
        0x0094: "Beats Electronics",
        0x009E: "Bose",
        0x00B8: "Qualcomm Technologies International",
        0x00D2: "Dialog Semiconductor",
        0x00E0: "Google",
        0x00EB: "Dolby",
        0x00FE: "Honeywell International",
        0x010F: "Philips Lighting",
        0x0117: "Jabra",
        0x011B: "Ring",
        0x012D: "Sony",
        0x0131: "Huawei Technologies",
        0x0137: "Xiaomi",
        0x0144: "Logitech",
        0x0157: "Fitbit",
        0x015D: "Tile",
        0x0171: "Amazon",
        0x018F: "LEGO System",
        0x0198: "Polar Electro",
        0x01AB: "Meta Platforms",
        0x01B3: "ASSA ABLOY",
        0x01BC: "Harman",
        0x01D4: "Sonos",
        0x01E5: "Skullcandy",
        0x0203: "JBL",
        0x022B: "Oura Health",
        0x0244: "Ember Technologies",
        0x0259: "Withings",
        0x0310: "Wyze Labs",
        0x038F: "Govee",
        0x03C2: "Snapchat",
        0x058E: "Meta Platforms Technologies",
        0x0D53: "Luxottica Group",
    ]

    /// Returns the manufacturer name for a given company ID.
    ///
    /// - Parameter id: The 16-bit Bluetooth SIG company identifier.
    /// - Returns: The company name, or nil if the ID is not in the database.
    static func name(for id: UInt16) -> String? {
        names[id]
    }
}
