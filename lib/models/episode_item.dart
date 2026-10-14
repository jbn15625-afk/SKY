class EpisodeItem {
  const EpisodeItem({
    required this.id,
    required this.seriesId,
    required this.groupName,
    required this.name,
    required this.url,
    required this.additionalUrl,
    required this.duration,
    required this.description,
  });

  final String id;
  final String seriesId;
  final String groupName;
  final String name;
  final String url;
  final String additionalUrl;
  final int duration;
  final String description;

  factory EpisodeItem.fromMap(String id, Map<dynamic, dynamic> data) {
    String text(dynamic value) => value == null ? '' : value.toString().trim();

    final rawDuration = data['duration'];
    final duration = rawDuration is num
        ? rawDuration.toInt()
        : int.tryParse(text(rawDuration)) ?? 0;

    final episodeId = text(data['episodeId']);

    return EpisodeItem(
      id: episodeId.isEmpty ? id : episodeId,
      seriesId: text(data['seriesId']),
      groupName: text(data['episodeGroupName']),
      name: text(data['episodeName']).isEmpty
          ? 'حلقة بدون اسم'
          : text(data['episodeName']),
      url: text(data['episodeUrl']),
      additionalUrl: text(data['additionalUrl']),
      duration: duration,
      description: text(data['description']),
    );
  }
}
