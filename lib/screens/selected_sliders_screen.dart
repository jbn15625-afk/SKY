import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/series_item.dart';
import '../services/animerc_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/form_widgets.dart';
import '../widgets/network_poster.dart';
import '../widgets/page_shell.dart';
import 'series_details_screen.dart';
import 'slider_manager_screen.dart';

/// عرض الأنميات المختارة في السلايدر مع الاسم والسنة والوصف وصورة الخلفية
/// (يطابق صفحة selected-sliders.html في تطبيق الويب).
class SelectedSlidersScreen extends StatefulWidget {
  const SelectedSlidersScreen({super.key});

  @override
  State<SelectedSlidersScreen> createState() => _SelectedSlidersScreenState();
}

class _SelectedSlidersScreenState extends State<SelectedSlidersScreen> {
  final _repository = AnimercRepository();
  late Future<List<SeriesItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchSliderSeries();
  }

  void _reload() {
    setState(() {
      _future = _repository.fetchSliderSeries();
    });
  }

  Future<void> _openManager() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SliderManagerScreen()),
    );
    if (mounted) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      title: 'السلايدرات المختارة',
      subtitle:
          'عرض الأنميات المختارة مع الاسم والسنة والوصف وصورة الخلفية.',
      children: [
        FutureBuilder<List<SeriesItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            if (snapshot.hasError) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatusMessage(
                    message:
                        'تعذر تحميل السلايدرات. تحقق من الاتصال وقواعد Realtime Database ثم أعد المحاولة.',
                    isError: true,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(label: 'إعادة المحاولة', onPressed: _reload),
                ],
              );
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      'لا توجد سلايدرات مختارة',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اختر المسلسلات من صفحة إدارة السلايدر لتظهر هنا.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'اختيار أنميات السلايدر',
                      onPressed: _openManager,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [for (final item in items) _SelectedSliderCard(item)],
            );
          },
        ),
      ],
    );
  }
}

class _SelectedSliderCard extends StatelessWidget {
  const _SelectedSliderCard(this.series);

  final SeriesItem series;

  @override
  Widget build(BuildContext context) {
    final background = series.desktopBackgroundUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Material(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SeriesDetailsScreen(seriesId: series.id),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: background.isNotEmpty
                      ? NetworkPoster(url: background, borderRadius: 0)
                      : Container(
                          alignment: Alignment.center,
                          color: const Color(0xFF101010),
                          child: Text(
                            'لا توجد صورة كمبيوتر',
                            style: GoogleFonts.cairo(color: AppColors.muted),
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        series.name,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        series.year.isEmpty ? 'السنة غير محددة' : series.year,
                        style: GoogleFonts.cairo(
                          color: AppColors.pink,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        series.description.isEmpty
                            ? 'لا يوجد وصف لهذا المسلسل.'
                            : series.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: AppColors.muted,
                          fontSize: 14,
                          height: 1.8,
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
