# ALU Internship Seeker

**Connecting student ambition with startup opportunities**

ALU internship seeker is a Flutter-based platform designed to connect African Leadership University students with startup opportunities, internships, projects, and entrepreneurial ecosystems. The application helps students discover opportunities, manage applications, connect with startups, and build professional networks.

---

# Table of Contents

* [Overview](#overview)
* [Features](#features)
* [Technology Stack](#technology-stack)
* [Application Architecture](#application-architecture)
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Firebase Configuration](#firebase-configuration)
* [Running the Application](#running-the-application)
* [Building the Application](#building-the-application)
* [Project Structure](#project-structure)
* [Environment Configuration](#environment-configuration)
* [Troubleshooting](#troubleshooting)
* [Future Improvements](#future-improvements)
* [Contributing](#contributing)
* [License](#license)

---

# Overview

ALU Venture Connect is a mobile and web application built to bridge the gap between students and entrepreneurial opportunities.

The platform enables students to:

* Discover startup opportunities
* Explore internships and projects
* Create professional profiles
* Submit applications
* Connect with startups
* Receive opportunity recommendations

The application follows a scalable Flutter architecture using feature-based organization, state management, Firebase services, and reusable components.

---

# Features

## Authentication

* User registration
* Secure login using Firebase Authentication
* Persistent authentication sessions
* Password recovery support

## Dashboard

* Personalized student dashboard
* Recent alerts
* Recommended opportunities
* Upcoming events and activities

## Opportunities

* Browse available opportunities
* Filter opportunities
* View opportunity details
* Apply for opportunities

## Startup Profiles

* View startup information
* Explore available positions
* Connect with startups

## Applications

* Track submitted applications
* View application status
* Manage opportunities

## Messaging

* Student-startup communication
* Message notifications

## User Experience

* Responsive UI
* Material Design components
* Light theme support
* Reusable widgets
* Secure local storage

---

# Technology Stack

## Frontend

| Technology      | Purpose                              |
| --------------- | ------------------------------------ |
| Flutter         | Cross-platform application framework |
| Dart            | Programming language                 |
| Provider        | State management                     |
| Material Design | UI components                        |

## Backend Services

| Technology              | Purpose             |
| ----------------------- | ------------------- |
| Firebase Authentication | User authentication |
| Firebase Firestore      | Database            |
| Firebase Storage        | File storage        |

## Additional Packages

* Dio - API communication
* Shared Preferences - Local storage
* Flutter Secure Storage - Secure data storage
* Google Fonts - Typography
* Cached Network Image - Image caching
* Flutter SVG - SVG rendering

---

# Application Architecture

The project uses a feature-based clean architecture approach.

```
lib/
│
├── core/
│   ├── constants/
│   ├── theme/
│   ├── services/
│   ├── errors/
│   └── utilities/
│
├── features/
│   ├── authentication/
│   ├── dashboard/
│   ├── opportunities/
│   ├── startups/
│   ├── applications/
│   └── messaging/
│
├── shared/
│   ├── widgets/
│   ├── components/
│   └── extensions/
│
├── models/
├── repositories/
├── providers/
├── routes/
│
└── main.dart
```

---

# Prerequisites

Before running the application, install:

## Flutter SDK

Verify installation:

```bash
flutter --version
```

Recommended:

```
Flutter 3.x+
Dart 3.x+
```

---

## Android Studio

Required for Android development.

Install:

* Android SDK
* Android Emulator
* Android SDK Platform Tools

Check:

```bash
flutter doctor
```

---

## Firebase CLI

Install:

```bash
npm install -g firebase-tools
```

Verify:

```bash
firebase --version
```

---

## FlutterFire CLI

Install:

```bash
dart pub global activate flutterfire_cli
```

Verify:

```bash
flutterfire --version
```

---

# Installation

## 1. Clone the repository

```bash
git clone https://github.com/N-Maurice/ALU-Internship-seeker_v2.git
```

Navigate into the project:

```bash
cd alu_internship_seeker_ii
```

---

## 2. Install dependencies

Run:

```bash
flutter pub get
```

---

## 3. Check Flutter configuration

Run:

```bash
flutter doctor
```

Resolve any issues before continuing.

---

# Firebase Configuration

This project uses Firebase services.

## 1. Create Firebase Project

Go to:

Firebase Console

Create a project:

```
alu-internship-seeker
```

---

## 2. Register Android Application

Find your Android package name:

```
android/app/build.gradle
```

Example:

```gradle
applicationId "com.example.alu_internship_seeker_ii"
```

Add this package name in Firebase.

---

## 3. Add SHA fingerprints

Generate SHA keys:

```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android
```

Add:

* SHA-1
* SHA-256

to:

```
Firebase Console
→ Project Settings
→ Android App
→ SHA certificate fingerprints
```

---

## 4. Add Firebase configuration file

Download:

```
google-services.json
```

Place it here:

```
android/app/google-services.json
```

---

## 5. Configure FlutterFire

Run:

```bash
flutterfire configure
```

This generates:

```
lib/firebase_options.dart
```

---

# Running the Application

## Run on Chrome

```bash
flutter run -d chrome
```

---

## Run on Android Device

Enable:

```
Developer Options
→ USB Debugging
```

Check device:

```bash
flutter devices
```

Run:

```bash
flutter run
```

---

## Run on Emulator

Start emulator:

```bash
flutter emulators --launch <emulator_id>
```

Then:

```bash
flutter run
```

---

# Building the Application

## Android APK

```bash
flutter build apk
```

Output:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Android App Bundle

For Play Store:

```bash
flutter build appbundle
```

---

## Web Build

```bash
flutter build web
```

---

# Environment Configuration

Sensitive configuration files should not be committed.

Recommended:

```
.env
firebase_options.dart
google-services.json
```

Add them to:

```
.gitignore
```

---

# Troubleshooting

## Firebase not connected

Run:

```bash
flutter clean
flutter pub get
flutterfire configure
```

Check:

```
lib/firebase_options.dart
```

exists.

---

## Android device not detected

Run:

```bash
adb devices
```

Enable:

```
Developer Options
USB Debugging
```

---

## Gradle build errors

Try:

```bash
flutter clean
cd android
gradlew clean
cd ..
flutter pub get
flutter run
```

---

## Firebase authentication errors

Verify:

Firebase Console:

```
Authentication
→ Sign-in method
→ Enable Email/Password
```

---

# Future Improvements

Planned features:

* AI-powered opportunity recommendations
* Startup verification system
* Real-time messaging
* Push notifications
* Student portfolio integration
* Advanced search and filtering
* Analytics dashboard

---

# Contributing

Contributions are welcome.

Steps:

1. Fork the repository
2. Create a feature branch

```bash
git checkout -b feature/new-feature
```

3. Commit changes

```bash
git commit -m "Add new feature"
```

4. Push changes

```bash
git push origin feature/new-feature
```

5. Open a Pull Request

---

# Developer

**ALU Venture Connect Team**

Built with Flutter to empower African student innovation.

---

# License

This project is developed for educational and innovation purposes.

All rights reserved.
