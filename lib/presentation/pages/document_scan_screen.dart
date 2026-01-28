import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../presentation/design_system/app_colors.dart';
import '../../presentation/design_system/app_typography.dart';
import '../../presentation/design_system/app_spacing.dart';

/// Document Scan and OCR Screen
/// Capture documents and extract text using OCR
class DocumentScanScreen extends StatefulWidget {
  const DocumentScanScreen({super.key});

  @override
  State<DocumentScanScreen> createState() => _DocumentScanScreenState();
}

class _DocumentScanScreenState extends State<DocumentScanScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  File? _capturedImage;
  String _extractedText = '';
  bool _isProcessing = false;
  final bool _showPreview = false;

  late AnimationController _scanAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _scanAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _scanAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.textPrimary(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Document Scanner',
          style: AppTypography.heading2(
            context,
            AppColors.textPrimary(context),
          ),
        ),
        actions: [
          if (_extractedText.isNotEmpty)
            IconButton(
              icon: Icon(Icons.save_outlined, color: AppColors.primaryColor),
              onPressed: _saveAsNote,
            ),
        ],
      ),
      body: _buildBody(isDark),
      floatingActionButton: _capturedImage == null
          ? FloatingActionButton.extended(
              onPressed: _showCaptureOptions,
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.camera_alt),
              label: Text(
                'Scan Document',
                style: AppTypography.button(context, Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(bool isDark) {
    if (_capturedImage == null) {
      return _buildWelcomeView(isDark);
    } else if (_isProcessing) {
      return _buildProcessingView(isDark);
    } else {
      return _buildResultsView(isDark);
    }
  }

  Widget _buildWelcomeView(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          SizedBox(height: AppSpacing.xxl),

          // Illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Icon(
              Icons.document_scanner_outlined,
              size: 80,
              color: AppColors.primaryColor,
            ),
          ),

          SizedBox(height: AppSpacing.xxl),

          Text(
            'Scan Documents',
            style: AppTypography.titleLarge(
              context,
              AppColors.textPrimary(context),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.lg),

          Text(
            'Transform physical documents into searchable digital notes with OCR technology',
            style: AppTypography.bodyMedium(
              context,
              AppColors.textSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.xxl),

          // Features
          _buildFeatureItem(
            Icons.camera_alt_outlined,
            'Smart Capture',
            'Auto-detect document edges and enhance image quality',
          ),

          SizedBox(height: AppSpacing.lg),

          _buildFeatureItem(
            Icons.text_fields_outlined,
            'Text Recognition',
            'Extract text from images with high accuracy OCR',
          ),

          SizedBox(height: AppSpacing.lg),

          _buildFeatureItem(
            Icons.edit_outlined,
            'Edit & Save',
            'Review, edit, and save as searchable notes',
          ),

          SizedBox(height: AppSpacing.xxl),

          // Tips
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Tips for better scans',
                      style: AppTypography.bodyLarge(
                        context,
                        AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  '• Ensure good lighting\n• Hold device steady\n• Position document flat\n• Avoid shadows and glare',
                  style: AppTypography.bodyMedium(
                    context,
                    AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Scanning Animation
          AnimatedBuilder(
            animation: _scanAnimationController,
            builder: (context, child) {
              return SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  children: [
                    // Background circle
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryColor.withOpacity(0.1),
                      ),
                    ),
                    // Animated scanning line
                    Positioned(
                      top: 200 * _scanAnimation.value - 2,
                      left: 20,
                      right: 20,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Center icon
                    Center(
                      child: Icon(
                        Icons.document_scanner,
                        size: 60,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: AppSpacing.xxl),

          Text(
            'Processing Document...',
            style: AppTypography.heading3(
              context,
              AppColors.textPrimary(context),
            ),
          ),

          SizedBox(height: AppSpacing.sm),

          Text(
            'Extracting text with OCR technology',
            style: AppTypography.bodyMedium(
              context,
              AppColors.textSecondary(context),
            ),
          ),

          SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: AppColors.primaryColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Preview
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(
                color: AppColors.textSecondary(context).withOpacity(0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              child: Image.file(_capturedImage!, fit: BoxFit.cover),
            ),
          ),

          SizedBox(height: AppSpacing.xl),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _retakePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Retake'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary(context),
                    side: BorderSide(
                      color: AppColors.textSecondary(context).withOpacity(0.3),
                    ),
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _copyText,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Text'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.xl),

          // Extracted Text
          Text(
            'Extracted Text',
            style: AppTypography.heading3(
              context,
              AppColors.textPrimary(context),
            ),
          ),

          SizedBox(height: AppSpacing.lg),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCardBackground
                  : AppColors.lightCardBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(
                color: AppColors.textSecondary(context).withOpacity(0.2),
              ),
            ),
            child: _extractedText.isEmpty
                ? Text(
                    'No text detected in the document. Try capturing again with better lighting.',
                    style: AppTypography.bodyMedium(
                      context,
                      AppColors.textSecondary(context),
                    ),
                  )
                : SelectableText(
                    _extractedText,
                    style: AppTypography.bodyMedium(
                      context,
                      AppColors.textPrimary(context),
                    ),
                  ),
          ),

          if (_extractedText.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xl),

            // Save Options
            Text(
              'Save Options',
              style: AppTypography.heading4(
                context,
                AppColors.textPrimary(context),
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveAsNote,
                icon: const Icon(Icons.note_add),
                label: const Text('Save as Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 24),
        ),
        SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyLarge(
                  context,
                  AppColors.textPrimary(context),
                ),
              ),
              Text(
                description,
                style: AppTypography.caption(
                  context,
                  AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCaptureOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _CaptureOptionsSheet(
        onCameraPressed: () {
          Navigator.pop(context);
          _captureFromCamera();
        },
        onGalleryPressed: () {
          Navigator.pop(context);
          _captureFromGallery();
        },
      ),
    );
  }

  Future<void> _captureFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
          _isProcessing = true;
        });

        _scanAnimationController.repeat();
        await _processImage();
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  Future<void> _captureFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
          _isProcessing = true;
        });

        _scanAnimationController.repeat();
        await _processImage();
      }
    } catch (e) {
      _showError('Failed to load image: $e');
    }
  }

  Future<void> _processImage() async {
    try {
      // Simulate OCR processing
      await Future.delayed(const Duration(seconds: 3));

      // Mock extracted text - replace with actual OCR implementation
      const mockText = '''Sample extracted text from the scanned document.

This is where the OCR technology would extract the text content from the captured image. The text recognition would identify:

• Headers and titles
• Body paragraphs
• Lists and bullet points
• Tables and structured data

The accuracy depends on image quality, lighting conditions, and font clarity.''';

      setState(() {
        _extractedText = mockText;
        _isProcessing = false;
      });

      _scanAnimationController.stop();
      _fadeAnimationController.forward();
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _scanAnimationController.stop();
      _showError('Failed to process image: $e');
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _extractedText = '';
      _isProcessing = false;
    });
    _scanAnimationController.reset();
    _fadeAnimationController.reset();
  }

  void _copyText() {
    if (_extractedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _extractedText));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Text copied to clipboard'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    }
  }

  void _saveAsNote() {
    if (_extractedText.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/note-editor',
        arguments: {
          'title': 'Scanned Document',
          'content': _extractedText,
          'image': _capturedImage?.path,
        },
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.errorColor),
    );
  }
}

class _CaptureOptionsSheet extends StatelessWidget {
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;

  const _CaptureOptionsSheet({
    required this.onCameraPressed,
    required this.onGalleryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCardBackground
            : AppColors.lightCardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusLG),
          topRight: Radius.circular(AppSpacing.radiusLG),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary(context).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          SizedBox(height: AppSpacing.xl),

          Text(
            'Capture Document',
            style: AppTypography.heading2(
              context,
              AppColors.textPrimary(context),
            ),
          ),

          SizedBox(height: AppSpacing.xl),

          // Camera Option
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              ),
              child: Icon(Icons.camera_alt, color: AppColors.primaryColor),
            ),
            title: Text(
              'Take Photo',
              style: AppTypography.bodyLarge(
                context,
                AppColors.textPrimary(context),
              ),
            ),
            subtitle: Text(
              'Capture document with camera',
              style: AppTypography.caption(
                context,
                AppColors.textSecondary(context),
              ),
            ),
            onTap: onCameraPressed,
          ),

          // Gallery Option
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
              ),
              child: Icon(Icons.photo_library, color: AppColors.accentGreen),
            ),
            title: Text(
              'Choose from Gallery',
              style: AppTypography.bodyLarge(
                context,
                AppColors.textPrimary(context),
              ),
            ),
            subtitle: Text(
              'Select existing image',
              style: AppTypography.caption(
                context,
                AppColors.textSecondary(context),
              ),
            ),
            onTap: onGalleryPressed,
          ),

          SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
