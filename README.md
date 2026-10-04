# FoodPack AI — Mobile Application

> **AI-Based Intelligent Food Packaging Material Recommendation System**  
> Complete cross-platform mobile client built with **Flutter**, connecting to a live Spring Boot REST API orchestrating a FastAPI ML microservice, XGBoost Regressor, and SHAP Explainability Engine.

---

## 🌟 Key Features

- **Multi-Step Recommendation Wizard**:
  - Step 1: Food commodity selection with automatic physicochemical property auto-fill (moisture, pH, fat, protein, carbs, sensitivities).
  - Step 2: Storage conditions (temperature, humidity, required shelf-life days, packaging environment).
  - Step 3: Multi-objective priority weights (barrier performance vs cost vs sustainability).
  - Step 4: Review and AI dispatch with real-time multi-stage scientific loading progress.
- **Explainable AI (SHAP TreeExplainer)**:
  - Visual breakdown of feature impacts directly from XGBoost TreeExplainer.
  - Emerald green positive contribution bars (e.g. superior OTR barrier, tensile strength).
  - Rose red negative penalizing bars (e.g. high cost, high storage temperature).
- **Comprehensive Score Radial Gauges**:
  - Real-time animated circular gauges displaying overall suitability, barrier performance, cost score, and eco-score.
- **Side-by-Side Top 3 Material Comparison**:
  - Detailed matrix comparing candidate materials on OTR, WVTR, tensile strength, thickness, cost per sqm, and recyclability.
- **In-App PDF Report Generator & Exporter**:
  - High-resolution vector PDF generation with full recommendation details, food parameters, and SHAP factors.
  - Native print and share sheet integration (`pdf`, `printing`).
- **Role-Based Experience**:
  - **Food Producer (`ROLE_PRODUCER`)**: Personalized dashboard, KPI metrics, recommendation wizard, saved bookmarks, and history log.
  - **Packaging Technologist (`ROLE_TECHNOLOGIST`)**: Foods & packaging materials catalog browser, plus live XGBoost model metrics (R², MSE, feature importances).
  - **Administrator (`ROLE_ADMIN`)**: User directory management, account activation toggles, and system audit logs.
- **Theme & Connectivity**:
  - Material 3 Biotech Emerald theme with dark mode and light mode support.
  - Live network connectivity monitoring with non-intrusive offline banners.
  - Dynamic in-app server host & port switcher (for instant switching between emulator `10.0.2.2` and physical Wi-Fi IP `192.168.x.x`).

---

## 🏗️ Architecture

```
Flutter Mobile App (Android / iOS / Web)
        ↓ (JWT Bearer REST APIs)
Spring Boot Backend (:8080)
        ↓ (HTTP ML Request)
FastAPI ML Service (:8000)
        ↓
XGBoost Regressor + SHAP TreeExplainer
        ↓
MySQL Database (:3306)
```

---

## 📱 Tech Stack & Packages

- **Framework**: Flutter 3.47+ (Dart 3.13+)
- **State Management**: Flutter Riverpod 3.x
- **Networking**: Dio (with JWT Bearer interceptor & error translator)
- **Local Secure Storage**: `flutter_secure_storage` & `shared_preferences`
- **Animations & Gauges**: `flutter_animate`, Custom Canvas radial painter
- **Reporting**: `pdf`, `printing`
- **Connectivity**: `connectivity_plus`

---

## 🚀 Getting Started

### Prerequisites

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and added to `PATH`.
2. Android Studio / Android SDK (API level 34+).
3. The backend services (MySQL on 3306, FastAPI on 8000, Spring Boot on 8080) running.

### Installation

```bash
# Clone the repository
git clone https://github.com/vijayakrishan/Food-Tech-Mobile-Version-.git
cd Food-Tech-Mobile-Version-

# Install Flutter dependencies
flutter pub get

# Run tests
flutter test

# Run static analysis
flutter analyze
```

### Running the App

#### A. On Android Emulator
```bash
flutter run
```
*The app automatically defaults to `http://10.0.2.2:8080` on Android emulators.*

#### B. On Physical Android Device (over Wi-Fi)
```bash
flutter run --dart-define=API_HOST=192.168.1.X --dart-define=API_PORT=8080
```
*(Replace `192.168.1.X` with your computer's local Wi-Fi IP address).*

> **Tip**: You can also change the backend server IP at runtime! On the Login screen or Profile tab, tap the **Server Settings** icon and enter your computer's LAN IP without recompiling.

---

## 🔑 Demo Accounts

Use the quick-fill chips on the Login screen:

| Role | Username | Password |
|---|---|---|
| **Food Producer** | `producer` | `producer123` |
| **Packaging Technologist** | `tech` | `tech123` |
| **Administrator** | `admin` | `admin123` |

---

## 🧪 Testing

```bash
# Run all unit and widget tests
flutter test

# Verify static code health
flutter analyze
```

---

## 📄 License
This project is proprietary and confidential. All rights reserved.
