# 📱 ClassTrack - Student Attendance System

Aplikasi mobile untuk tracking kehadiran mahasiswa menggunakan Flutter dengan data statis (tanpa Firebase).

## 🚀 Quick Start

```bash
# 1. Install dependencies
flutter pub get

# 2. Run app
flutter run
```

## 🎯 Fitur

- ✅ **Login System** - Login dengan email/password apapun (mode demo)
- ✅ **Course List** - Tampilan daftar mata kuliah yang tersedia
- ✅ **Attendance History** - Riwayat kehadiran mahasiswa
- ✅ **Submit Attendance** - Catat kehadiran untuk mata kuliah tertentu
- ✅ **Static Mock Data** - Data statis untuk testing tanpa database

## 💾 Data Demo

Aplikasi menggunakan data statis yang sudah built-in:

### Test Login
- Email: **apa saja** (contoh: `test@example.com`)
- Password: **apa saja** (contoh: `password`)

### Mock Courses
1. Advanced Data Structures - Prof. Smith
2. Web Development - Prof. Johnson  
3. Machine Learning - Prof. Williams
4. Database Systems - Prof. Brown

### Mock Attendance
- Aplikasi otomatis menampilkan 3 riwayat attendance sample
- Setiap submit attendance baru akan ditambahkan ke list

## 🏗️ Arsitektur

Menggunakan **Clean Architecture** dengan layer:
- **Domain Layer**: Entities, Repositories (abstraction), Use Cases
- **Data Layer**: Models, DataSources (mock implementation), Repositories (implementation)
- **Presentation Layer**: Pages, Providers (Riverpod)

## 📦 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^3.2.0  # State management
  intl: ^0.20.2             # Date formatting
```

**Note**: Firebase packages telah dihapus. Aplikasi sekarang berjalan full offline dengan mock data.

## 🔧 Development

```bash
# Check for issues
flutter analyze

# Run tests
flutter test

# Run app in debug mode
flutter run

# Build release APK
flutter build apk
```

## 📱 Screenshots Preview

Aplikasi memiliki 3 halaman utama:
1. **Login Page** - Input email & password
2. **Course List Page** - Daftar mata kuliah
3. **Attendance Page** - Riwayat kehadiran untuk mata kuliah tertentu

## 🎨 Custom Features

- Mock data source yang mudah di-extend
- Clean Architecture untuk maintainability
- State management dengan Riverpod
- Responsive UI design

## 📝 Notes

- Semua data bersifat in-memory (tidak persistent)
- Restart aplikasi akan reset data ke initial state
- Perfect untuk demo dan testing UI/UX

---
**Version**: 1.0.0  
**Flutter SDK**: ^3.9.2
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

3. Klik "Publish"

## 🌱 Data Seeding (Manual via Terminal)

Buat file `seed.dart` di root project:

```bash
touch seed.dart
```

Copy paste kode ini ke `seed.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'lib/firebase_options.dart';
import 'lib/core/utils/seed_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Seed dummy data
  await seedDummyData();

  // Optional: clear data
  // await clearAllData();

  exit(0);
}
```

Kemudian jalankan:

```bash
dart seed.dart
```

**Output yang benar:**

```
🌱 Starting data seeding...

📝 Creating test users...
✅ Created user: student1@test.com (John Doe)
✅ Created user: student2@test.com (Jane Smith)
✅ Created user: student3@test.com (Bob Johnson)

📚 Creating courses...
✅ Created course: Mobile Application Development (CS401)
✅ Created course: Software Engineering (CS302)
✅ Created course: Database Systems (CS303)
✅ Created course: Web Development (CS201)
✅ Created course: Data Structures & Algorithms (CS205)

📋 Creating sample attendance records...
✅ Created 45 attendance records

✨ Data seeding completed successfully!

📌 Test Credentials:
   Email: student1@test.com
   Email: student2@test.com
   Email: student3@test.com
   Password: password123

🚀 You can now login with any of these accounts!
```

## 👥 Test Credentials

| Email | Password | Nama |
|-------|----------|------|
| student1@test.com | password123 | John Doe |
| student2@test.com | password123 | Jane Smith |
| student3@test.com | password123 | Bob Johnson |

## 🏗️ Tech Stack

- Flutter 3.9.2+
- Firebase Authentication
- Cloud Firestore
- Riverpod (State Management)
- Clean Architecture

## 🧪 Testing

```bash
flutter test
```

## 📱 Run

```bash
flutter run
```

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Seed fails | Check Firebase Auth & Firestore enabled, rules published |
| Can't login | Run seeding, check internet, verify Firebase setup |
| Build error | `flutter clean && flutter pub get` |

---

Made with ❤️ for STT Bandung
