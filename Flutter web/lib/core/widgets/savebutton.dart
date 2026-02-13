import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/screens/admin/admin_profile/state_managment/cubit_d_profile.dart';
import '../../features/screens/admin/admin_profile/state_managment/state_d_profile.dart';

class SaveButtonWidget extends StatelessWidget {
  final String selectedCity;
  final DateTime? selectedDate;
  final VoidCallback onSaveSuccess;
  final VoidCallback onSaveError;

  const SaveButtonWidget({
    super.key,
    required this.selectedCity,
    this.selectedDate,
    required this.onSaveSuccess,
    required this.onSaveError,
  });

  void _showSuccessSnackbar(BuildContext context, String message) {
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

  void _showErrorSnackbar(BuildContext context, String message) {
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminProfileCubit, AdminProfileState>(
      listener: (context, state) {
        if (state is AdminProfileLoaded) {
          _showSuccessSnackbar(context, "Profile updated successfully!");
          onSaveSuccess();
        } else if (state is AdminProfileError) {
          _showErrorSnackbar(context, state.message);
          onSaveError();
        }
      },
      builder: (context, state) {
        final isLoading = state is AdminProfileLoading;

        return InkWell(
          onTap: isLoading
              ? null
              : () {
            context.read<AdminProfileCubit>().updateProfile(
              city: selectedCity,
              dateOfBirth: selectedDate,
              photo: null,
            );
          },
          child: Center(
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
                    ? Row(
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
                    const SizedBox(width: 10),
                    const Text(
                      "Saving...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: "inter",
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
                    : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: "inter",
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
        );
      },
    );
  }
}