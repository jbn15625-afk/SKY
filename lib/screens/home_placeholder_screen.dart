import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'Ani',
                    children: [
                      TextSpan(
                        text: 'merc',
                        style: TextStyle(color: AppColors.pink),
                      ),
                    ],
                  ),
                  style: GoogleFonts.cairo(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'تم تسجيل الدخول بنجاح',
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  email,
                  textDirection: TextDirection.ltr,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'هذه صفحة مؤقتة. في الخطوة التالية سنحوّل الصفحة الرئيسية والمسلسلات من موقع الويب.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    height: 1.8,
                    color: AppColors.label,
                  ),
                ),
                const SizedBox(height: 28),
                OutlinedButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0x80FF3D68)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'تسجيل الخروج',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
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
