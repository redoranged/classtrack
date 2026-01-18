import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  AttendanceModel({
    required super.userId,
    required super.courseId,
    required super.date,
    required super.status,
  });

  factory AttendanceModel.fromFirestore(Map<String, dynamic> json) {
    return AttendanceModel(
      userId: json['userId'] ?? '',
      courseId: json['courseId'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'courseId': courseId,
      'date': Timestamp.fromDate(date),
      'status': status,
    };
  }
}
