
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/state_managments/cubit.dart';
import 'package:lms/features/screens/admin/department/get_department/get_All_departments/state_managments/states.dart';



import 'all_model/model.dart';

class UpdateDepartmentScreen extends StatefulWidget {
  final GetAllDepartmentModel department;

  const UpdateDepartmentScreen({super.key, required this.department});

  @override
  State<UpdateDepartmentScreen> createState() => _UpdateDepartmentScreenState();
}

class _UpdateDepartmentScreenState extends State<UpdateDepartmentScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController headCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.department.name);
    descCtrl = TextEditingController(text: widget.department.description);
    headCtrl =
        TextEditingController(text: widget.department.headId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Department")),
      body: BlocConsumer<DepartmentsCubit, DepartmentsState>(
        listener: (context, state) {
          if (state is UpdateDepartmentSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            Navigator.pop(context);
          }
          if (state is UpdateDepartmentError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: headCtrl,
                  decoration: const InputDecoration(labelText: "Head ID"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                state is UpdateDepartmentLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () {
                    context.read<DepartmentsCubit>().updateDepartment(
                      id: widget.department.id,
                      name: nameCtrl.text,
                      description: descCtrl.text,
                      headId: int.parse(headCtrl.text),
                    );
                  },
                  child: const Text("Update"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
