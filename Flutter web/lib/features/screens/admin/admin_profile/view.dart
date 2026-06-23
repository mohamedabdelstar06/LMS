import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/core/widgets/custome_drop_down.dart';
import 'package:lms/core/widgets/management/management_layout.dart';
import 'package:lms/core/widgets/management/management_menu_config.dart';
import 'package:lms/core/widgets/cutome_test_field.dart';
import 'package:lms/core/widgets/dateDropDown.dart';
import 'package:lms/core/widgets/profile_picture.dart';
import 'package:lms/features/screens/admin/admin_profile/state_management/cubit_d_profile.dart';
import 'package:lms/features/screens/admin/admin_profile/state_management/state_d_profile.dart';

import 'model/view.dart';
class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminProfileCubit()..getProfile(),
      child: const _AdminProfileContent(),
    );
  }
}

class _AdminProfileContent extends StatefulWidget {
  const _AdminProfileContent();

  @override
  State<_AdminProfileContent> createState() => _AdminProfileContentState();
}

class _AdminProfileContentState extends State<_AdminProfileContent> {
  String selectedMenuItem = 'Profile';
  DateTime? selectedDate;
  String selectedCity = 'Select City';
  bool isCityExpanded = false;

  final GlobalKey<BuildProfilePictureState> _profilePictureKey =
      GlobalKey<BuildProfilePictureState>();

  final FocusNode fullNameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode nationalIdFocus = FocusNode();
  final FocusNode dobFocus = FocusNode();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  final List<String> cities = [
    'Cairo',
    'Alexandria',
    'Giza',
    'Shubra El-Kheima',
    'Port Said',
    'Suez',
    'Luxor',
    'Aswan',
    'Qena',
    'Ismailia',
    'Fayoum',
    'Minya',
    'Beni Suef',
    'Assiut',
    'Sohag',
    'Red Sea',
    'North Sinai',
    'South Sinai',
    'Matrouh',
    'New Valley',
    'Damietta',
    'Kafr El Sheikh',
    'Beheira',
    'Monufia',
    'Qalyubia',
    'Sharqia',
    'Daqahlia',
    'Gharbia',
  ];

  bool _isInitialized = false;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    nationalIdController.dispose();
    dobController.dispose();
    fullNameFocus.dispose();
    emailFocus.dispose();
    nationalIdFocus.dispose();
    dobFocus.dispose();
    super.dispose();
  }

  void _initControllers(User user) {
    if (_isInitialized) return;

    fullNameController.text = user.fullName;
    emailController.text = user.email;
    nationalIdController.text = user.nationalId;

    if (user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty) {
      try {
        final date = DateTime.parse(user.dateOfBirth!);
        dobController.text = _formatDate(date);
        selectedDate = date;
      } catch (_) {
        dobController.text = '';
        selectedDate = null;
      }
    }

    selectedCity = user.city ?? selectedCity;

    _isInitialized = true;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString()}/${date.month.toString()}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ManagementScaffold(
        selectedMenuItem: selectedMenuItem,
        role: ManagementRole.admin,
        child: BlocConsumer<AdminProfileCubit, AdminProfileState>(
          listener: (context, state) {
            if (state is AdminProfileLoaded) {
              _showSuccessSnackbar('Profile updated successfully!');
              _profilePictureKey.currentState?.clearImage();
            } else if (state is AdminProfileError) {
              _showErrorSnackbar(state.message);
            }
          },
          builder: (context, state) {
            if (state is AdminProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2563EB),
                ),
              );
            } else if (state is AdminProfileError) {
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
                      state.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AdminProfileLoaded) {
              final user = state.profile.user;
              _initControllers(user);
              return _buildProfileContent(context, user: user);
            }
            return const Center(child: Text('Loading...'));
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, {required User user}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          constraints: const BoxConstraints(maxWidth: 1132),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const Text(
                  'Your Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Here are all your personal details that you can view and update anytime',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                BuildProfilePicture(
                  key: _profilePictureKey,
                  userImageUrl: user.profileImageUrl,
                ),
                const SizedBox(height: 24),
                buildTextField(
                  true,
                  'Full Name',
                  fullNameController,
                  Icons.person,
                  user.fullName,
                  true,
                ),
                const SizedBox(height: 16),
                buildTextField(
                  true,
                  'Email address',
                  emailController,
                  Icons.email,
                  user.email,
                  true,
                ),
                const SizedBox(height: 16),
                buildTextField(
                  true,
                  'National ID',
                  nationalIdController,
                  Icons.badge,
                  user.nationalId,
                  true,
                ),
                const SizedBox(height: 16),
                ProfileDateField(
                  controller: dobController,
                  focusNode: dobFocus,
                  label: 'Date of Birth',
                  hint: 'Select Date of Birth',
                  selectedDate:
                      user.dateOfBirth != null && user.dateOfBirth!.isNotEmpty
                      ? DateTime.parse(user.dateOfBirth!)
                      : null,
                  onDateSelected: (date) {
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                        dobController.text = _formatDate(date);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                buildDropdownField(
                  'City',
                  selectedCity,
                  cities,
                  isCityExpanded,
                  (value) {
                    setState(() {
                      selectedCity = value;
                      isCityExpanded = false;
                    });
                  },
                  () {
                    setState(() {
                      isCityExpanded = !isCityExpanded;
                    });
                  },
                ),
                const SizedBox(height: 32),
                _buildSaveButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final cubit = context.read<AdminProfileCubit>();
    final state = context.watch<AdminProfileCubit>().state;
    final isLoading = state is AdminProfileLoading;

    return InkWell(
      onTap: isLoading ? null : () => _handleSave(context, cubit),
      child: Container(
        width: 470,
        height: 45,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Saving...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter',
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'inter',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.save, color: Colors.white, size: 20),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    AdminProfileCubit cubit,
  ) async {
    try {
      final photo = await _profilePictureKey.currentState?.getPhotoAsync();

      cubit.updateProfile(
        city: selectedCity,
        dateOfBirth: selectedDate,
        photo: photo,
      );
    } catch (e) {
      _showErrorSnackbar('Failed to prepare image: $e');
    }
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
