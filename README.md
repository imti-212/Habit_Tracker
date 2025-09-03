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

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- The Flutter community for inspiration and support

## 📞 Support

If you have any questions or need help, please open an issue on GitHub.

---

**Made with ❤️ using Flutter and Firebase**
