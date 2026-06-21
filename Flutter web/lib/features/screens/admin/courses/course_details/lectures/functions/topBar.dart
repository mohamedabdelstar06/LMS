import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.searchCtrl,
    required this.onSearch,
    required this.filterType,
    required this.onFilterChange,
    required this.lectureCount,
    this.onAddNew,
    this.subtitle,
  });

  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final String filterType;
  final ValueChanged<String> onFilterChange;
  final int lectureCount;

  /// Pass null to hide the "Add Lecture" button entirely (e.g. for
  /// students, who have no permission to add lectures).
  final VoidCallback? onAddNew;

  /// Shown under "All Lectures". Defaults to 'Manage course lectures'
  /// (admin/instructor copy) when not provided, so existing call sites
  /// that don't pass it keep working unchanged.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.video_library_rounded,
                        color: Color(0xFF175CD3),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'All Lectures',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF175CD3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$lectureCount',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF175CD3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle ?? 'Manage course lectures',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: ['All', 'Pdf', 'Video', 'Audio'].map((t) {
                  final sel = filterType == t;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => onFilterChange(t),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: sel ? const Color(0xFF175CD3) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: sel
                                ? const Color(0xFF175CD3)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 240,
                height: 40,
                child: TextField(
                  controller: searchCtrl,
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search lectures...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF94A3B8),
                      size: 18,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFF175CD3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
              // Only rendered when onAddNew is provided — students (who
              // pass null) never see this button at all, not even disabled.
              if (onAddNew != null) ...[
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onAddNew,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    'Add Lecture',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF175CD3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 11,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
