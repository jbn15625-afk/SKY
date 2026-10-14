import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/series_item.dart';
import '../services/animerc_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/animerc_logo.dart';
import '../widgets/network_poster.dart';

class SeriesDetailsScreen extends StatefulWidget {
  const SeriesDetailsScreen({super.key, required this.seriesId});

  final String seriesId;

  @override
  State<SeriesDetailsScreen> createState() => _SeriesDetailsScreenState();
}

class _SeriesDetailsScreenState extends State<SeriesDetailsScreen> {
  final _repository = AnimercRepository();
  late Future<SeriesItem?> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchSeries(widget.seriesId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const AnimercLogo(),
      ),
      body: FutureBuilder<SeriesItem?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          final series = snapshot.data;
          if (series == null) {
            return Center(
              child: Text(
                'تعذر العثور على هذا المسلسل.',
                style: GoogleFonts.cairo(color: AppColors.muted),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(48, 24, 48, 48),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NetworkPoster(
                        url: series.coverUrl,
                        width: 240,
                        height: 340,
                        borderRadius: 16,
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              series.genreLabel,
                              style: GoogleFonts.cairo(
                                color: AppColors.pink,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              series.name,
                              style: GoogleFonts.cairo(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                if (series.year.isNotEmpty)
                                  _MetaChip(series.year),
                                if (series.type.isNotEmpty)
                                  _MetaChip(series.type),
                                if (series.studio.isNotEmpty)
                                  _MetaChip(series.studio),
                                if (series.rating > 0)
                                  _MetaChip(
                                    '★ ${series.rating.toStringAsFixed(1)}',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              series.description.isEmpty
                                  ? 'لا يوجد وصف لهذا المسلسل.'
                                  : series.description,
                              style: GoogleFonts.cairo(
                                color: AppColors.muted,
                                fontSize: 15,
                                height: 1.9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(fontSize: 12, color: AppColors.label),
      ),
    );
  }
}
