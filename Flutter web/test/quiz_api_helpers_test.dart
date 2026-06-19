import 'package:flutter_test/flutter_test.dart';
import 'package:lms/core/helpers/api_url_helper.dart';
import 'package:lms/core/helpers/json_list_parser.dart';
import 'package:lms/features/screens/quizes/quiz_model.dart';

void main() {
  group('parseJsonObjectList', () {
    test('parses raw list', () {
      final result = parseJsonObjectList([
        {'attemptId': 1, 'score': 80},
      ]);
      expect(result, hasLength(1));
      expect(result.first['attemptId'], 1);
    });

    test('parses wrapped results map', () {
      final result = parseJsonObjectList({
        'results': [
          {'attemptId': 2, 'score': 55},
          {'attemptId': 3, 'score': 90},
        ],
      });
      expect(result, hasLength(2));
    });

    test('parses single result object', () {
      final result = parseJsonObjectList({
        'attemptId': 9,
        'quizId': 4,
        'score': 70,
      });
      expect(result, hasLength(1));
      expect(result.first['attemptId'], 9);
    });
  });

  group('ApiUrlHelper.resolveMediaUrl', () {
    test('fixes api double slash before uploads', () {
      final url = ApiUrlHelper.resolveMediaUrl('/uploads/users/abc.jpg');
      expect(url, 'https://skylearn.runasp.net/uploads/users/abc.jpg');
    });

    test('strips api prefix from upload paths', () {
      final url = ApiUrlHelper.resolveMediaUrl('/api/uploads/users/abc.jpg');
      expect(url, 'https://skylearn.runasp.net/uploads/users/abc.jpg');
    });

    test('normalizes already absolute broken url', () {
      final url = ApiUrlHelper.resolveMediaUrl(
        'https://skylearn.runasp.net/api//uploads/users/abc.jpg',
      );
      expect(url, 'https://skylearn.runasp.net/uploads/users/abc.jpg');
    });
  });

  group('QuizResult.fromJson', () {
    test('reads student name from results payload', () {
      final result = QuizResult.fromJson({
        'attemptId': 1,
        'quizId': 2,
        'studentName': 'Ahmed Ali',
        'score': 88,
        'passingScore': 50,
        'passed': true,
        'totalQuestions': 10,
        'correctAnswers': 8,
        'totalMarks': 10,
        'earnedMarks': 8,
        'gradingMode': 'Auto',
        'isFullyGraded': true,
      });
      expect(result.studentName, 'Ahmed Ali');
    });
  });
}
