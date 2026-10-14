import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class PageLinkCard extends StatefulWidget {
  const PageLinkCard({
    super.key,
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

  @override
  State<PageLinkCard> createState() => _PageLinkCardState();
}

class _PageLinkCardState extends State<PageLinkCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hovering ? -5 : 0, 0),
        decoration: BoxDecoration(
          color: _hovering ? const Color(0xFF1A1A1A) : AppColors.panel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovering ? AppColors.accent : const Color(0xFF222222),
          ),
          boxShadow: [
            BoxShadow(
              color: _hovering
                  ? const Color(0x26E50914)
                  : const Color(0x1A000000),
              blurRadius: _hovering ? 20 : 6,
              offset: Offset(0, _hovering ? 10 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.icon,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      widget.title,
                      style: GoogleFonts.cairo(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: GoogleFonts.cairo(
                        color: const Color(0xFFAAAAAA),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.action,
                      style: GoogleFonts.cairo(
                        color: AppColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
