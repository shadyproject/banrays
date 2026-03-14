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

            if let hexData = device.manufacturerDataHex {
                Text(hexData)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            } else {
                Text("No manufacturer data")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}
