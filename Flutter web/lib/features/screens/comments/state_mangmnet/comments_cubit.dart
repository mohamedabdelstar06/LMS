import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit() : super(CommentsInitial());
}
