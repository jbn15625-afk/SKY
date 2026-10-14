import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/series_item.dart';
import '../services/animerc_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/animerc_logo.dart';
import '../widgets/network_poster.dart';
import 'series_details_screen.dart';

class SeriesListScreen extends StatefulWidget {
  const SeriesListScreen({super.key});

  @override
  State<SeriesListScreen> createState() => _SeriesListScreenState();
}

class _SeriesListScreenState extends State<SeriesListScreen> {
  final _repository = AnimercRepository();
  late Future<List<SeriesItem>> _future;
  String _filter = 'all';

  static const _filters = [
    ('all', 'الكل'),
    ('action', 'أكشن'),
    ('school', 'مدرسي'),
    ('drama', 'دراما'),
    ('comedy', 'كوميديا'),
    ('romance', 'رومانسي'),
    ('thriller', 'تشويق'),
  ];

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchAllSeries();
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
      body: FutureBuilder<List<SeriesItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'تعذر تحميل المسلسلات. تحقق من الاتصال ثم حدّث الصفحة.',
                style: GoogleFonts.cairo(color: AppColors.muted),
              ),
            );
          }

          final all = snapshot.data ?? [];
          final filtered = _filter == 'all'
              ? all
              : all.where((item) => item.genre.contains(_filter)).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(48, 24, 48, 48),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مكتبة AniMerc',
                          style: GoogleFonts.cairo(
                            color: AppColors.pink,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'كل المسلسلات',
                          style: GoogleFonts.cairo(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x21FFFFFF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x33FFFFFF)),
                    ),
                    child: Text(
                      'اختر مسلسلًا لعرض تفاصيله',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFC9A8FF),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final filter in _filters)
                    FilterChip(
                      selected: _filter == filter.$1,
                      label: Text(filter.$2),
                      onSelected: (_) => setState(() => _filter = filter.$1),
                      selectedColor: const Color(0x1FFF3D68),
                      backgroundColor: AppColors.panel,
                      side: BorderSide(
                        color: _filter == filter.$1
                            ? AppColors.pink
                            : AppColors.border,
                      ),
                      labelStyle: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      showCheckmark: false,
                    ),
                ],
              ),
              const SizedBox(height: 25),
              if (filtered.isEmpty)
                Container(
                  height: 190,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFF383047),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Text(
                    all.isEmpty
                        ? 'لا توجد مسلسلات حتى الآن'
                        : 'لا توجد نتائج',
                    style: GoogleFonts.cairo(color: AppColors.muted),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1100
                        ? 4
                        : constraints.maxWidth >= 800
                            ? 3
                            : 2;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        childAspectRatio: 0.62,
                      ),
                      itemBuilder: (context, index) {
                        return _SeriesCard(series: filtered[index]);
                      },
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SeriesCard extends StatefulWidget {
  const _SeriesCard({required this.series});

  final SeriesItem series;

  @override
  State<_SeriesCard> createState() => _SeriesCardState();
}

class _SeriesCardState extends State<_SeriesCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final series = widget.series;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: _hovering ? const Color(0xFF666666) : const Color(0xFF292929),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SeriesDetailsScreen(seriesId: series.id),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(13),
                          ),
                          child: NetworkPoster(
                            url: series.coverUrl,
                            borderRadius: 0,
                          ),
                        ),
                      ),
                      if (series.rating > 0)
                        Positioned(
                          top: 9,
                          right: 9,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.rating,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '★ ${series.rating.toStringAsFixed(1)}',
                              style: GoogleFonts.cairo(
                                color: const Color(0xFF111111),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        series.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        [
                          series.genreLabel,
                          if (series.year.isNotEmpty) series.year,
                        ].join('  •  '),
                        style: GoogleFonts.cairo(
                          color: const Color(0xFFBDBDBD),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        series.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: const Color(0xFF999999),
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
