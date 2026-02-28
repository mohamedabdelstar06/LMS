import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'logs_state.dart';

class LogsCubit extends Cubit<LogsState> {
  LogsCubit() : super(LogsInitial());
}
