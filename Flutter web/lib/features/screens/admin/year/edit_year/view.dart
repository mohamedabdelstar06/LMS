import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../get_year/get_All_years/all_model/model.dart';
import '../get_year/get_All_years/state_mangement/cubit.dart';
import '../get_year/get_All_years/state_mangement/states.dart';

class EditYearScreen extends StatefulWidget {
  final GetAllYearModel year;

  const EditYearScreen({super.key, required this.year});

  @override
  State<EditYearScreen> createState() => _EditYearScreenState();
}

class _EditYearScreenState extends State<EditYearScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _totalHoursController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.year.name);
    _descriptionController = TextEditingController(text: widget.year.description);
    _totalHoursController = TextEditingController(text: widget.year.totalHours.toString());
    _startDateController = TextEditingController(text: widget.year.startDate.toIso8601String());
    _endDateController = TextEditingController(text: widget.year.endDate.toIso8601String());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _totalHoursController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _submitUpdate() {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final totalHours = int.tryParse(_totalHoursController.text.trim()) ?? 0;

    if (name.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    context.read<AllYearsCubit>().updateYears(
      id: widget.year.id,
      name: name,
      description: description,
      headId: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Year'),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: BlocConsumer<AllYearsCubit, AllYearsState>(
        listener: (context, state) {
          if (state is UpdateYearSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            Navigator.pop(context, true);
          } else if (state is UpdateYearError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is UpdateYearLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Year Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _totalHoursController,
                    decoration: const InputDecoration(
                      labelText: 'Total Hours',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _startDateController,
                    decoration: const InputDecoration(
                      labelText: 'Start Date (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _endDateController,
                    decoration: const InputDecoration(
                      labelText: 'End Date (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
