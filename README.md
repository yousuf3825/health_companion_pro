# SehatLink Pro

A comprehensive Flutter application designed for healthcare professionals including Doctors and Pharmacies to manage consultations, prescriptions, and medicine requests. This is a static frontend application built specifically for Android platforms.

## Overview

SehatLink Pro bridges the gap between healthcare providers by offering a unified platform for:
- **Doctors**: Manage patient consultations, create prescriptions, schedule appointments, and track medical history
- **Pharmacies**: Handle prescription fulfillment, medicine inventory, and patient medicine requests

## Features

### For Doctors 🩺
- **Patient Management**: View and manage patient information and medical history
- **Appointment Scheduling**: Set available time slots and manage appointments
- **Prescription Creation**: Create and manage digital prescriptions
- **Consultation Records**: Maintain detailed consultation records
- **Schedule Overview**: View daily/weekly appointment schedules

### For Pharmacies 💊
- **Prescription Management**: Receive and process prescriptions from doctors
- **Medicine Inventory**: Track and manage medicine stock
- **Patient Requests**: Handle medicine requests from patients
- **Order Processing**: Manage prescription fulfillment workflow
- **Stock Alerts**: Monitor medicine availability and expiry dates

### Common Features
- **Role-based Authentication**: Separate registration and login flows for doctors and pharmacies
- **Material Design 3**: Modern, clean UI with accessibility features
- **Responsive Design**: Optimized for Android devices
- **Profile Management**: Comprehensive user profile and settings
- **Secure File Uploads**: Document verification during registration

## Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Design System**: Material Design 3
- **Platform**: Android Only
- **Architecture**: StatefulWidget with static data models
- **Navigation**: Named routes with role-based navigation

## Project Structure

```
lib/
├── main.dart                          # App entry point and routing
├── models/
│   └── app_state.dart                 # Global state management
└── screens/
    ├── splash_screen.dart             # App launch screen
    ├── role_selection_screen.dart     # Doctor/Pharmacy selection
    ├── registration_verification_screen.dart
    ├── login_screen.dart
    ├── dashboard_screen.dart          # Role-based dashboard
    ├── settings_screen.dart
    ├── doctor/                        # Doctor-specific screens
    │   ├── patient_management_screen.dart
    │   ├── prescription_screen.dart
    │   ├── consultation_screen.dart
    │   ├── schedule_screen.dart
    │   └── slot_setup_screen.dart
    └── pharmacy/                      # Pharmacy-specific screens
        ├── prescription_management_screen.dart
        ├── medicine_inventory_screen.dart
        ├── patient_requests_screen.dart
        └── orders_screen.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Android SDK and emulator/physical device for testing

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd health_companion_pro
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

### Building for Android

```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

## Usage

1. **Launch the app** - The splash screen will appear for 3 seconds
2. **Select Role** - Choose between Doctor or Pharmacy
3. **Register** - Complete role-specific registration with required documents
4. **Login** - Use credentials to access the dashboard
5. **Navigate** - Use the role-based dashboard to access different features

### Doctor Workflow
1. Set up available time slots (9 AM - 5 PM format)
2. Manage patient appointments and consultations
3. Create and send prescriptions to pharmacies
4. View patient medical history and records

### Pharmacy Workflow
1. Receive and process prescriptions from doctors
2. Manage medicine inventory and stock levels
3. Handle patient medicine requests
4. Process orders and maintain fulfillment records

## Configuration

The app uses a centralized state management system in `lib/models/app_state.dart`:

- **Role Management**: Handles doctor/pharmacy role switching
- **User Data**: Stores current user information
- **Navigation State**: Manages role-based navigation flows

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue on GitHub
- Contact the development team
- Check the Flutter documentation for framework-specific questions

## Roadmap

- [ ] Backend API integration
- [ ] Real-time notifications
- [ ] iOS platform support
- [ ] Advanced prescription management
- [ ] Telemedicine features
- [ ] Payment gateway integration
