import CoreBluetooth
import Foundation

enum BLEScannerState: Sendable {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}

actor BLEScanner: NSObject {
    private var centralManager: CBCentralManager?
    private var continuation: AsyncStream<DiscoveredDevice>.Continuation?
    private var stateContinuation: AsyncStream<BLEScannerState>.Continuation?

    private var isScanning = false

    override init() {
        super.init()
    }

    func start() {
        guard centralManager == nil else { return }
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func stateStream() -> AsyncStream<BLEScannerState> {
        AsyncStream { continuation in
            self.stateContinuation = continuation
            if let manager = self.centralManager {
                continuation.yield(self.mapState(manager.state))
            }
        }
    }

    func scanForDevices() -> AsyncStream<DiscoveredDevice> {
        AsyncStream { continuation in
            self.continuation = continuation
            continuation.onTermination = { [weak self] _ in
                Task { [weak self] in
                    await self?.stopScanning()
                }
            }
            self.startScanning()
        }
    }

    func stopScanning() {
        guard isScanning else { return }
        isScanning = false
        centralManager?.stopScan()
        continuation?.finish()
        continuation = nil
    }

    private func startScanning() {
        guard let manager = centralManager,
              manager.state == .poweredOn else {
            return
        }
        isScanning = true
        manager.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }

    private func mapState(_ state: CBManagerState) -> BLEScannerState {
        switch state {
        case .unknown: .unknown
        case .resetting: .resetting
        case .unsupported: .unsupported
        case .unauthorized: .unauthorized
        case .poweredOff: .poweredOff
        case .poweredOn: .poweredOn
        @unknown default: .unknown
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension BLEScanner: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let state = central.state
        Task {
            await handleStateUpdate(state)
        }
    }

    private func handleStateUpdate(_ state: CBManagerState) {
        let mappedState = mapState(state)
        stateContinuation?.yield(mappedState)

        if state == .poweredOn && continuation != nil {
            startScanning()
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let serviceUUIDs = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID])?
            .map { UUID(uuidString: $0.uuidString) ?? UUID() }

        let device = DiscoveredDevice(
            id: peripheral.identifier,
            name: peripheral.name ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String,
            rssi: RSSI.intValue,
            manufacturerData: advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
            serviceUUIDs: serviceUUIDs,
            timestamp: Date()
        )

        Task {
            await handleDiscoveredDevice(device)
        }
    }

    private func handleDiscoveredDevice(_ device: DiscoveredDevice) {
        continuation?.yield(device)
    }
}
