import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape;

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
            if (_documentReady)
              Text(
                'Page $_currentPage of $_pageCount',
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
      body: ColoredBox(
        color: Colors.black,
        child: SafeArea(
          top: false,
          child: _buildBody(isLandscape: isLandscape, orientation: orientation),
        ),
      ),
    );
  }

  Widget _buildBody({
    required bool isLandscape,
    required Orientation orientation,
  }) {
    if (_error != null) {
      return Center(
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
      );
    }

    if (_filePath == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewerPadding = EdgeInsets.fromLTRB(
          isLandscape ? 24 : 12,
          isLandscape ? 18 : 12,
          isLandscape ? 24 : 12,
          isLandscape ? 88 : 96,
        );

        final viewerWidth = constraints.maxWidth - viewerPadding.horizontal;
        final viewerHeight = constraints.maxHeight - viewerPadding.vertical;

        final maxViewerWidth = isLandscape
            ? viewerWidth.clamp(360.0, 1080.0)
            : viewerWidth.clamp(260.0, 760.0);
        final maxViewerHeight = isLandscape
            ? viewerHeight.clamp(260.0, 760.0)
            : viewerHeight.clamp(360.0, 1120.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: viewerPadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxViewerWidth,
                    maxHeight: maxViewerHeight,
                  ),
                  child: _ViewerFrame(
                    child: SfPdfViewer.file(
                      File(_filePath!),
                      key: ValueKey(
                        '${_filePath!}_${orientation.name}_${constraints.maxWidth.round()}_${constraints.maxHeight.round()}',
                      ),
                      controller: _pdfController,
                      canShowScrollHead: false,
                      canShowScrollStatus: false,
                      pageLayoutMode: PdfPageLayoutMode.single,
                      scrollDirection: PdfScrollDirection.vertical,
                      maxZoomLevel: 4,
                      enableDoubleTapZooming: true,
                      onDocumentLoaded: (details) {
                        if (!mounted) return;
                        setState(() {
                          _documentReady = true;
                          _pageCount = details.document.pages.count;
                          _currentPage = _pdfController.pageNumber;
                          _zoomLevel = _pdfController.zoomLevel;
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
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: _ViewerControlsBar(
                  canGoPrevious: _currentPage > 1,
                  canGoNext: _pageCount > 0 && _currentPage < _pageCount,
                  canZoomOut: _zoomLevel > 1.0,
                  canZoomIn: _zoomLevel < 4.0,
                  onPreviousPage: _goToPreviousPage,
                  onNextPage: _goToNextPage,
                  onZoomOut: _zoomOut,
                  onZoomIn: _zoomIn,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ViewerFrame extends StatelessWidget {
  final Widget child;

  const _ViewerFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ColoredBox(
          color: Colors.black,
          child: child,
        ),
      ),
    );
  }
}

class _ViewerControlsBar extends StatelessWidget {
  final bool canGoPrevious;
  final bool canGoNext;
  final bool canZoomOut;
  final bool canZoomIn;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;

  const _ViewerControlsBar({
    required this.canGoPrevious,
    required this.canGoNext,
    required this.canZoomOut,
    required this.canZoomIn,
    required this.onPreviousPage,
    required this.onNextPage,
    required this.onZoomOut,
    required this.onZoomIn,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.82),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _ViewerIconButton(
                icon: Icons.chevron_left_rounded,
                tooltip: 'Previous page',
                enabled: canGoPrevious,
                onTap: onPreviousPage,
              ),
              _ViewerIconButton(
                icon: Icons.zoom_out_rounded,
                tooltip: 'Zoom out',
                enabled: canZoomOut,
                onTap: onZoomOut,
              ),
              _ViewerIconButton(
                icon: Icons.zoom_in_rounded,
                tooltip: 'Zoom in',
                enabled: canZoomIn,
                onTap: onZoomIn,
              ),
              _ViewerIconButton(
                icon: Icons.chevron_right_rounded,
                tooltip: 'Next page',
                enabled: canGoNext,
                onTap: onNextPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ViewerIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  const _ViewerIconButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = enabled ? Colors.white : Colors.white.withOpacity(0.28);

    return Material(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: foreground, size: 24),
          ),
        ),
      ),
    );
  }
}
