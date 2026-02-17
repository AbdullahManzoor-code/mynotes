import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../design_system/design_system.dart';

/// Document scan metadata
class ScannedDocument {
  final String filePath;
  final String fileName;
  final List<String> pageImagePaths; // Paths to each scanned page
  final DateTime createdAt;
  final int pageCount;

  ScannedDocument({
    required this.filePath,
    required this.fileName,
    required this.pageImagePaths,
    required this.createdAt,
    required this.pageCount,
  });

  String get formattedDate =>
      '${createdAt.day}/${createdAt.month}/${createdAt.year}';
}

/// Document scanner capture widget with a premium feel
class DocumentScannerWidget extends StatefulWidget {
  final Function(ScannedDocument) onScanComplete;
  final VoidCallback? onCancel;

  const DocumentScannerWidget({
    super.key,
    required this.onScanComplete,
    this.onCancel,
  });

  @override
  State<DocumentScannerWidget> createState() => _DocumentScannerWidgetState();
}

class _DocumentScannerWidgetState extends State<DocumentScannerWidget> {
  final List<String> _scannedPages = [];
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _capturePage() async {
    HapticFeedback.mediumImpact();
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _isProcessing = true;
        });

        // Simulate a "Processing/Optimizing" phase for premium feel
        await Future.delayed(const Duration(milliseconds: 1200));

        if (mounted) {
          setState(() {
            _scannedPages.add(image.path);
            _isProcessing = false;
          });
          HapticFeedback.lightImpact();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removePage(int index) {
    if (index < 0 || index >= _scannedPages.length) return;
    HapticFeedback.selectionClick();
    setState(() {
      _scannedPages.removeAt(index);
    });
  }

  void _completeScan() {
    if (_scannedPages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please scan at least one page'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final document = ScannedDocument(
      filePath: _scannedPages.first,
      fileName: 'Scan_$timestamp.pdf',
      pageImagePaths: List.from(_scannedPages), // Create a copy
      createdAt: DateTime.now(),
      pageCount: _scannedPages.length,
    );

    widget.onScanComplete(document);
  }

  void _cancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBody(),

          // Top Bar
          Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),

          // Bottom Capture Button
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),

          // Processing Overlay
          if (_isProcessing) Positioned.fill(child: _buildProcessingOverlay()),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return GlassContainer(
      blur: 20,
      borderRadius: 0,
      color: Colors.white.withOpacity(0.8),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10.h,
        bottom: 15.h,
        left: 20.w,
        right: 20.w,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.close_rounded), onPressed: _cancel),
          Column(
            children: [
              Text(
                'Document Scan',
                style: AppTypography.heading4(
                  context,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${_scannedPages.length} Pages Captured',
                style: AppTypography.bodySmall(context),
              ),
            ],
          ),
          if (_scannedPages.isNotEmpty)
            _buildDoneButton()
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildDoneButton() {
    return InkWell(
      onTap: _completeScan,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          'Finish',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_scannedPages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppAnimations.tapScale(
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.document_scanner_rounded,
                  size: 60.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text('Ready to scan', style: AppTypography.heading3(context)),
            SizedBox(height: 8.h),
            Text(
              'Position the document within the frame',
              style: AppTypography.bodyMedium(context),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return AppAnimations.tapScale(
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(20.w, 140.h, 20.w, 160.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 16.w,
          childAspectRatio: 0.7,
        ),
        itemCount: _scannedPages.length,
        itemBuilder: (context, index) {
          return _buildPageThumbnail(index);
        },
      ),
    );
  }

  Widget _buildPageThumbnail(int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.textSecondary(context).withOpacity(0.1),
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Image.file(
              File(_scannedPages[index]),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => _removePage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'Page ${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Center(
      child: GestureDetector(
        onTap: _isProcessing ? null : _capturePage,
        child: Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: _isProcessing
                  ? AppColors.primary.withOpacity(0.5)
                  : AppColors.primary,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: _isProcessing
                    ? AppColors.primary.withOpacity(0.5)
                    : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 30.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return GlassContainer(
      blur: 15,
      borderRadius: 0,
      color: Colors.black.withOpacity(0.2),
      child: Center(
        child: GlassContainer(
          borderRadius: 24.r,
          blur: 30,
          color: Colors.white.withOpacity(0.9),
          padding: EdgeInsets.all(40.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 24.h),
              Text(
                'Optimizing Scan...',
                style: AppTypography.heading4(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Text('Sharpening edges', style: AppTypography.bodySmall(context)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Document viewer widget for previewing a scanned document
class DocumentViewerWidget extends StatefulWidget {
  final ScannedDocument document;
  final VoidCallback? onDelete;

  const DocumentViewerWidget({
    super.key,
    required this.document,
    this.onDelete,
  });

  @override
  State<DocumentViewerWidget> createState() => _DocumentViewerWidgetState();
}

class _DocumentViewerWidgetState extends State<DocumentViewerWidget> {
  @override
  void initState() {
    super.initState();
      // Initialize page index in build method
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(vertical: 8.h),
      borderRadius: 20.r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.document.fileName,
                      style: AppTypography.heading4(
                        context,
                      ).copyWith(fontSize: 14.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.document.pageCount} pages • ${widget.document.formattedDate}',
                      style: AppTypography.bodySmall(context),
                    ),
                  ],
                ),
              ),
              if (widget.onDelete != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade400,
                    size: 22.sp,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onDelete!();
                  },
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // Page Preview Slider/Viewer
          SizedBox(
            height: 220.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.document.pageImagePaths.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 160.w,
                  margin: EdgeInsets.only(right: 12.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.textSecondary(context).withOpacity(0.1),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.file(
                      File(widget.document.pageImagePaths[index]),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          if (widget.document.pageCount > 1)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swipe_left_rounded,
                    size: 14.sp,
                    color: AppColors.textSecondary(context),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'Swipe to see all pages',
                    style: AppTypography.bodySmall(context),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Document attachments list
class DocumentAttachmentsList extends StatelessWidget {
  final List<ScannedDocument> documents;
  final Function(int) onDocumentDelete;
  final Function(int)? onDocumentTap;

  const DocumentAttachmentsList({
    super.key,
    required this.documents,
    required this.onDocumentDelete,
    this.onDocumentTap,
  });

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppAnimations.tapScale(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h, top: 16.h),
            child: Text(
              'Scanned Documents',
              style: AppTypography.heading4(context).copyWith(
                color: AppColors.textSecondary(context),
                letterSpacing: 0.5,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: documents.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: onDocumentTap != null
                    ? () => onDocumentTap!(index)
                    : null,
                child: DocumentViewerWidget(
                  document: documents[index],
                  onDelete: () => onDocumentDelete(index),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
