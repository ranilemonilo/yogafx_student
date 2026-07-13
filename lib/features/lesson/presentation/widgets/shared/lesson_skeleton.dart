import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';
import 'bone.dart';

bool _isTabletLandscapeLayout(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return size.shortestSide >= 600 &&
      MediaQuery.orientationOf(context) == Orientation.landscape;
}

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
            final isTabletLandscape = _isTabletLandscapeLayout(context);
            final details = SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTabletLandscape ? 640 : double.infinity,
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isTabletLandscape ? 24 : 20,
                      20,
                      isTabletLandscape ? 24 : 20,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Bone(width: 100, height: 10, color: shimmer),
                        const SizedBox(height: 12),
                        Bone(width: 260, height: 26, color: shimmer),
                        const SizedBox(height: 18),
                        Bone(
                          width: double.infinity,
                          height: 2.5,
                          color: shimmer,
                        ),
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
                ),
              ),
            );

            if (isTabletLandscape) {
              return Row(
                children: [
                  const Expanded(
                    flex: 7,
                    child: ColoredBox(color: Colors.black),
                  ),
                  Container(width: 1, color: AppColors.divider),
                  Expanded(
                    flex: 5,
                    child: details,
                  ),
                ],
              );
            }

            final skeleton = Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(color: Colors.black),
                ),
                if (!isCompactHeight) Expanded(child: details) else details,
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
