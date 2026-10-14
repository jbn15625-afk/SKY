import 'package:firebase_database/firebase_database.dart';

import '../models/episode_item.dart';
import '../models/series_item.dart';

class AnimercRepository {
  AnimercRepository({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  // ---------------------------------------------------------------- series

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

  /// يضيف مسلسلًا جديدًا ويعيد المعرّف الذي أنشأته Firebase.
  /// [data] يجب أن يحتوي كل الحقول التي تشترطها قواعد قاعدة البيانات
  /// (بدون `id` لأنه يُضاف هنا).
  Future<String> addSeries(Map<String, Object?> data) async {
    final newRef = _database.ref('series').push();
    final key = newRef.key;
    if (key == null) {
      throw StateError('تعذر إنشاء معرّف للمسلسل.');
    }
    await newRef.set({'id': key, ...data});
    return key;
  }

  // ---------------------------------------------------------------- slider

  Future<List<SeriesItem>> fetchSliderSeries() async {
    final selectedIds = await fetchSliderIds();
    final seriesById = await _fetchSeriesById();

    return selectedIds
        .where(seriesById.containsKey)
        .map((id) => seriesById[id]!)
        .toList();
  }

  Future<List<String>> fetchSliderIds() async {
    final snapshot = await _database.ref('slider').get();
    return _orderedIds(snapshot.value);
  }

  /// يحفظ اختيار السلايدر بنفس طريقة موقع الويب: مفاتيح "0","1",... وتُحذف
  /// المفاتيح القديمة غير المستخدمة. نستخدم update (وليس set) لأن قواعد
  /// قاعدة البيانات تسمح بالكتابة على مستوى كل موضع وليس على العقدة كلها.
  Future<void> saveSliderSelection(List<String> ids) async {
    final sliderRef = _database.ref('slider');
    final snapshot = await sliderRef.get();
    final oldValue = snapshot.value;

    final updates = <String, Object?>{};
    if (oldValue is Map) {
      for (final key in oldValue.keys) {
        updates[key.toString()] = null;
      }
    } else if (oldValue is List) {
      for (var i = 0; i < oldValue.length; i++) {
        if (oldValue[i] != null) updates['$i'] = null;
      }
    }
    for (var i = 0; i < ids.length; i++) {
      updates['$i'] = ids[i];
    }

    if (updates.isNotEmpty) {
      await sliderRef.update(updates);
    }
  }

  // -------------------------------------------------------------- episodes

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

  /// يضيف حلقة جديدة ويعيد معرّفها.
  Future<String> addEpisode(Map<String, Object?> data) async {
    final newRef = _database.ref('episodes').push();
    final key = newRef.key;
    if (key == null) {
      throw StateError('تعذر إنشاء معرّف للحلقة.');
    }
    await newRef.set({...data, 'episodeId': key});
    return key;
  }

  // --------------------------------------------------------------- helpers

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
