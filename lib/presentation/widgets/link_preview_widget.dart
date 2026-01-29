import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool get isValidUrl {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }
}

/// URL validator
class UrlValidator {
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.startsWith('http://') || url.startsWith('https://');
    } catch (e) {
      return false;
    }
  }

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
    Key? key,
    required this.link,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

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
    return GestureDetector(
      onTap: onTap ?? _openLink,
      child: Card(
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            if (link.imageUrl != null)
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  image: DecorationImage(
                    image: NetworkImage(link.imageUrl!),
                    fit: BoxFit.cover,
                    onError: (_, __) => Text('Error loading image'),
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Domain and favicon
                  Row(
                    children: [
                      if (link.faviconUrl != null)
                        Image.network(
                          link.faviconUrl!,
                          width: 16,
                          height: 16,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.language, size: 16),
                        )
                      else
                        Icon(Icons.language, size: 16),
                      SizedBox(width: 8),
                      Text(
                        link.domain,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Title
                  Text(
                    link.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Description
                  if (link.description != null) ...[
                    SizedBox(height: 6),
                    Text(
                      link.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // URL and delete button
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          link.url,
                          style: Theme.of(context).textTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onDelete != null)
                        IconButton(
                          icon: Icon(Icons.close, size: 18),
                          onPressed: onDelete,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(minWidth: 32),
                        ),
                    ],
                  ),
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

  const LinkInputField({Key? key, required this.onLinkAdded, this.onCancel})
    : super(key: key);

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

    if (!UrlValidator.isValidUrl(url) &&
        !UrlValidator.isValidUrl(UrlValidator.normalizeUrl(url))) {
      setState(() => _urlError = 'Invalid URL format');
      return;
    }

    setState(() {
      _urlError = null;
      _isLoading = true;
    });

    try {
      final normalizedUrl = UrlValidator.normalizeUrl(url);

      // Mock OpenGraph fetch (in real app, use http package to fetch metadata)
      final preview = LinkPreview(
        url: normalizedUrl,
        title: UrlValidator.getDisplayUrl(normalizedUrl),
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
          decoration: InputDecoration(
            hintText: 'Paste link URL',
            prefixIcon: Icon(Icons.link),
            suffixIcon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorText: _urlError,
          ),
          onSubmitted: (_) => _validateAndAdd(),
          enabled: !_isLoading,
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.onCancel != null)
              TextButton(onPressed: widget.onCancel, child: Text('Cancel')),
            SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _isLoading ? null : _validateAndAdd,
              icon: Icon(Icons.add),
              label: Text('Add Link'),
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
    Key? key,
    required this.links,
    required this.onLinkDelete,
    this.onLinkTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Links', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: links.length,
          separatorBuilder: (_, __) => SizedBox(height: 8),
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
