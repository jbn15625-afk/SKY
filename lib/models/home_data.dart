import 'series_item.dart';

class HomeData {
  const HomeData({
    required this.slider,
    required this.movies,
    required this.series,
  });

  final List<SeriesItem> slider;
  final List<SeriesItem> movies;
  final List<SeriesItem> series;

  bool get isEmpty => slider.isEmpty && movies.isEmpty && series.isEmpty;
}
