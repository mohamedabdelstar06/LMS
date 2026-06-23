// ============================================================
// generate_quiz_sheet.dart — AI quiz generator (multipart API)
// ============================================================
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/model/view.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/state_mangment/cubit.dart';
import 'package:lms/features/screens/admin/squadron/get_squadron/state_mangment/states.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';

class GenerateQuizSheet extends StatefulWidget {
  const GenerateQuizSheet({
    super.key,
    required this.courseId,
    this.availableLectures = const [],
  });

  final int courseId;
  /// List of (id, title) pairs for lectures in this course.
  final List<(int, String)> availableLectures;

  @override
  State<GenerateQuizSheet> createState() => _GenerateQuizSheetState();
}

class _GenerateQuizSheetState extends State<GenerateQuizSheet> {
  final _titleCtrl = TextEditingController();
  final _promptCtrl = TextEditingController();

  int _questionsCount = 10;
  String _difficulty = 'Medium';
  String _questionTypes = 'Mixed';
  String _scope = 'Course'; // Course | Lecture | Squadron
  final Set<int> _selectedLectures = {};
  Uint8List? _pickedFileBytes;
  String? _pickedFileName;
  int? _selectedSquadronId;

  static const _difficulties = [
    ('Easy', '😊 Easy', Color(0xFF10B981)),
    ('Medium', '🎯 Medium', Color(0xFFF59E0B)),
    ('Hard', '🔥 Hard', Color(0xFFEF4444)),
  ];

  static const _types = ['SingleChoice', 'MultipleChoice', 'TrueFalse', 'Mixed'];
  static const _scopes = ['Course', 'Lecture', 'Squadron'];

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _promptCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      setState(() {
        _pickedFileBytes = file.bytes;
        _pickedFileName = file.name;
      });
    }
  }

  bool get _canGenerate {
    if (_titleCtrl.text.trim().isEmpty) return false;
    if (_scope == 'Lecture' && _selectedLectures.isEmpty && _pickedFileBytes == null) {
      return false;
    }
    if (_scope == 'Squadron' && _selectedSquadronId == null) return false;
    return true;
  }

  void _generate() {
    if (!_canGenerate) return;
    Navigator.of(context).pop(
      GenerateQuizRequest(
        courseId: widget.courseId,
        lectureIds: _selectedLectures.toList(),
        importedPdfBytes: _pickedFileBytes,
        importedPdfName: _pickedFileName,
        questionTypes: _questionTypes,
        numberOfQuestions: _questionsCount,
        difficultyLevel: _difficulty,
        customPrompt: _promptCtrl.text.trim(),
        quizScope: _scope,
        targetSquadronId: _scope == 'Squadron' ? _selectedSquadronId : null,
        title: _titleCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollCtrl) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Quiz Generator', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('From lectures, a PDF, or both', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Quiz Title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleCtrl,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'e.g. "Photosynthesis Quiz"',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text('Generate From', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    Row(
                      children: _scopes.map((s) {
                        final selected = _scope == s;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: s != _scopes.last ? 8 : 0),
                            child: GestureDetector(
                              onTap: () => setState(() => _scope = s),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected ? const Color(0xFF6366F1).withOpacity(0.1) : const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: selected ? const Color(0xFF6366F1) : Colors.grey.shade200, width: selected ? 2 : 1),
                                ),
                                child: Text(s, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? const Color(0xFF6366F1) : Colors.grey.shade600)),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    if (_scope == 'Lecture') ...[
                      const SizedBox(height: 14),
                      Text('Select Lectures', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                      const SizedBox(height: 8),
                      if (widget.availableLectures.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8)),
                          child: const Text('No lectures found for this course.', style: TextStyle(fontSize: 12, color: Color(0xFFD97706))),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.availableLectures.map((lec) {
                            final selected = _selectedLectures.contains(lec.$1);
                            return GestureDetector(
                              onTap: () => setState(() {
                                if (selected) {
                                  _selectedLectures.remove(lec.$1);
                                } else {
                                  _selectedLectures.add(lec.$1);
                                }
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected ? const Color(0xFF6366F1) : const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: selected ? const Color(0xFF6366F1) : Colors.grey.shade200),
                                ),
                                child: Text(lec.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.grey.shade600)),
                              ),
                            );
                          }).toList(),
                        ),
                    ],

                    if (_scope == 'Squadron') ...[
                      const SizedBox(height: 14),
                      const Text('Target Squadron', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                      const SizedBox(height: 8),
                      BlocBuilder<SquadronsCubitDrop, GetSquadronsState>(
                        builder: (context, state) {
                          if (state is GetSquadronsLoading) {
                            return const LinearProgressIndicator(minHeight: 2);
                          }
                          if (state is GetSquadronsError) {
                            return Text(state.message, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12));
                          }
                          final squadrons = state is GetSquadronsLoaded
                              ? state.squadrons
                              : <SquadronModel>[];
                          return DropdownButtonFormField<int>(
                            initialValue: _selectedSquadronId,
                            decoration: InputDecoration(
                              hintText: 'Select squadron',
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                            ),
                            items: squadrons
                                .map(
                                  (s) => DropdownMenuItem<int>(
                                    value: s.id,
                                    child: Text(s.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(() => _selectedSquadronId = value),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 18),
                    const Text('Import a PDF (optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickPdf,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _pickedFileBytes != null ? const Color(0xFFF0FDF4) : const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _pickedFileBytes != null ? const Color(0xFF10B981) : const Color(0xFFE0E7FF)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _pickedFileBytes != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                              color: _pickedFileBytes != null ? const Color(0xFF10B981) : const Color(0xFF6366F1),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _pickedFileName ?? 'Choose a PDF file',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _pickedFileBytes != null ? const Color(0xFF10B981) : const Color(0xFF6366F1)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_pickedFileBytes != null)
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () => setState(() {
                                  _pickedFileBytes = null;
                                  _pickedFileName = null;
                                }),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Number of Questions', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(20)),
                          child: Text('$_questionsCount', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6366F1), fontSize: 15)),
                        ),
                      ],
                    ),
                    Slider(
                      value: _questionsCount.toDouble(),
                      min: 5,
                      max: 30,
                      divisions: 5,
                      activeColor: const Color(0xFF6366F1),
                      onChanged: (v) => setState(() => _questionsCount = v.toInt()),
                    ),

                    const SizedBox(height: 10),
                    const Text('Question Types', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _types.map((t) {
                        final selected = _questionTypes == t;
                        return GestureDetector(
                          onTap: () => setState(() => _questionTypes = t),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF6366F1).withOpacity(0.12) : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: selected ? const Color(0xFF6366F1) : Colors.grey.shade200),
                            ),
                            child: Text(t, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? const Color(0xFF6366F1) : Colors.grey.shade600)),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),
                    const Text('Difficulty', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    Row(
                      children: _difficulties.map((d) {
                        final selected = _difficulty == d.$1;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: d.$1 != 'Hard' ? 8 : 0),
                            child: GestureDetector(
                              onTap: () => setState(() => _difficulty = d.$1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: selected ? d.$3.withOpacity(0.12) : const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: selected ? d.$3 : Colors.grey.shade200, width: selected ? 2 : 1),
                                ),
                                child: Text(d.$2, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? d.$3 : Colors.grey.shade500)),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),
                    const Text('Custom Instructions (optional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _promptCtrl,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'e.g. "Focus on definitions and real-world examples"',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _canGenerate ? _generate : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome, size: 18),
                            SizedBox(width: 8),
                            Text('Generate with AI', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    if (!_canGenerate)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _titleCtrl.text.trim().isEmpty
                              ? 'Enter a title to continue'
                              : _scope == 'Lecture'
                                  ? 'Select at least one lecture or upload a PDF'
                                  : 'Select a target squadron',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                          textAlign: TextAlign.center,
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
}

Future<GenerateQuizRequest?> showGenerateQuizSheet(
  BuildContext context, {
  required int courseId,
  List<(int, String)> availableLectures = const [],
}) {
  return showModalBottomSheet<GenerateQuizRequest>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => SquadronsCubitDrop()..fetchSquadrons(),
      child: GenerateQuizSheet(
        courseId: courseId,
        availableLectures: availableLectures,
      ),
    ),
  );
}
