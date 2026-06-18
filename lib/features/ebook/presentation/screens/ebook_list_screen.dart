import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/running_login_time_card.dart';
import '../../data/models/ebook_model.dart';
import '../providers/ebook_provider.dart';

class EbookListScreen extends ConsumerWidget {
  const EbookListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ebooksAsync = ref.watch(ebookListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ebooksAsync.when(
        loading: () => const _EbookListSkeleton(),
        error: (e, _) => _EbookError(
          message: e.toString(),
          onRetry: () => ref.invalidate(ebookListProvider),
        ),
        data: (data) => _EbookListContent(data: data),
      ),
    );
  }
}

class _EbookListContent extends ConsumerWidget {
  final EbookListData data;

  const _EbookListContent({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(ebookListProvider);
        await ref.read(ebookListProvider.future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverAppBar(
            backgroundColor: AppColors.background,
            floating: true,
            snap: true,
            title: Text('Ebooks'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: data.items.isEmpty
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RunningLoginTimeCard(),
                        SizedBox(height: 12),
                        _EbookEmptyState(),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: RunningLoginTimeCard(),
                        ),
                        ...data.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _EbookCard(item: item),
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

class _EbookCard extends StatelessWidget {
  final EbookItem item;

  const _EbookCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/ebooks/${item.id}'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.menu_book_outlined, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.fileName ?? 'Ebook file',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _EbookEmptyState extends StatelessWidget {
  const _EbookEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: const Column(
        children: [
          Icon(Icons.menu_book_outlined, color: AppColors.textMuted, size: 40),
          SizedBox(height: 12),
          Text(
            'No ebooks available',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

class _EbookListSkeleton extends StatelessWidget {
  const _EbookListSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          backgroundColor: AppColors.background,
          floating: true,
          snap: true,
          title: Text('Ebooks'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.shimmer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EbookError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _EbookError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_outlined,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
