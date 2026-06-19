// ============================================================
// delete_quiz_dialog.dart — Danger Zone with name confirmation
// ============================================================
import 'package:flutter/material.dart';

class DeleteQuizDialog extends StatefulWidget {
  const DeleteQuizDialog({super.key, required this.quizTitle});
  final String quizTitle;

  @override
  State<DeleteQuizDialog> createState() => _DeleteQuizDialogState();
}

class _DeleteQuizDialogState extends State<DeleteQuizDialog>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  bool _confirmed = false;
  bool _shaking = false;
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _controller.addListener(() {
      final matches = _controller.text.trim() == widget.quizTitle.trim();
      if (matches != _confirmed) setState(() => _confirmed = matches);
    });
  }

  void _tryDelete() {
    if (!_confirmed) {
      _shakeCtrl.forward(from: 0);
      setState(() => _shaking = true);
      Future.delayed(
        const Duration(milliseconds: 400),
        () => setState(() => _shaking = false),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 480,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withOpacity(0.15),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF3B30), Color(0xFFFF6B6B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '⚠ Danger Zone',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'This action cannot be undone',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFCDD2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Color(0xFFEF4444), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF991B1B)),
                              children: [
                                const TextSpan(
                                    text:
                                        'You are about to permanently delete the quiz '),
                                TextSpan(
                                  text: '"${widget.quizTitle}"',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700),
                                ),
                                const TextSpan(
                                    text:
                                        ' along with all its questions, options, and student attempts.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(text: 'Type '),
                        TextSpan(
                          text: widget.quizTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEF4444),
                            fontFamily: 'monospace',
                          ),
                        ),
                        const TextSpan(text: ' to confirm:'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _shakeCtrl,
                    builder: (context, child) {
                      final offset = _shaking
                          ? 8 * (0.5 - (_shakeCtrl.value % 1).abs()).abs()
                          : 0.0;
                      return Transform.translate(
                          offset: Offset(offset, 0), child: child);
                    },
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                      ),
                      decoration: InputDecoration(
                        hintText: widget.quizTitle,
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontFamily: 'monospace'),
                        filled: true,
                        fillColor: _confirmed
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFFAFAFA),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _confirmed
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade200,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _confirmed
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade200,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: _confirmed
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            width: 2,
                          ),
                        ),
                        suffixIcon: _confirmed
                            ? const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF10B981))
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: _confirmed ? 1.0 : 0.4,
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: _tryDelete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: _confirmed ? 2 : 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.delete_forever_rounded, size: 18),
                                SizedBox(width: 6),
                                Text('Delete Forever',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> showDeleteQuizDialog(
  BuildContext context, {
  required String quizTitle,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => DeleteQuizDialog(quizTitle: quizTitle),
  );
  return result ?? false;
}
