// ============================================================
// quiz_card.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';

class QuizCard extends StatelessWidget {
  const QuizCard({
    super.key,
    required this.quiz,
    required this.isAdmin,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onResults,
    this.onToggleVisibility,
  });

  final QuizModel quiz;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onResults;
  final VoidCallback? onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final isExpired =
        quiz.deadLineDate != null && quiz.deadLineDate!.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.08),
                  const Color(0xFF8B5CF6).withOpacity(0.04),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    quiz.isAiGenerated
                        ? Icons.auto_awesome
                        : Icons.quiz_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              quiz.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E1B4B),
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (quiz.isAiGenerated)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'AI',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (quiz.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          quiz.description,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                _StatusBadge(isVisible: quiz.isVisible, isExpired: isExpired),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatChip(
                  icon: Icons.help_outline_rounded,
                  label: '${quiz.questionCount} Qs',
                  color: const Color(0xFF6366F1),
                ),
                if (quiz.timeLimitMinutes != null)
                  _StatChip(
                    icon: Icons.timer_outlined,
                    label: '${quiz.timeLimitMinutes} min',
                    color: const Color(0xFF0EA5E9),
                  ),
                _StatChip(
                  icon: Icons.verified_outlined,
                  label: '${quiz.passingScore.toInt()}% pass',
                  color: const Color(0xFF10B981),
                ),
                _StatChip(
                  icon: Icons.replay_rounded,
                  label: '${quiz.maxAttempts} ${quiz.maxAttempts == 1 ? "try" : "tries"}',
                  color: const Color(0xFFF59E0B),
                ),
                if (quiz.targetSquadronName != null)
                  _StatChip(
                    icon: Icons.groups_rounded,
                    label: quiz.targetSquadronName!,
                    color: const Color(0xFFEC4899),
                  ),
              ],
            ),
          ),

          // Actions
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: isAdmin ? _buildAdminActions(context, isExpired) : _buildStudentActions(context, isExpired),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context, bool isExpired) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.bar_chart_rounded,
            label: 'Results',
            color: const Color(0xFF0EA5E9),
            onTap: onResults ?? () {},
          ),
        ),
        const SizedBox(width: 8),
        _IconActionButton(
          icon: quiz.isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
          color: quiz.isVisible ? const Color(0xFF10B981) : Colors.grey,
          tooltip: quiz.isVisible ? 'Visible to students' : 'Hidden from students',
          onTap: onToggleVisibility ?? () {},
        ),
        const SizedBox(width: 8),
        _IconActionButton(
          icon: Icons.edit_rounded,
          color: const Color(0xFFF59E0B),
          tooltip: 'Edit',
          onTap: onEdit ?? () {},
        ),
        const SizedBox(width: 8),
        _IconActionButton(
          icon: Icons.delete_outline_rounded,
          color: const Color(0xFFEF4444),
          tooltip: 'Delete',
          onTap: onDelete ?? () {},
        ),
      ],
    );
  }

  Widget _buildStudentActions(BuildContext context, bool isExpired) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: isExpired ? Icons.lock_outline_rounded : Icons.play_arrow_rounded,
            label: isExpired ? 'Closed' : 'Take Quiz',
            color: isExpired ? Colors.grey : const Color(0xFF6366F1),
            onTap: isExpired ? () {} : onTap,
          ),
        ),
        const SizedBox(width: 8),
        _IconActionButton(
          icon: Icons.bar_chart_rounded,
          color: const Color(0xFF0EA5E9),
          tooltip: 'My Result',
          onTap: onResults ?? () {},
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isVisible, required this.isExpired});
  final bool isVisible;
  final bool isExpired;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    if (isExpired) {
      color = const Color(0xFFEF4444);
      label = 'Expired';
    } else if (isVisible) {
      color = const Color(0xFF10B981);
      label = 'Live';
    } else {
      color = const Color(0xFFF59E0B);
      label = 'Hidden';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 5),
          Text(label,
              style:
                  TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({required this.icon, required this.color, required this.tooltip, required this.onTap});
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(padding: const EdgeInsets.all(10), child: Icon(icon, color: color, size: 18)),
        ),
      ),
    );
  }
}
