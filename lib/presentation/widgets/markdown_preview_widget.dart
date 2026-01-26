import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Markdown Preview Widget
/// Renders markdown-formatted text with basic styling
class MarkdownPreviewWidget extends StatelessWidget {
  final String content;
  final bool isDark;

  const MarkdownPreviewWidget({
    Key? key,
    required this.content,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _parseMarkdown(content, context),
      ),
    );
  }

  List<Widget> _parseMarkdown(String text, BuildContext context) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Headers
      if (line.startsWith('# ')) {
        widgets.add(_buildHeader(line.substring(2), 1, context));
      } else if (line.startsWith('## ')) {
        widgets.add(_buildHeader(line.substring(3), 2, context));
      } else if (line.startsWith('### ')) {
        widgets.add(_buildHeader(line.substring(4), 3, context));
      }
      // Bold
      else if (line.startsWith('**') && line.endsWith('**')) {
        widgets.add(_buildBold(line.substring(2, line.length - 2), context));
      }
      // Checkbox items
      else if (line.trim().startsWith('- [ ]')) {
        widgets.add(
          _buildCheckbox(line.replaceFirst('- [ ]', '').trim(), false, context),
        );
      } else if (line.trim().startsWith('- [x]')) {
        widgets.add(
          _buildCheckbox(line.replaceFirst('- [x]', '').trim(), true, context),
        );
      }
      // Bullet points
      else if (line.trim().startsWith('- ')) {
        widgets.add(_buildBullet(line.replaceFirst('- ', '').trim(), context));
      }
      // Numbered lists
      else if (RegExp(r'^\d+\. ').hasMatch(line.trim())) {
        widgets.add(
          _buildNumbered(
            line.replaceFirst(RegExp(r'^\d+\. '), '').trim(),
            context,
          ),
        );
      }
      // Quote
      else if (line.startsWith('> ')) {
        widgets.add(_buildQuote(line.substring(2), context));
      }
      // Horizontal rule
      else if (line.trim() == '---') {
        widgets.add(_buildDivider());
      }
      // Regular text
      else if (line.trim().isNotEmpty) {
        widgets.add(_buildText(_parseInlineMarkdown(line), context));
      }
      // Empty line (spacing)
      else {
        widgets.add(SizedBox(height: 8.h));
      }
    }

    return widgets;
  }

  Widget _buildHeader(String text, int level, BuildContext context) {
    double fontSize;
    switch (level) {
      case 1:
        fontSize = 28.sp;
        break;
      case 2:
        fontSize = 24.sp;
        break;
      default:
        fontSize = 20.sp;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildBold(String text, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildText(String text, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          color: isDark ? Colors.white70 : Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBullet(String text, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, top: 4.h, bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 16.sp)),
          Expanded(
            child: Text(
              _parseInlineMarkdown(text),
              style: TextStyle(
                fontSize: 16.sp,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumbered(String text, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, top: 4.h, bottom: 4.h),
      child: Text(
        _parseInlineMarkdown(text),
        style: TextStyle(
          fontSize: 16.sp,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCheckbox(String text, bool checked, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, top: 4.h, bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            size: 20.sp,
            color: checked ? Colors.green : Colors.grey,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              _parseInlineMarkdown(text),
              style: TextStyle(
                fontSize: 16.sp,
                color: isDark ? Colors.white70 : Colors.black87,
                decoration: checked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuote(String text, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        border: Border(
          left: BorderSide(
            color: isDark ? Colors.blue : Colors.blue[700]!,
            width: 4,
          ),
        ),
      ),
      child: Text(
        _parseInlineMarkdown(text),
        style: TextStyle(
          fontSize: 16.sp,
          fontStyle: FontStyle.italic,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Divider(
        color: isDark ? Colors.grey[700] : Colors.grey[300],
        thickness: 1,
      ),
    );
  }

  String _parseInlineMarkdown(String text) {
    // Remove inline markdown for now (bold, italic)
    // In a full implementation, you'd use RichText with TextSpans
    return text
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1') // Bold
        .replaceAll(RegExp(r'\*(.+?)\*'), r'$1') // Italic
        .replaceAll(RegExp(r'`(.+?)`'), r'$1'); // Code
  }
}
