import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/dialog_provider.dart';

class DialogDetailScreen extends ConsumerWidget {
  final String dialogKey;

  const DialogDetailScreen({super.key, required this.dialogKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dialogAsync = ref.watch(dialogDetailProvider(dialogKey));

    return Scaffold(
      backgroundColor: Colors.black,
      body: dialogAsync.when(
        loading: () => const _DialogDetailSkeleton(),
        error: (e, _) => _DialogDetailError(
          message: e.toString(),
          onRetry: () => ref.invalidate(dialogDetailProvider(dialogKey)),
        ),
        data: (dialog) => _DialogDetailContent(dialog: dialog),
      ),
    );
  }
}

class _DialogDetailContent extends StatefulWidget {
  final dynamic dialog;

  const _DialogDetailContent({required this.dialog});

  @override
  State<_DialogDetailContent> createState() => _DialogDetailContentState();
}

class _DialogDetailContentState extends State<_DialogDetailContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dialog = widget.dialog;
    final content = (dialog.content as String?)?.trim() ?? '';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.black,
          expandedHeight: 0,
          floating: true,
          snap: true,
          elevation: 0,
          leadingWidth: 56,
          leading: Padding(
            padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dialog.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: content.isEmpty
                          ? const Text(
                              'No dialog content has been added yet.',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                              ),
                            )
                          : Html(
                              data: content,
                              style: {
                            'html': Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontFamily: 'Montserrat',
                              fontSize: FontSize(14),
                              lineHeight: const LineHeight(1.75),
                              backgroundColor: Colors.white,
                            ),
                            'body': Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              backgroundColor: Colors.white,
                            ),
                            'p': Style(
                              margin: Margins.only(bottom: 14),
                            ),
                            'div': Style(
                              margin: Margins.only(bottom: 14),
                            ),
                            'strong': Style(
                              fontWeight: FontWeight.w700,
                            ),
                            'b': Style(
                              fontWeight: FontWeight.w700,
                            ),
                            'h1': Style(
                              margin: Margins.only(bottom: 16),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              lineHeight: const LineHeight(1.25),
                            ),
                            'h2': Style(
                              margin: Margins.only(bottom: 14),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              lineHeight: const LineHeight(1.3),
                            ),
                            'h3': Style(
                              margin: Margins.only(bottom: 12),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              lineHeight: const LineHeight(1.35),
                            ),
                            'h4': Style(
                              margin: Margins.only(bottom: 10),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              lineHeight: const LineHeight(1.4),
                            ),
                            'h5': Style(
                              margin: Margins.only(bottom: 10),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              lineHeight: const LineHeight(1.45),
                            ),
                            'h6': Style(
                              margin: Margins.only(bottom: 8),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              lineHeight: const LineHeight(1.45),
                                ),
                                'ul': Style(
                                  margin: Margins.only(bottom: 14, left: 14),
                                  padding: HtmlPaddings.zero,
                                ),
                                'ol': Style(
                                  margin: Margins.only(bottom: 14, left: 14),
                                  padding: HtmlPaddings.zero,
                                ),
                            'li': Style(
                              margin: Margins.only(bottom: 8),
                            ),
                            'span': Style(
                              fontFamily: 'Montserrat',
                            ),
                            'font': Style(
                              fontFamily: 'Montserrat',
                            ),
                            'blockquote': Style(
                              backgroundColor: const Color(0xFFF8FAFC),
                              border: Border(
                                left: BorderSide(
                                      color: const Color(0xFFE2E8F0),
                                      width: 3,
                                    ),
                                  ),
                                  padding: HtmlPaddings.only(
                                    left: 14,
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  margin: Margins.only(bottom: 14),
                                ),
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogDetailSkeleton extends StatefulWidget {
  const _DialogDetailSkeleton();

  @override
  State<_DialogDetailSkeleton> createState() => _DialogDetailSkeletonState();
}

class _DialogDetailSkeletonState extends State<_DialogDetailSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

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
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.black,
              floating: true,
              snap: true,
              leading: Container(
                margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: shimmer,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bone(width: 220, height: 30, color: shimmer),
                    const SizedBox(height: 20),
                    _Bone(
                      width: double.infinity,
                      height: 260,
                      color: shimmer,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Bone extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _Bone({
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
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _DialogDetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DialogDetailError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.10),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.25),
                ),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontFamily: 'Montserrat',
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.button),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: AppColors.textPrimary,
                      size: 15,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Try again',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
