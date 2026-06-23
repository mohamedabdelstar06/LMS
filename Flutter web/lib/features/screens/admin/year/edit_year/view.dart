import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lms/features/screens/admin/year/create_year/state_management/years_cubit.dart';
import 'package:lms/features/screens/admin/year/create_year/state_management/years_states.dart';
import '../../../../../core/cons/Colors/app_colors.dart';
import '../../department/get_department/model/model.dart';
import '../../department/get_department/state_mangment/cubit.dart';
import '../../department/get_department/state_mangment/states.dart';
import '../get_year/get_All_years/all_model/model.dart';
import '../get_year/get_All_years/state_mangement/cubit.dart';
import '../get_year/get_All_years/state_mangement/states.dart';
import '../get_year/get_All_years/view.dart';

class EditYearScreen extends StatelessWidget {

  const EditYearScreen({super.key, required this.year});
  final GetAllYearModel year;

  @override
  Widget build(BuildContext context) {
    return  MultiBlocProvider(
      providers: [
        BlocProvider<YearCubit>(
          create: (_) => YearCubit(),
        ),
        BlocProvider<DepartmentsCubitDrop>(
          create: (_) => DepartmentsCubitDrop()..fetchDepartments(),
        ),
      ],
      child: const UpdateYearScreen(),
    );
  }
}

class UpdateYearScreen extends StatefulWidget {
  const UpdateYearScreen({super.key});

  @override
  State<UpdateYearScreen> createState() => _CreateYearScreenState();
}

class _CreateYearScreenState extends State<UpdateYearScreen> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  final _formKey = GlobalKey<FormState>();
  bool isDepartmentExpanded = false;

  String selectedMenuItem = 'Create Years';
  String? hoveredMenuItem;
  bool isLogoutHovered = false;
  String selectedDepartmentName = 'Select Department';
  int? selectedDepartmentId;
  late DateTime? selectedStartDate;
  late DateTime? selectedEndDate;
  final dobStartController = TextEditingController();
  final dobEndController = TextEditingController();
  final dobStartFocus = FocusNode();
  final dobEndFocus = FocusNode();
  bool _isInitialized = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    dobStartController.dispose();
    dobEndController.dispose();
    dobStartFocus.dispose();
    dobEndFocus.dispose();

    super.dispose();
  }

  void _initializeFields(GetAllYearModel year) {
    if (_isInitialized) return;

    nameController.text = year.name;
    descriptionController.text = year.description;
    selectedDepartmentName = year.departmentName;
    selectedStartDate = year.startDate;
    selectedEndDate = year.endDate;


    dobStartController.text =
    '${year.startDate!.day}/${year.startDate!.month}/${year.startDate!.year}';
  
    dobEndController.text =
    '${year.endDate!.day}/${year.endDate!.month}/${year.endDate!.year}';
  
    _isInitialized = true;
  }

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    descriptionController = TextEditingController();
    selectedStartDate = null;
    selectedEndDate = null;
    selectedDepartmentName = 'Select Department';
    selectedDepartmentId = null;
    dobStartController.text = '';
    dobEndController.text = '';
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
            Expanded(
              child: BlocConsumer<AllYearsCubit, AllYearsState>(
                listener: (context, state) {
                  if (state is UpdateYearSuccess) {
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
                    _clearForm();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const YearsScreen()),
                    );
                    context.read<AllYearsCubit>().fetchYearss();
                  }
                  if (state is UpdateYearError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is YearByIdLoading ) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2563EB),
                      ),
                    );
                  }

                  if (state is YearByIdLoaded) {
                    final year = state.year;
                    _initializeFields(year);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: Center(child: _buildFormContainer(state)),
                    );
                  }
                  if (state is YearsError || state is YearByIdError) {
                    final message = state is YearsError
                        ? state.message
                        : (state as YearByIdError).message;
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
          ],
        ),
      ),
    );
  }

  void _clearForm() {
    nameController.clear();
    descriptionController.clear();

    setState(() => selectedDepartmentName = 'Select Department');
    selectedStartDate = null;
    selectedEndDate = null;
    dobStartController.text = '';
    dobEndController.text = '';
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

  Widget _buildActionButtons(YearByIdLoaded state) {
    final isLoading = context.watch<AllYearsCubit>().state is UpdateYearLoading;
    final year = state.year;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: InkWell(
            onTap: isLoading
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      if (selectedStartDate == null ||
                          selectedEndDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select both start and end dates',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      final departmentState =
                          context.read<DepartmentsCubitDrop>().state;

                      if (departmentState is DepartmentLoadedState) {
                        final matchedDepartment =
                        departmentState.departments.firstWhere(
                              (d) => d.name == selectedDepartmentName,
                        );

                        selectedDepartmentId = matchedDepartment.id;
                      }

                      if (selectedDepartmentId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a valid department'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (selectedDepartmentName == 'Select Department' ||
                          selectedDepartmentName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a department name'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      context.read<AllYearsCubit>().updateYears(
                            id: year.id,
                            name: nameController.text,
                            description: descriptionController.text,
                            departmentName: selectedDepartmentName,
                            departmentId: selectedDepartmentId!,
                            totalHours: int.parse(year.totalHours.toString()),
                            startDate: selectedStartDate!,
                            endDate: selectedEndDate!,
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
                            'Updating Year...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Update Year',
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

  Widget _buildFormContainer(YearByIdLoaded state) {
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
                  'Edit Year',
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
                    Expanded(child: _buildField('Year Name', nameController)),
                    const SizedBox(width: 20),
                    Expanded(
                      child:
                          BlocBuilder<
                            DepartmentsCubitDrop,
                            DepartmentsStateDrop
                          >(
                            builder: (context, departmentState) {
                              if (departmentState is DepartmentsErrorState) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Department Name',
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
                              } else if (departmentState
                                  is DepartmentLoadedState) {
                                final departmentsTooShow =
                                    departmentState.departments.isEmpty
                                    ? [
                                        GetDepartmentModel(
                                          name: 'No departments available',
                                          id: -1,
                                          description: '',
                                          headId: 0,
                                          headName: '',
                                          createdAt: DateTime.now(),
                                          updatedAt: DateTime.now(),
                                          years: [],
                                        ),
                                      ]
                                    : departmentState.departments;
                                return _buildDropdownField(
                                  selectedDepartmentName,
                                  departmentsTooShow,
                                  isDepartmentExpanded,
                                  (department) {
                                    setState(() {
                                      selectedDepartmentName =
                                          department.name;
                                      selectedDepartmentId = department.id;
                                      isDepartmentExpanded = false;
                                    });
                                  },
                                  () => setState(
                                    () => isDepartmentExpanded =
                                        !isDepartmentExpanded,
                                  ),
                                );
                              }
                              else if (departmentState is DepartmentsErrorState) {
                                return _buildDropdownField(
                                  'Error loading departments',
                                  [
                                    GetDepartmentModel(
                                      name: state.year.name,
                                      id: state.year.id,
                                      description: state.year.description,
                                      headId: 0,
                                      headName: 'state.year.headName',
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                      years: [],
                                    ),
                                  ],
                                  isDepartmentExpanded,
                                  (user) => setState(() {
                                    selectedDepartmentName = user.name;
                                    selectedDepartmentId = user.id;
                                    isDepartmentExpanded = false;
                                  }),
                                  () => setState(
                                    () => isDepartmentExpanded =
                                        !isDepartmentExpanded,
                                  ),

                                );

                              }
                              else {
                                return _buildDropdownField(
                                  selectedDepartmentName,

                                  [
                                    GetDepartmentModel(
                                      name: state.year.name,
                                      id: state.year.id,
                                      description: state.year.description,
                                      headId: 0,

                                      headName: 'state.year.headName',
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                      years: [],
                                    ),
                                  ],
                                  isDepartmentExpanded,
                                  (user) => setState(() {
                                    selectedDepartmentName = user.name;
                                    selectedDepartmentId = user.id;
                                    isDepartmentExpanded = false;
                                  }),
                                  () => setState(
                                    () => isDepartmentExpanded = !isDepartmentExpanded,
                                  ),
                                );
                              }
                            },
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        'Start Date',
                        dobStartController,
                        dobStartFocus,
                        'Select Date',
                        onDateChanged: (date) {
                          setState(() {
                            selectedStartDate = date;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildDateField(
                        'End date',
                        dobEndController,
                        dobEndFocus,
                        'Select Date',
                        onDateChanged: (date) {
                          setState(() {
                            selectedEndDate = date;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildField('Description', descriptionController, maxLines: 4),
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
    List<GetDepartmentModel> departments,
    bool isExpanded,
    Function(GetDepartmentModel) onSelected,
    Function() onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Department Name',
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

  Widget _buildDateField(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    String hint, {
    required Function(DateTime) onDateChanged,
  }) {
    final formatter = DateFormat('dd/MM/yyyy');

    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        final isFocused = focusNode.hasFocus;
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isFocused ? Colors.white : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFocused
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE2E8F0),
                  width: isFocused ? 2 : 1,
                ),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                readOnly: true,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  suffixIcon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF94A3B8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedStartDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF2563EB),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    onDateChanged(picked);

                    controller.text =
                        controller.text = formatter.format(picked);;
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
