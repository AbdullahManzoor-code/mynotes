import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system/design_system.dart';

/// OCR Text Extraction Screen
/// Shows extracted text from scanned documents with editing capabilities
class OcrTextExtractionScreen extends StatefulWidget {
  final String? documentImagePath;
  final String? extractedText;

  const OcrTextExtractionScreen({
    super.key,
    this.documentImagePath,
    this.extractedText,
  });

  @override
  State<OcrTextExtractionScreen> createState() =>
      _OcrTextExtractionScreenState();
}

class _OcrTextExtractionScreenState extends State<OcrTextExtractionScreen> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    AppLogger.i('OcrTextExtractionScreen: initState');
    _textController = TextEditingController(
      text: widget.extractedText ?? _getDefaultText(),
    );
  }

  @override
  void dispose() {
    AppLogger.i('OcrTextExtractionScreen: dispose');
    _textController.dispose();
    super.dispose();
  }

  String _getDefaultText() {
    return '''Annual Strategy Meeting Notes
October 14, 2023

1. Q4 Goals:
- Increase user retention by 15%
- Launch 'Calm Productivity' features
- Optimize mobile OCR engine

2. Action Items:
- Sarah: Finalize UI mocks
- David: Database migration
- Jenny: User feedback survey

Next Meeting: Tuesday at 10 AM''';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: _buildTopAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDocumentPreview(),
                SizedBox(height: 24.h),
                _buildExtractedTextSection(),
                SizedBox(height: 16.h),
                _buildPrivacyBadge(),
                SizedBox(height: 140.h), // Space for bottom actions
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActions(context),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTopAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'OCR Extraction',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor.withOpacity(0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 56,
      leading: Container(
        margin: EdgeInsets.only(left: 16.w),
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 24,
        ),
      ),
    );
  }

  Widget _buildDocumentPreview() {
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Document image or placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: widget.documentImagePath != null
                ? Image.asset(
                    widget.documentImagePath!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildDocumentPlaceholder(),
                  )
                : _buildDocumentPlaceholder(),
          ),
          // Selection overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.4),
                width: 2,
              ),
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPlaceholder() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final surfaceColor = isDark
            ? Colors.grey.shade800
            : Colors.grey.shade100;
        final textColor =
            theme.textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [surfaceColor.withOpacity(0.8), surfaceColor],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.document_scanner_outlined,
                size: 48.sp,
                color: textColor,
              ),
              SizedBox(height: 8.h),
              Text(
                'Scanned Document',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExtractedTextSection() {
    return Column(
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Extracted Text',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            TextButton(
              onPressed: _copyAllText,
              child: Text(
                'Copy All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // Text Field
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade700
                  : Colors.grey.shade300,
            ),
          ),
          child: TextFormField(
            controller: _textController,
            maxLines: null,
            minLines: 12,
            decoration: InputDecoration(
              hintText: 'Extracted text will appear here...',
              hintStyle: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(16.w),
              filled: true,
              fillColor: Colors.transparent,
            ),
            style: TextStyle(fontSize: 16.sp, height: 1.5, fontFamily: 'Inter'),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyBadge() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 16.sp,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
          ),
          SizedBox(width: 6.w),
          Text(
            'Processed on-device for privacy',
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700.withOpacity(0.5)
                : Colors.grey.shade300.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Insert into Note Button
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton.icon(
              onPressed: _insertIntoNote,
              icon: const Icon(Icons.note_add_outlined),
              label: const Text(
                'Insert into Note',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withOpacity(0.3),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Retake Photo Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton.icon(
              onPressed: _retakePhoto,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text(
                'Retake Photo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyAllText() {
    AppLogger.i('OcrTextExtractionScreen: Copying extracted text');
    Clipboard.setData(ClipboardData(text: _textController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Text copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _insertIntoNote() {
    AppLogger.i('OcrTextExtractionScreen: Inserting into note');
    // Navigate back with extracted text
    Navigator.pop(context, {
      'extractedText': _textController.text,
      'action': 'insert',
    });
  }

  void _retakePhoto() {
    AppLogger.i('OcrTextExtractionScreen: Retaking photo');
    Navigator.pop(context, {'action': 'retake'});
  }
}
