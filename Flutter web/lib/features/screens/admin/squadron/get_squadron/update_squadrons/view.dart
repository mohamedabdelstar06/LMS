import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/cons/Colors/app_colors.dart';
import '../get_all squadrons/state_managment/cubit.dart';
import '../get_all squadrons/state_managment/states.dart';
import '../model/view.dart';

class EditSquadronScreen extends StatefulWidget {
  const EditSquadronScreen({super.key, required this.squadronId, this.squadronData, });
  final int squadronId;
  final SquadronModel? squadronData;

  @override
  State<EditSquadronScreen> createState() => _EditSquadronScreenState();
}

class _EditSquadronScreenState extends State<EditSquadronScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    if (widget.squadronData != null) {
      nameController.text = widget.squadronData!.name;
      descriptionController.text = widget.squadronData!.description;
    } else {

      context.read<AllSquadronCubit>().fetchSquadronById(widget.squadronId);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _clearForm() {
    nameController.clear();
    descriptionController.clear();
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

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1}) {
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
          controller: controller,
          maxLines: maxLines,
          validator: (v) => v!.isEmpty ? "Field Required" : null,
          decoration: _inputStyle(label),
        ),
      ],
    );
  }

  Widget _buildActionButton(bool isLoading, dynamic squadron) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: isLoading
                ? null
                : () {
              if (_formKey.currentState!.validate()) {
                final updated = squadron.copyWith(
                  name: nameController.text,
                  description: descriptionController.text,
                );
                context.read<AllSquadronCubit>().updateSquadron(updated);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 310),
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
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
                        color: Colors.white,
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


  Widget _buildFormContainer(bool isLoading, dynamic squadron) {
    return FadeInUp(
      duration: const Duration(seconds: 2),
      child: Container(
        width: 1100,
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              _buildField("Squadron Name", nameController),
              const SizedBox(height: 24),
              _buildField("Description", descriptionController, maxLines: 4),
              const SizedBox(height: 40),
              _buildActionButton(isLoading, squadron),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
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
        child: BlocConsumer<AllSquadronCubit, AllSquadronState>(
          listener: (context, state) {

            if (state is UpdateSquadronSuccess) {
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
              Navigator.pop(context);
              // Navigator.pushReplacement(
              //   context,
              //   MaterialPageRoute(builder: (_) => const GetSquadronPage()),
              // );
            }

            if (state is UpdateSquadronError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            dynamic squadron;

            if (state is GetSquadronByIdLoaded) {
              squadron = state.squadron;
              nameController.text = squadron.name;
              descriptionController.text = squadron.description;
            } else if (state is UpdateSquadronLoading) {
              final cubitState = context.read<AllSquadronCubit>().state;
              if (cubitState is GetSquadronByIdLoaded) {
                squadron = cubitState.squadron;
              }
            }

            final isLoading = state is UpdateSquadronLoading;


            return SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: _buildFormContainer(isLoading, squadron),
                ),
              );
            }



        ),
      ),
    );
  }
}
