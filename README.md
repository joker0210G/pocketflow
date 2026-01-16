# 💸 PocketFlow

A minimalist, vibrant financial tracking application designed for students to manage their pocket money with ease. PocketFlow simplifies personal finance by visualizing money in "buckets" (categories) and providing clear insights into spending habits.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-purple?style=for-the-badge)
![Hive](https://img.shields.io/badge/Hive-Local%20Database-orange?style=for-the-badge)

## ✨ Features

- **💰 Transaction Tracking**: Easily log Income and Expenses.
- **📊 Smart Dashboard**: View your Current Balance, Total Income, and Total Expenses at a glance.
- **📂 Category Buckets**: Categorize spending into intuitive buckets like *Food, Travel, Entertainment, and more*.
- **📈 Visual Analytics**: Beautiful Pie Charts to visualize where your money goes.
- **⚡ Fast & Offline**: Built with **Hive** for instant, offline-first data persistence.
- **🎨 Modern UI**: A clean, Material 3 design with vibrant colors and smooth interactions.

## 📱 Screenshots

| Home Dashboard | Add Transaction |
|:---:|:---:|
| <!-- Insert Home Screenshot --> <img src="docs/screenshots/home.png" alt="Home" width="250"/> | <!-- Insert Add Screenshot --> <img src="docs/screenshots/add.png" alt="Add" width="250"/> |

> *Note: Add your screenshots in a `docs/screenshots` folder or replace the links above.*

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **Language**: [Dart](https://dart.dev/)
- **State Management**: [Riverpod](https://riverpod.dev/) (Providers & StateNotifiers)
- **Local Database**: [Hive](https://docs.hivedb.dev/) (NoSQL, fast key-value storage)
- **Charting**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Utilities**:
    - `google_fonts`: For modern typography (Poppins).
    - `intl`: Date and Currency formatting.
    - `uuid`: Unique IDs for transactions.

## 🚀 Getting Started

Follow these steps to set up the project locally.

### Prerequisites
- Flutter SDK installed ([Guide](https://docs.flutter.dev/get-started/install))
- Git installed

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/pocketflow.git
   cd pocketflow
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

## 📂 Project Structure

The project follows a **Feature-First / Layered Architecture** to ensure scalability and maintainability.

```
lib/
├── core/            # Global constants, theme, and extensions
├── data/            # Data layer (Models, Repositories, Hive setup)
├── logic/           # Business logic (Riverpod Providers)
├── ui/              # Presentation layer
│   ├── screens/     # Full-page screens (Home, Stats)
│   └── widgets/     # Reusable UI components (Cards, lists, sheets)
└── main.dart        # Entry point and App setup
```

## 🤝 Contributing

Contributions are welcome! If you have any ideas or feature requests:

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
Built with 💙 using Flutter.
