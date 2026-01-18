import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/class_session_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/attendance_provider.dart';
import '../providers/usecase_providers.dart';

class ClassDetailPage extends ConsumerWidget {
  final CourseEntity course;

  const ClassDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isTeacher = user?.role == 'teacher';

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isTeacher ? 'Manage Session' : 'Class Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: isTeacher
          ? _buildTeacherView(context, ref, user!)
          : _buildStudentView(context, ref, user!),
    );
  }

  // ============ TEACHER VIEW ============
  Widget _buildTeacherView(
    BuildContext context,
    WidgetRef ref,
    UserEntity user,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Header
          _buildCourseHeader(),
          SizedBox(height: 24),

          // Class Code Section
          _buildClassCodeSection(),
          SizedBox(height: 24),

          // Session Management Section
          Text(
            'Session Management',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 12),
          _buildSessionManagementSection(context, ref, user),
          SizedBox(height: 24),
          // Session History Section
          Text(
            'Session History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 12),
          _buildSessionHistory(ref),
        ],
      ),
    );
  }

  // ============ STUDENT VIEW ============
  Widget _buildStudentView(
    BuildContext context,
    WidgetRef ref,
    UserEntity user,
  ) {
    final historyAsync = ref.watch(attendanceHistoryProvider(user.id));

    return historyAsync.when(
      data: (allHistory) {
        final classHistory = allHistory
            .where((r) => r.courseId == course.id)
            .toList();

        final presentCount = classHistory
            .where((r) => r.status.toLowerCase() == 'present')
            .length;
        final absentCount = classHistory
            .where((r) => r.status.toLowerCase() == 'absent')
            .length;
        final totalSessions = classHistory.length;
        final attendanceRate = totalSessions == 0
            ? 0.0
            : (presentCount / totalSessions) * 100;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Header
              _buildCourseHeader(),
              SizedBox(height: 24),

              // Attendance Stats
              Text(
                'Attendance Statistics',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Rate',
                      '${attendanceRate.toStringAsFixed(1)}%',
                      Color(0xFF6366F1),
                      Icons.trending_up_rounded,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Present',
                      presentCount.toString(),
                      Color(0xFF10B981),
                      Icons.check_circle_rounded,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Absent',
                      absentCount.toString(),
                      Color(0xFFEF4444),
                      Icons.cancel_rounded,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Check-in Button (only when active session)
              Consumer(
                builder: (context, consumerRef, _) {
                  final activeSessionAsync = consumerRef.watch(
                    activeSessionProvider(course.id),
                  );
                  return activeSessionAsync.when(
                    data: (session) => session != null
                        ? _buildCheckInButton(context, ref)
                        : SizedBox.shrink(),
                    loading: () => SizedBox.shrink(),
                    error: (err, st) => SizedBox.shrink(),
                  );
                },
              ),
              SizedBox(height: 24),

              // Session History
              Text(
                'Attendance History ($totalSessions)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 12),
              if (classHistory.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 56,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No attendance records\nfor this class yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: classHistory.length,
                  itemBuilder: (context, index) {
                    final record = classHistory[index];
                    final isPresent = record.status.toLowerCase() == 'present';
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPresent
                              ? Color(0xFF10B981).withValues(alpha: 0.2)
                              : Color(0xFFEF4444).withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isPresent
                                  ? Color(0xFF10B981).withValues(alpha: 0.1)
                                  : Color(0xFFEF4444).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isPresent
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              color: isPresent
                                  ? Color(0xFF10B981)
                                  : Color(0xFFEF4444),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Session ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy • HH:mm',
                                  ).format(record.date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isPresent
                                  ? Color(0xFF10B981).withValues(alpha: 0.15)
                                  : Color(0xFFEF4444).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isPresent ? 'Present' : 'Absent',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isPresent
                                    ? Color(0xFF10B981)
                                    : Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
        ),
      ),
      error: (err, st) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Failed to load class details',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionHistory(WidgetRef ref) {
    final sessionsAsync = ref.watch(courseSessionsProvider(course.id));
    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No sessions yet',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final s = sessions[index];
            return Consumer(
              builder: (context, consumerRef, _) {
                final countsAsync = consumerRef.watch(
                  sessionAttendanceCountsProvider(s.id),
                );
                return countsAsync.when(
                  data: (counts) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFE5E7EB), width: 1),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            color: Color(0xFF6366F1),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Session ${sessions.length - index}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy • HH:mm',
                                  ).format(s.startedAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Present ${counts['present']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF059669),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFEF4444).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Absent ${counts['absent']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              Color(0xFF6366F1),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  error: (err, st) => SizedBox.shrink(),
                );
              },
            );
          },
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
        ),
      ),
      error: (err, st) => Center(
        child: Text(
          'Error loading sessions',
          style: TextStyle(fontSize: 12, color: Colors.red),
        ),
      ),
    );
  }

  // ============ HELPER WIDGETS ============

  Widget _buildCourseHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.book_rounded, color: Colors.white, size: 28),
          ),
          SizedBox(height: 16),
          Text(
            course.name,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: Colors.white.withValues(alpha: 0.8),
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                course.lecturer,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassCodeSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE5E7EB), width: 1),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code_rounded, color: Color(0xFF6366F1), size: 20),
              SizedBox(width: 8),
              Text(
                'Class Code',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    course.classCode,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6366F1),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Copy to clipboard
                    },
                    child: Icon(
                      Icons.copy_rounded,
                      color: Color(0xFF6366F1),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Share this code with students to let them join',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionManagementSection(
    BuildContext context,
    WidgetRef ref,
    UserEntity user,
  ) {
    return Consumer(
      builder: (context, consumerRef, _) {
        final activeSessionAsync = consumerRef.watch(
          activeSessionProvider(course.id),
        );

        return activeSessionAsync.when(
          data: (activeSession) {
            if (activeSession == null) {
              // No active session - show start button
              return _buildStartSessionButton(context, ref, user);
            } else {
              // Active session - show close button and real-time checked-in list
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCloseSessionButton(context, ref, activeSession),
                  SizedBox(height: 16),
                  _buildRealtimeCheckedInList(ref, activeSession.id),
                ],
              );
            }
          },
          loading: () => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
              ),
            ),
          ),
          error: (err, st) => Container(
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            padding: EdgeInsets.all(16),
            child: Text(
              'Error loading session: ${err.toString()}',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRealtimeCheckedInList(WidgetRef ref, String sessionId) {
    final attendanceStream = ref.watch(
      sessionAttendanceStreamProvider(sessionId),
    );
    return attendanceStream.when(
      data: (list) {
        final presentList = list
            .where((e) => e.status.toLowerCase() == 'present')
            .toList();
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE5E7EB), width: 1),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people_alt_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Checked-in Students (${presentList.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              if (presentList.isEmpty)
                Text(
                  'No one has checked in yet',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                )
              else
                ...presentList.map(
                  (a) => Container(
                    margin: EdgeInsets.only(bottom: 8),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFF10B981).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFF10B981), width: 0.8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF10B981),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            a.userId,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF059669),
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(a.date),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF6366F1)),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Loading attendance...',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      error: (err, st) => SizedBox.shrink(),
    );
  }

  Widget _buildStartSessionButton(
    BuildContext context,
    WidgetRef ref,
    UserEntity user,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            try {
              final startSession = ref.read(startSessionProvider);
              await startSession(
                StartClassSessionParams(
                  courseId: course.id,
                  teacherId: user.id,
                ),
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Session started!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
                // Invalidate active session for this course to refresh
                ref.invalidate(activeSessionProvider(course.id));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Start Session',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCloseSessionButton(
    BuildContext context,
    WidgetRef ref,
    ClassSessionEntity session,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active session indicator
        Container(
          decoration: BoxDecoration(
            color: Color(0x1F10B981),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF10B981), width: 1.5),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Active',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Started at ${DateFormat('HH:mm').format(session.startedAt)}',
                      style: TextStyle(fontSize: 12, color: Color(0xFF059669)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEF4444), Color(0xFFDC2405)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Close Session?'),
                      content: Text(
                        'Students who haven\'t checked in will be marked as absent.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            'Close',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    try {
                      final closeSession = ref.read(closeSessionProvider);
                      await closeSession(
                        CloseSessionParams(sessionId: session.id),
                      );

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✓ Session closed! Absent marked.'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                        ref.invalidate(activeSessionProvider(course.id));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.stop_circle_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Close Session',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckInButton(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final user = ref.read(currentUserProvider);
            if (user == null) return;

            try {
              final activeSessionAsync = ref.read(
                activeSessionProvider(course.id),
              );
              final activeSession = await activeSessionAsync.when(
                data: (data) => Future.value(data),
                loading: () => Future.error('Loading...'),
                error: (err, _) => Future.error(err),
              );

              if (activeSession == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No active session for this class'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                return;
              }

              final checkIn = ref.read(checkInProvider);
              await checkIn(
                CheckInParams(
                  userId: user.id,
                  courseId: course.id,
                  sessionId: activeSession.id,
                ),
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Checked in successfully!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Check In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
