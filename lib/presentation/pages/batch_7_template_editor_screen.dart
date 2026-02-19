import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/injection_container.dart';
import 'package:mynotes/presentation/bloc/template_management/template_management_bloc.dart';
import 'package:mynotes/core/design_system/app_colors.dart';
import 'package:mynotes/core/design_system/app_typography.dart';
import 'package:mynotes/core/design_system/app_spacing.dart';
import 'package:mynotes/core/services/global_ui_service.dart';
import 'package:mynotes/core/utils/app_logger.dart';

/// Template Editor - Batch 7, Screen 2
/// Modernized to use Design System and Global UI Services
class TemplateEditorScreen extends StatefulWidget {
  final dynamic existingTemplate;

  const TemplateEditorScreen({super.key, this.existingTemplate});

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingTemplate?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingTemplate?.description ?? '',
    );

    // Initialize BLoC state for editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLogger.i(
        'TemplateEditorScreen: Initializing with template ${widget.existingTemplate?.name ?? "new"}',
      );
      context.read<TemplateManagementBloc>().add(
        StartEditingTemplateEvent(template: widget.existingTemplate),
      );
    });
  }

  @override
  void dispose() {
    AppLogger.i('TemplateEditorScreen: Disposed');
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TemplateManagementBloc, TemplateManagementState>(
      builder: (context, state) {
        if (state is! TemplatesLoaded) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          appBar: AppBar(
            title: Text(
              widget.existingTemplate != null
                  ? 'Edit Template'
                  : 'New Template',
              style: AppTypography.displayMedium(context, AppColors.darkText),
            ),
            centerTitle: true,
            backgroundColor: AppColors.lightSurface,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.darkText),
            actions: [
              if (widget.existingTemplate != null)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                  onPressed: () {
                    AppLogger.i('TemplateEditorScreen: Tapping delete button');
                    _showDeleteConfirmation(context);
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: AppSpacing.paddingAllL,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(context, 'Basic Information', [
                  _buildTextField(
                    context,
                    'Template Name',
                    _nameController,
                    'e.g. Daily Meeting',
                  ),
                  AppSpacing.gapM,
                  _buildTextField(
                    context,
                    'Description',
                    _descriptionController,
                    'What is this template for?',
                    maxLines: 3,
                  ),
                ]),
                AppSpacing.gapL,
                _buildSection(context, 'Categorization', [
                  _buildCategorySelector(context, state.editingCategory),
                ]),
                AppSpacing.gapL,
                _buildSection(context, 'Structure & Fields', [
                  _buildFieldsList(context, state.editingFields),
                  AppSpacing.gapM,
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        AppLogger.i(
                          'TemplateEditorScreen: Tapping add field button',
                        );
                        _showAddFieldDialog(context, state.editingFields);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(
                        Icons.add_rounded,
                        color: AppColors.primaryColor,
                      ),
                      label: Text(
                        'Add Field',
                        style: AppTypography.button(
                          context,
                          AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ]),
                AppSpacing.gapXXL,
                _buildActionButtons(context, state),
                AppSpacing.gapXXL,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: AppTypography.heading3(context)),
        ),
        Container(
          padding: AppSpacing.paddingAllM,
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall(
            context,
            AppColors.secondaryText,
            FontWeight.bold,
          ),
        ),
        AppSpacing.gapS,
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTypography.bodySmall(context, AppColors.darkText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodySmall(context, AppColors.tertiaryText),
            filled: true,
            fillColor: AppColors.lightBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(BuildContext context, String currentCategory) {
    final categories = ['Work', 'Personal', 'Health', 'Learning'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = currentCategory == category;
        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              AppLogger.i('TemplateEditorScreen: Selecting category $category');
              context.read<TemplateManagementBloc>().add(
                UpdateEditingTemplateEvent(category: category),
              );
              getIt<GlobalUiService>().hapticFeedback();
            }
          },
          selectedColor: AppColors.primaryColor,
          backgroundColor: AppColors.lightBackground,
          labelStyle: AppTypography.labelSmall(
            context,
            isSelected ? Colors.white : AppColors.secondaryText,
            isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? Colors.transparent : AppColors.borderLight,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFieldsList(
    BuildContext context,
    List<Map<String, String>> fields,
  ) {
    if (fields.isEmpty) {
      return Container(
        padding: AppSpacing.paddingAllL,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.view_headline_rounded,
              color: AppColors.tertiaryText,
              size: 32,
            ),
            AppSpacing.gapS,
            Text(
              'No fields defined yet',
              style: AppTypography.bodySmall(context, AppColors.tertiaryText),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: fields.length,
      separatorBuilder: (context, index) => AppSpacing.gapS,
      itemBuilder: (context, index) {
        final field = fields[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(
              Icons.drag_indicator_rounded,
              color: AppColors.tertiaryText,
            ),
            title: Text(
              field['name'] ?? '',
              style: AppTypography.bodyMedium(
                context,
                AppColors.darkText,
                FontWeight.w600,
              ),
            ),
            subtitle: Text(
              field['type']?.toUpperCase() ?? '',
              style: AppTypography.labelSmall(context, AppColors.primaryColor),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.remove_circle_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
              onPressed: () {
                final fieldName = field['name'] ?? 'unknown';
                AppLogger.i(
                  'TemplateEditorScreen: Removing field $fieldName at index $index',
                );
                final newFields = List<Map<String, String>>.from(fields);
                newFields.removeAt(index);
                context.read<TemplateManagementBloc>().add(
                  UpdateEditingTemplateEvent(fields: newFields),
                );
                getIt<GlobalUiService>().hapticFeedback();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, TemplatesLoaded state) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              AppLogger.i('TemplateEditorScreen: Cancelling edit');
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
              'Cancel',
              style: AppTypography.button(context, AppColors.secondaryText),
            ),
          ),
        ),
        AppSpacing.gapM,
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              AppLogger.i('TemplateEditorScreen: Tapping save button');
              _saveTemplate(context, state);
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
              'Save Template',
              style: AppTypography.button(context, Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _showAddFieldDialog(
    BuildContext context,
    List<Map<String, String>> currentFields,
  ) {
    final fieldNameController = TextEditingController();
    String selectedType = 'text';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (modalContext, setModalState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Data Field',
                style: AppTypography.heading1(modalContext),
              ),
              AppSpacing.gapL,
              _buildTextField(
                modalContext,
                'Field Name',
                fieldNameController,
                'e.g. Meeting Minutes',
              ),
              AppSpacing.gapL,
              Text(
                'Format',
                style: AppTypography.labelSmall(
                  modalContext,
                  AppColors.secondaryText,
                  FontWeight.bold,
                ),
              ),
              AppSpacing.gapS,
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.lightBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['text', 'number', 'date', 'checkbox']
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          t.toUpperCase(),
                          style: AppTypography.bodySmall(
                            modalContext,
                            AppColors.darkText,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  AppLogger.i(
                    'TemplateEditorScreen: Changing new field format to $v',
                  );
                  setModalState(() => selectedType = v ?? 'text');
                },
              ),
              AppSpacing.gapXL,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (fieldNameController.text.isNotEmpty) {
                      AppLogger.i(
                        'TemplateEditorScreen: Adding field ${fieldNameController.text} to template',
                      );
                      final newFields = List<Map<String, String>>.from(
                        currentFields,
                      );
                      newFields.add({
                        'name': fieldNameController.text,
                        'type': selectedType,
                      });
                      context.read<TemplateManagementBloc>().add(
                        UpdateEditingTemplateEvent(fields: newFields),
                      );
                      Navigator.pop(modalContext);
                      getIt<GlobalUiService>().hapticFeedback();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Add Field'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    AppLogger.i('TemplateEditorScreen: Showing delete confirmation dialog');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Template?'),
        content: const Text(
          'This will permanently remove this template from your gallery.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              AppLogger.i('TemplateEditorScreen: Cancelling template deletion');
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final tid = widget.existingTemplate!.id;
              AppLogger.i(
                'TemplateEditorScreen: Confirming deletion for template ID $tid',
              );
              context.read<TemplateManagementBloc>().add(
                DeleteTemplateEvent(templateId: tid),
              );
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              getIt<GlobalUiService>().showSuccess('Template deleted');
              getIt<GlobalUiService>().hapticFeedback();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _saveTemplate(BuildContext context, TemplatesLoaded state) {
    if (_nameController.text.isEmpty) {
      AppLogger.w('TemplateEditorScreen: Save failed - template name is empty');
      getIt<GlobalUiService>().showWarning('Please enter a template name');
      return;
    }

    AppLogger.i(
      'TemplateEditorScreen: Saving template "${_nameController.text}"',
    );
    context.read<TemplateManagementBloc>().add(
      CreateTemplateEvent(
        name: _nameController.text,
        description: _descriptionController.text,
        category: state.editingCategory,
        fields: state.editingFields,
      ),
    );
    getIt<GlobalUiService>().hapticFeedback();
    Navigator.pop(context);
  }
}




