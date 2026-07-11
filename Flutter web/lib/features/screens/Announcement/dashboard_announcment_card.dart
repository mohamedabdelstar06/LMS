// ════════════════════════════════════════════════════════════════════════════
//  dashboard_announcement_card.dart
//  Drop this file next to dashboard_cubit.dart
//  Then add <DashboardAnnouncementCard/> in _DashboardBody after _RecentCoursesCard
// ════════════════════════════════════════════════════════════════════════════
// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lms/core/helpers/api_url_helper.dart';

import 'package:lms/features/screens/Announcement/cubit.dart';
import 'package:lms/features/screens/Announcement/model.dart';
import 'package:lms/features/screens/Announcement/states.dart';
import 'package:lms/features/screens/Announcement/view.dart';
  

// ── colours shared with dashboard ────────────────────────────────────────────
const _kBg = Color(0xFFF0F4FF);
const _kCard = Colors.white;
const _kBlue = Color(0xFF2563EB);
const _kText = Color(0xFF101828);
const _kSub = Color(0xFF667085);
const _kRed = Color(0xFFF04438);
const _kGreen = Color(0xFF12B76A);
const _kAmber = Color(0xFFF79009);

const _audienceAccents = [
  Color(0xFF6366F1),
  Color(0xFF0EA5E9),
  Color(0xFF10B981),
  Color(0xFFF59E0B),
  Color(0xFFEC4899),
];

// ─────────────────────────────────────────────────────────────────────────────
//  DashboardAnnouncementCard
//  Fetches the 3 latest announcements and shows them in a card.
//  Tapping "See all" navigates to AllAnnouncementScreen.
// ─────────────────────────────────────────────────────────────────────────────
class DashboardAnnouncementCard extends StatelessWidget {
  const DashboardAnnouncementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnnouncementCubit()..getAllAnnouncements(pageSize: 3),
      child: const _AnnouncementCardBody(),
    );
  }
}

class _AnnouncementCardBody extends StatelessWidget {
  const _AnnouncementCardBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kBlue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  color: _kBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Latest Announcements',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kText,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AllAnnouncementScreen(),
                  ),
                ),
                child: const Text(
                  'See all',
                  style: TextStyle(color: _kBlue, fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Content ──
          BlocBuilder<AnnouncementCubit, AnnouncementState>(
            builder: (_, state) {
              if (state is GetAllAnnouncementsLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _kBlue,
                    ),
                  ),
                );
              }

              if (state is GetAllAnnouncementsError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: _kRed, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              if (state is GetAllAnnouncementsSuccess) {
                if (state.announcements.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No announcements yet',
                        style: TextStyle(color: _kSub, fontSize: 13),
                      ),
                    ),
                  );
                }

                return Column(
                  children: state.announcements
                      .take(3)
                      .toList()
                      .asMap()
                      .entries
                      .map(
                        (e) => _AnnouncementTile(
                          announcement: e.value,
                          index: e.key,
                        ),
                      )
                      .toList(),
                );
              }

              return const SizedBox.shrink();
            },
          ),

          // ── Footer button ──
          const SizedBox(height: 4),
        
        ],
      ),
    );
  }
}

// ─── Single announcement row ──────────────────────────────────────────────────
class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({required this.announcement, required this.index});
  final AnnouncementModel announcement;
  final int index;

  Color get _accent =>
      _audienceAccents[announcement.audienceType % _audienceAccents.length];

  @override
  Widget build(BuildContext context) {
    final a = announcement;
    final fmt = DateFormat('d MMM · h:mm a');
    final resolvedImageUrl = ApiUrlHelper.resolveMediaUrl(a.imageUrl);
    final hasImage = resolvedImageUrl != null && resolvedImageUrl.isNotEmpty;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AllAnnouncementScreen()),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kBg.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _accent.withOpacity(0.18)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left accent bar
            Container(
              width: 3,
              height: 56,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Image thumbnail (if any)
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  resolvedImageUrl!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 56,
                    height: 56,
                    color: _accent.withOpacity(0.12),
                    child: Icon(
                      Icons.campaign_rounded,
                      color: _accent,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pin badge
                  if (a.isPinned)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.push_pin_rounded,
                            size: 11,
                            color: _kAmber,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'PINNED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _kAmber,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Text(
                    a.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _kText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    a.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _kSub,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Date + audience pill
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  fmt.format(a.createdAt),
                  style: const TextStyle(fontSize: 10, color: _kSub),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _audienceLabel(a.audienceType),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _audienceLabel(int type) {
    switch (type) {
      case 1:
        return 'Dept';
      case 2:
        return 'Year';
      case 3:
        return 'Squad';
      case 4:
        return 'Course';
      default:
        return 'All';
    }
  }
}


// ════════════════════════════════════════════════════════════════════════════
//  UPDATED _StatsGrid — copy this class over the one in dashboard_view.dart
//  (replaces the old _StatsGrid class only)
// ════════════════════════════════════════════════════════════════════════════
//
// Changes:
//   • Total Users  → GetUserPage()            (unchanged)
//   • Students     → FilteredUsersScreen(role: FilteredRole.students)
//   • Instructors  → FilteredUsersScreen(role: FilteredRole.instructors)
//   • Admins       → FilteredUsersScreen(role: FilteredRole.admins)   ← NEW
//   • Courses      → AdminCourseScreen()       (unchanged)
//   • Departments  → DepartmentsScreen()       (unchanged)
//   • Squadrons    → GetSquadronPage()         (unchanged)
//
// Import at the top of dashboard_view.dart:
//   import 'package:lms/features/screens/admin/users/filtered_users_screen.dart';
//
// ─────────────────────────────────────────────────────────────────────────────
//
// class _StatsGrid extends StatelessWidget {
//   const _StatsGrid({required this.stats, required this.isWide});
//   final DashboardStatsModel stats;
//   final bool isWide;
//
//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       _StatData(
//         'Total Users',
//         stats.totalUsers,
//         Icons.people_rounded,
//         _kBlue,
//         const GetUserPage(),
//         'All registered accounts',
//       ),
//       _StatData(
//         'Students',
//         stats.totalStudents,
//         Icons.school_rounded,
//         _kGreen,
//         const FilteredUsersScreen(role: FilteredRole.students),   // ← changed
//         'Active learners enrolled',
//       ),
//       _StatData(
//         'Instructors',
//         stats.totalInstructors,
//         Icons.person_pin_rounded,
//         _kOrange,
//         const FilteredUsersScreen(role: FilteredRole.instructors), // ← changed
//         'Teaching staff members',
//       ),
//       _StatData(
//         'Admins',
//         stats.totalAdmins,
//         Icons.admin_panel_settings_rounded,
//         _kBlue,
//         const FilteredUsersScreen(role: FilteredRole.admins),      // ← NEW card
//         'System administrators',
//       ),
//       _StatData(
//         'Courses',
//         stats.totalCourses,
//         Icons.menu_book_rounded,
//         _kIndigo,
//         const AdminCourseScreen(),
//         'Published course catalog',
//       ),
//       _StatData(
//         'Departments',
//         stats.totalDepartments,
//         Icons.domain_rounded,
//         _kPurple,
//         const DepartmentsScreen(),
//         'Academic divisions',
//       ),
//       _StatData(
//         'Squadrons',
//         stats.totalSquadrons,
//         Icons.flight_takeoff_rounded,
//         _kRed,
//         const GetSquadronPage(),
//         'Active flight squadrons',
//       ),
//     ];
//
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: isWide ? 4 : 2,   // 4 cols on wide to fit 7 cards
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//         childAspectRatio: isWide ? 3.1 : 1.8,
//       ),
//       itemCount: items.length,
//       itemBuilder: (_, i) => _AnimatedStatCard(data: items[i], delay: i * 80),
//     );
//   }
// }