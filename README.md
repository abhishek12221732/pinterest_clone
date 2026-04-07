# 📌 Pinterest Architecture & UI Clone

A high-fidelity, performance-optimized Flutter clone of the Pinterest mobile application. Built as a 5-day architectural sprint demonstrating advanced layout geometry, complex scroll physics, and seamless state preservation.

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev/)
[![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-blue?style=for-the-badge)](https://riverpod.dev/)
[![GoRouter](https://img.shields.io/badge/GoRouter-Routing-lightgrey?style=for-the-badge)]()

**🎥 [View the 60-Second Video Walkthrough Here]** *(Insert your YouTube/Drive link here)*

---

## 🏗️ Key Technical Achievements

This project goes beyond standard UI layouts to replicate the specific native feel of the Pinterest application using advanced Flutter mechanics.

* **Custom Physics-Driven Pull-to-Refresh:** Instead of relying on heavy third-party animation packages, I implemented a custom `CupertinoSliverRefreshControl` inside a `CustomScrollView`. This exposes raw scroll physics, allowing the signature 4-dot Pinterest spinner to scale and rotate dynamically based on the user's exact drag percentage.
* **Persistent State via IndexedStack Routing:** Implemented `StatefulShellRoute.indexedStack` using `go_router`. This ensures that as the user navigates between the Home feed, Search, and Profile, all scroll positions, Masonry grid layouts, and active API states are perfectly preserved in memory without unnecessary rebuilds.
* **Progressive Hero Animations:** Engineered a race-condition bypass for the Pin Detail screen. During the `Hero` flight animation, the UI uses the instantly available RAM-cached thumbnail (`memCacheWidth: 400`) as a placeholder, allowing the high-resolution image to decode asynchronously without causing layout snaps or dropped frames.
* **Theme-Aware Dynamic Shimmers:** Built custom `Shimmer` skeletons that automatically read `Theme.of(context).brightness` to provide flawless dark/light mode transitions without flashing bright placeholders.

---

## 🧠 Architecture & Trade-offs (Evaluator Note)

Given the strict 5-day timeline for this sprint, I made specific prioritization decisions to maximize the core product experience:

> **Authentication Bypass:** While tools like Clerk/Firebase are standard for scalable auth, forcing an evaluator through an OAuth flow or email verification creates unnecessary friction during a code review. I prioritized a 60FPS UI, complex Sliver layouts, and API integration. A functional "Login" screen is provided to demonstrate routing, but it currently acts as a **Guest Bypass** so you can immediately interact with the core application.

---

## 🛠️ Tech Stack & Dependencies

* **UI Engine:** Flutter (Material & Cupertino Slivers)
* **State Management:** `flutter_riverpod` (Utilizing `.family` modifiers for tab-specific caching)
* **Routing:** `go_router` (Stateful nested navigation)
* **Network:** `dio` (Fetching live curated data from the Pexels API)
* **Image Handling:** `cached_network_image`
* **Layouts:** `flutter_staggered_grid_view` (Modern `SliverMasonryGrid` implementations)

---

## 🚀 Getting Started

### App Preview
<img src="assets/screenshot1.jpg" alt="Screenshot 1" width="260" />
<img src="assets/screenshot2.jpg" alt="Screenshot 2" width="260" />
<img src="assets/screenshot3.jpg" alt="Screenshot 3" width="260" />


### APK Download
You can also download the ready-to-install APK here:

[Download Pinterest Clone APK](https://drive.google.com/file/d/1wnh8ibwN2qgZ8Qz50pKWobE-uDWQqt_O/view?usp=sharing)


### Prerequisites
* Flutter SDK (Stable channel)
* Android Studio / Xcode

### Installation
1. Clone the repository.
2. Create a `.env` file in the root directory and add your Pexels API key:
   ```
   PEXELS_API_KEY=your_pexels_api_key_here
   ```
   Get your free API key from [Pexels API](https://www.pexels.com/api/).
3. Fetch dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```



### Building for Production
To generate a release-ready APK with fully optimized AOT compilation and tree-shaking:
```bash
flutter build apk --release
```
