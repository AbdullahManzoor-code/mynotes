import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/presentation/bloc/rule_builder/rule_builder_bloc.dart';
import 'package:mynotes/presentation/design_system/app_colors.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';
import 'package:mynotes/presentation/design_system/app_spacing.dart';
import 'package:mynotes/injection_container.dart';
import 'package:mynotes/core/services/global_ui_service.dart';
import 'package:mynotes/core/utils/app_logger.dart';

/// Rule Builder Screen - Batch 5, Screen 2
/// Refactored to use Design System, Global UI Services, and BLoC
class RuleBuilderScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? initialRules;

  const RuleBuilderScreen({super.key, this.initialRules});

  @override
  State<RuleBuilderScreen> createState() => _RuleBuilderScreenState();
}

class _RuleBuilderScreenState extends State<RuleBuilderScreen> {
  final _fieldController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fieldController.addListener(_onFieldChanged);
    _valueController.addListener(_onValueChanged);
  }

  @override
  void dispose() {
    _fieldController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    AppLogger.i(
      'RuleBuilderScreen: Field name changed to ${_fieldController.text}',
    );
    context.read<RuleBuilderBloc>().add(
      UpdateRuleFieldEvent(field: _fieldController.text),
    );
  }

  void _onValueChanged() {
    AppLogger.i('RuleBuilderScreen: Value changed');
    context.read<RuleBuilderBloc>().add(
      UpdateRuleValueEvent(value: _valueController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.i('RuleBuilderScreen: Building UI');
    return BlocProvider<RuleBuilderBloc>(
      create: (context) {
        final bloc = getIt<RuleBuilderBloc>();
        if (widget.initialRules != null) {
          AppLogger.i(
            'RuleBuilderScreen: Initializing with ${widget.initialRules!.length} rules',
          );
          bloc.add(
            InitializeRuleBuilderEvent(initialRules: widget.initialRules!),
          );
        }
        return bloc;
      },
      child: BlocBuilder<RuleBuilderBloc, RuleBuilderState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.lightBackground,
            appBar: AppBar(
              title: Text(
                'Rule Builder',
                style: AppTypography.displayMedium(context, AppColors.darkText),
              ),
              centerTitle: true,
              backgroundColor: AppColors.lightSurface,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.darkText),
            ),
            body: SingleChildScrollView(
              padding: AppSpacing.paddingAllL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rules Guide
                  _buildRulesGuide(context),
                  AppSpacing.gapL,

                  // Rule Input
                  _buildRuleInput(context, state),
                  AppSpacing.gapL,

                  // Built Rules Preview
                  _buildRulesPreview(context, state),
                  AppSpacing.gapL,

                  // Action Buttons
                  _buildActionButtons(context, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRulesGuide(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rule Components', style: AppTypography.heading2(context)),
        AppSpacing.gapS,
        Container(
          padding: AppSpacing.paddingAllM,
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGuideItem(
                context,
                'Field',
                'The property to check (e.g., type, size, content)',
              ),
              _buildGuideItem(
                context,
                'Operator',
                'How to compare (=, >, <, contains, starts with)',
              ),
              _buildGuideItem(
                context,
                'Value',
                'The target value to match against',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuideItem(
    BuildContext context,
    String label,
    String description,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall(
              context,
              AppColors.primaryColor,
              FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            description,
            style: AppTypography.bodySmall(context, AppColors.secondaryText),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleInput(BuildContext context, RuleBuilderState state) {
    final bloc = context.read<RuleBuilderBloc>();
    final ruleEngine = bloc.ruleEngine;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Define Criteria', style: AppTypography.heading2(context)),
        AppSpacing.gapM,

        // Field Input
        TextField(
          controller: _fieldController,
          style: AppTypography.bodyMedium(context, AppColors.darkText),
          decoration: InputDecoration(
            labelText: 'Field Name',
            hintText: 'e.g., type, size, name',
            prefixIcon: const Icon(
              Icons.category_rounded,
              color: AppColors.primaryColor,
            ),
            filled: true,
            fillColor: AppColors.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            suffixIcon: PopupMenuButton<String>(
              icon: const Icon(
                Icons.arrow_drop_down_circle_outlined,
                color: AppColors.primaryColor,
              ),
              onSelected: (val) {
                AppLogger.i(
                  'RuleBuilderScreen: Selected field from menu: $val',
                );
                _fieldController.text = val;
                bloc.add(UpdateRuleFieldEvent(field: val));
              },
              itemBuilder: (context) => [
                _buildPopupItem('type'),
                _buildPopupItem('size'),
                _buildPopupItem('name'),
                _buildPopupItem('createdAt'),
                _buildPopupItem('tags'),
              ],
            ),
          ),
        ),
        AppSpacing.gapM,

        // Operator Selection
        DropdownButtonFormField<String>(
          value: state.operator,
          items: ruleEngine.getSupportedOperators().map((op) {
            return DropdownMenuItem(
              value: op,
              child: Text(_getOperatorLabel(op)),
            );
          }).toList(),
          onChanged: (value) {
            AppLogger.i('RuleBuilderScreen: Operator changed to $value');
            bloc.add(UpdateRuleOperatorEvent(operator: value ?? '='));
          },
          decoration: InputDecoration(
            labelText: 'Operator',
            prefixIcon: const Icon(
              Icons.compare_arrows_rounded,
              color: AppColors.primaryColor,
            ),
            filled: true,
            fillColor: AppColors.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          _getOperatorDescription(state.operator),
          style: AppTypography.labelSmall(
            context,
            AppColors.secondaryText,
          ).copyWith(fontStyle: FontStyle.italic),
        ),
        AppSpacing.gapM,

        // Value Input
        TextField(
          controller: _valueController,
          style: AppTypography.bodyMedium(context, AppColors.darkText),
          decoration: InputDecoration(
            labelText: 'Value',
            hintText: 'Target for comparison',
            prefixIcon: const Icon(
              Icons.edit_note_rounded,
              color: AppColors.primaryColor,
            ),
            filled: true,
            fillColor: AppColors.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
        AppSpacing.gapL,

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add This Rule'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            onPressed: () {
              AppLogger.i('RuleBuilderScreen: Add This Rule button pressed');
              _addRule(context, state);
            },
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupItem(String value) {
    return PopupMenuItem(value: value, child: Text(value));
  }

  Widget _buildRulesPreview(BuildContext context, RuleBuilderState state) {
    if (state.builtRules.isEmpty) {
      return Center(
        child: Padding(
          padding: AppSpacing.paddingAllM,
          child: Column(
            children: [
              Icon(
                Icons.format_list_bulleted_rounded,
                size: 48.sp,
                color: AppColors.borderLight,
              ),
              AppSpacing.gapS,
              Text(
                'No rules defined yet',
                style: AppTypography.bodySmall(context, AppColors.tertiaryText),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Rules (${state.builtRules.length})',
          style: AppTypography.heading2(context),
        ),
        AppSpacing.gapM,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.builtRules.length,
          separatorBuilder: (context, index) => AppSpacing.gapS,
          itemBuilder: (context, index) {
            final rule = state.builtRules[index];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary10,
                  radius: 14.r,
                  child: Text(
                    '${index + 1}',
                    style: AppTypography.labelSmall(
                      context,
                      AppColors.primaryColor,
                      FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  '${rule['field']} ${_getOperatorLabel(rule['operator'])} ${rule['value']}',
                  style: AppTypography.bodyMedium(context, AppColors.darkText),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                  onPressed: () {
                    AppLogger.i(
                      'RuleBuilderScreen: Remove rule at index $index',
                    );
                    context.read<RuleBuilderBloc>().add(
                      RemoveRuleIndexEvent(index: index),
                    );
                    getIt<GlobalUiService>().hapticFeedback();
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, RuleBuilderState state) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              AppLogger.i('RuleBuilderScreen: Clear All rules button pressed');
              context.read<RuleBuilderBloc>().add(const ClearAllRulesEvent());
              getIt<GlobalUiService>().hapticFeedback();
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text('Clear All'),
          ),
        ),
        AppSpacing.gapM,
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              AppLogger.i(
                'RuleBuilderScreen: Save Rules button pressed - count: ${state.builtRules.length}',
              );
              getIt<GlobalUiService>().hapticFeedback();
              Navigator.pop(context, state.builtRules);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Save Rules',
              style: AppTypography.button(context, AppColors.lightSurface),
            ),
          ),
        ),
      ],
    );
  }

  void _addRule(BuildContext context, RuleBuilderState state) async {
    final bloc = context.read<RuleBuilderBloc>();
    final field = state.field.trim();
    final value = state.value.trim();

    if (field.isEmpty || value.isEmpty) {
      AppLogger.w(
        'RuleBuilderScreen: Validation failed - field or value is empty',
      );
      getIt<GlobalUiService>().showWarning('Please fill in all rule fields');
      return;
    }

    final rule = {'field': field, 'operator': state.operator, 'value': value};

    final isValid = await bloc.ruleEngine.validateRule(rule);

    if (isValid) {
      AppLogger.i('RuleBuilderScreen: Rule validated and added: $rule');
      bloc.add(AddRuleEvent(rule: rule));
      _fieldController.clear();
      _valueController.clear();
      getIt<GlobalUiService>().showSuccess('Rule expression added');
      getIt<GlobalUiService>().hapticFeedback();
    } else {
      AppLogger.e('RuleBuilderScreen: Rule validation failed for $rule');
      getIt<GlobalUiService>().showError('Invalid rule syntax');
    }
  }

  String _getOperatorLabel(String operator) {
    switch (operator) {
      case 'equals':
        return 'Equals (=)';
      case 'contains':
        return 'Contains (~)';
      case 'greaterThan':
        return 'Greater Than (>)';
      case 'lessThan':
        return 'Less Than (<)';
      case 'startsWith':
        return 'Starts With (^)';
      case 'endsWith':
        return 'Ends With (\$)';
      case 'inList':
        return 'In List (∈)';
      default:
        return operator;
    }
  }

  String _getOperatorDescription(String operator) {
    switch (operator) {
      case 'equals':
        return 'Exact match required';
      case 'contains':
        return 'Value must appear anywhere';
      case 'greaterThan':
        return 'Field must be numerically greater';
      case 'lessThan':
        return 'Field must be numerically less';
      case 'startsWith':
        return 'Field begins with value';
      case 'endsWith':
        return 'Field concludes with value';
      case 'inList':
        return 'Field matches any comma-separated value';
      default:
        return '';
    }
  }
}
