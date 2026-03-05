// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
//
// import '../../../core/cons/Colors/app_colors.dart';
// import '../../../core/helpers/logout_server/logout.dart';
// import '../admin/courses/get_All_courses/model/model.dart';
//
// List<GetCourseModel> courses = [];
//
// class CourseScreen extends StatefulWidget {
//   const CourseScreen({super.key});
//
//   @override
//   State<CourseScreen> createState() => _CourseScreenState();
// }
//
// class _CourseScreenState extends State<CourseScreen> {
//   // String? email;
//   //
//   // @override
//   // void initState() {
//   //   super.initState();
//   //   loadEmail();
//   // }
//   //
//   // void loadEmail() async {
//   //   email = await PrefHelper.getEmail();
//   //   setState(() {});
//   // }
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//
//     final isLarge = width > 1200;
//     final isMedium = width > 800;
//
//     return Container(
//       decoration: _backgroundGradient(),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         body: SafeArea(
//           child: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             child: Container(
//               width: double.infinity,
//               constraints: BoxConstraints(
//                 maxWidth: isLarge ? 1400 : (isMedium ? 1000 : double.infinity),
//               ),
//               margin: EdgeInsets.symmetric(
//                 horizontal: isLarge ? 40 : (isMedium ? 20 : 16),
//                 vertical: 20,
//               ),
//               child: Column(
//                 children: [
//                   _buildHeader(context, isLarge),
//                   const SizedBox(height: 30),
//                   _buildCoursesSection(context, isLarge),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   BoxDecoration _backgroundGradient() {
//     return BoxDecoration(
//       gradient: LinearGradient(
//         colors: [
//           MYColors.gradientColor_3,
//           MYColors.gradientColor_1.withValues(alpha: 0.35),
//           MYColors.gradientColor_3,
//         ],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//     );
//   }
//
//   Widget _buildHeader(BuildContext context, bool isLarge) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: _cardDecoration(),
//       child: Row(
//         children: [
//           Expanded(flex: isLarge ? 2 : 1, child: _buildSearchBar()),
//           const SizedBox(width: 20),
//           Row(
//             children: [
//               _buildNotificationButton(
//                 icon: 'assets/icons/message-icon.svg',
//                 onPressed: () {},
//               ),
//               const SizedBox(width: 12),
//               _buildNotificationButton(
//                 icon: 'assets/icons/bell_icon.svg',
//                 onPressed: () {},
//               ),
//               const SizedBox(width: 20),
//               _buildUserProfile(context),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSearchBar() {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         color: const Color(0xffF8FAFC),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(color: const Color(0xffE2E8F0)),
//       ),
//       child: TextFormField(
//         decoration: InputDecoration(
//           border: InputBorder.none,
//           hintText: 'Search courses...',
//           contentPadding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 15,
//           ),
//           prefixIcon: Padding(
//             padding: const EdgeInsets.all(12),
//             child: SvgPicture.asset('assets/icons/search.svg', width: 20),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCoursesSection(BuildContext context, bool isLarge) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(24),
//       decoration: _cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildWelcome(isLarge),
//           const SizedBox(height: 30),
//           _buildCoursesGrid(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildWelcome(bool isLarge) {
//     return Row(
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     'Welcome Back',
//                     style: TextStyle(
//                       color: const Color(0xFF175CD3),
//                       fontSize: isLarge ? 36 : 28,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Image.asset(
//                     'assets/icons/hand.png',
//                     width: isLarge ? 32 : 24,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Start your learning journey now — your next big achievement starts here!',
//                 style: TextStyle(color: Color(0xFF64748B)),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCoursesGrid() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final int crossAxisCount = constraints.maxWidth > 1200
//             ? 4
//             : constraints.maxWidth > 900
//             ? 3
//             : constraints.maxWidth > 600
//             ? 2
//             : 1;
//
//         return GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: crossAxisCount,
//             crossAxisSpacing: 20,
//             mainAxisSpacing: 20,
//             childAspectRatio: 1.22,
//           ),
//           itemCount: courses.length,
//           itemBuilder: (context, index) {
//             return _buildCourseCard(courses[index], index);
//           },
//         );
//       },
//     );
//   }
//
//   BoxDecoration _cardDecoration() {
//     return BoxDecoration(
//       color: Colors.white.withValues(alpha: 0.9),
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withValues(alpha: 0.05),
//           blurRadius: 20,
//           offset: const Offset(0, 10),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildNotificationButton({
//     required String icon,
//     required VoidCallback onPressed,
//   }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onPressed,
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: const Color(0xffF8FAFC),
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: const Color(0xffE2E8F0)),
//           ),
//           child: Center(
//             child: Badge(
//               smallSize: 6,
//               backgroundColor: const Color(0xffFF3B30),
//               offset: const Offset(-1, 1),
//               child: SvgPicture.asset(
//                 icon,
//                 width: 18,
//                 height: 18,
//                 colorFilter: const ColorFilter.mode(
//                   Color(0xFF175CD3),
//                   BlendMode.srcIn,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUserProfile(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xffF8FAFC),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xffE2E8F0)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const CircleAvatar(
//             radius: 16,
//             backgroundImage: AssetImage('assets/logo/logo.jpg'),
//           ),
//           const SizedBox(width: 8),
//           const Text(
//             'Mohamed Ahmed',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               fontFamily: 'inter',
//               color: Color(0xFF1E293B),
//             ),
//           ),
//           const SizedBox(width: 4),
//           IconButton(
//             icon: const Icon(
//               Icons.keyboard_arrow_down_outlined,
//               color: Color(0xFF64748B),
//               size: 20,
//             ),
//             onPressed: () => _showUserMenu(context),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCourseCard(dynamic course, int index) {
//     return TweenAnimationBuilder<double>(
//       duration: Duration(milliseconds: 300 + (index * 100)),
//       tween: Tween(begin: 0.0, end: 1.0),
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, 20 * (1 - value)),
//           child: Opacity(
//             opacity: value,
//             child: GestureDetector(
//               onTap: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('📘 Selected: ${course.title}'),
//                     backgroundColor: const Color(0xFF175CD3),
//                     behavior: SnackBarBehavior.floating,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 );
//               },
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 width: 304,
//                 height: 250,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: 0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Course Image - Fixed height
//                     SizedBox(
//                       width: 304,
//                       height: 164,
//                       child: ClipRRect(
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20),
//                         ),
//                         child: Image.asset(
//                           course.imageUrl,
//                           // fit: BoxFit.cover,
//                           width: 304,
//                           height: 164,
//                           cacheWidth: 304,
//                           cacheHeight: 164,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               width: 304,
//                               height: 164,
//                               color: const Color(0xffF1F5F9),
//                               child: const Icon(
//                                 Icons.image_not_supported,
//                                 color: Color(0xFF94A3B8),
//                                 size: 40,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//
//                     // Course Content - Fixed height
//                     Expanded(
//                       child: SizedBox(
//                         width: 304,
//                         height: 86,
//                         // padding: EdgeInsets.all(12),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               course.title,
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w700,
//                                 fontFamily: 'inter',
//                                 color: Color(0xFF1E293B),
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 3),
//                             Text(
//                               course.subTitle,
//                               style: const TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w400,
//                                 fontFamily: 'inter',
//                                 color: Color(0xFF64748B),
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const Spacer(),
//                             Row(
//                               children: [
//                                 const Icon(
//                                   Icons.star,
//                                   color: Color(0xFFF59E0B),
//                                   size: 14,
//                                 ),
//                                 const Spacer(),
//                                 Text(
//                                   '${course.rate} Complete',
//                                   style: const TextStyle(
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w500,
//                                     color: Color(0xFF64748B),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _showUserMenu(BuildContext context) async {
//     final RenderBox button = context.findRenderObject() as RenderBox;
//     final RenderBox overlay =
//         Overlay.of(context).context.findRenderObject() as RenderBox;
//
//     final RelativeRect position = RelativeRect.fromRect(
//       Rect.fromPoints(
//         button.localToGlobal(Offset.zero, ancestor: overlay),
//         button.localToGlobal(
//           button.size.bottomRight(Offset.zero),
//           ancestor: overlay,
//         ),
//       ),
//       Offset.zero & overlay.size,
//     );
//
//     final result = await showMenu<String>(
//       context: context,
//       position: position,
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       items: [
//         const PopupMenuItem<String>(
//           value: 'profile',
//           child: Row(
//             children: [
//               Icon(Icons.person, color: Color(0xFF175CD3)),
//               SizedBox(width: 8),
//               Text(
//                 'Profile',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//         ),
//         const PopupMenuItem<String>(
//           value: 'settings',
//           child: Row(
//             children: [
//               Icon(Icons.settings, color: Color(0xFF059669)),
//               SizedBox(width: 8),
//               Text(
//                 'Settings',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//         ),
//         const PopupMenuDivider(),
//         const PopupMenuItem<String>(
//           value: 'logout',
//           child: Row(
//             children: [
//               Icon(Icons.logout, color: Color(0xFFDC2626)),
//               SizedBox(width: 8),
//               Text(
//                 'Logout',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFFDC2626),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//
//     if (result == 'logout') {
//       await LogoutServer.logout();
//     } else if (result == 'profile') {
//       // TODO: Add profile action later
//     } else if (result == 'settings') {
//       // TODO: Add settings action later
//     }
//   }
// }
