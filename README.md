# IDN POS

A Flutter-based Point of Sale (POS) application designed to support sales transactions and related cashier operations.

## Features

- QR code and barcode scanning support
- QR code generation
- Thermal printer integration
- Permission handling for device features
- Date and number formatting for transaction-related data

## Tech Stack

- **Flutter**: Cross-platform application development
- **Dart**: Programming language
- **Mobile Scanner**: QR code and barcode scanning
- **QR Flutter**: QR code generation
- **Blue Thermal Printer**: Thermal printer integration
- **Permission Handler**: Device permission management
- **Intl**: Date and number formatting

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- A compatible Android device or emulator

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/najlanafisah/idn_pos.git
   cd idn_pos
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the application:

   ```bash
   flutter run
   ```

## Project Structure

```text
idn_pos/
├── android/          # Android configuration
├── ios/              # iOS configuration
├── assets/
│   └── icons/        # Application icons
├── lib/              # Main application source code
├── macos/            # macOS Flutter configuration
├── test/             # Application tests
├── web/              # Web configuration
├── pubspec.yaml      # Dependencies and project settings
├── pubspec.lock      # Dependency versions
└── README.md         # Project documentation
```

## Project Status

A Flutter POS application project with QR code, scanning, and thermal printing dependencies.

## License

No license has been specified for this repository.
