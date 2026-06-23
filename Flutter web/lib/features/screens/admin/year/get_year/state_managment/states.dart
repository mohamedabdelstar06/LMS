

import '../model.dart';

abstract class YearsStateDrop {}

class YearInitialState extends YearsStateDrop {}

class YearLoadingState extends YearsStateDrop {}

class YearLoadedState extends YearsStateDrop {
  YearLoadedState(this.years);
  final List<GetYearModel> years;

}

class YearsErrorState extends YearsStateDrop {
  YearsErrorState(this.message);
  final String message;
}
