import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:lms/core/cons/Colors/app_colors.dart';
import 'package:lms/core/widgets/app_network_image.dart';
 import 'package:lms/core/widgets/custome_sidebar.dart';
import 'package:lms/features/screens/admin/courses/home_courses/view.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/all_model/model.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/state_managments/cubit.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/state_managments/states.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/view.dart';
import 'package:lms/features/screens/admin/users/get_users/get_user_dropdown/model_dropdown/view.dart';
import 'package:lms/features/screens/admin/users/get_users/get_user_dropdown/state_managment/cubit.dart';
import 'package:lms/features/screens/admin/users/get_users/get_user_dropdown/state_managment/states.dart';

class UpdateDepartmentPage extends StatefulWidget {
  final int departmentId;

  const UpdateDepartmentPage({super.key, required this.departmentId});

  @override
  State<UpdateDepartmentPage> createState() => _UpdateDepartmentPageState();
}

class _UpdateDepartmentPageState extends State<UpdateDepartmentPage> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  final _formKey = GlobalKey<FormState>();
  bool isHeadExpanded = false;

  Uint8List? selectedImageBytes;
  String selectedMenuItem = 'Create Departments';
  String selectedHeadName = "Select Head";
  int? selectedHeadId;
  bool _isInitialized = false;

  Future<void> pickImage() async {
    final bytes = await ImagePickerWeb.getImageAsBytes();
    if (bytes != null) {
      setState(() => selectedImageBytes = bytes);
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<DepartmentsCubit>().fetchDepartmentById(widget.departmentId);
    context.read<UsersCubitDrop>().fetchAdminsAndInstructors();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    selectedImageBytes = null;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _initializeFields(GetAllDepartmentModel department) {
    if (_isInitialized) return;
    nameController.text = department.name;
    descriptionController.text = department.description;
    selectedHeadName = department.headName;
    selectedHeadId = department.headId;
    _isInitialized = true;
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

        child: BlocConsumer<DepartmentsCubit, DepartmentsState>(
          listener: (context, state) {
            if (state is UpdateDepartmentSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(state.message),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DepartmentsScreen(),
                ),
              );
               context.read<DepartmentsCubit>().fetchDepartments();
            } else if (state is UpdateDepartmentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(state.message),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DepartmentByIdLoading ||
                state is UpdateDepartmentLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2563EB),
                ),
              );
            }

            if (state is DepartmentByIdLoaded) {
              final department = state.department;
              _initializeFields(department);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Center(child: _buildFormContainer(state)),
              );
            }

            if (state is DepartmentsError ||
                state is DepartmentByIdError) {
              final message = state is DepartmentsError
                  ? state.message
                  : (state as DepartmentByIdError).message;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildField(
      String label,
      TextEditingController controller, {
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          validator: (v) => v!.isEmpty ? "Field Required" : null,
          controller: controller,
          maxLines: maxLines,
          decoration: _inputStyle(label),
        ),
      ],
    );
  }

  Widget _buildUploadArea(String? currentImageUrl) {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedImageBytes != null
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
            width: 2,
          ),
          color: const Color(0xFFF8FAFC),
        ),
        child: selectedImageBytes != null
            ? Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: MemoryImage(selectedImageBytes!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 48,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Click to change',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
            : currentImageUrl != null && currentImageUrl.isNotEmpty
            ? Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: AppNetworkImage(
                imageUrl: currentImageUrl,
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.black.withOpacity(0.2),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Click to change image',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.cloud_upload_outlined,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
            SizedBox(height: 12),
            Text(
              "Upload Department Image",
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Click to upload",
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(DepartmentByIdLoaded state) {
    final isLoading =
    context.watch<DepartmentsCubit>().state is UpdateDepartmentLoading;
    final department = state.department;

    return SizedBox(
      width: double.infinity,
      child:  Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminCourseScreen(),
                ),
              ),
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 55,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isLoading ? null : () => _handleUpdate(department),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1849A9), Color(0xFF53B1FD)],
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Updating Department...",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Update Department",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.save, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpdate(GetAllDepartmentModel department) {
    if (_formKey.currentState!.validate()) {
       if (selectedHeadName == "Select Head" || selectedHeadName.isEmpty || selectedHeadId == null) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Row(
               children: [Icon(Icons.warning, color: Colors.white), SizedBox(width: 12), Text("Please select a department head")],
             ),
             backgroundColor: Colors.orange,
             behavior: SnackBarBehavior.floating,
           ),
         );
         return;
       }

      context.read<DepartmentsCubit>().updateDepartment(
        department.id,
        nameController.text,
        descriptionController.text,
        selectedImageBytes,
        selectedHeadName,
      );
    }
  }

  Widget _buildFormContainer(DepartmentByIdLoaded state) {
    return TweenAnimationBuilder(
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
        constraints: const BoxConstraints(maxWidth: 1100),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Update Department",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildField("Department Name", nameController),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: BlocBuilder<UsersCubitDrop, UsersStateDrop>(
                      builder: (context, userState) {
                        if (userState is UsersLoadingState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Department Head",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (userState is UsersLoadedState) {
                          final usersToShow = userState.users.isEmpty
                              ? [
                            UserLiteModel(
                              fullName: "No users available",
                              role: "System",
                              id: -1,
                            ),
                          ]
                              : userState.users;
                          return _buildDropdownField(
                            selectedHeadName,
                            usersToShow,
                            isHeadExpanded,
                                (user) {
                              if (user.id != -1) {
                                setState(() {
                                  selectedHeadName = user.fullName;
                                  selectedHeadId = user.id;
                                  isHeadExpanded = false;
                                });
                              }
                            },
                                () => setState(
                                  () => isHeadExpanded = !isHeadExpanded,
                            ),
                          );
                        } else if (userState is UsersErrorState) {
                          return _buildDropdownField(
                            "Error loading users",
                            [
                              UserLiteModel(
                                fullName: state.department.headName,
                                role: "Current Head (API Error)",
                                id: state.department.id,
                              ),
                            ],
                            isHeadExpanded,
                                (user) => setState(() {
                              selectedHeadName = user.fullName;
                              selectedHeadId = user.id;
                              isHeadExpanded = false;
                            }),
                                () => setState(
                                  () => isHeadExpanded = !isHeadExpanded,
                            ),
                          );
                        } else {
                          return _buildDropdownField(
                            selectedHeadName,
                            [
                              UserLiteModel(
                                fullName: state.department.headName,
                                role: "Current Head",
                                id: state.department.id,
                              ),
                            ],
                            isHeadExpanded,
                                (user) => setState(() {
                              selectedHeadName = user.fullName;
                              selectedHeadId = user.id;
                              isHeadExpanded = false;
                            }),
                                () => setState(
                                  () => isHeadExpanded = !isHeadExpanded,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildField("Description", descriptionController, maxLines: 4),
              const SizedBox(height: 24),
              const Text(
                "Photo",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 8),
              _buildUploadArea(state.department.imageUrl),
              const SizedBox(height: 40),
              _buildActionButtons(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      String displayValue,
      List<UserLiteModel> users,
      bool isExpanded,
      Function(UserLiteModel) onSelected,
      Function() onToggle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Department Head",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isExpanded ? Colors.white : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isExpanded
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE2E8F0),
                  width: isExpanded ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: isExpanded
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        displayValue,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 300),
            child: users.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No users available',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isSelected = displayValue == user.fullName;

                return InkWell(
                  onTap: () => onSelected(user),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2563EB).withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: user.role == "Admin"
                                ? Colors.purple.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            user.role == "Admin"
                                ? Icons.admin_panel_settings
                                : Icons.school,
                            size: 16,
                            color: user.role == "Admin"
                                ? Colors.purple
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF1E293B),
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                              ),
                              Text(
                                user.role,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2563EB),
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}