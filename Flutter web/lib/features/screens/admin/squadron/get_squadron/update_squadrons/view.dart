import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/cons/Colors/app_colors.dart';
import '../../../../../../core/helpers/logout_server/logout.dart';
import '../../../../Announcement/view.dart';
import '../../../admin_profile/view.dart';
import '../../../courses/Enrollment_course/view.dart';
import '../../../courses/create_course/Adding_view.dart';
import '../../../courses/home_courses/view.dart';
import '../../../department/create_department/view.dart';
import '../../../department/get_department/get_All_departments/view.dart';
import '../../../user_file/import_file/view.dart';
import '../../../users/create_user/View.dart';
import '../../../users/get_users/view.dart';
import '../../../year/create_year/view.dart';
import '../../../year/get_year/get_All_years/view.dart';
import '../../create_squadron/view.dart';
import '../get_all squadrons/state_managment/cubit.dart';
import '../get_all squadrons/state_managment/states.dart';
import '../get_all squadrons/view.dart';




class EditSquadronScreen extends StatefulWidget {
  final int squadronId;
  const EditSquadronScreen({super.key, required this.squadronId});

  @override
  State<EditSquadronScreen> createState() => _EditSquadronScreenState();
}

class _EditSquadronScreenState extends State<EditSquadronScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;


  String selectedMenuItem = 'Edit Squadrons';
  String? hoveredMenuItem;
  bool isLogoutHovered = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();

    context.read<AllSquadronCubit>()
        .fetchSquadronById(widget.squadronId);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();


    super.dispose();
  }





  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      hintText: label,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MYColors.gradientColor_3,
              MYColors.gradientColor_2.withOpacity(0.25),
              MYColors.gradientColor_3,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            _buildSidebar(),
            BlocConsumer<AllSquadronCubit, AllSquadronState>(
              listener: (context, state) {
                if (state is UpdateSquadronSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                  );
                  _clearForm();
                }
                if (state is UpdateSquadronError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                if (state is GetSquadronByIdLoading ||
                    state is UpdateSquadronLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is GetSquadronByIdLoaded) {
                  final squadron = state.squadron;

                  nameController.text = squadron.name;
                  descriptionController.text = squadron.description;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: _buildFormContainer(state),
                    ),
                  );}


                if (state is AllSquadronError) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox();
                },
            ),
          ],
        ),
      ),
    );
  }

  void _clearForm() {
    nameController.clear();
    descriptionController.clear();

  }

  Widget _buildField(
      String label,
      TextEditingController nameController, {
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),

        ),
        const SizedBox(height: 8),
        TextFormField(
          validator: (v) => v!.isEmpty ? "Field Required" : null,

          controller: nameController,
          maxLines: maxLines,
          decoration: _inputStyle(label),
        ),
      ],
    );
  }


  Widget _buildActionButtons(GetSquadronByIdLoaded state) {
    bool isLoading = state is GetSquadronByIdLoading;
    final squadron = state.squadron;
    return Row(
      children: [

        Expanded(
          flex: 2,
          child: InkWell(
            onTap: isLoading ? null : () {
              final updated = squadron.copyWith(
                            name: nameController.text,
                            description: descriptionController.text,
                          );

                          context
                              .read<AllSquadronCubit>()
                              .updateSquadron(updated);
                          setState(() {});
              },

            child: Container(
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1849A9),
                    Color(0xFF53B1FD),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isLoading
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Updating Squadron...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                    : const Text(
                  "Update Squadron",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildFormContainer(GetSquadronByIdLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 600),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          width: 1100,
          constraints: const BoxConstraints(maxWidth: 1124),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Edit Squadron",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildField(
                        "Squadron Name",
                        nameController,
                      ),
                    ),
                    const SizedBox(width: 20),

                  ],
                ),

                const SizedBox(height: 24),


                _buildField(
                  "Description",
                  descriptionController,
                  maxLines: 4,
                ),
                const SizedBox(height: 40),

                _buildActionButtons(state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      margin: const EdgeInsetsDirectional.only(
        start: 40,
        end: 0,
        top: 50,
        bottom: 50,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListView(
        children: [
          const SizedBox(height: 40),
          _buildMenuItem(
            Icons.person_outline,
            Icons.person,
            'Profile',
            'Profile',
                () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminProfileScreen(),
                    ),
                  );
            },
          ),
          _buildMenuItem(
            Icons.book_outlined,
            Icons.book,
            'My Courses',
            'My Courses',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminCourseScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            Icons.notifications_active_outlined,
            Icons.notifications_active_rounded,
            'Announcements',
            'Announcements',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AnnouncementScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            Icons.person_add_alt_1_outlined,
            Icons.person_add_alt_1,
            'Create Users',
            'Create users',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateUserScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            Icons.folder_copy_outlined,
            Icons.folder_copy_rounded,
            'Create Departments',
            'Create Departments',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CreateDepartmentPage()),
              );
            },
          ),
          _buildMenuItem(
            Icons.calendar_month,
            Icons.calendar_month_outlined,
            'Create Years',
            'Create Years',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CreateYearPage()),
              );
            },
          ),

          _buildMenuItem(
            Icons.calendar_month,
            Icons.calendar_month_outlined,
            'Add Enrollment',
            'Add Enrollment',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => EnrollmentPage()),
              );
            },
          ),
          _buildMenuItem(
            Icons.event_available,
            Icons.event_note_outlined,
            'Create New Course',
            'Create New Course',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CreateNewCoursePage()),
              );
            },
          ),
          _buildMenuItem(
            Icons.airplanemode_active,
            Icons.airplanemode_active_rounded,
            'Create Squadrons',
            'Create Squadrons',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CreateSquadronsPage()),
              );
            },
          ),
          _buildMenuItem(
            Icons.airplanemode_active,
            Icons.airplanemode_active_rounded,
            'Edit Squadrons',
            'Edit Squadrons',
                () {

            },
          ),
          _buildMenuItem(
            Icons.supervised_user_circle_rounded,
            Icons.supervised_user_circle_outlined,
            'All Squadrons',
            'All Squadrons',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GetSquadronPage()),
              );
            },
          ),
          _buildMenuItem(
            Icons.supervised_user_circle_rounded,
            Icons.supervised_user_circle_outlined,
            'All Users',
            'All Users',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GetUsersPage()),
              );
            },
          ),

          _buildMenuItem(
            Icons.school_outlined,
            Icons.school,
            'All Departments',
            'All Departments',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DepartmentsScreen()),
              );
            },
          ),
          _buildMenuItem(
            Icons.auto_awesome_motion_rounded,
            Icons.auto_awesome_motion_outlined,
            'All Years',
            'All Years',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => YearsScreen()),
              );
            },
          ),

          _buildMenuItem(
            Icons.file_open_outlined,
            Icons.file_open,
            'Import users File',
            'Import users File',
                () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ImportStudentsScreen()),
              );
            },
          ),

          _buildMenuItem(
            Icons.grade_outlined,
            Icons.grade,
            'Grades overview',
            'Grades overview',
                () {},
          ),
          const Spacer(),
          _buildLogoutButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isLogoutHovered = true),
      onExit: (_) => setState(() => isLogoutHovered = false),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await LogoutServer.logout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isLogoutHovered
                ? const Color(0xFFEF4444).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isLogoutHovered
                  ? const Color(0xFFEF4444).withOpacity(0.3)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.logout, color: const Color(0xFFEF4444), size: 20),
              const SizedBox(width: 12),
              const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      IconData outlinedIcon,
      IconData filledIcon,
      String title,
      String value,
      onTap,
      ) {
    final isSelected = selectedMenuItem == value;
    final isHovered = hoveredMenuItem == value;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hoveredMenuItem = value),
      onExit: (_) => setState(() => hoveredMenuItem = null),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedMenuItem = value;
          });
        },
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : isHovered
                  ? const Color(0xFF2563EB).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isHovered && !isSelected
                    ? const Color(0xFF2563EB).withOpacity(0.3)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? filledIcon : outlinedIcon,
                    key: ValueKey(isSelected),
                    color: isSelected
                        ? Colors.white
                        : isHovered
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF64748B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isHovered
                        ? const Color(0xFF2563EB)
                        : Colors.black87,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

