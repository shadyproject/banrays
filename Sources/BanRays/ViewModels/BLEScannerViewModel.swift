import Foundation

enum ScanState: Sendable, Equatable {
    case idle
    case scanning
    case error(String)
}

@Observable
@MainActor
final class BLEScannerViewModel {
    private(set) var devices: [DiscoveredDevice] = []
    private(set) var scanState: ScanState = .idle
    private(set) var bluetoothState: BLEScannerState = .unknown

    private let scanner = BLEScanner()
    private var scanTask: Task<Void, Never>?
    private var stateTask: Task<Void, Never>?

    init() {
        startMonitoringState()
    }


    func startScanning() {
        guard scanState != .scanning else { return }

        devices = []
        scanState = .scanning

        scanTask?.cancel()
        scanTask = Task {
            let stream = await scanner.scanForDevices()
            for await device in stream {
                guard !Task.isCancelled else { break }
                updateDevice(device)
            }
            if !Task.isCancelled {
                scanState = .idle
            }
        }
    }

    func stopScanning() {
        scanTask?.cancel()
        scanTask = nil
        Task {
            await scanner.stopScanning()
        }
        scanState = .idle
    }

    func clearAndRescan() {
        stopScanning()
        startScanning()
    }

    private func startMonitoringState() {
        stateTask = Task {
            await scanner.start()
            let stream = await scanner.stateStream()
            for await state in stream {
                guard !Task.isCancelled else { break }
                bluetoothState = state
                handleBluetoothStateChange(state)
            }
        }
    }

    private func handleBluetoothStateChange(_ state: BLEScannerState) {
        switch state {
        case .poweredOff:
            scanState = .error("Bluetooth is turned off")
        case .unauthorized:
            scanState = .error("Bluetooth permission denied")
        case .unsupported:
            scanState = .error("Bluetooth is not supported")
        case .poweredOn:
            if case .error = scanState {
                scanState = .idle
            }
        case .unknown, .resetting:
            break
        }
    }

    private func updateDevice(_ device: DiscoveredDevice) {
        if let index = devices.firstIndex(where: { $0.id == device.id }) {
            devices[index] = device
        } else {
            devices.append(device)
        }
        devices.sort { $0.timestamp > $1.timestamp }
    }
}
