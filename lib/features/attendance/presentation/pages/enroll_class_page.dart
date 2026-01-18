import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnrollClassPage extends ConsumerStatefulWidget {
  const EnrollClassPage({super.key});

  @override
  ConsumerState<EnrollClassPage> createState() => _EnrollClassPageState();
}

class _EnrollClassPageState extends ConsumerState<EnrollClassPage> {
  final _classCodeController = TextEditingController();
  bool _isLoading = false;

  // Mock available classes untuk contoh
  final _availableClasses = [
    {
      'id': 'CS101',
      'name': 'Data Structures',
      'lecturer': 'Prof. Anderson',
      'schedule': 'Mon, Wed 10:00 AM',
      'students': '45',
    },
    {
      'id': 'CS202',
      'name': 'Database Systems',
      'lecturer': 'Prof. Williams',
      'schedule': 'Tue, Thu 2:00 PM',
      'students': '38',
    },
    {
      'id': 'CS303',
      'name': 'Software Engineering',
      'lecturer': 'Prof. Johnson',
      'schedule': 'Mon, Wed 1:00 PM',
      'students': '52',
    },
    {
      'id': 'CS404',
      'name': 'AI Fundamentals',
      'lecturer': 'Prof. Brown',
      'schedule': 'Tue, Thu 10:00 AM',
      'students': '41',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Enroll to Classes',
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
            // Search by Class Code
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
                decoration: InputDecoration(
                  hintText: 'e.g., CS101',
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
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        _enrollByCode();
                      },
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
                            'Enroll',
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
            SizedBox(height: 32),

            // Available Classes
            Text(
              'Available Classes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _availableClasses.length,
              itemBuilder: (context, index) {
                final classData = _availableClasses[index];
                return _buildClassCard(context, classData);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, Map<String, String> classData) {
    final colors = [
      Color(0xFF6366F1),
      Color(0xFF3B82F6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
    ];
    final color = colors[_availableClasses.indexOf(classData) % colors.length];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _enrollClass(classData['id']!);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: color,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classData['name']!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Code: ${classData['id']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: color,
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
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Enroll',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 6),
                    Text(
                      classData['lecturer']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 6),
                    Text(
                      classData['schedule']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 16),
                    Icon(
                      Icons.group_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 6),
                    Text(
                      '${classData['students']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _enrollByCode() {
    final code = _classCodeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a class code'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    _enrollClass(code);
  }

  void _enrollClass(String classId) {
    // TODO: Implement enrollment logic when database is ready
    setState(() => _isLoading = true);

    // Simulate API call
    Future.delayed(Duration(seconds: 1), () {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Successfully enrolled to class $classId!'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );

      _classCodeController.clear();
      // Pop setelah 1 detik
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pop(context);
      });
    });
  }

  @override
  void dispose() {
    _classCodeController.dispose();
    super.dispose();
  }
}
