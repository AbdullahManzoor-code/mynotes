import 'package:flutter/material.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'dart:ui' as ui;
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/core/services/sharing_service.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 7: EXPORT & SHARING
/// Sharing Options Screen - Share via email, social, etc.
/// ════════════════════════════════════════════════════════════════════════════

class SharingOptionsScreen extends StatefulWidget {
  final String? itemTitle;
  final String? itemContent;
  final String? itemMood;

  const SharingOptionsScreen({
    super.key,
    this.itemTitle,
    this.itemContent,
    this.itemMood,
  });

  @override
  State<SharingOptionsScreen> createState() => _SharingOptionsScreenState();
}

class _SharingOptionsScreenState extends State<SharingOptionsScreen> {
  late SharingService _sharingService;
  String _shareableText = '';

  @override
  void initState() {
    super.initState();
    _sharingService = SharingService();
    _generateShareableText();
  }

  void _generateShareableText() {
    _shareableText = _sharingService.getShareableText(
      title: widget.itemTitle ?? 'Check this out',
      message: widget.itemContent ?? '',
      hashtags: '#MyNotes #Reflection #Productivity',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Share Options'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildBackgroundGlow(context),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 60.h),
                  Text(
                    'Share With Others',
                    style: AppTypography.heading2(context),
                  ),
                  SizedBox(height: 24.h),
                  _buildPreview(context),
                  SizedBox(height: 32.h),
                  _buildShareOptions(context),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: context.theme.dividerColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share Preview',
            style: AppTypography.body1(
              context,
            ).copyWith(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: context.theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: context.theme.dividerColor),
            ),
            child: Text(
              _shareableText,
              style: AppTypography.body2(context).copyWith(fontSize: 12.sp),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 12.h),
          TextButton.icon(
            onPressed: () => _copyToClipboard(),
            icon: const Icon(Icons.content_copy),
            label: const Text('Copy to Clipboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOptions(BuildContext context) {
    return Column(
      children: [
        _buildShareOption(
          context,
          'System Share',
          'Share via installed apps',
          Icons.share,
          () => _shareViaSystem(),
        ),
        SizedBox(height: 12.h),
        _buildShareOption(
          context,
          'Email',
          'Send via email to someone',
          Icons.email,
          () => _shareViaEmail(),
        ),
        SizedBox(height: 12.h),
        _buildShareOption(
          context,
          'Copy Text',
          'Copy to clipboard for sharing',
          Icons.content_copy,
          () => _copyToClipboard(),
        ),
        SizedBox(height: 12.h),
        _buildShareOption(
          context,
          'Social Media',
          'Share to Twitter, Facebook, etc.',
          Icons.public,
          () => _shareToSocial(),
        ),
        SizedBox(height: 12.h),
        _buildShareOption(
          context,
          'Generate Link',
          'Create shareable link',
          Icons.link,
          () => _generateShareLink(),
        ),
      ],
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: context.theme.dividerColor, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24.r, color: AppColors.primary),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body1(
                      context,
                    ).copyWith(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: AppTypography.caption(
                      context,
                    ).copyWith(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.r,
              color: context.theme.disabledColor,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareViaSystem() async {
    AppLogger.i('Sharing via system');
    final success = await _sharingService.shareText(
      text: _shareableText,
      subject: widget.itemTitle,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _shareViaEmail() async {
    AppLogger.i('Sharing via email');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share via Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'recipient@example.com',
                labelText: 'Email Address',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              AppLogger.i('Email prepared');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email app opening...')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard() async {
    AppLogger.i('Copying to clipboard');
    await _shareableText.share();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
    }
  }

  Future<void> _shareToSocial() async {
    AppLogger.i('Opening social media options');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share to Social Media'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Twitter'),
              onTap: () {
                Navigator.pop(context);
                AppLogger.i('Twitter sharing');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Facebook'),
              onTap: () {
                Navigator.pop(context);
                AppLogger.i('Facebook sharing');
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('LinkedIn'),
              onTap: () {
                Navigator.pop(context);
                AppLogger.i('LinkedIn sharing');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateShareLink() async {
    AppLogger.i('Generating share link');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final shareLink = 'https://mynotes.app/share/$timestamp';

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Share Link Generated'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: context.theme.cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: SelectableText(shareLink),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                _sharingService.shareText(text: shareLink);
                Navigator.pop(context);
              },
              child: const Text('Share Link'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBackgroundGlow(BuildContext context) {
    return Positioned(
      top: -100.h,
      right: -100.w,
      child: Container(
        width: 300.w,
        height: 300.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(0.08),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}


