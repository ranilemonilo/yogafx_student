import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart';
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
  int? _totalPages;
  int _currentPage = 0;
  PDFViewController? _pdfController;
  FitPolicy _fitPolicy = FitPolicy.BOTH;

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

  Future<void> _setFitPolicy(FitPolicy nextPolicy) async {
    if (_fitPolicy == nextPolicy) return;
    final currentPage = _currentPage;
    setState(() => _fitPolicy = nextPolicy);

    // Tunggu viewer re-create setelah key berubah, lalu kembalikan posisi halaman.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      final controller = _pdfController;
      if (controller == null) return;
      await controller.setPage(currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape;
    final maxViewerWidth = isLandscape ? 980.0 : 720.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_filePath != null && _totalPages != null)
              Text(
                'Page ${_currentPage + 1} of $_totalPages',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
          ],
        ),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        color: Colors.black,
        padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? 24 : 12,
          vertical: isLandscape ? 16 : 12,
        ),
        child: _error != null
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
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final maxViewerHeight = isLandscape
                          ? constraints.maxHeight * 0.9
                          : constraints.maxHeight * 0.94;

                      return Stack(
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: maxViewerWidth,
                                maxHeight: maxViewerHeight,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: PDFView(
                                    key: ValueKey(
                                      '${_filePath!}_${orientation.name}_${_fitPolicy.name}_${_currentPage}',
                                    ),
                                    filePath: _filePath!,
                                    backgroundColor: Colors.black,
                                    autoSpacing: true,
                                    pageFling: true,
                                    pageSnap: true,
                                    defaultPage: _currentPage,
                                    fitPolicy: _fitPolicy,
                                    onViewCreated: (controller) {
                                      _pdfController = controller;
                                    },
                                    onRender: (pages) {
                                      if (!mounted) return;
                                      setState(() {
                                        _totalPages = pages;
                                        _currentPage = _currentPage.clamp(
                                          0,
                                          (pages ?? 1) - 1,
                                        );
                                      });
                                    },
                                    onPageChanged: (page, _) {
                                      if (!mounted || page == null) return;
                                      setState(() => _currentPage = page);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: SafeArea(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _PdfZoomButton(
                                icon: Icons.zoom_out_rounded,
                                tooltip: 'Zoom out',
                                onTap: () => _setFitPolicy(FitPolicy.HEIGHT),
                              ),
                              const SizedBox(width: 10),
                              _PdfZoomButton(
                                icon: Icons.fit_screen_rounded,
                                tooltip: 'Fit page',
                                onTap: () => _setFitPolicy(FitPolicy.BOTH),
                              ),
                              const SizedBox(width: 10),
                              _PdfZoomButton(
                                icon: Icons.zoom_in_rounded,
                                tooltip: 'Zoom in',
                                onTap: () => _setFitPolicy(FitPolicy.WIDTH),
                              ),
                            ],
                          ),
                        ),
                          ),
                        ],
                      );
                    },
                  ),
      ),
    );
  }
}

class _PdfZoomButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _PdfZoomButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.72),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
