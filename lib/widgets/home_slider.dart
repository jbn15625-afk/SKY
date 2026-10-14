import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/series_item.dart';
import '../screens/series_details_screen.dart';
import '../theme/app_colors.dart';
import 'network_poster.dart';

class HomeSlider extends StatefulWidget {
  const HomeSlider({
    super.key,
    required this.series,
    this.compact = false,
  });

  final List<SeriesItem> series;

  /// نسخة مضغوطة للهاتف (هوامش وصورة وخط أصغر).
  final bool compact;

  static double heightFor(bool compact) => compact ? 290 : 310;

  @override
  State<HomeSlider> createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  int _index = 0;

  void _show(int index) {
    if (widget.series.isEmpty) return;
    setState(() {
      _index = (index + widget.series.length) % widget.series.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;
    final height = HomeSlider.heightFor(compact);

    if (widget.series.isEmpty) {
      return const SizedBox.shrink();
    }

    // لو تغيّرت قائمة المسلسلات (بعد إعادة التحميل) قد يصبح الفهرس خارجها.
    final index = _index < widget.series.length ? _index : 0;
    final item = widget.series[index];
    final background = item.backgroundFor(compact: compact);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (background.isNotEmpty)
              CachedNetworkImage(imageUrl: background, fit: BoxFit.cover)
            else
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF24202C), Color(0xFF090909)],
                  ),
                ),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xF7080711),
                    Color(0xA3080711),
                    Color(0x52080711),
                  ],
                ),
              ),
            ),
            Padding(
              padding: compact
                  ? const EdgeInsets.fromLTRB(16, 18, 16, 58)
                  : const EdgeInsets.fromLTRB(36, 28, 36, 58),
              child: Row(
                children: [
                  NetworkPoster(
                    url: item.coverUrl,
                    width: compact ? 100 : 155,
                    height: compact ? 150 : 220,
                  ),
                  SizedBox(width: compact ? 16 : 28),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'اختيار AniMerc',
                          style: GoogleFonts.cairo(
                            color: AppColors.pink,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: compact ? 22 : 36,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        if (item.year.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            item.year,
                            style: GoogleFonts.cairo(
                              color: AppColors.muted,
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    SeriesDetailsScreen(seriesId: item.id),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF090909),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          child: const Text('عرض التفاصيل'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.series.length > 1)
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Row(
                  children: [
                    _ControlButton(
                      label: 'السابق',
                      onTap: () => _show(index - 1),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var i = 0; i < widget.series.length; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3.5),
                              child: GestureDetector(
                                onTap: () => _show(i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i == index
                                        ? Colors.white
                                        : Colors.white24,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _ControlButton(
                      label: 'التالي',
                      onTap: () => _show(index + 1),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.border),
        backgroundColor: const Color(0xD1080711),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.cairo(fontSize: 13),
      ),
      child: Text(label),
    );
  }
}
