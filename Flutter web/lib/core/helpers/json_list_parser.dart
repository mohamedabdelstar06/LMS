/// Extracts a list of JSON objects from common API response shapes.
List<Map<String, dynamic>> parseJsonObjectList(
  dynamic data, {
  List<String> listKeys = const [
    'data',
    'results',
    'items',
    'value',
    'submissions',
    'attempts',
  ],
}) {
  if (data is List) {
    return data
        .whereType<Map>()
        .map(Map<String, dynamic>.from)
        .toList();
  }

  if (data is Map) {
    final map = Map<String, dynamic>.from(data);

    for (final key in listKeys) {
      final value = map[key];
      if (value is List) {
        return value
            .whereType<Map>()
            .map(Map<String, dynamic>.from)
            .toList();
      }
    }

    // Some endpoints return a single object instead of a list.
    if (_looksLikeItem(map)) {
      return [map];
    }
  }

  return [];
}

bool _looksLikeItem(Map<String, dynamic> map) {
  return map.containsKey('id') ||
      map.containsKey('attemptId') ||
      map.containsKey('quizId') ||
      map.containsKey('studentAnswerId');
}
