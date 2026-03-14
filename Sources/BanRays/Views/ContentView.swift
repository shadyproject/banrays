import SwiftUI

struct ContentView: View {
    @State private var viewModel = BLEScannerViewModel()

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.scanState {
                case .idle:
                    idleView
                case .scanning:
                    scanningView
                case .error(let message):
                    errorView(message: message)
                }
            }
            .navigationTitle("BanRays")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    scanButton
                }
            }
        }
    }

    @ViewBuilder
    private var idleView: some View {
        if viewModel.devices.isEmpty {
            ContentUnavailableView(
                "No Devices",
                systemImage: "antenna.radiowaves.left.and.right",
                description: Text("Tap Scan to search for nearby BLE devices")
            )
        } else {
            deviceList
        }
    }

    private var scanningView: some View {
        VStack {
            if viewModel.devices.isEmpty {
                ContentUnavailableView {
                    Label("Scanning", systemImage: "antenna.radiowaves.left.and.right")
                } description: {
                    Text("Searching for nearby BLE devices...")
                } actions: {
                    ProgressView()
                        .padding(.top, 8)
                }
            } else {
                deviceList
            }
        }
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView(
            "Error",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
    }

    private var deviceList: some View {
        List(viewModel.devices) { device in
            DeviceRowView(device: device)
        }
        .refreshable {
            viewModel.clearAndRescan()
        }
    }

    private var scanButton: some View {
        Button {
            if case .scanning = viewModel.scanState {
                viewModel.stopScanning()
            } else {
                viewModel.startScanning()
            }
        } label: {
            if case .scanning = viewModel.scanState {
                Label("Stop", systemImage: "stop.fill")
            } else {
                Label("Scan", systemImage: "antenna.radiowaves.left.and.right")
            }
        }
    }
}

#Preview {
    ContentView()
}
