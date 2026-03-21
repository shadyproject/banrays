import SwiftUI

struct PinnedDeviceCardView: View {
    let device: DiscoveredDevice

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if device.isSmartGlasses {
                    Image(systemName: "eyeglasses")
                        .foregroundStyle(.red)
                }
                Text(manufacturerName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(device.isSmartGlasses ? .red : .orange)
            }

            Text(device.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)

            HStack {
                Text("\(device.rssi) dBm")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(device.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .frame(width: 160)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
    }

    // MARK: - Private

    private var manufacturerName: String {
        if let decoded = device.decodedAdvertisement {
            switch decoded {
            case .iBeacon:
                return "iBeacon"
            case let .unknown(name, _):
                return name ?? "Unknown"
            }
        }
        return "Unknown"
    }

    private var cardBackground: Color {
        device.isSmartGlasses ? Color.red.opacity(0.1) : Color(.secondarySystemBackground)
    }

    private var borderColor: Color {
        device.isSmartGlasses ? Color.red.opacity(0.3) : Color(.separator)
    }
}
