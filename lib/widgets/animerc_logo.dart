import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class AnimercLogo extends StatelessWidget {
  const AnimercLogo({super.key, this.size = 27});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
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
        fontSize: size,
        fontWeight: FontWeight.w900,
        letterSpacing: -1,
        color: Colors.white,
      ),
    );
  }
}
