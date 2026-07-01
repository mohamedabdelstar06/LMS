import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:lms/core/widgets/management/management_layout.dart';
import 'package:lms/core/widgets/management/management_menu_config.dart';
import '../../users/get_users/get_user_dropdown/model_dropdown/view.dart';
import '../../users/get_users/get_user_dropdown/state_managment/cubit.dart';
import '../../users/get_users/get_user_dropdown/state_managment/states.dart';
import 'State_Mangment/create_dep_cubit.dart';
import 'State_Mangment/create_dep_state.dart';

class CreateDepartmentPage extends StatelessWidget {
  const CreateDepartmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DepartmentCubit(),
      child: const CreateDepartmentScreen(),
    );
  }
}

class CreateDepartmentScreen extends StatefulWidget {
  const CreateDepartmentScreen({super.key});

  @override
  State<CreateDepartmentScreen> createState() => _CreateDepartmentScreenState();
}

class _CreateDepartmentScreenState extends State<CreateDepartmentScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final headNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isHeadExpanded = false;

  Uint8List? selectedImageBytes;
  String selectedMenuItem = 'Create Departments';
  String? hoveredMenuItem;
  bool isLogoutHovered = false;
  String selectedHeadName = 'Select Head';

  Future<void> pickImage() async {
    final bytes = await ImagePickerWeb.getImageAsBytes();
    if (bytes != null) {
      setState(() => selectedImageBytes = bytes);
    }
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
    return ManagementScaffold(
      selectedMenuItem: selectedMenuItem,
      role: ManagementRole.admin,
      child: BlocConsumer<DepartmentCubit, DepartmentState>(
        listener: (context, state) {
          if (state is DepartmentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            _clearForm();
          }
          if (state is DepartmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Center(child: _buildFormContainer(state)),
          );
        },
      ),
    );
  }

  void _clearForm() {
    nameController.clear();
    descriptionController.clear();
    headNameController.clear();
    setState(() => selectedImageBytes = null);
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          validator: (v) => v!.isEmpty ? 'Field Required' : null,

          controller: nameController,
          maxLines: maxLines,
          decoration: _inputStyle(label),
        ),
      ],
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
          color: const Color(0xFFF8FAFC),
        ),
        child: selectedImageBytes == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: Color(0xFF94A3B8),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Upload Department Image',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(selectedImageBytes!, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildActionButtons(DepartmentState state) {
    final bool isLoading = state is DepartmentLoading;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedHeadName == 'Select Head' ||
                          selectedHeadName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a department head'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      context.read<DepartmentCubit>().createDepartment(
                        nameController,
                        descriptionController,
                        selectedHeadName,
                        selectedImageBytes,
                      );
                    }
                  },
            child: Container(
              height: 55,
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
                            'Creating Department...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Create Department',
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

  Widget _buildFormContainer(DepartmentState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: TweenAnimationBuilder(
        duration: const Duration(milliseconds: 600),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, value, child) {
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
                color: Colors.black.withValues(alpha: .05),
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
                  'Create Department',
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
                      child: _buildField('Department Name', nameController),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: BlocProvider(
                        create: (_) =>
                            UsersCubitDrop()..fetchAdminsAndInstructors(),
                        child: BlocBuilder<UsersCubitDrop, UsersStateDrop>(
                          builder: (context, userState) {
                            if (userState is UsersLoadingState) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (userState is UsersErrorState) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: Text(
                                  'Error: ${userState.message}',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            if (userState is UsersLoadedState) {
                              if (userState.users.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 30),
                                  child: Text('No users found'),
                                );
                              }

                              final List<UserLiteModel> users = userState.users
                                  .whereType<UserLiteModel>()
                                  .toList();

                              return _buildDropdownField(
                                selectedHeadName,
                                users,
                                isHeadExpanded,
                                (chosenUser) {
                                  setState(() {
                                    selectedHeadName = chosenUser.fullName;
                                    isHeadExpanded = false;
                                  });
                                },
                                () => setState(
                                  () => isHeadExpanded = !isHeadExpanded,
                                ),
                              );
                            }

                            return const SizedBox(height: 50);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildField('Description', descriptionController, maxLines: 4),
                const SizedBox(height: 24),

                const Text(
                  'Photo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 8),
                _buildUploadArea(),

                const SizedBox(height: 40),

                _buildActionButtons(state),
              ],
            ),
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
          'Department Head',
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
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 10,
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return InkWell(
                  onTap: () => onSelected(user),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${user.fullName} (${user.role})',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        if (displayValue == user.fullName)
                          const Icon(
                            Icons.check,
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
