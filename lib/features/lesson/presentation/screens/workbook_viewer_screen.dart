import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class WorkbookViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const WorkbookViewerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<WorkbookViewerScreen> createState() => _WorkbookViewerScreenState();
}

class _WorkbookViewerScreenState extends State<WorkbookViewerScreen> {
  String? _filePath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/workbook_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final dio = ApiClient.create();
      await dio.download(widget.url, targetPath);

      if (!mounted) return;
      setState(() => _filePath = targetPath);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.title)),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            )
          : _filePath == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : PDFView(filePath: _filePath!),
    );
  }
}
