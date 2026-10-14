import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/home_data.dart';
import '../services/animerc_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/animerc_logo.dart';
import '../widgets/home_slider.dart';
import '../widgets/poster_card.dart';

/// الصفحة الرئيسية: السلايدر في الأعلى، ثم الأفلام، ثم المسلسلات.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = AnimercRepository();
  late Future<HomeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchHomeData();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _repository.fetchHomeData();
    });
    try {
      await _future;
    } catch (_) {
      // الخطأ يُعرض داخل الصفحة نفسها.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;
          final horizontal = compact ? 16.0 : 48.0;

          return Column(
            children: [
              _HomeHeader(
                compact: compact,
                onLogout: () => FirebaseAuth.instance.signOut(),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: AppColors.panel,
                  onRefresh: _reload,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      compact ? 16 : 28,
                      horizontal,
                      40,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: FutureBuilder<HomeData>(
                            future: _future,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _StateBox(
                                  height: HomeSlider.heightFor(compact),
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return _StateBox(
                                  height: HomeSlider.heightFor(compact),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'تعذر تحميل المحتوى. تحقق من الاتصال ثم أعد المحاولة.',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.cairo(
                                          color: AppColors.muted,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      OutlinedButton(
                                        onPressed: _reload,
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: AppColors.border,
                                          ),
                                        ),
                                        child: Text(
                                          'إعادة المحاولة',
                                          style: GoogleFonts.cairo(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return _HomeContent(
                                data: snapshot.requireData,
                                compact: compact,
                              );
                            },
                          ),
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

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.data, required this.compact});

  final HomeData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _StateBox(
        height: 220,
        child: Text(
          'لا يوجد محتوى حتى الآن.',
          style: GoogleFonts.cairo(color: AppColors.muted),
        ),
      );
    }

    final gap = SizedBox(height: compact ? 28 : 40);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.slider.isNotEmpty) ...[
          SizedBox(
            width: double.infinity,
            child: HomeSlider(series: data.slider, compact: compact),
          ),
          gap,
        ],
        if (data.movies.isNotEmpty) ...[
          PosterSection(
            title: 'الأفلام',
            items: data.movies,
            compact: compact,
          ),
          gap,
        ],
        if (data.series.isNotEmpty)
          PosterSection(
            title: 'المسلسلات',
            items: data.series,
            compact: compact,
          ),
      ],
    );
  }
}

class _StateBox extends StatelessWidget {
  const _StateBox({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onLogout, required this.compact});

  final VoidCallback onLogout;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final horizontal = compact ? 16.0 : 48.0;

    return Container(
      // نضيف ارتفاع شريط الحالة (الشق/الكاميرا) فوق الهيدر على الهاتف.
      padding: EdgeInsets.fromLTRB(
        horizontal,
        MediaQuery.of(context).padding.top,
        horizontal,
        0,
      ),
      decoration: const BoxDecoration(
        color: Color(0xF5090909),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        height: compact ? 64 : 72,
        child: Row(
          children: [
            const AnimercLogo(),
            const Spacer(),
            // مؤقتًا زر الخروج هنا، وسينتقل لصفحة البروفايل عند بنائها.
            TextButton(
              onPressed: onLogout,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0x80FF3D68)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'تسجيل الخروج',
                style: GoogleFonts.cairo(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
