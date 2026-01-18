# 📱 ClassTrack - Session-Based Attendance System

Aplikasi mobile modern untuk manajemen kehadiran berbasis sesi menggunakan Flutter, Supabase, dan Clean Architecture dengan fitur role-based access untuk dosen dan mahasiswa.

## ✨ Fitur Utama

### 👨‍🏫 **Untuk Dosen**
- ✅ Kelola mata kuliah yang dibuat sendiri
- ✅ Mulai dan tutup sesi kehadiran
- ✅ Lihat daftar mahasiswa yang check-in secara real-time
- ✅ Histori lengkap setiap sesi dengan jumlah present/absent
- ✅ Generate kode kelas untuk pendaftaran mahasiswa

### 👨‍🎓 **Untuk Mahasiswa**
- ✅ Daftar mata kuliah menggunakan kode kelas
- ✅ Lihat mata kuliah yang sudah diikuti
- ✅ Check-in pada sesi aktif
- ✅ Indikator visual sesi aktif pada kartu mata kuliah
- ✅ Statistik kehadiran dan riwayat lengkap per mata kuliah

## 🎯 Cara Kerja Sistem

1. **Dosen membuat mata kuliah** dan mendapatkan kode kelas unik
2. **Mahasiswa mendaftar** menggunakan kode kelas
3. **Dosen memulai sesi** untuk pertemuan kelas
4. **Mahasiswa check-in** selama sesi berlangsung
5. **Dosen menutup sesi** - sistem otomatis menandai absent untuk yang tidak check-in
6. **Histori tersimpan** untuk review dan analisis

## 🏗️ Arsitektur

Menggunakan **Clean Architecture** dengan pemisahan layer yang jelas:

```
lib/
├── core/
│   ├── usecase/           # Base use case interface
│   └── utils/             # Utilities
├── features/
│   └── attendance/
│       ├── domain/        # Business logic & entities
│       │   ├── entities/  # User, Course, Attendance, Session
│       │   ├── repositories/  # Repository interfaces
│       │   └── usecases/  # Business use cases
│       ├── data/          # Data implementation
│       │   ├── datasources/  # Supabase datasource
│       │   ├── models/    # Data models
│       │   └── repositories/  # Repository implementation
│       └── presentation/  # UI layer
│           ├── pages/     # Screens
│           └── providers/ # Riverpod state management
```

**Prinsip Utama:**
- Domain layer tidak bergantung pada framework eksternal
- Data layer mengimplementasikan interface dari domain
- Presentation hanya berkomunikasi melalui use cases
- Dependency injection menggunakan Riverpod providers

## 🚀 Setup & Installation

### Prerequisites
- Flutter SDK ^3.9.2
- Dart SDK ^3.9.2
- Akun Supabase (gratis)

### 1. Clone Repository

```bash
git clone <repository-url>
cd classtrack
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Konfigurasi Supabase

#### a. Buat Project Supabase
1. Kunjungi [supabase.com](https://supabase.com)
2. Buat project baru
3. Catat **URL** dan **anon key**

#### b. Setup Database Schema

Jalankan SQL berikut di Supabase SQL Editor:

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('student', 'teacher')),
  student_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Courses table
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  class_code TEXT UNIQUE NOT NULL,
  lecturer TEXT NOT NULL,
  teacher_id UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enrollments table
CREATE TABLE enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  course_id UUID REFERENCES courses(id),
  enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, course_id)
);

-- Class sessions table
CREATE TABLE class_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID REFERENCES courses(id),
  teacher_id UUID REFERENCES users(id),
  started_at TIMESTAMP WITH TIME ZONE NOT NULL,
  closed_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Attendances table
CREATE TABLE attendances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  course_id UUID REFERENCES courses(id),
  session_id UUID REFERENCES class_sessions(id),
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('present', 'absent')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_courses_teacher ON courses(teacher_id);
CREATE INDEX idx_enrollments_user ON enrollments(user_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);
CREATE INDEX idx_sessions_course ON class_sessions(course_id);
CREATE INDEX idx_attendances_user ON attendances(user_id);
CREATE INDEX idx_attendances_session ON attendances(session_id);
```

#### c. Konfigurasi Kode

Edit `lib/main.dart` dengan kredensial Supabase:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 4. Jalankan Aplikasi

```bash
flutter run
```

## 📦 Tech Stack

| Teknologi | Versi | Fungsi |
|-----------|-------|--------|
| Flutter | ^3.9.2 | Mobile framework |
| Dart | ^3.9.2 | Programming language |
| Supabase | ^2.8.0 | Backend as a Service (Auth + Database) |
| Riverpod | ^3.2.0 | State management |
| Intl | ^0.20.2 | Internationalization & date formatting |

## 🔧 Development

```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 📱 Struktur Halaman

1. **Login/Register** - Autentikasi pengguna
2. **Course List** - Daftar mata kuliah (role-based)
3. **Class Detail** - Detail mata kuliah dengan manajemen sesi (dosen) atau check-in (mahasiswa)
4. **Enroll Class** - Mahasiswa mendaftar dengan kode kelas
5. **Profile** - Informasi pengguna dan statistik

## 🎨 Fitur UI/UX

- **Material Design 3** dengan color scheme modern
- **Real-time updates** menggunakan polling untuk sesi aktif
- **Status colors** konsisten (hijau = present, merah = absent)
- **Role-based UI** yang berbeda untuk dosen dan mahasiswa
- **Responsive layout** dengan grid dan list views
- **Loading states** dan error handling yang user-friendly

## 🔐 Security Best Practices

- ✅ Row Level Security (RLS) pada Supabase
- ✅ Authentication required untuk semua operasi
- ✅ Role-based access control
- ✅ Input validation pada client dan server
- ✅ Secure storage untuk credentials

## 📄 License

MIT License - Lihat file LICENSE untuk detail

---

**Version**: 1.0.0  
**Last Updated**: January 2026
