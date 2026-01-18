import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedDummyData() async {
  final firestore = FirebaseFirestore.instance;

  // Seed Courses
  final courses = [
    {'name': 'Mobile Application Development', 'lecturer': 'Dr. Smith'},
    {'name': 'Software Engineering', 'lecturer': 'Prof. Johnson'},
    {'name': 'Database Systems', 'lecturer': 'Dr. Williams'},
  ];

  for (var course in courses) {
    await firestore.collection('courses').add(course);
  }

  // Seed Users (Note: Auth users must be created via Firebase Console or Auth API)
  // This just adds the user profile to Firestore
  // You should use the UID from Firebase Auth here
  /*
  await firestore.collection('users').doc('USER_UID').set({
    'name': 'John Doe',
    'studentId': 'S12345',
  });
  */
}
