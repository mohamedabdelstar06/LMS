import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/model.dart';
import '../state_managment/lectures_cubit.dart';
import '../state_managment/lectures_state.dart';
import 'DiaogFieldFunctions.dart';
import 'Functions_of_add_lecture/edit_dialog.dart';

void showAddEditDialog(
    BuildContext context,
    int courseId,
    LectureCubit cubit, {
      LectureModel? lecture,
    }) {
  final  isEdit = lecture != null;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: AddEditDialog(
        courseId: courseId,
        cubit: cubit,
        lecture: lecture,
        isEdit: isEdit,
      ),
    ),
  );
}














