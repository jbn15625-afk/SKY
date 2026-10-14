import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/series_item.dart';
import '../services/animerc_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/animerc_logo.dart';
import '../widgets/home_slider.dart';
import '../widgets/page_link_card.dart';
import 'add_series_screen.dart';
import 'episodes_screen.dart';
import 'selected_sliders_screen.dart';
import 'series_list_screen.dart';
import 'slider_manager_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = AnimercRepository();
  late Future<List<SeriesItem>> _sliderFuture;

  @override
  void initState() {
    super.initState();
    _sliderFuture = _repository.fetchSliderSeries();
  }

  Future<void> _reload() async {
    setState(() {
      _sliderFuture = _repository.fetchSliderSeries();
    });
    try {
      await _sliderFuture;
    } catch (_) {
      // الخطأ يُعرض داخل منطقة السلايدر نفسها.
    }
  }

  /// يفتح [screen] وعند الرجوع منه يعيد تحميل السلايدر،
  /// لأن بعض الصفحات (مثل إدارة السلايدر) تغيّر محتواه.
  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
    if (mounted) _reload();
  }

  List<_HomeLink> get _links => [
        _HomeLink(
          icon: '▤',
          title: 'اختيار أنميات السلايدر',
          description:
              'اختر المسلسلات التي تريد عرضها في السلايدر على الرئيسية.',
          action: 'إدارة السلايدر ←',
          onTap: () => _open(const SliderManagerScreen()),
        ),
        _HomeLink(
          icon: '▣',
          title: 'السلايدرات المختارة',
          description:
              'عرض الأنميات المختارة مع الاسم والسنة والوصف وصورة الكمبيوتر.',
          action: 'عرض السلايدرات ←',
          onTap: () => _open(const SelectedSlidersScreen()),
        ),
        _HomeLink(
          icon: '▦',
          title: 'قائمة المسلسلات',
          description: 'تصفح المسلسلات واختر مسلسلًا لعرض معلوماته وحلقاته.',
          action: 'تصفح المسلسلات ←',
          onTap: () => _open(const SeriesListScreen()),
        ),
        _HomeLink(
          icon: 'ⓘ',
          title: 'تفاصيل مسلسل',
          description: 'افتح القائمة أولًا، ثم اضغط على المسلسل المطلوب.',
          action: 'اختر مسلسلًا ←',
          onTap: () => _open(const SeriesListScreen()),
        ),
        _HomeLink(
          icon: '＋',
          title: 'إضافة مسلسل',
          description: 'أدخل معلومات مسلسل جديد واحفظه في قاعدة البيانات.',
          action: 'إضافة مسلسل ←',
          onTap: () => _open(const AddSeriesScreen()),
        ),
        _HomeLink(
          icon: '▶',
          title: 'الحلقات',
          description: 'أضف حلقة واربطها بأحد المسلسلات الموجودة.',
          action: 'إدارة الحلقات ←',
          onTap: () => _open(const EpisodesScreen()),
        ),
        _HomeLink(
          icon: '↪',
          title: 'تسجيل الخروج',
          description: 'إنهاء الجلسة الحالية والعودة إلى صفحة تسجيل الدخول.',
          action: 'تسجيل الخروج ←',
          onTap: () => FirebaseAuth.instance.signOut(),
        ),
      ];

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
                      compact ? 24 : 40,
                      horizontal,
                      32,
                    ),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: Column(
                            children: [
                              _Intro(compact: compact),
                              SizedBox(height: compact ? 22 : 30),
                              _SliderArea(
                                future: _sliderFuture,
                                compact: compact,
                                onRetry: _reload,
                                onManageSlider: () =>
                                    _open(const SliderManagerScreen()),
                              ),
                              SizedBox(height: compact ? 28 : 40),
                              _LinksGrid(links: _links),
                              const SizedBox(height: 40),
                              const Divider(color: AppColors.border),
                              const SizedBox(height: 14),
                              const _Footer(),
                            ],
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

class _HomeLink {
  const _HomeLink({
    required this.icon,
    required this.title,
    required this.description,
    required this.action,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String description;
  final String action;
  final VoidCallback onTap;
}

class _Intro extends StatelessWidget {
  const _Intro({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'AniMerc',
          style: GoogleFonts.cairo(
            color: AppColors.pink,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'إلى أين تريد الذهاب؟',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: compact ? 28 : 42,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'اختر الصفحة التي تريد فتحها.',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(color: AppColors.muted, fontSize: 15),
        ),
      ],
    );
  }
}

class _SliderArea extends StatelessWidget {
  const _SliderArea({
    required this.future,
    required this.compact,
    required this.onRetry,
    required this.onManageSlider,
  });

  final Future<List<SeriesItem>> future;
  final bool compact;
  final Future<void> Function() onRetry;
  final VoidCallback onManageSlider;

  @override
  Widget build(BuildContext context) {
    final height = HomeSlider.heightFor(compact);

    return FutureBuilder<List<SeriesItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _SliderMessage(
            height: height,
            children: [
              Text(
                'جارٍ تحميل المسلسلات المختارة...',
                style: GoogleFonts.cairo(color: AppColors.muted),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return _SliderMessage(
            height: height,
            children: [
              Text(
                'تعذر تحميل السلايدر. تحقق من الاتصال ثم أعد المحاولة.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
              ),
            ],
          );
        }

        return HomeSlider(
          series: snapshot.data ?? [],
          compact: compact,
          onManageSlider: onManageSlider,
        );
      },
    );
  }
}

class _SliderMessage extends StatelessWidget {
  const _SliderMessage({required this.height, required this.children});

  final double height;
  final List<Widget> children;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _LinksGrid extends StatelessWidget {
  const _LinksGrid({required this.links});

  final List<_HomeLink> links;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 900
            ? 3
            : width >= 560
                ? 2
                : 1;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          // ارتفاع ثابت بدل نسبة عرض/ارتفاع، حتى لا يفيض النص على الشاشات
          // الضيقة أو عند تكبير الخط.
          childAspectRatio: _aspectRatio(width, columns),
          children: [
            for (final link in links)
              PageLinkCard(
                icon: link.icon,
                title: link.title,
                description: link.description,
                action: link.action,
                onTap: link.onTap,
              ),
          ],
        );
      },
    );
  }

  double _aspectRatio(double width, int columns) {
    const spacing = 20.0;
    const cardHeight = 270.0;
    final cardWidth = (width - spacing * (columns - 1)) / columns;
    return cardWidth / cardHeight;
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.cairo(color: AppColors.muted, fontSize: 12);

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 6,
        children: [
          Text('قصتك القادمة على بُعد حلقة.', style: style),
          Text('© 2026 Animerc — جميع الحقوق محفوظة', style: style),
        ],
      ),
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
        height: compact ? 70 : 78,
        child: Row(
          children: [
            const AnimercLogo(),
            const Spacer(),
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
