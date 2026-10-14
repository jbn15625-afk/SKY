import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class NetworkPoster extends StatelessWidget {
  const NetworkPoster({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  final String url;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    if (url.isEmpty) {
      return _placeholder(radius);
    }

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: url,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, _) => Container(
          width: width,
          height: height,
          color: const Color(0xFF17141E),
        ),
        errorWidget: (context, _, _) => _placeholder(radius),
      ),
    );
  }

  Widget _placeholder(BorderRadius radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF292929), Color(0xFF101010)],
        ),
        border: Border.all(color: const Color(0x2EFFFFFF)),
      ),
      child: const Center(
        child: Text('✦', style: TextStyle(color: AppColors.muted, fontSize: 42)),
      ),
    );
  }
}
