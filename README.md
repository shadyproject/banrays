# BanRays

A BLE (Bluetooth Low Energy) scanner for iOS that discovers nearby devices and decodes their advertising data into human-readable formats.

## Features

- Real-time BLE device scanning
- Decodes manufacturer-specific advertising data:
  - **iBeacon**: Displays proximity UUID, major/minor values, and TX power
  - **Other manufacturers**: Shows company name from Bluetooth SIG database
- Signal strength (RSSI) display
- Swift 6 with strict concurrency

## Requirements

- iOS 17.0+
- Xcode 15.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## Building

```bash
# Install XcodeGen if needed
brew install xcodegen

# Generate Xcode project
xcodegen generate

# Build
xcodebuild build -scheme BanRays -destination 'generic/platform=iOS'
```

## Running Tests

```bash
xcodebuild test -scheme BanRays -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Project Structure

```
Sources/BanRays/
├── App.swift                     # Entry point
├── Models/
│   ├── DiscoveredDevice.swift    # BLE device model
│   └── DecodedAdvertisement.swift # Decoded advertisement types
├── Services/
│   ├── BLEScanner.swift          # CoreBluetooth scanner actor
│   ├── AdvertisementDecoder.swift # Decodes manufacturer data
│   └── ManufacturerIDs.swift     # Bluetooth SIG company IDs
├── ViewModels/
│   └── BLEScannerViewModel.swift
└── Views/
    ├── ContentView.swift
    └── DeviceRowView.swift
```

## Supported Manufacturers

The app recognizes ~50 common Bluetooth SIG company identifiers including Apple, Google, Microsoft, Samsung, Nordic Semiconductor, Garmin, Fitbit, Tile, Amazon, Sony, Bose, and others.

## License

MIT
