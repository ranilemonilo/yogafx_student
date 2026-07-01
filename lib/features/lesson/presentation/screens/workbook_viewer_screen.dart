import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
  final PdfViewerController _pdfController = PdfViewerController();

  String? _filePath;
  String? _error;
  int _currentPage = 1;
  int _pageCount = 0;
  double _zoomLevel = 1.0;
  bool _documentReady = false;

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
      setState(() {
        _filePath = targetPath;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  void _setZoomLevel(double nextZoom) {
    final clampedZoom = nextZoom.clamp(1.0, 4.0);
    _pdfController.zoomLevel = clampedZoom;
    if (!mounted) return;
    setState(() => _zoomLevel = clampedZoom);
  }

  void _zoomIn() => _setZoomLevel(_zoomLevel + 0.25);

  void _zoomOut() => _setZoomLevel(_zoomLevel - 0.25);

  void _goToPreviousPage() {
    if (_currentPage <= 1) return;
    _pdfController.previousPage();
  }

  void _goToNextPage() {
    if (_pageCount == 0 || _currentPage >= _pageCount) return;
    _pdfController.nextPage();
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
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      child: Row(
                        children: [
                          _PdfToolbarButton(
                            icon: Icons.remove_rounded,
                            onTap: _zoomOut,
                          ),
                          const SizedBox(width: 8),
                          _PdfToolbarButton(
                            icon: Icons.add_rounded,
                            onTap: _zoomIn,
                          ),
                          const SizedBox(width: 8),
                          _PdfToolbarButton(
                            icon: Icons.chevron_left_rounded,
                            onTap: _goToPreviousPage,
                          ),
                          const SizedBox(width: 8),
                          _PdfToolbarButton(
                            icon: Icons.chevron_right_rounded,
                            onTap: _goToNextPage,
                          ),
                          const Spacer(),
                          Text(
                            '$_currentPage / $_pageCount',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.divider,
                            width: 0.8,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SfPdfViewer.file(
                            File(_filePath!),
                            controller: _pdfController,
                            canShowPaginationDialog: false,
                            onDocumentLoaded: (details) {
                              if (!mounted) return;
                              setState(() {
                                _pageCount = details.document.pages.count;
                                _documentReady = true;
                              });
                            },
                            onPageChanged: (details) {
                              if (!mounted) return;
                              setState(() => _currentPage = details.newPageNumber);
                            },
                            onZoomLevelChanged: (details) {
                              if (!mounted) return;
                              setState(() => _zoomLevel = details.newZoomLevel);
                            },
                            onDocumentLoadFailed: (details) {
                              if (!mounted) return;
                              setState(() => _error = details.description);
                            },
                          ),
                        ),
                      ),
                    ),
                    if (_documentReady)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Zoom ${(_zoomLevel * 100).round()}%',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _PdfToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PdfToolbarButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 0.8),
          ),
          child: Icon(
            icon,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ),
      ),
    );
  }
}
