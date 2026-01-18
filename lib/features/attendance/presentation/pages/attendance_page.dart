import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/course_entity.dart';
import '../providers/attendance_provider.dart';

class AttendancePage extends ConsumerWidget {
  final CourseEntity course;
  const AttendancePage({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(course.name)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Submit Attendance for ${course.name}',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor: const Color.fromARGB(255, 11, 16, 11),
                ),
                onPressed: state.isLoading
                    ? null
                    : () async {
                        await ref.read(attendanceNotifierProvider.notifier).submitAttendance(course.id, 'Present');
                        if (context.mounted) Navigator.pop(context);
                      },
                child: const Text('Mark as Present', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(200, 50)),
                onPressed: state.isLoading
                    ? null
                    : () async {
                        await ref.read(attendanceNotifierProvider.notifier).submitAttendance(course.id, 'Absent');
                        if (context.mounted) Navigator.pop(context);
                      },
                child: const Text('Mark as Absent'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceHistoryPage extends ConsumerWidget {
  final String userId;
  const AttendanceHistoryPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(attendanceHistoryProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: historyAsync.when(
        data: (history) => history.isEmpty
            ? const Center(child: Text('No attendance records found.'))
            : ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final record = history[index];
                  return ListTile(
                    title: Text('Course: ${record.courseId}'),
                    subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(record.date)),
                    trailing: Chip(
                      label: Text(record.status),
                      backgroundColor: record.status == 'Present' ? Colors.green.shade100 : Colors.red.shade100,
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
