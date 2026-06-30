import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

class Bone extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const Bone({
    super.key,
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.avatar),
      ),
    );
  }
}
