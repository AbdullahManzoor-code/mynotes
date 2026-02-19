import 'package:flutter/material.dart';
import 'package:mynotes/core/utils/url_validator_util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../design_system/app_colors.dart';

/// Link preview metadata (from OpenGraph)
class LinkPreview {
  final String url;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? faviconUrl;
  final DateTime createdAt;

  LinkPreview({
    required this.url,
    required this.title,
    this.description,
    this.imageUrl,
    this.faviconUrl,
    required this.createdAt,
  });

  String get domain {
    try {
      return Uri.parse(url).host.replaceFirst('www.', '');
    } catch (e) {
      return 'Link';
    }
  }

  bool get isValidUrl => UrlValidatorUtil.isValidUrl(url);

  static String normalizeUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }

  static String getDisplayUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceFirst('www.', '');
    } catch (e) {
      return 'Link';
    }
  }
}

/// Link preview widget (card style)
class LinkPreviewWidget extends StatelessWidget {
  final LinkPreview link;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const LinkPreviewWidget({
    super.key,
    required this.link,
    this.onTap,
    this.onDelete,
  });

  void _openLink() async {
    if (await canLaunchUrl(Uri.parse(link.url))) {
      await launchUrl(
        Uri.parse(link.url),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBackground : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? _openLink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Image with gradient overlay
            if (link.imageUrl != null && link.imageUrl!.isNotEmpty)
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: link.imageUrl!,
                    height: 160.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 160.h,
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withOpacity(0.05),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 160.h,
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withOpacity(0.05),
                      child: const Center(child: Icon(Icons.link_off)),
                    ),
                  ),
                  // Optional: Subtle gradient overlay for better text readability
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Domain and favicon
                  Row(
                    children: [
                      if (link.faviconUrl != null &&
                          link.faviconUrl!.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: link.faviconUrl!,
                          width: 18.w,
                          height: 18.w,
                          placeholder: (context, url) =>
                              Icon(Icons.language, size: 18.sp),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.language, size: 18.sp),
                        )
                      else
                        Icon(
                          Icons.language,
                          size: 18.sp,
                          color: isDark
                              ? AppColors.linkColorDark
                              : AppColors.linkColorLight,
                        ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          link.domain,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: isDark
                                    ? AppColors.secondaryTextDark
                                    : AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      if (onDelete != null)
                        SizedBox(
                          width: 28.w,
                          height: 28.w,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.close_rounded,
                              size: 18.sp,
                              color: isDark
                                  ? Colors.white.withOpacity(0.6)
                                  : Colors.grey.shade500,
                            ),
                            onPressed: onDelete,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Title
                  Text(
                    link.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Description
                  if (link.description != null &&
                      link.description!.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      link.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.secondaryTextDark.withOpacity(0.8)
                            : AppColors.textMuted,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Link input field with validation
class LinkInputField extends StatefulWidget {
  final Function(LinkPreview) onLinkAdded;
  final VoidCallback? onCancel;

  const LinkInputField({super.key, required this.onLinkAdded, this.onCancel});

  @override
  State<LinkInputField> createState() => _LinkInputFieldState();
}

class _LinkInputFieldState extends State<LinkInputField> {
  late TextEditingController _controller;
  String? _urlError;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _validateAndAdd() async {
    final url = _controller.text.trim();

    if (url.isEmpty) {
      setState(() => _urlError = 'Please enter a URL');
      return;
    }

    if (!UrlValidatorUtil.isValidUrl(url) &&
        !UrlValidatorUtil.isValidUrl(UrlValidatorUtil.normalizeUrl(url))) {
      setState(() => _urlError = 'Invalid URL format');
      return;
    }

    setState(() {
      _urlError = null;
      _isLoading = true;
    });

    try {
      final normalizedUrl = UrlValidatorUtil.normalizeUrl(url);

      // In a real app, we would use AnyLinkPreview to fetch metadata

      final preview = LinkPreview(
        url: normalizedUrl,
        title: UrlValidatorUtil.getDisplayUrl(normalizedUrl),
        description: 'Link preview',
        createdAt: DateTime.now(),
      );

      widget.onLinkAdded(preview);
      _controller.clear();

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _urlError = 'Failed to fetch link preview';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Paste link URL',
            prefixIcon: const Icon(Icons.link),
            suffixIcon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            errorText: _urlError,
          ),
          onSubmitted: (_) => _validateAndAdd(),
          enabled: !_isLoading,
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.onCancel != null)
              TextButton(onPressed: widget.onCancel, child: Text('Cancel')),
            SizedBox(width: 8.w),
            FilledButton.icon(
              onPressed: _isLoading ? null : _validateAndAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Link'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Link attachments list
class LinkAttachmentsList extends StatelessWidget {
  final List<LinkPreview> links;
  final Function(int) onLinkDelete;
  final Function(int)? onLinkTap;

  const LinkAttachmentsList({
    super.key,
    required this.links,
    required this.onLinkDelete,
    this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Links',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: links.length,
          separatorBuilder: (_, __) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            return LinkPreviewWidget(
              link: links[index],
              onTap: onLinkTap != null ? () => onLinkTap!(index) : null,
              onDelete: () => onLinkDelete(index),
            );
          },
        ),
      ],
    );
  }
}


