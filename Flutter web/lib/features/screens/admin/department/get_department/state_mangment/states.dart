

import '../model/model.dart';

abstract class DepartmentsStateDrop {}

class DepartmentInitialState extends DepartmentsStateDrop {}

class DepartmentLoadingState extends DepartmentsStateDrop {}

class DepartmentLoadedState extends DepartmentsStateDrop {
  DepartmentLoadedState(this.departments);
  final List<GetDepartmentModel> departments;
}

class DepartmentsErrorState extends DepartmentsStateDrop {
  DepartmentsErrorState(this.message);
  final String message;
}
