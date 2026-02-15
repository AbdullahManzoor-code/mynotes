import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/injection_container.dart';
import 'package:mynotes/presentation/bloc/template_management/template_management_bloc.dart';
import 'package:mynotes/core/design_system/app_colors.dart';
import 'package:mynotes/core/design_system/app_typography.dart';
import 'package:mynotes/core/design_system/app_spacing.dart';
import 'package:mynotes/core/services/global_ui_service.dart';
import 'package:mynotes/core/utils/app_logger.dart';

/// Template Gallery - Batch 7, Screen 1
/// Refactored to use Design System and optimized UI patterns
class TemplateGalleryScreen extends StatelessWidget {
  const TemplateGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Template Gallery',
          style: AppTypography.displayMedium(context, AppColors.darkText),
        ),
        centerTitle: true,
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkText),
      ),
      body: BlocBuilder<TemplateManagementBloc, TemplateManagementState>(
        builder: (context, state) {
          if (state is! TemplatesLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          return Column(
            children: [
              // Search and Filter Header
              _buildHeader(context, state),

              // Templates Grid
              Expanded(child: _buildTemplatesGrid(context, state)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AppLogger.i(
            'TemplateGalleryScreen: Navigating to create new template',
          );
          // Navigate to editor with new template
          getIt<GlobalUiService>().hapticFeedback();
        },
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TemplatesLoaded state) {
    return Container(
      color: AppColors.lightSurface,
      padding: AppSpacing.paddingAllM,
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              AppLogger.i(
                'TemplateGalleryScreen: Searching templates for "$value"',
              );
              context.read<TemplateManagementBloc>().add(
                SearchTemplatesEvent(value),
              );
            },
            decoration: InputDecoration(
              hintText: 'Search templates...',
              hintStyle: AppTypography.bodySmall(
                context,
                AppColors.tertiaryText,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.tertiaryText,
              ),
              filled: true,
              fillColor: AppColors.lightBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          AppSpacing.gapM,
          _buildCategoryFilter(context, state.selectedCategory),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, String selectedCategory) {
    final categories = ['All', 'Work', 'Personal', 'Health', 'Learning'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((category) {
          final isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  AppLogger.i(
                    'TemplateGalleryScreen: Filtering templates by category $category',
                  );
                  context.read<TemplateManagementBloc>().add(
                    FilterTemplatesEvent(category),
                  );
                  getIt<GlobalUiService>().hapticFeedback();
                }
              },
              backgroundColor: AppColors.lightBackground,
              selectedColor: AppColors.primaryColor,
              labelStyle: AppTypography.labelSmall(
                context,
                isSelected ? Colors.white : AppColors.secondaryText,
                isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              pressElevation: 0,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTemplatesGrid(BuildContext context, TemplatesLoaded state) {
    final templates = state.templates.where((template) {
      final matchesSearch = template.name.toLowerCase().contains(
        state.searchQuery.toLowerCase(),
      );
      final matchesCategory =
          state.selectedCategory == 'All' ||
          template.category == state.selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: AppColors.borderLight,
            ),
            AppSpacing.gapM,
            Text(
              'No templates match your search',
              style: AppTypography.bodyMedium(context, AppColors.secondaryText),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: AppSpacing.paddingAllM,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildTemplateCard(context, template);
      },
    );
  }

  Widget _buildTemplateCard(BuildContext context, dynamic template) {
    final iconColor = _getCategoryColor(template.category);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            AppLogger.i(
              'TemplateGalleryScreen: Tapping template ${template.name}',
            );
            _showTemplatePreview(context, template);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: AppSpacing.paddingAllM,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getTemplateIcon(template.category),
                    size: 48,
                    color: iconColor,
                  ),
                ),
                AppSpacing.gapM,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.name,
                        style: AppTypography.bodyMedium(
                          context,
                          AppColors.darkText,
                          FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        template.category,
                        style: AppTypography.labelSmall(
                          context,
                          AppColors.tertiaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapS,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      AppLogger.i(
                        'TemplateGalleryScreen: Using template ${template.name} from card button',
                      );
                      _useTemplate(context, template);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTemplatePreview(BuildContext context, dynamic template) {
    AppLogger.i('TemplateGalleryScreen: Showing preview for ${template.name}');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AppSpacing.gapL,
            Text(template.name, style: AppTypography.heading1(context)),
            AppSpacing.gapS,
            Text(
              template.category,
              style: AppTypography.labelSmall(
                context,
                AppColors.primaryColor,
                FontWeight.bold,
              ),
            ),
            AppSpacing.gapL,
            Text('Description', style: AppTypography.heading3(context)),
            AppSpacing.gapS,
            Text(
              template.description ?? 'No description provided.',
              style: AppTypography.bodySmall(context, AppColors.secondaryText),
            ),
            AppSpacing.gapL,
            Text('Input Fields', style: AppTypography.heading3(context)),
            AppSpacing.gapM,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ((template.fields ?? []) as List).map((field) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    field['name'] ?? 'Field',
                    style: AppTypography.labelSmall(
                      context,
                      AppColors.darkText,
                    ),
                  ),
                );
              }).toList(),
            ),
            AppSpacing.gapXL,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      AppLogger.i(
                        'TemplateGalleryScreen: Closing preview for ${template.name}',
                      );
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: AppTypography.button(
                        context,
                        AppColors.secondaryText,
                      ),
                    ),
                  ),
                ),
                AppSpacing.gapM,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      AppLogger.i(
                        'TemplateGalleryScreen: Using template ${template.name} from preview',
                      );
                      _useTemplate(context, template);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Use Template',
                      style: AppTypography.button(context, Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _useTemplate(BuildContext context, dynamic template) {
    AppLogger.i('TemplateGalleryScreen: Applying template "${template.name}"');
    context.read<TemplateManagementBloc>().add(
      CreateTemplateEvent(
        name: template.name,
        description: template.description ?? '',
        fields: template.fields ?? [],
        category: template.category,
      ),
    );
    getIt<GlobalUiService>().hapticFeedback();
    getIt<GlobalUiService>().showSuccess('Template "${template.name}" applied');
  }

  IconData _getTemplateIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.business_center_rounded;
      case 'Personal':
        return Icons.face_rounded;
      case 'Health':
        return Icons.favorite_rounded;
      case 'Learning':
        return Icons.school_rounded;
      default:
        return Icons.notes_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return AppColors.primaryColor;
      case 'Personal':
        return Colors.orangeAccent;
      case 'Health':
        return AppColors.successGreen;
      case 'Learning':
        return Colors.purpleAccent;
      default:
        return AppColors.tertiaryText;
    }
  }
}
