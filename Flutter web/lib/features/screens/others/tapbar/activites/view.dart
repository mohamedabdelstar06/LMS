import 'package:flutter/material.dart';

class ActivitesTapbarScreen extends StatelessWidget {
  const ActivitesTapbarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Activities',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5b5b9f),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        children: [
          ActivitySection(
            title: 'Assignments',
            icon: Icons.assignment,
            initiallyExpanded: true,
            children: [
              AssignmentItem(
                title: 'Assignment: Languages of Love',
                status: 'Submission in progress',
                dueDate: 'Monday, 23 March 2026, 12:00 AM',
                statusIcon: Icons.schedule,
                statusColor: Colors.orange,
                imageUrl: 'https://picsum.photos/seed/love-languages/400/200.jpg',
              ),
              AssignmentItem(
                title: '(Mobile assignment) View from your window',
                status: 'Not submitted',
                dueDate: 'Wednesday, 23 December 2026, 12:00 AM',
                statusIcon: Icons.radio_button_unchecked,
                statusColor: Colors.grey,
                imageUrl: 'https://picsum.photos/seed/window-view/400/200.jpg',
              ),
              AssignmentItem(
                title: 'Assignment: My dream destination',
                status: 'Submitted for grading',
                dueDate: 'Thursday, 30 April 2026, 1:00 AM',
                statusIcon: Icons.check_circle,
                statusColor: Colors.green,
                imageUrl: 'https://picsum.photos/seed/dream-destination/400/200.jpg',
              ),
            ],
          ),
          ActivitySection(
            title: 'Databases',
            icon: Icons.storage,
            initiallyExpanded: true,
            children: [
              DatabaseItem(
                title: 'Database: Food for Moodlers',
                dueDate: 'Friday, 16 February 2024, 11:05 AM',
                entries: '21',
                myEntries: '1',
                comments: '7',
                grade: 'Really tasty',
                imageUrl: 'https://picsum.photos/seed/food-database/400/200.jpg',
              ),
              DatabaseItem(
                title: 'Database: Identity Pages',
                dueDate: '-',
                entries: '3',
                myEntries: '1',
                comments: '0',
                grade: '-',
                imageUrl: 'https://picsum.photos/seed/identity-pages/400/200.jpg',
              ),
              DatabaseItem(
                title: 'Database: Beautiful Places',
                dueDate: '-',
                entries: '9',
                myEntries: '0',
                comments: '0',
                grade: '-',
                imageUrl: 'https://picsum.photos/seed/beautiful-places/400/200.jpg',
              ),
            ],
          ),
          ActivitySection(
            title: 'Glossaries',
            icon: Icons.book,
            initiallyExpanded: false,
            children: [
              const EmptySection(message: 'No glossaries available'),
            ],
          ),
          ActivitySection(
            title: 'Quizzes',
            icon: Icons.quiz,
            initiallyExpanded: false,
            children: [
              const EmptySection(message: 'No quizzes available'),
            ],
          ),
          ActivitySection(
            title: 'Resources',
            icon: Icons.real_estate_agent_rounded,
            initiallyExpanded: false,
            children: [
              const EmptySection(message: 'No Resources available'),
            ],
          ),
          ActivitySection(
            title: 'Workshops',
            icon: Icons.work_history,
            initiallyExpanded: false,
            children: [
              const EmptySection(message: 'No Workshops available'),
            ],
          ),
        ],
      ),
    );
  }
}

class ActivitySection extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool initiallyExpanded;

  const ActivitySection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  State<ActivitySection> createState() => _ActivitySectionState();
}

class _ActivitySectionState extends State<ActivitySection>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _colorAnimation = ColorTween(
      begin: Colors.grey[100],
      end: const Color(0xFF5b5b9f).withOpacity(0.1),
    ).animate(_controller);

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _colorAnimation.value,
        ),
        child: Column(
          children: [
            InkWell(
              onTap: _toggle,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5b5b9f).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        color: const Color(0xFF5b5b9f),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5b5b9f),
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizeTransition(
              axis: Axis.vertical,
              sizeFactor: _expandAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssignmentItem extends StatelessWidget {
  final String title;
  final String status;
  final String dueDate;
  final IconData statusIcon;
  final Color statusColor;
  final String imageUrl;

  const AssignmentItem({
    super.key,
    required this.title,
    required this.status,
    required this.dueDate,
    required this.statusIcon,
    required this.statusColor,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 16.0, top: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              height: 150,
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Image not available',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5b5b9f)),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Loading image...',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 11,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (dueDate.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Due: $dueDate',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DatabaseItem extends StatelessWidget {
  final String title;
  final String dueDate;
  final String entries;
  final String myEntries;
  final String comments;
  final String grade;
  final String imageUrl;

  const DatabaseItem({
    super.key,
    required this.title,
    required this.dueDate,
    required this.entries,
    required this.myEntries,
    required this.comments,
    required this.grade,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 16.0, top: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              height: 150,
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Image not available',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5b5b9f)),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Loading image...',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            if (dueDate != '-')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Due: $dueDate',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            if (entries != '-')
              Row(
                children: [
                  _buildStat('Entries', entries, Icons.list),
                  const SizedBox(width: 15),
                  _buildStat('Mine', myEntries, Icons.person),
                  const SizedBox(width: 15),
                  _buildStat('Comments', comments, Icons.comment),
                ],
              ),
            if (grade != '-')
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Grade: $grade',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                children: [
                  TextSpan(text: '$label: '),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptySection extends StatelessWidget {
  final String message;

  const EmptySection({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}