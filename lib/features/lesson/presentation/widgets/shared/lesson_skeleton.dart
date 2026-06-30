import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import 'bone.dart';

class LessonSkeleton extends StatefulWidget {
  const LessonSkeleton({super.key});

  @override
  State<LessonSkeleton> createState() => _LessonSkeletonState();
}

class _LessonSkeletonState extends State<LessonSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final shimmer =
            Color.lerp(AppColors.shimmer, AppColors.shimmerHighlight, _anim.value)!;
        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompactHeight = constraints.maxHeight < 560;
            final skeleton = Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(color: Colors.black),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bone(width: 100, height: 10, color: shimmer),
                      const SizedBox(height: 12),
                      Bone(width: 260, height: 26, color: shimmer),
                      const SizedBox(height: 18),
                      Bone(width: double.infinity, height: 2.5, color: shimmer),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Bone(width: 90, height: 36, color: shimmer),
                          const SizedBox(width: 8),
                          Bone(width: 70, height: 36, color: shimmer),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Bone(width: double.infinity, height: 80, color: shimmer),
                      const SizedBox(height: 14),
                      Bone(width: double.infinity, height: 80, color: shimmer),
                    ],
                  ),
                ),
              ],
            );

            if (!isCompactHeight) {
              return skeleton;
            }

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: skeleton,
              ),
            );
          },
        );
      },
    );
  }
}
