import SwiftUI

struct DeviceDetailView: View {
    let device: DiscoveredDevice

    @State private var showRawData = false

    var body: some View {
        List {
            Section("Device") {
                row(label: "Name", value: device.name ?? "Unknown")
                row(label: "Identifier", value: device.id.uuidString)
                row(label: "Signal Strength", value: "\(device.rssi) dBm")
                row(label: "Last Seen", value: device.timestamp.formatted(date: .omitted, time: .standard))
            }

            if let decoded = device.decodedAdvertisement {
                advertisementSection(decoded)
            }

            if let data = device.manufacturerData, !data.isEmpty {
                Section {
                    Button {
                        withAnimation {
                            showRawData.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Raw Data")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("\(data.count) bytes")
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .rotationEffect(.degrees(showRawData ? 90 : 0))
                        }
                    }

                    if showRawData {
                        rawDataView(data)
                    }
                }
            }
        }
        .navigationTitle(device.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Private Views

    @ViewBuilder
    private func advertisementSection(_ advertisement: DecodedAdvertisement) -> some View {
        switch advertisement {
        case let .iBeacon(uuid, major, minor, txPower):
            iBeaconSection(uuid: uuid, major: major, minor: minor, txPower: txPower)

        case let .unknown(manufacturerName, _):
            if let name = manufacturerName {
                Section("Manufacturer") {
                    row(label: "Company", value: name)
                }
            }
        }
    }

    private func iBeaconSection(uuid: UUID, major: UInt16, minor: UInt16, txPower: Int8) -> some View {
        Section("iBeacon") {
            VStack(alignment: .leading, spacing: 4) {
                Text("Proximity UUID")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(uuid.uuidString)
                    .font(.system(.body, design: .monospaced))
            }
            .padding(.vertical, 2)

            row(label: "Major", value: "\(major)")
            row(label: "Minor", value: "\(minor)")
            row(label: "TX Power", value: "\(txPower) dBm")
            row(label: "Estimated Range", value: estimatedRange(txPower: txPower, rssi: device.rssi))
        }
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .monospaced))
        }
    }

    private func rawDataView(_ data: Data) -> some View {
        Text(formatHex(data))
            .font(.system(.caption, design: .monospaced))
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Helpers

    private func formatHex(_ data: Data) -> String {
        data.enumerated().map { index, byte in
            let hex = String(format: "%02X", byte)
            return (index > 0 && index % 8 == 0) ? " \(hex)" : hex
        }.joined(separator: " ")
    }

    private func estimatedRange(txPower: Int8, rssi: Int) -> String {
        // Path loss model: RSSI = TxPower - 10 * n * log10(d)
        // Solving for d: d = 10^((TxPower - RSSI) / (10 * n))
        // Using n = 2 for free space (typical indoor is 2-4)
        let n: Double = 2.0
        let distance = pow(10.0, Double(Int(txPower) - rssi) / (10.0 * n))

        if distance < 1.0 {
            return String(format: "%.1f cm", distance * 100)
        } else if distance < 10.0 {
            return String(format: "%.1f m", distance)
        } else {
            return String(format: "%.0f m", distance)
        }
    }
}
