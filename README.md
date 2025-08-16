# 🚇 Subway Enforcement & Fine Management System

A **full-stack mobile application** built with **Flutter** and **Firebase**, designed to help officers manage pedestrian crossing violations, track incidents, and handle fines in real-time.

---

## 💡 Project Inspiration

This project was inspired by a real-world scenario in my home country, Sri Lanka. With the construction of new subway crossings, a system was needed to encourage pedestrians to use them for their safety and to manage the transition away from traditional road-level crossings. I developed this application as a practical, technological solution to that civic challenge, creating a tool that could be used by enforcement officers to log violations, issue warnings or fines, and track payments efficiently.

---

## ✨ Features

### 👮 Secure Officer Authentication

* Clean, modern login/logout system for officers
* Powered by **Firebase Authentication**

### 🔍 Real-Time Violator Search

* Officers can search the database instantly by a citizen's National Identity Card (NIC) number to retrieve their history.

### 🗃️ Complete Data Management (CRUD) : Full CRUD (Create, Read, Update, Delete) functionality for managing violations.


* Add new violators to the system on the spot
* Issue **Warnings** for first-time offenses
* Issue **Fines** with specific monetary amounts for repeat offenses

### 💳 Fine Tracking & Payment

* View violator’s complete incident history
* Clear status indicators for **paid** and **unpaid fines**
* Manually mark fines as *Paid*, updating in **real-time**

### ⚙️ Automated Backend Logic (Proof-of-Concept)

* Includes a fully developed Firebase Cloud Function (written in TypeScript) that automatically triggers when a new fine is created.
* This function securely communicates with the PayHere (Sandbox) payment gateway to generate a unique online payment link for each fine
* The generated link is then saved back to the database, ready to be sent to the violator.


---

## 🛠️ Tech Stack

* **Frontend:** Flutter & Dart
* **Backend & Database:** Firebase
* **Authentication:** Firebase Authentication
* **Database:** Cloud Firestore (NoSQL)
* **Cloud Functions:** Server-side automation & API communication
* **Payment Gateway:** PayHere (Sandbox Environment)
* **Backend Language:** TypeScript

---

## 📸 Screenshots

* Login Screen

  <img width="910" height="908" alt="Screenshot 2025-08-16 120014" src="https://github.com/user-attachments/assets/f50dd90f-1a71-4711-90ac-9f4b06b0b7a2" />
* Officer Dashboard

  <img width="907" height="906" alt="Screenshot 2025-08-16 120033" src="https://github.com/user-attachments/assets/f2cc8469-a0a1-4243-9e07-bc9e86251738" />
* Search & Results

<img width="908" height="895" alt="Screenshot 2025-08-16 120152" src="https://github.com/user-attachments/assets/cbbad92d-8653-47b6-80ba-09cbbbee9c68" />

  

---

## 🚀 Setup and Installation

### 1. Clone the Repository

```bash
git clone https://github.com/amiladilshan7/subway-enforcement-app.git
```

### 2. Navigate to the Project Directory

```bash
cd subway-enforcement-app
```

### 3. Install Flutter Dependencies

```bash
flutter pub get
```

### 4. Firebase Setup

1. Create a new project on the **Firebase Console**
2. Add an **Android/iOS app** to your Firebase project
3. Download:

   * `google-services.json` → place in `android/app/`
   * `GoogleService-Info.plist` → place in `ios/Runner/`

### 5. Run the App

```bash
flutter run
```

---

## 🎯 About the Project

_This project was developed as a **personal portfolio piece** to demonstrate **full-stack mobile application development skills**._




