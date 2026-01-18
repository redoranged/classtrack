-- Supabase Database Schema untuk Aplikasi Absensi Mahasiswa
-- Jalankan SQL ini di Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table: users
-- Menyimpan data mahasiswa dan pengajar
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    student_id TEXT UNIQUE,
    role TEXT NOT NULL DEFAULT 'student' CHECK (role IN ('student', 'teacher')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: courses
-- Menyimpan data mata kuliah
CREATE TABLE IF NOT EXISTS courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    class_code TEXT UNIQUE NOT NULL,
    lecturer TEXT NOT NULL,
    teacher_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: class_sessions (untuk sesi kelas yang dimulai pengajar)
CREATE TABLE IF NOT EXISTS class_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    teacher_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    closed_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Table: enrollments
-- Menyimpan data pendaftaran mahasiswa ke mata kuliah
CREATE TABLE IF NOT EXISTS enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, course_id)
);

-- Table: attendances
-- Menyimpan data absensi mahasiswa
CREATE TABLE IF NOT EXISTS attendances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    session_id UUID REFERENCES class_sessions(id) ON DELETE CASCADE,
    date TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('present', 'absent', 'late', 'excused')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, session_id)
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_courses_class_code ON courses(class_code);
CREATE INDEX IF NOT EXISTS idx_class_sessions_course_id ON class_sessions(course_id);
CREATE INDEX IF NOT EXISTS idx_class_sessions_is_active ON class_sessions(is_active);
CREATE INDEX IF NOT EXISTS idx_enrollments_user_id ON enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id ON enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_attendances_user_id ON attendances(user_id);
CREATE INDEX IF NOT EXISTS idx_attendances_course_id ON attendances(course_id);
CREATE INDEX IF NOT EXISTS idx_attendances_session_id ON attendances(session_id);
CREATE INDEX IF NOT EXISTS idx_attendances_date ON attendances(date);

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendances ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_sessions ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users table
-- Users can only read their own data
CREATE POLICY "Users can read own data" 
    ON users FOR SELECT 
    USING (auth.uid() = id);

-- Users can update their own data
CREATE POLICY "Users can update own data" 
    ON users FOR UPDATE 
    USING (auth.uid() = id);

-- Users can insert themselves (auth must match id)
CREATE POLICY "Users can insert self" 
    ON users FOR INSERT 
    TO authenticated
    WITH CHECK (auth.uid() = id);

-- RLS Policies for courses table
-- All authenticated users can read courses
CREATE POLICY "Authenticated users can read courses" 
    ON courses FOR SELECT 
    TO authenticated 
    USING (true);

-- Teachers can create courses
CREATE POLICY "Teachers can insert courses" 
    ON courses FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT role FROM users WHERE id = auth.uid()) = 'teacher');

-- RLS Policies for enrollments table
-- Users can read their own enrollments
CREATE POLICY "Users can read own enrollments" 
    ON enrollments FOR SELECT 
    USING (auth.uid() = user_id);

-- Users can enroll themselves in courses
CREATE POLICY "Users can enroll themselves" 
    ON enrollments FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- RLS Policies for attendances table
-- Users can read their own attendance records
CREATE POLICY "Users can read own attendance" 
    ON attendances FOR SELECT 
    USING (auth.uid() = user_id);

-- Users can mark their own attendance
CREATE POLICY "Users can mark own attendance" 
    ON attendances FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

-- RLS Policies for class_sessions
-- Teachers can start sessions
CREATE POLICY "Teachers can insert sessions" 
    ON class_sessions FOR INSERT
    TO authenticated
    WITH CHECK ((SELECT role FROM users WHERE id = auth.uid()) = 'teacher');

-- Teachers can update their own sessions
CREATE POLICY "Teachers can update own sessions" 
    ON class_sessions FOR UPDATE
    TO authenticated
    USING (teacher_id = auth.uid());

-- Authenticated users can read sessions
CREATE POLICY "Authenticated can read sessions" 
    ON class_sessions FOR SELECT
    TO authenticated
    USING (true);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers to auto-update updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_courses_updated_at BEFORE UPDATE ON courses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Optional: auto-close sessions after some logic could be handled in app logic
