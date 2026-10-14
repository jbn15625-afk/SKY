import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/series_item.dart';
import '../services/animerc_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/animerc_logo.dart';
import '../widgets/home_slider.dart';
import '../widgets/page_link_card.dart';
import 'coming_soon_screen.dart';
import 'series_list_screen.dart';

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
    await _sliderFuture;
  }

  void _openComingSoon(String title, String description) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComingSoonScreen(
          title: title,
          description: description,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _HomeHeader(
            onLogout: () => FirebaseAuth.instance.signOut(),
          ),
          Expanded(
            child: RefreshIndicator(
              color: Colors.white,
              backgroundColor: AppColors.panel,
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(48, 40, 48, 32),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
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
                            style: GoogleFonts.cairo(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'اختر الصفحة التي تريد فتحها.',
                            style: GoogleFonts.cairo(
                              color: AppColors.muted,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 30),
                          FutureBuilder<List<SeriesItem>>(
                            future: _sliderFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(
                                  height: 310,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.panel,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    'جارٍ تحميل المسلسلات المختارة...',
                                    style: GoogleFonts.cairo(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                );
                              }

                              if (snapshot.hasError) {
                                return Container(
                                  height: 310,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    color: AppColors.panel,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    'تعذر تحميل السلايدر. تحقق من الاتصال ثم أعد المحاولة.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cairo(
                                      color: AppColors.muted,
                                    ),
                                  ),
                                );
                              }

                              return HomeSlider(
                                series: snapshot.data ?? [],
                                onManageSlider: () => _openComingSoon(
                                  'اختيار أنميات السلايدر',
                                  'اختر المسلسلات التي تريد عرضها في السلايدر على الرئيسية.',
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                          LayoutBuilder(
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
                                childAspectRatio: 1.12,
                                children: [
                                  PageLinkCard(
                                    icon: '▤',
                                    title: 'اختيار أنميات السلايدر',
                                    description:
                                        'اختر المسلسلات التي تريد عرضها في السلايدر على الرئيسية.',
                                    action: 'إدارة السلايدر ←',
                                    onTap: () => _openComingSoon(
                                      'اختيار أنميات السلايدر',
                                      'اختر المسلسلات التي تريد عرضها في السلايدر على الرئيسية.',
                                    ),
                                  ),
                                  PageLinkCard(
                                    icon: '▣',
                                    title: 'السلايدرات المختارة',
                                    description:
                                        'عرض الأنميات المختارة مع الاسم والسنة والوصف وصورة الكمبيوتر.',
                                    action: 'عرض السلايدرات ←',
                                    onTap: () => _openComingSoon(
                                      'السلايدرات المختارة',
                                      'عرض الأنميات المختارة مع الاسم والسنة والوصف وصورة الكمبيوتر.',
                                    ),
                                  ),
                                  PageLinkCard(
                                    icon: '▦',
                                    title: 'قائمة المسلسلات',
                                    description:
                                        'تصفح المسلسلات واختر مسلسلًا لعرض معلوماته وحلقاته.',
                                    action: 'تصفح المسلسلات ←',
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const SeriesListScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  PageLinkCard(
                                    icon: 'ⓘ',
                                    title: 'تفاصيل مسلسل',
                                    description:
                                        'افتح القائمة أولًا، ثم اضغط على المسلسل المطلوب.',
                                    action: 'اختر مسلسلًا ←',
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const SeriesListScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  PageLinkCard(
                                    icon: '＋',
                                    title: 'إضافة مسلسل',
                                    description:
                                        'أدخل معلومات مسلسل جديد واحفظه في قاعدة البيانات.',
                                    action: 'إضافة مسلسل ←',
                                    onTap: () => _openComingSoon(
                                      'إضافة مسلسل',
                                      'أدخل معلومات مسلسل جديد واحفظه في قاعدة البيانات.',
                                    ),
                                  ),
                                  PageLinkCard(
                                    icon: '▶',
                                    title: 'الحلقات',
                                    description:
                                        'أضف حلقة واربطها بأحد المسلسلات الموجودة.',
                                    action: 'إدارة الحلقات ←',
                                    onTap: () => _openComingSoon(
                                      'الحلقات',
                                      'أضف حلقة واربطها بأحد المسلسلات الموجودة.',
                                    ),
                                  ),
                                  PageLinkCard(
                                    icon: '↪',
                                    title: 'تسجيل الخروج',
                                    description:
                                        'إنهاء الجلسة الحالية والعودة إلى صفحة تسجيل الدخول.',
                                    action: 'تسجيل الخروج ←',
                                    onTap: () =>
                                        FirebaseAuth.instance.signOut(),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 48),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Text(
                                'قصتك القادمة على بُعد حلقة.',
                                style: GoogleFonts.cairo(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '© 2026 Animerc — جميع الحقوق محفوظة',
                                style: GoogleFonts.cairo(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 48),
      decoration: const BoxDecoration(
        color: Color(0xF5090909),
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const AnimercLogo(),
          const Spacer(),
          TextButton(
            onPressed: onLogout,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0x80FF3D68)),
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
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
    );
  }
}
