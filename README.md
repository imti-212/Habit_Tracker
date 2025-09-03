
# Habit Tracker App

A comprehensive Flutter application for tracking habits, visualizing progress, and staying motivated with inspirational quotes. Built with Firebase integration for authentication and data persistence.

## 🚀 Features

### 📱 Core Functionality
- **Habit Management**: Create, edit, and track daily habits
- **Progress Visualization**: Beautiful charts and statistics
- **Motivational Quotes**: Daily inspirational quotes to keep you motivated
- **User Authentication**: Secure login and registration with Firebase
- **Dark/Light Theme**: Toggle between themes for better user experience

### 🔥 Firebase Integration
- **Authentication**: Email/password login and registration
- **Cloud Firestore**: Real-time data synchronization
- **Cross-Platform**: Works on Android, iOS, Web, macOS, and Windows

### 🎨 UI/UX Features
- **Modern Design**: Clean and intuitive interface
- **Responsive Layout**: Adapts to different screen sizes
- **Cyan Color Theme**: Beautiful gradient backgrounds
- **Custom Widgets**: Reusable components for consistency

## 📸 Screenshots

### Login Screen
- Beautiful cyan gradient background
- Modern authentication flow
- Responsive design

### Home Dashboard
- Progress summary
- Today's habits overview
- Motivational quotes carousel

### Habit Management
- Add new habits
- Track completion
- Edit habit details

### Progress Tracking
- Visual progress charts
- Statistics and analytics
- Achievement tracking

## 🛠️ Technology Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Backend**: Firebase
  - Authentication
  - Cloud Firestore
- **State Management**: Provider
- **UI Components**: Material Design 3
- **Charts**: fl_chart
- **HTTP**: http package for API calls

## 📋 Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Firebase account
- Git

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/habit-tracker.git
   cd habit-tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication and Cloud Firestore
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS
   - Place them in the respective directories

4. **Configure Firebase**
   ```bash
   flutterfire configure
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── habit_model.dart
│   ├── quote_model.dart
│   └── user_model.dart
├── providers/               # State management
│   ├── auth_provider.dart
│   ├── habit_provider.dart
│   ├── quote_provider.dart
│   └── theme_provider.dart
├── screens/                 # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── main/
│   │   ├── home_screen.dart
│   │   ├── habits_screen.dart
│   │   ├── progress_screen.dart
│   │   ├── quotes_screen.dart
│   │   └── profile_screen.dart
│   └── splash_screen.dart
├── widgets/                 # Reusable widgets
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   ├── habit_card.dart
│   ├── progress_summary.dart
│   └── quote_card.dart
└── utils/                   # Utilities
    ├── constants.dart
    └── theme.dart
```

## 🔧 Configuration

### Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Authentication (Email/Password)
4. Enable Cloud Firestore
5. Add your apps (Android, iOS, Web)
6. Download configuration files

### Environment Variables
Create a `.env` file in the root directory:
```env
FIREBASE_PROJECT_ID=your-project-id
```

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## ScreenShots
<img width="900" height="1003" alt="Screenshot 2025-09-03 144941" src="https://github.com/user-attachments/assets/2d1f499f-a134-43bb-a83d-92311d1e3987" />
<img width="902" height="1004" alt="Screenshot 2025-09-03 144730" src="https://github.com/user-attachments/assets/2267226a-25cb-45c4-9f19-a974b9f85ef0" />
<img width="902" height="1009" alt="Screenshot 2025-09-03 144716" src="https://github.com/user-attachments/assets/364644c7-0fee-43ff-86c2-83dca3952f30" />
<img width="905" height="1006" alt="Screenshot 2025-09-03 144703" src="https://github.com/user-attachments/assets/226f82da-874b-487a-a51f-d021b35e3542" />
<img width="897" height="1005" alt="Screenshot 2025-09-03 144652" src="https://github.com/user-attachments/assets/7dcae574-e69a-451a-8fd4-516a7a65fb7d" />
<img width="901" height="1002" alt="Screenshot 2025-09-03 144621" src="https://github.com/user-attachments/assets/16ad807b-6460-4e62-891e-bf5fa97a0e8e" />
<img width="900" height="1002" alt="Screenshot 2025-09-03 144609" src="https://github.com/user-attachments/assets/69fed307-fc55-42b5-bab4-72d41d563564" />
<img width="900" height="1005" alt="Screenshot 2025-09-03 144530" src="https://github.com/user-attachments/assets/0b013275-bfc8-4d81-a480-ee5c47cbcb1d" />
<img width="904" height="1001" alt="Screenshot 2025-09-03 144457" src="https://github.com/user-attachments/assets/45638653-b29c-4b67-8f65-6943023dc914" />
<img width="914" height="1004" alt="Screenshot 2025-09-03 144434" src="https://github.com/user-attachments/assets/318486e8-b092-4322-8a51-d69120e63d58" />
<img width="905" height="1001" alt="Screenshot 2025-09-03 144417" src="https://github.com/user-attachments/assets/115aa456-7058-4adc-8dd8-cdcf7a415eb9" />
<img width="911" height="999" alt="Screenshot 2025-09-03 144321" src="https://github.com/user-attachments/assets/9416dfb7-791e-46c3-b7b3-0bd2f062b971" />
<img width="906" height="1005" alt="Screenshot 2025-09-03 144305" src="https://github.com/user-attachments/assets/ffab4a13-71cc-4354-bddb-2dd677cd9905" />
<img width="907" height="1003" alt="Screenshot 2025-09-03 144219" src="https://github.com/user-attachments/assets/632ab221-5f4b-4538-a56e-5a3df521426c" />
<img width="1906" height="789" alt="Screenshot 2025-09-03 142812" src="https://github.com/user-attachments/assets/efa8bafa-56fd-4146-a3a7-abf3d45a9e19" />
