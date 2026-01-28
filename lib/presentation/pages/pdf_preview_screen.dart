import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/note.dart';

/// PDF Preview Screen
/// Shows PDF preview before exporting and sharing
class PdfPreviewScreen extends StatefulWidget {
  final Note note;
  final String? pdfPath;

  const PdfPreviewScreen({super.key, required this.note, this.pdfPath});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  bool _isExporting = false;
  bool _includeMedia = true;
  String? _exportedPdfPath;

  @override
  void initState() {
    super.initState();
    _exportedPdfPath = widget.pdfPath;
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);

    try {
      // TODO: Integrate with PdfExportService
      await Future.delayed(const Duration(seconds: 2)); // Simulate export

      // Mock PDF path
      final pdfPath = '/storage/emulated/0/Download/${widget.note.title}.pdf';

      setState(() {
        _exportedPdfPath = pdfPath;
        _isExporting = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF exported to $pdfPath'),
          action: SnackBarAction(label: 'Share', onPressed: _sharePdf),
        ),
      );
    } catch (e) {
      setState(() => _isExporting = false);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _sharePdf() async {
    if (_exportedPdfPath == null) {
      await _exportPdf();
      return;
    }

    try {
      await Share.shareXFiles([
        XFile(_exportedPdfPath!),
      ], text: 'Check out my note: ${widget.note.title}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isExporting ? null : _sharePdf,
          ),
        ],
      ),
      body: Column(
        children: [
          // Options
          _buildOptions(),

          const Divider(height: 1),

          // Preview
          Expanded(
            child: _isExporting
                ? _buildExportingState()
                : _exportedPdfPath != null
                ? _buildPdfPreview()
                : _buildNoPreview(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Options',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _includeMedia,
            onChanged: (value) {
              setState(() => _includeMedia = value);
            },
            title: const Text('Include media'),
            subtitle: Text(
              _includeMedia
                  ? 'Images and videos will be embedded'
                  : 'Only text content will be exported',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            activeColor: AppColors.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPdfPreview() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 8,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  widget.note.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Content preview
                Text(
                  widget.note.content.isEmpty
                      ? 'No content'
                      : widget.note.content,
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Media count
                if (_includeMedia && widget.note.hasMedia) ...[
                  Row(
                    children: [
                      const Icon(Icons.image, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.note.media.length} media items',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.infoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.infoColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is a preview. Actual PDF will have better formatting.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No PDF generated yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap Export to generate PDF',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildExportingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Generating PDF...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _includeMedia
                ? 'Embedding media files...'
                : 'Formatting text content...',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isExporting ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportPdf,
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.file_download),
                label: Text(_isExporting ? 'Exporting...' : 'Export PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
