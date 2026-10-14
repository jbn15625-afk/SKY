import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/series_item.dart';
import '../screens/series_details_screen.dart';
import '../theme/app_colors.dart';
import 'network_poster.dart';

/// بطاقة بوستر (غلاف + اسم + سنة) تفتح صفحة معلومات المسلسل/الفيلم.
class PosterCard extends StatefulWidget {
  const PosterCard({super.key, required this.series, required this.width});

  final SeriesItem series;
  final double width;

  /// ارتفاع البطاقة كاملة (البوستر بنسبة 2:3 + سطر الاسم + سطر التفاصيل).
  static double heightFor(double width) => width * 1.5 + 66;

  @override
  State<PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<PosterCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final series = widget.series;
    final posterHeight = widget.width * 1.5;
    final meta = [
      if (series.year.isNotEmpty) series.year,
      series.genreLabel,
    ].join('  •  ');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SeriesDetailsScreen(seriesId: series.id),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: widget.width,
          transform: Matrix4.translationValues(0, _hovering ? -4 : 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  NetworkPoster(
                    url: series.coverUrl,
                    width: widget.width,
                    height: posterHeight,
                    borderRadius: 12,
                  ),
                  if (series.rating > 0)
                    PositionedDirectional(
                      top: 8,
                      end: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.rating,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '★ ${series.rating.toStringAsFixed(1)}',
                          style: GoogleFonts.cairo(
                            color: const Color(0xFF111111),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                series.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                meta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: const Color(0xFFBDBDBD),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// قسم أفقي بعنوان وقائمة بوسترات (الأفلام / المسلسلات).
class PosterSection extends StatelessWidget {
  const PosterSection({
    super.key,
    required this.title,
    required this.items,
    this.compact = false,
  });

  final String title;
  final List<SeriesItem> items;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cardWidth = compact ? 130.0 : 160.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.pink,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: compact ? 20 : 24,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: PosterCard.heightFor(cardWidth),
          child: ScrollConfiguration(
            // للسماح بالسحب بالماوس على نسخة سطح المكتب والويب.
            behavior: const _DragScrollBehavior(),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, index) =>
                  PosterCard(series: items[index], width: cardWidth),
            ),
          ),
        ),
      ],
    );
  }
}

class _DragScrollBehavior extends MaterialScrollBehavior {
  const _DragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}
