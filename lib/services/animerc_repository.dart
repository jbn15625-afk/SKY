import 'package:firebase_database/firebase_database.dart';

import '../models/episode_item.dart';
import '../models/home_data.dart';
import '../models/series_item.dart';

/// قراءة فقط: التطبيق للمشاهدة، وإدارة المحتوى تتم من موقع الويب.
class AnimercRepository {
  AnimercRepository({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  /// كل ما تحتاجه الصفحة الرئيسية بقراءتين فقط (series + slider).
  Future<HomeData> fetchHomeData() async {
    final results = await Future.wait([
      _fetchSeriesById(),
      _database.ref('slider').get(),
    ]);

    final seriesById = results[0] as Map<String, SeriesItem>;
    final sliderSnapshot = results[1] as DataSnapshot;

    final slider = [
      for (final id in _orderedIds(sliderSnapshot.value))
        if (seriesById.containsKey(id)) seriesById[id]!,
    ];

    // المعرّفات التي تنشئها Firebase تتزايد مع الوقت، فالترتيب التنازلي
    // يعرض الأحدث إضافةً أولًا.
    final all = seriesById.values.toList()
      ..sort((a, b) => b.id.compareTo(a.id));

    return HomeData(
      slider: slider,
      movies: all.where((item) => item.isMovie).toList(),
      series: all.where((item) => !item.isMovie).toList(),
    );
  }

  Future<SeriesItem?> fetchSeries(String id) async {
    final snapshot = await _database.ref('series/$id').get();
    final value = snapshot.value;
    if (value is! Map) return null;
    return SeriesItem.fromMap(id, Map<dynamic, dynamic>.from(value));
  }

  Future<List<EpisodeItem>> fetchEpisodes() async {
    final snapshot = await _database.ref('episodes').get();
    final value = snapshot.value;
    if (value is! Map) return [];

    final result = <EpisodeItem>[];
    value.forEach((key, item) {
      if (item is Map) {
        result.add(
          EpisodeItem.fromMap(key.toString(), Map<dynamic, dynamic>.from(item)),
        );
      }
    });
    return result;
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

  /// Realtime Database قد تُرجع القائمة كـ List (عندما تكون المفاتيح 0,1,2...)
  /// أو كـ Map. نرتّب المفاتيح رقميًا حتى لا يأتي "10" قبل "2".
  List<String> _orderedIds(Object? value) {
    final ordered = <MapEntry<String, Object?>>[];

    if (value is Map) {
      for (final entry in value.entries) {
        ordered.add(MapEntry(entry.key.toString(), entry.value));
      }
    } else if (value is List) {
      for (var i = 0; i < value.length; i++) {
        ordered.add(MapEntry('$i', value[i]));
      }
    } else {
      return const [];
    }

    ordered.sort((a, b) {
      final left = int.tryParse(a.key);
      final right = int.tryParse(b.key);
      if (left != null && right != null) return left.compareTo(right);
      return a.key.compareTo(b.key);
    });

    return [
      for (final entry in ordered)
        if (entry.value is String && (entry.value as String).isNotEmpty)
          entry.value as String,
    ];
  }
}
