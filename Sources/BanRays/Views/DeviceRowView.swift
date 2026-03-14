import SwiftUI

struct DeviceRowView: View {
    let device: DiscoveredDevice

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(device.displayName)
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                Text("\(device.rssi) dBm")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            advertisementView
        }
        .padding(.vertical, 4)
    }

    // MARK: - Private Views

    @ViewBuilder
    private var advertisementView: some View {
        switch device.decodedAdvertisement {
        case let .iBeacon(uuid, major, minor, txPower):
            iBeaconView(uuid: uuid, major: major, minor: minor, txPower: txPower)

        case let .unknown(manufacturerName, rawData):
            unknownAdvertisementView(manufacturerName: manufacturerName, rawData: rawData)

        case nil:
            Text("No manufacturer data")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private func iBeaconView(uuid: UUID, major: UInt16, minor: UInt16, txPower: Int8) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("iBeacon")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.blue)

            Text(uuid.uuidString)
                .font(.system(.caption2, design: .monospaced))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Text("Major: \(major)")
                Text("Minor: \(minor)")
                Text("TX: \(txPower) dBm")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }

    private func unknownAdvertisementView(manufacturerName: String?, rawData: Data) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            if let name = manufacturerName {
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.orange)
            }

            Text(formatHex(rawData))
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }

    private func formatHex(_ data: Data) -> String {
        data.map { String(format: "%02X", $0) }.joined(separator: " ")
    }
}
