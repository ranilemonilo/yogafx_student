import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../core/api/api_client.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../data/models/lesson_model.dart';
import '../shared/sheet_button.dart';

class LessonWorkbookSheet extends StatelessWidget {
  final LessonWorkbook workbook;

  const LessonWorkbookSheet({super.key, required this.workbook});

  void _showTopSnackBar(
    ScaffoldMessengerState messenger,
    BuildContext context, {
    required String message,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: action,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(
            16,
            MediaQuery.paddingOf(context).top + 12,
            16,
            0,
          ),
        ),
      );
  }

  Future<void> _downloadWorkbook(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final routeContext = navigator.context;

    _showTopSnackBar(
      messenger,
      context,
      message: 'Downloading workbook...',
      duration: const Duration(seconds: 2),
    );
    navigator.pop();
    try {
      final fileName = _buildFileName(workbook.fileName);
      final directory = await _resolveDownloadDirectory();
      final targetPath = '${directory.path}${Platform.pathSeparator}$fileName';
      final dio = ApiClient.create();
      await dio.download(url, targetPath);

      _showTopSnackBar(
        messenger,
        routeContext,
        message: 'Workbook downloaded',
        action: workbook.url == null
            ? null
            : SnackBarAction(
                label: 'Open',
                onPressed: () {
                  routeContext.push(
                    AppRoutes.workbookViewer,
                    extra: {
                      'url': workbook.url!,
                      'title': workbook.fileName ?? 'Workbook',
                    },
                  );
                },
              ),
        duration: const Duration(seconds: 6),
      );
    } catch (e) {
      _showTopSnackBar(
        messenger,
        routeContext,
        message: 'Download failed: $e',
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<Directory> _resolveDownloadDirectory() async {
    if (Platform.isAndroid) {
      final publicDownloads = Directory('/storage/emulated/0/Download');
      if (await publicDownloads.exists()) return publicDownloads;
      throw const FileSystemException('Download folder not found');
    }

    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) return downloadsDir;
    throw const FileSystemException('Download folder not found');
  }

  String _buildFileName(String? rawName) {
    final baseName = (rawName == null || rawName.trim().isEmpty)
        ? 'workbook_${DateTime.now().millisecondsSinceEpoch}.pdf'
        : rawName.trim();
    return baseName.toLowerCase().endsWith('.pdf')
        ? baseName
        : '$baseName.pdf';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppRadius.badge),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Workbook',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            workbook.fileName ?? 'Lesson file',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 24),
          if (workbook.downloadUrl != null)
            SheetButton(
              label: 'Download',
              icon: Icons.download_rounded,
              isPrimary: true,
              onTap: () => _downloadWorkbook(context, workbook.downloadUrl!),
            ),
          if (workbook.url != null) ...[
            if (workbook.downloadUrl != null) const SizedBox(height: 10),
            SheetButton(
              label: 'Open Workbook',
              icon: Icons.open_in_new_rounded,
              isPrimary: workbook.downloadUrl == null,
              onTap: () {
                Navigator.pop(context);
                context.push(
                  AppRoutes.workbookViewer,
                  extra: {
                    'url': workbook.url!,
                    'title': workbook.fileName ?? 'Workbook',
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
