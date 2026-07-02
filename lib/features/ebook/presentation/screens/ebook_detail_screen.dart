import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/ebook_model.dart';
import '../providers/ebook_provider.dart';

class EbookDetailScreen extends ConsumerWidget {
  final int ebookId;

  const EbookDetailScreen({super.key, required this.ebookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ebookAsync = ref.watch(ebookDetailProvider(ebookId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ebookAsync.when(
        loading: () => const _EbookDetailSkeleton(),
        error: (e, _) => _EbookDetailError(
          message: e.toString(),
          onRetry: () => ref.invalidate(ebookDetailProvider(ebookId)),
        ),
        data: (ebook) => _EbookDetailContent(ebook: ebook),
      ),
    );
  }
}

class _EbookDetailContent extends StatelessWidget {
  final EbookItem ebook;

  const _EbookDetailContent({required this.ebook});

  @override
  Widget build(BuildContext context) {
    final downloadUrl = ebook.downloadUrl ?? ebook.file.downloadUrl;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          floating: true,
          snap: true,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
          ),
          title: const Text('Ebook Detail'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.divider, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.menu_book_outlined,
                          color: AppColors.primary, size: 34),
                      const SizedBox(height: 16),
                      Text(
                        ebook.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ebook.fileName ?? 'Ebook file',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 18),
                      _DetailRow(label: 'Preview', value: ebook.previewSupported ? 'Available' : 'Unavailable'),
                      _DetailRow(label: 'Mime type', value: ebook.mimeType ?? '-'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (ebook.previewUrl != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openUrl(ebook.previewUrl!),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Preview Ebook'),
                    ),
                  ),
                if (downloadUrl != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadEbook(context, ebook),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.divider),
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      icon: const Icon(Icons.download_outlined, size: 16),
                      label: const Text('Download Ebook'),
                    ),
                  ),
                ],
                if (!ebook.previewSupported && ebook.previewMessage != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    ebook.previewMessage!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openUrl(String value) async {
    final uri = Uri.parse(value);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _downloadEbook(BuildContext context, EbookItem ebook) async {
    final downloadUrl = ebook.downloadUrl ?? ebook.file.downloadUrl;
    if (downloadUrl == null || downloadUrl.trim().isEmpty) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = _resolveDownloadFileName(ebook, downloadUrl);
      final targetDirectory =
          Directory('${directory.path}${Platform.pathSeparator}ebooks');
      if (!await targetDirectory.exists()) {
        await targetDirectory.create(recursive: true);
      }

      final targetPath =
          '${targetDirectory.path}${Platform.pathSeparator}$fileName';
      final dio = ApiClient.create();
      await dio.download(downloadUrl, targetPath);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ebook downloaded to $fileName')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download ebook: $e')),
      );
    }
  }

  String _resolveDownloadFileName(EbookItem ebook, String downloadUrl) {
    final fromFileName = (ebook.fileName ?? '').trim();
    if (fromFileName.isNotEmpty) return _sanitizeFileName(fromFileName);

    final uri = Uri.parse(downloadUrl);
    if (uri.pathSegments.isNotEmpty) {
      final lastSegment = uri.pathSegments.last.trim();
      if (lastSegment.isNotEmpty) return _sanitizeFileName(lastSegment);
    }

    return 'ebook_${ebook.id}.pdf';
  }

  String _sanitizeFileName(String value) {
    return value.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

class _EbookDetailSkeleton extends StatelessWidget {
  const _EbookDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          backgroundColor: AppColors.background,
          floating: true,
          snap: true,
          title: Text('Ebook Detail'),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.shimmer,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EbookDetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _EbookDetailError({required this.message, required this.onRetry});

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
