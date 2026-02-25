import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:lms/features/screens/admin/courses/home_courses/state_managment/states.dart';
import 'package:lms/features/screens/admin/courses/home_courses/state_managment/cubit.dart';
import 'package:lms/features/screens/admin/courses/home_courses/model/model.dart';

import 'package:lms/features/screens/admin/year/get_year/get_All_years/state_mangement/cubit.dart';
import '../../../../../core/cons/Colors/app_colors.dart';
import '../../../../../core/widgets/app_network_image.dart';
import '../../department/get_department/model/model.dart';
import '../../department/get_department/state_mangment/cubit.dart';
import '../../department/get_department/state_mangment/states.dart';

import '../../year/get_year/model.dart';
import '../../year/get_year/state_managment/cubit.dart';
import '../../year/get_year/state_managment/states.dart';

class UpdateNewCoursePage extends StatefulWidget {
  // final GetCoursesModel courseModel;
  final int courseId;

  const UpdateNewCoursePage({super.key, required this.courseId});

  @override
  State<UpdateNewCoursePage> createState() => _UpdateNewCoursePageState();
}

class _UpdateNewCoursePageState extends State<UpdateNewCoursePage> {
  Uint8List? coverImage;

  String? currentImageUrl;
  String? selectedDepartmentId;
  String? selectedYearId;
  List<YearModel> availableYears = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController creditHoursController = TextEditingController();
  bool _isInitialized = false;

  final _formKey = GlobalKey<FormState>();
  bool isDepartmentExpanded = false;

  String selectedDepartmentName = 'Select Department';
  String selectedYearName = 'Select Year';
  bool isYearExpanded = false;

  void _initControllers(GetCoursesModel course) {
    if (_isInitialized) return;

    nameController.text = course.title ?? '';
    descriptionController.text = course.description ?? '';
    creditHoursController.text = course.creditHours?.toString() ?? '';

    selectedDepartmentName = course.departmentName;
    selectedYearName = course.yearName;

    if (course.imageUrl.isNotEmpty) {
      currentImageUrl = course.imageUrl.startsWith('http')
          ? course.imageUrl
          : 'https://skylearn.runasp.net/${course.imageUrl.startsWith('/') ? course.imageUrl.substring(1) : course.imageUrl}';
    }

    _isInitialized = true;
  }

  void _fetchAvailableYears(String departmentId) {
    final yearCubit = context.read<AllYearsCubit>();
    yearCubit.fetchYearById(int.parse(departmentId));
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 400),
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Upload completed successfully',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
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





  Future<void> pickImage() async {
    final img = await ImagePickerWeb.getImageAsBytes();
    if (img != null) {
      setState(() => coverImage = img);
      showSuccessSnackBar('Image uploaded successfully');
    }
  }

  Widget uploadBox(String? networkImageUrl) {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: coverImage != null
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
            width: 2,
          ),
          color: const Color(0xFFF8FAFC),
        ),
        child: coverImage != null
            ? Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: MemoryImage(coverImage!),
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
            : currentImageUrl != null && currentImageUrl!.isNotEmpty
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
                    'Upload Department Image',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Click to upload',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              MYColors.gradientColor_3,
              MYColors.gradientColor_2.withValues(alpha: 0.25),
              MYColors.gradientColor_3,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: BlocConsumer<GetCoursesCubit, GetCourseStates>(
            listener: (context, state) {
              if (state is UpdateCourseSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
                Navigator.pop(context);
                context.read<GetCoursesCubit>()..getCourses();
              }


              if (state is UpdateCourseError) {
                _showErrorSnackbar(state.message);
              }
            },
            builder: (context, state) {
              final cubit = context.read<GetCoursesCubit>();
              final course = cubit.currentCourses.firstWhere(
                (c) => c.id == widget.courseId,
                orElse: () => GetCoursesModel(
                  id: widget.courseId,
                  title: '',
                  description: '',
                  creditHours: 0,
                  departmentName: '',
                  yearName: '',
                  departmentId: 0,
                  yearId: 0,
                  enrolledStudentsCount: 0,
                  imageUrl: '',
                  instructorId: 0,
                  instructorName: '',
                  createdAt: DateTime.now(),
                ),
              );

              _initControllers(course);

              if (state is GetCourseLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                );
              }

              if (state is GetCourseError) {
                return Center(child: Text(state.message));
              }

              // ✅ عرض الفورم لأي state تاني (UpdateCourseLoading, UpdateCourseSuccess, GetCourseSuccess)
              return _buildFormContainer(state, widget.courseId);
            },
          ),
        ),
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

  void _clearForm() {
    nameController.clear();
    descriptionController.clear();
    creditHoursController.clear();

    // setState(() => selectedImageBytes = null);
  }

  Widget _buildSecondDropdownField(
    String displayValue,
    List<YearModel> years,
    bool isExpanded,
    Function(YearModel) onSelected,
    Function() onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Year Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'inter',
            color: Colors.blue[900],
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
            constraints: const BoxConstraints(maxHeight: 250),
            child: years.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: Text(
                        'No years already created for this department',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: years.length,
                    itemBuilder: (context, index) {
                      final year = years[index];
                      return InkWell(
                        onTap: () => onSelected(year),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  year.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              if (displayValue == year.name)
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

  Widget _buildDropdownField(
    String displayValue,
    List<GetDepartmentModel> departments,
    bool isExpanded,
    Function(GetDepartmentModel) onSelected,
    Function() onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Department Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'inter',
            color: Colors.blue[900],
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
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: departments.length,
              itemBuilder: (context, index) {
                final department = departments[index];
                return InkWell(
                  onTap: () => onSelected(department),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${department.name} (${department.headName})',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        if (displayValue == department.name)
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

  Widget _buildFormContainer(GetCourseStates state, int id) {
    return SingleChildScrollView(
      child: Container(
        width: 1100,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 30)],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Course Title',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'inter',
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,

                decoration: const InputDecoration(
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  hintText: 'Introduction to Marketing',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Course Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'inter',
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Brief overview of what the course covers',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Course CreditHours',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'inter',
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: creditHoursController,
                decoration: const InputDecoration(
                  hintText: 'Number of credit hours',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: BlocProvider(
                      create: (_) => DepartmentsCubitDrop()..fetchDepartments(),
                      child:
                          BlocBuilder<
                            DepartmentsCubitDrop,
                            DepartmentsStateDrop
                          >(
                            builder: (context, departmentState) {
                              if (departmentState is DepartmentLoadingState) {
                                return const Padding(
                                  padding: EdgeInsets.only(top: 30),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (departmentState is DepartmentsErrorState) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 30),
                                  child: Text(
                                    'Error: ${departmentState.message}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              if (departmentState is DepartmentLoadedState) {
                                if (departmentState.departments.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.only(top: 30),
                                    child: Text('No departments found'),
                                  );
                                }

                                List<GetDepartmentModel> departments =
                                    departmentState.departments
                                        .whereType<GetDepartmentModel>()
                                        .toList();

                                return _buildDropdownField(
                                  selectedDepartmentName,
                                  departments,
                                  isDepartmentExpanded,
                                  (chosenDep) {
                                    setState(() {
                                      selectedDepartmentId = chosenDep.id
                                          .toString();
                                      availableYears = chosenDep.years;
                                      selectedYearName = 'Select Year';
                                      selectedYearId = null;
                                      selectedDepartmentName = chosenDep.name;
                                      isDepartmentExpanded = false;
                                    });
                                  },
                                  () => setState(
                                    () => isDepartmentExpanded =
                                        !isDepartmentExpanded,
                                  ),
                                );
                              }

                              return const SizedBox(height: 50);
                            },
                          ),
                    ),
                  ),

                  const SizedBox(width: 30),
                  Expanded(
                    child: BlocProvider(
                      create: (_) => YearsCubitDrop()..fetchYears(),
                      child: BlocBuilder<YearsCubitDrop, YearsStateDrop>(
                        builder: (context, yearState) {
                          if (yearState is YearLoadingState) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 30),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          if (yearState is YearsErrorState) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Text(
                                'Error: ${yearState.message}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (yearState is YearLoadedState) {
                            if (yearState.years.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: Text('No years found'),
                              );
                            }

                            // ignore: unused_local_variable
                            List<GetYearModel> years = yearState.years
                                .whereType<GetYearModel>()
                                .toList();

                            return _buildSecondDropdownField(
                              selectedYearName,
                              availableYears,

                              isYearExpanded,
                              (chosenYear) {
                                setState(() {
                                  selectedYearName = chosenYear.name;
                                  selectedYearId = chosenYear.id.toString();

                                  isYearExpanded = false;
                                });
                              },
                              () => setState(
                                () => isYearExpanded = !isYearExpanded,
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
              const SizedBox(height: 16),

              Row(children: [Expanded(child: uploadBox(currentImageUrl))]),
              const SizedBox(height: 32),
              _buildActionButtons(state, id),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(GetCourseStates state, int id) {
    bool isLoading = state is UpdateCourseLoading;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedDepartmentName == 'Select Department' ||
                          selectedDepartmentName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a department Name'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (selectedYearName == 'Select Year' ||
                          selectedYearName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a year Name'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      final courseDate = {
                        'title': nameController.text,
                        'description': descriptionController.text,
                        'departmentName': selectedDepartmentName,
                        'yearName': selectedYearName,

                        'credithours': creditHoursController.text,
                        'imageFile': coverImage,
                      };

                      context.read<GetCoursesCubit>().updateCourse(
                        courseId: id,
                        courseData: courseDate,

                        // nameController,
                        // descriptionController,
                        //
                        // selectedDepartmentName,
                        // selectedYearName,
                        // creditHoursController,
                        // coverImage,
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
                            'Updating Course...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Update Course',
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
}
