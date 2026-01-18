import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/usecase_providers.dart';
import '../providers/attendance_provider.dart';

class EnrollClassPage extends ConsumerStatefulWidget {
  const EnrollClassPage({super.key});

  @override
  ConsumerState<EnrollClassPage> createState() => _EnrollClassPageState();
}

class _EnrollClassPageState extends ConsumerState<EnrollClassPage> {
  final _classCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Join Course',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instruction
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFC4B5FD), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_rounded, color: Color(0xFF6366F1)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ask your lecturer for the class code to join a course.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4338CA),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Class Code Input
            Text(
              'Enter Class Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 12),
            Container(
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
              child: TextField(
                controller: _classCodeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g., ABC123',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(
                    Icons.code_rounded,
                    color: Color(0xFF6366F1),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _joinCourse(ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6366F1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Join Course',
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
          ],
        ),
      ),
    );
  }

  void _joinCourse(WidgetRef ref) async {
    final code = _classCodeController.text.trim();
    if (code.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a class code'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final joinCourseByCode = ref.read(joinCourseProvider);
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) throw Exception('User not authenticated');
      await joinCourseByCode(JoinCourseByCodeParams(
        userId: currentUser.id,
        classCode: code,
      ));

      if (!mounted) return;
      _classCodeController.clear();
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Successfully joined course!'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );

      ref.invalidate(coursesProvider);

      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pop(context);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _classCodeController.dispose();
    super.dispose();
  }
}
