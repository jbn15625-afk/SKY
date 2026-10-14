import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import 'animerc_logo.dart';

/// هيكل مشترك للصفحات الداخلية: شريط علوي بالشعار، عنوان، ثم المحتوى
/// بعرض أقصى مريح وهوامش تتكيّف مع الهاتف.
class PageShell extends StatelessWidget {
  const PageShell({
    super.key,
    required this.title,
    required this.children,
    this.eyebrow = 'AniMerc',
    this.subtitle,
    this.maxWidth = 900,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final double maxWidth;
  final List<Widget> children;

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;
          final horizontal = compact ? 16.0 : 48.0;

          return ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 48),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eyebrow,
                        style: GoogleFonts.cairo(
                          color: AppColors.pink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: compact ? 26 : 34,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle!,
                          style: GoogleFonts.cairo(
                            color: AppColors.muted,
                            fontSize: 14,
                            height: 1.7,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      ...children,
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
