import 'package:flutter/material.dart';
import 'package:mynotes/injection_container.dart';
import '../../core/services/global_ui_service.dart';

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
      '${createdAt.month}/${createdAt.day}/${createdAt.year}';
}

/// Document scanner capture widget
class DocumentScannerWidget extends StatefulWidget {
  final Function(ScannedDocument) onScanComplete;
  final VoidCallback? onCancel;

  const DocumentScannerWidget({
    Key? key,
    required this.onScanComplete,
    this.onCancel,
  }) : super(key: key);

  @override
  State<DocumentScannerWidget> createState() => _DocumentScannerWidgetState();
}

class _DocumentScannerWidgetState extends State<DocumentScannerWidget> {
  List<String> _scannedPages = [];
  bool _isScanning = false;

  void _addPage() {
    setState(() {
      _isScanning = true;
    });

    // Simulate camera capture
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          _scannedPages.add('/tmp/scan_page_${_scannedPages.length}.jpg');
          _isScanning = false;
        });
      }
    });
  }

  void _removePage(int index) {
    setState(() {
      _scannedPages.removeAt(index);
    });
  }

  void _completeScan() {
    if (_scannedPages.isEmpty) {
      getIt<GlobalUiService>().showWarning('Please scan at least one page');
      return;
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final document = ScannedDocument(
      filePath: '/tmp/scan_$timestamp.pdf',
      fileName: 'Scan_$timestamp.pdf',
      pageImagePaths: _scannedPages,
      createdAt: DateTime.now(),
      pageCount: _scannedPages.length,
    );

    widget.onScanComplete(document);
  }

  void _cancel() {
    setState(() {
      _scannedPages.clear();
    });
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document Scanner',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_scannedPages.length} page(s)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: _cancel,
              ),
            ],
          ),
        ),

        // Scanner preview area
        Expanded(
          child: _scannedPages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.document_scanner,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No pages scanned yet',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _scannedPages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 32),
                              SizedBox(height: 8),
                              Text('Page ${index + 1}'),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -8,
                          right: -8,
                          child: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 14,
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 12,
                              ),
                              onPressed: () => _removePage(index),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),

        // Bottom controls
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: _cancel,
                icon: Icon(Icons.close),
                label: Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: _isScanning ? null : _addPage,
                icon: _isScanning
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Icon(Icons.camera_alt),
                label: Text(_isScanning ? 'Scanning...' : 'Scan Page'),
              ),
              FilledButton.icon(
                onPressed: _scannedPages.isEmpty ? null : _completeScan,
                icon: Icon(Icons.check),
                label: Text('Done'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Document viewer widget
class DocumentViewerWidget extends StatefulWidget {
  final ScannedDocument document;
  final VoidCallback? onDelete;

  const DocumentViewerWidget({Key? key, required this.document, this.onDelete})
    : super(key: key);

  @override
  State<DocumentViewerWidget> createState() => _DocumentViewerWidgetState();
}

class _DocumentViewerWidgetState extends State<DocumentViewerWidget> {
  late int _currentPageIndex;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with filename
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.document.fileName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${widget.document.pageCount} page(s) • ${widget.document.formattedDate}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (widget.onDelete != null)
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: widget.onDelete,
              ),
          ],
        ),

        SizedBox(height: 12),

        // Document preview
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description, size: 40),
              SizedBox(height: 8),
              Text(
                'Page ${_currentPageIndex + 1} of ${widget.document.pageCount}',
              ),
            ],
          ),
        ),

        SizedBox(height: 12),

        // Page navigation
        if (widget.document.pageCount > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _currentPageIndex > 0
                    ? () => setState(() => _currentPageIndex--)
                    : null,
              ),
              Text(
                '${_currentPageIndex + 1} / ${widget.document.pageCount}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: _currentPageIndex < widget.document.pageCount - 1
                    ? () => setState(() => _currentPageIndex++)
                    : null,
              ),
            ],
          ),
      ],
    );
  }
}

/// Document attachments list
class DocumentAttachmentsList extends StatelessWidget {
  final List<ScannedDocument> documents;
  final Function(int) onDocumentDelete;
  final Function(int)? onDocumentTap;

  const DocumentAttachmentsList({
    Key? key,
    required this.documents,
    required this.onDocumentDelete,
    this.onDocumentTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scanned Documents',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: documents.length,
          separatorBuilder: (_, __) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: onDocumentTap != null ? () => onDocumentTap!(index) : null,
              child: DocumentViewerWidget(
                document: documents[index],
                onDelete: () => onDocumentDelete(index),
              ),
            );
          },
        ),
      ],
    );
  }
}
