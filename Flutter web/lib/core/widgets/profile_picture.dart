/*
import 'package:flutter/material.dart';

class DateRangeSelector extends StatelessWidget {
  final List<String> years = [for (int y = 1980; y <= 2030; y++) y.toString()];

  DateRangeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Start / End Date",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(child: _buildDropdown("2020")),
            const SizedBox(width: 16),
            Expanded(child: _buildDropdown("2025")),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(String initialValue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xF3F7FBFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: initialValue,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        decoration: const InputDecoration(border: InputBorder.none),
        items: years
            .map(
              (y) => DropdownMenuItem(
                value: y,
                child: Text(y, style: const TextStyle(fontSize: 15)),
              ),
            )
            .toList(),
        onChanged: (value) {},
      ),
    );
  }
}
*/
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/core/widgets/app_network_image.dart';


class BuildProfilePicture extends StatefulWidget {

  const BuildProfilePicture({super.key, this.userImageUrl});
  final String? userImageUrl;

  @override
  State<BuildProfilePicture> createState() => BuildProfilePictureState();
}

class BuildProfilePictureState extends State<BuildProfilePicture> {
  bool isProfilePictureHovered = false;
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  Uint8List? _webImage;

  MultipartFile? getPhoto() {
    if (kIsWeb && _webImage != null) {
      return MultipartFile.fromBytes(_webImage!, filename: 'profile_image.jpg');
    } else if (!kIsWeb && _selectedImage != null) {
      return MultipartFile.fromFile(
            _selectedImage!.path,
            filename: _selectedImage!.path.split('/').last,
          )
          as MultipartFile;
    }
    return null;
  }

  Future<MultipartFile?> getPhotoAsync() async {
    if (kIsWeb && _webImage != null) {
      return MultipartFile.fromBytes(_webImage!, filename: 'profile_image.jpg');
    } else if (!kIsWeb && _selectedImage != null) {
      return await MultipartFile.fromFile(
        _selectedImage!.path,
        filename: _selectedImage!.path.split('/').last,
      );
    }
    return null;
  }

  void clearImage() {
    setState(() {
      _webImage = null;
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isProfilePictureHovered = true),
        onExit: (_) => setState(() => isProfilePictureHovered = false),
        child: GestureDetector(
          onTap: _pickImage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.identity()
              ..scale(isProfilePictureHovered ? 1.05 : 1.0),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isProfilePictureHovered
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF2563EB).withOpacity(0.3),
                      width: isProfilePictureHovered ? 4 : 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF2563EB,
                        ).withOpacity(isProfilePictureHovered ? 0.3 : 0.1),
                        blurRadius: isProfilePictureHovered ? 20 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(child: _buildProfileImage()),
                  ),
                ),
                if (isProfilePictureHovered)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.4),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Change Photo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    transform: Matrix4.identity()
                      ..rotateZ(isProfilePictureHovered ? 0.2 : 0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.5),
                            blurRadius: isProfilePictureHovered ? 12 : 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isProfilePictureHovered ? Icons.edit : Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (kIsWeb && _webImage != null) {
      return Image.memory(
        _webImage!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else if (!kIsWeb && _selectedImage != null) {
      return Image.file(
        _selectedImage!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }

    return AppNetworkImage(
      imageUrl: widget.userImageUrl ?? '',
      width: 100,
      height: 100,
      imageType: AppImageType.user,
    );
  }

  Future<void> _pickImage() async {
    await _pickImageFromSource(ImageSource.gallery);
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _webImage = bytes);
        } else {
          setState(() => _selectedImage = File(pickedFile.path));
        }

        _showSuccessSnackbar(
          'Profile picture selected! Click "Save Changes" to update.',
        );
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image. Please try again.');
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


