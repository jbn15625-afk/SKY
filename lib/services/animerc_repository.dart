import 'package:firebase_database/firebase_database.dart';

import '../models/series_item.dart';

class AnimercRepository {
  AnimercRepository({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  Future<List<SeriesItem>> fetchAllSeries() async {
    final byId = await _fetchSeriesById();
    return byId.values.toList();
  }

  Future<SeriesItem?> fetchSeries(String id) async {
    final snapshot = await _database.ref('series/$id').get();
    final value = snapshot.value;
    if (value is! Map) return null;
    return SeriesItem.fromMap(id, Map<dynamic, dynamic>.from(value));
  }

  Future<List<SeriesItem>> fetchSliderSeries() async {
    final sliderSnapshot = await _database.ref('slider').get();
    final seriesById = await _fetchSeriesById();
    final selectedIds = _orderedIds(sliderSnapshot.value);

    return selectedIds
        .where(seriesById.containsKey)
        .map((id) => seriesById[id]!)
        .toList();
  }

  Future<Map<String, SeriesItem>> _fetchSeriesById() async {
    final snapshot = await _database.ref('series').get();
    final value = snapshot.value;
    if (value is! Map) return {};

    final result = <String, SeriesItem>{};
    value.forEach((key, item) {
      if (item is Map) {
        final id = key.toString();
        result[id] = SeriesItem.fromMap(id, Map<dynamic, dynamic>.from(item));
      }
    });
    return result;
  }

  List<String> _orderedIds(Object? value) {
    if (value is! Map) return const [];

    final entries = value.entries.toList()
      ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));

    return [
      for (final entry in entries)
        if (entry.value is String && (entry.value as String).isNotEmpty)
          entry.value as String,
    ];
  }
}
