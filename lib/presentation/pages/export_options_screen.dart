import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/core/extensions/context_extensions.dart';
import 'dart:ui' as ui;
import 'package:mynotes/presentation/design_system/design_system.dart';
import 'package:mynotes/presentation/bloc/export/export_bloc.dart';
import 'package:mynotes/injection_container.dart' show getIt;

/// ════════════════════════════════════════════════════════════════════════════
/// PHASE 7: EXPORT & SHARING
/// Export Options Screen - Choose export format and settings
/// Uses ExportBloc for state management
/// ════════════════════════════════════════════════════════════════════════════

class ExportOptionsScreen extends StatefulWidget {
  final String? itemTitle;
  final String? itemContent;
  final List<String>? tags;

  const ExportOptionsScreen({
    super.key,
    this.itemTitle,
    this.itemContent,
    this.tags,
  });

  @override
  State<ExportOptionsScreen> createState() => _ExportOptionsScreenState();
}

class _ExportOptionsScreenState extends State<ExportOptionsScreen> {
  String _selectedFormat = 'pdf';
  bool _includeTags = true;
  bool _includeTimestamps = true;
  bool _includeMediaRefs = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ExportBloc>(),
      child: BlocListener<ExportBloc, ExportState>(
        listener: (context, state) {
          if (state is ExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Exported to: ${state.filePath}')),
            );
            Navigator.pop(context, state.filePath);
          } else if (state is ExportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.errorMessage}')),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background(context),
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Export Options'),
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
                        'Choose Export Format',
                        style: AppTypography.heading2(context),
                      ),
                      SizedBox(height: 24.h),
                      _buildFormatOptions(context),
                      SizedBox(height: 32.h),
                      _buildExportOptions(context),
                      SizedBox(height: 32.h),
                      BlocBuilder<ExportBloc, ExportState>(
                        builder: (context, state) {
                          return _buildExportButton(context, state.isLoading);
                        },
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormatOptions(BuildContext context) {
    final formats = [
      {
        'id': 'pdf',
        'name': 'PDF Document',
        'description': 'Professional formatted PDF report',
        'icon': Icons.picture_as_pdf,
      },
      {
        'id': 'markdown',
        'name': 'Markdown File',
        'description': 'Markdown format for editing',
        'icon': Icons.text_fields,
      },
      {
        'id': 'json',
        'name': 'JSON Data',
        'description': 'Structured data format',
        'icon': Icons.code,
      },
    ];

    return Column(
      children: formats.map((format) {
        final isSelected = _selectedFormat == format['id'];
        return GestureDetector(
          onTap: () {
            setState(() => _selectedFormat = format['id'] as String);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: context.theme.cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : context.theme.dividerColor,
                width: isSelected ? 2 : 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  format['icon'] as IconData,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary as Color,
                  size: 24.r,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        format['name'] as String,
                        style: AppTypography.body1(context).copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        format['description'] as String,
                        style: AppTypography.caption(
                          context,
                        ).copyWith(fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 24.r,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExportOptions(BuildContext context) {
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
            'Export Settings',
            style: AppTypography.body1(
              context,
            ).copyWith(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          ..._buildSettingOptions(context),
        ],
      ),
    );
  }

  List<Widget> _buildSettingOptions(BuildContext context) {
    return [
      _buildSettingTile(
        context,
        'Include Tags',
        'Add tags metadata to export',
        Icons.label,
        _includeTags,
        (value) => setState(() => _includeTags = value),
      ),
      SizedBox(height: 12.h),
      _buildSettingTile(
        context,
        'Include Timestamps',
        'Add creation and modification dates',
        Icons.schedule,
        _includeTimestamps,
        (value) => setState(() => _includeTimestamps = value),
      ),
      SizedBox(height: 12.h),
      _buildSettingTile(
        context,
        'Include Media References',
        'Link to attached files and images',
        Icons.attachment,
        _includeMediaRefs,
        (value) => setState(() => _includeMediaRefs = value),
      ),
    ];
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: AppColors.primary),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.body2(context)),
              Text(
                subtitle,
                style: AppTypography.caption(context).copyWith(fontSize: 11.sp),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildExportButton(BuildContext context, bool isExporting) {
    return ElevatedButton.icon(
      onPressed: isExporting ? null : () => _performExport(context),
      icon: isExporting
          ? SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download),
      label: Text(isExporting ? 'Exporting...' : 'Export Now'),
      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 48.h)),
    );
  }

  void _performExport(BuildContext context) {
    final title = widget.itemTitle ?? 'Export';
    final content = widget.itemContent ?? '';

    context.read<ExportBloc>().add(
      ExportCustomContentEvent(
        title: title,
        content: content,
        tags: widget.tags,
        createdDate: DateTime.now(),
        format: _selectedFormat,
        includeTags: _includeTags,
        includeTimestamps: _includeTimestamps,
        includeMediaRefs: _includeMediaRefs,
      ),
    );
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
