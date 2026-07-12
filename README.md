# ALU Connect

ALU Connect is a Flutter mobile application that connects ALU students with verified student startups for internships, projects, and practical experience.

## Features

### Students

- Browse opportunities
- Search and filter jobs
- Bookmark opportunities
- Apply for opportunities
- Track application status

### Startup Founders

- Create a startup profile
- Post opportunities (after verification)
- View applicants
- Accept or reject applications

---

## Tech Stack

- Flutter
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Provider

---

## Architecture

```
UI
 ↓
Providers
 ↓
FirebaseService
 ↓
Firebase
```

The UI communicates with Providers, and Providers use FirebaseService for all database operations.

---

## Firestore Collections

- users
- startups
- opportunities
- applications

---

## Setup

```bash
flutter pub get
flutterfire configure
flutter run
```

Deploy Firestore rules before running the application.

---

## Startup Verification

New startups are created with **Pending** status.

To test posting:

1. Create a startup.
2. Open Firebase Console.
3. Change `verificationStatus` from `pending` to `verified`.
4. Reopen the app and post opportunities.

---

## Future Improvements

- In-app messaging
- Push notifications
- Admin verification dashboard
- Better search functionality
