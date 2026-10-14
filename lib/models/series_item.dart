class SeriesItem {
  const SeriesItem({
    required this.id,
    required this.name,
    required this.type,
    required this.year,
    required this.countries,
    required this.description,
    required this.genre,
    required this.coverUrl,
    required this.desktopBackgroundUrl,
    required this.mobileBackgroundUrl,
    required this.studio,
    required this.platform,
    required this.audioLanguage,
    required this.subtitleLanguage,
    required this.likes,
    required this.rating,
    required this.episodeCount,
    required this.seasonCount,
  });

  final String id;
  final String name;
  final String type;
  final String year;
  final String countries;
  final String description;
  final String genre;
  final String coverUrl;
  final String desktopBackgroundUrl;
  final String mobileBackgroundUrl;
  final String studio;
  final String platform;
  final String audioLanguage;
  final String subtitleLanguage;
  final int likes;
  final double rating;
  final int episodeCount;
  final int seasonCount;

  static const genreLabels = {
    'action': 'أكشن',
    'school': 'مدرسي',
    'drama': 'دراما',
    'comedy': 'كوميديا',
    'romance': 'رومانسي',
    'thriller': 'تشويق',
    'other': 'أخرى',
  };

  String get genreLabel => genreLabels[genre] ?? (genre.isEmpty ? 'غير مصنف' : genre);

  String get backgroundUrl {
    if (isHttpUrl(desktopBackgroundUrl)) return desktopBackgroundUrl;
    if (isHttpUrl(coverUrl)) return coverUrl;
    return '';
  }

  factory SeriesItem.fromMap(String id, Map<dynamic, dynamic> data) {
    return SeriesItem(
      id: id,
      name: _text(data['name']).isEmpty ? 'مسلسل بدون اسم' : _text(data['name']),
      type: _text(data['type']),
      year: _text(data['year']),
      countries: _text(data['countries']),
      description: _text(data['description']),
      genre: _text(data['genre']).toLowerCase(),
      coverUrl: _http(_text(data['coverUrl'])),
      desktopBackgroundUrl: _http(_text(data['desktopBackgroundUrl'])),
      mobileBackgroundUrl: _http(_text(data['mobileBackgroundUrl'])),
      studio: _text(data['studio']),
      platform: _text(data['platform']),
      audioLanguage: _text(data['audioLanguage']),
      subtitleLanguage: _text(data['subtitleLanguage']),
      likes: _int(data['likes']),
      rating: _double(data['rating']),
      episodeCount: _int(data['episodeCount']),
      seasonCount: _int(data['seasonCount']),
    );
  }

  static String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String _http(String value) => isHttpUrl(value) ? value : '';

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(_text(value)) ?? 0;
  }

  static double _double(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(_text(value)) ?? 0;
  }

  static bool isHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}
