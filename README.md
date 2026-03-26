# Finvestea

A modern investment tracking and financial management app built with **Flutter** and **Firebase**.

## 🤖 Agentic Development with Antigravity
This application has been developed using **Antigravity**, utilizing advanced agentic AI to evolve the codebase into a production-ready state. The project initially started from a template with a suboptimal architecture; however, it has since been refactored to follow strict, high-quality development rules.

## 🏗️ Architecture & Production Standards
To ensure the app is robust and scalable, we have implemented a set of strict architectural and state-management rules:
- **Feature-Driven Architecture**: Code is logically separated into autonomous features.
- **State Management**: Standardized use of **Bloc** and **Cubit** for reactive and predictable state flow.
- **Routing**: Centralized navigation using **GoRouter** with named routes.
- **Networking**: High-performance HTTP client using **Dio** with interceptors and robust error handling.
- **Consistency**: Decoupled UI components from business logic for easier testing and maintenance.

## ⚙️ Environment Strategy (Main Targets)
This project uses multi-target entry points to maintain a clean separation between development and production environments, facilitating a professional CI/CD pipeline:

- **`lib/main_dev.dart`**: Used for local development. It initializes with `dev` configurations, mock data injection, and relaxed security constraints to speed up debugging.
- **`lib/main_prod.dart`**: The production entry point. It enforces strict environment configurations, production API keys (via `.env`), and enhanced logging/monitoring for deployment.

Run command example:
```bash
flutter run --target lib/main_dev.dart
```

## 🛠️ Key Technical Highlights
- **Specialized Data Parsing**: Replaced the standard `excel` package with `table_parser` to ensure more reliable and easier Excel/CSV data manipulation.
- **Cloud Infrastructure**: Fully integrated with **Firebase** (Auth, Firestore, Storage) for real-time data persistence and asset management.
- **AI Insights via Gemini**: Leverages **Google Gemini AI** to provide sophisticated, automated investment analysis based on user portfolio data.
- **Portfolio Analytics**: Built-in analytics dashboard utilizing `fl_chart` for visualizing portfolio performance and asset allocation.

---
