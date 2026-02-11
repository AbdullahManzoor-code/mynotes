import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/injection_container.dart';
import 'package:mynotes/domain/entities/smart_collection.dart';
import 'package:mynotes/presentation/bloc/smart_collections_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_collection_wizard_bloc.dart';
import 'package:mynotes/core/routes/app_routes.dart';
import 'package:mynotes/presentation/design_system/app_colors.dart';
import 'package:mynotes/presentation/design_system/app_typography.dart';
import 'package:mynotes/presentation/design_system/app_spacing.dart';
import 'package:mynotes/core/services/global_ui_service.dart';

/// Create Smart Collection Wizard - Batch 5, Screen 1
/// Refactored to use Design System, Global UI Services, and BLoC
class CreateSmartCollectionWizard extends StatefulWidget {
  const CreateSmartCollectionWizard({Key? key}) : super(key: key);

  @override
  State<CreateSmartCollectionWizard> createState() =>
      _CreateSmartCollectionWizardState();
}

class _CreateSmartCollectionWizardState
    extends State<CreateSmartCollectionWizard> {
  late PageController _pageController;
  final _collectionNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _collectionNameController.addListener(_onNameChanged);
    _descriptionController.addListener(_onDescriptionChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _collectionNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    context.read<SmartCollectionWizardBloc>().add(
      UpdateWizardBasicInfoEvent(
        name: _collectionNameController.text,
        description: _descriptionController.text,
      ),
    );
  }

  void _onDescriptionChanged() {
    context.read<SmartCollectionWizardBloc>().add(
      UpdateWizardBasicInfoEvent(
        name: _collectionNameController.text,
        description: _descriptionController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SmartCollectionWizardBloc>(
      create: (context) => getIt<SmartCollectionWizardBloc>(),
      child: BlocBuilder<SmartCollectionWizardBloc, SmartCollectionWizardState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.lightBackground,
            appBar: AppBar(
              title: Text(
                'New Smart Collection',
                style: AppTypography.displayMedium(context, AppColors.darkText),
              ),
              backgroundColor: AppColors.lightSurface,
              centerTitle: true,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.darkText),
            ),
            body: Column(
              children: [
                // Step Indicator
                _buildStepIndicator(context, state),
                // Content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      context.read<SmartCollectionWizardBloc>().add(
                        UpdateWizardStepEvent(step: index),
                      );
                    },
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1BasicInfo(context),
                      _buildStep2AddRules(context, state),
                      _buildStep3ReviewLogic(context, state),
                    ],
                  ),
                ),
                // Navigation Buttons
                _buildNavigationButtons(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context,
    SmartCollectionWizardState state,
  ) {
    return Container(
      padding: AppSpacing.paddingAllM,
      color: AppColors.lightSurface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStepCircle(context, 0, 'Info', state.currentStep),
          _buildConnector(0, state.currentStep),
          _buildStepCircle(context, 1, 'Rules', state.currentStep),
          _buildConnector(1, state.currentStep),
          _buildStepCircle(context, 2, 'Apply', state.currentStep),
        ],
      ),
    );
  }

  Widget _buildStepCircle(
    BuildContext context,
    int step,
    String label,
    int currentStep,
  ) {
    final isCompleted = currentStep > step;
    final isCurrent = currentStep == step;

    final Color circleColor = isCompleted || isCurrent
        ? AppColors.primaryColor
        : AppColors.borderLight;

    final Color textColor = isCurrent
        ? AppColors.primaryColor
        : (isCompleted ? AppColors.darkText : AppColors.secondaryText);

    return Column(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent
                ? circleColor
                : (isCompleted ? circleColor : AppColors.lightSurface),
            border: Border.all(color: circleColor, width: 2.w),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 8.r,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? Icon(Icons.check, color: AppColors.lightSurface, size: 20.sp)
              : Text(
                  '${step + 1}',
                  style: AppTypography.labelSmall(
                    context,
                    isCurrent
                        ? AppColors.lightSurface
                        : AppColors.secondaryText,
                    FontWeight.bold,
                  ).copyWith(fontSize: 14.sp),
                ),
        ),
        AppSpacing.gapS,
        Text(
          label,
          style: AppTypography.labelSmall(
            context,
            textColor,
            isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(int index, int currentStep) {
    return Expanded(
      child: Container(
        height: 2.h,
        color: currentStep > index
            ? AppColors.primaryColor
            : AppColors.borderLight,
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 18.h),
      ),
    );
  }

  Widget _buildStep1BasicInfo(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingAllL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about your collection',
            style: AppTypography.heading1(context),
          ),
          AppSpacing.gapS,
          Text(
            'These details help you identify your smart collection later.',
            style: AppTypography.bodyMedium(context, AppColors.secondaryText),
          ),
          AppSpacing.gapL,
          TextField(
            controller: _collectionNameController,
            style: AppTypography.bodyMedium(context, AppColors.darkText),
            decoration: InputDecoration(
              labelText: 'Collection Name',
              hintText: 'e.g., Critical Tasks',
              prefixIcon: const Icon(
                Icons.folder_open_rounded,
                color: AppColors.primaryColor,
              ),
              filled: true,
              fillColor: AppColors.lightSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
            ),
          ),
          AppSpacing.gapM,
          TextField(
            controller: _descriptionController,
            style: AppTypography.bodyMedium(context, AppColors.darkText),
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'What notes should this gather?',
              prefixIcon: const Icon(
                Icons.description_outlined,
                color: AppColors.primaryColor,
              ),
              filled: true,
              fillColor: AppColors.lightSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2AddRules(
    BuildContext context,
    SmartCollectionWizardState state,
  ) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingAllL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add Rules', style: AppTypography.heading1(context)),
              TextButton.icon(
                icon: Icon(Icons.add_circle_outline_rounded, size: 20.sp),
                label: const Text('Add Rule'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  textStyle: AppTypography.button(context),
                ),
                onPressed: () => _navigateToRuleBuilder(context, state),
              ),
            ],
          ),
          AppSpacing.gapS,
          Text(
            'Rules define the membership of your smart collection.',
            style: AppTypography.bodyMedium(context, AppColors.secondaryText),
          ),
          AppSpacing.gapL,
          if (state.rules.isEmpty)
            _buildEmptyRulesState(context)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.rules.length,
              separatorBuilder: (context, index) => AppSpacing.gapS,
              itemBuilder: (context, index) {
                final rule = state.rules[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: AppSpacing.paddingAllS,
                      decoration: BoxDecoration(
                        color: AppColors.primary10,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: const Icon(
                        Icons.filter_list_rounded,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      '${rule['field']} ${rule['operator']} ${rule['value']}',
                      style: AppTypography.bodyMedium(
                        context,
                        AppColors.darkText,
                        FontWeight.w600,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      onPressed: () {
                        context.read<SmartCollectionWizardBloc>().add(
                          RemoveWizardRuleEvent(index: index),
                        );
                        getIt<GlobalUiService>().hapticFeedback();
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyRulesState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAllL,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.primary10,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rule_folder_outlined,
                size: 48.sp,
                color: AppColors.primaryColor,
              ),
            ),
            AppSpacing.gapM,
            Text('No rules added yet', style: AppTypography.heading2(context)),
            AppSpacing.gapS,
            Text(
              'Specify how to filter your notes automatically.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(context, AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3ReviewLogic(
    BuildContext context,
    SmartCollectionWizardState state,
  ) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingAllL,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Finalize Collection', style: AppTypography.heading1(context)),
          AppSpacing.gapL,
          Container(
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Padding(
              padding: AppSpacing.paddingAllM,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReviewItem(context, 'Name', state.name),
                  Divider(height: 32.h, color: AppColors.borderLight),
                  _buildReviewItem(
                    context,
                    'Description',
                    state.description.isEmpty ? 'None' : state.description,
                  ),
                  Divider(height: 32.h, color: AppColors.borderLight),
                  _buildReviewItem(
                    context,
                    'Rules',
                    '${state.rules.length} total criteria',
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.gapL,
          Text('Selection Logic', style: AppTypography.heading2(context)),
          AppSpacing.gapS,
          Text(
            'Choose how rules interact with each other.',
            style: AppTypography.bodySmall(context, AppColors.secondaryText),
          ),
          AppSpacing.gapM,
          Row(
            children: [
              Expanded(
                child: _buildLogicOption(
                  context,
                  'AND',
                  'Matches everything',
                  state.logic == 'AND',
                  () => context.read<SmartCollectionWizardBloc>().add(
                    const UpdateWizardLogicEvent(logic: 'AND'),
                  ),
                ),
              ),
              AppSpacing.gapM,
              Expanded(
                child: _buildLogicOption(
                  context,
                  'OR',
                  'Matches anything',
                  state.logic == 'OR',
                  () => context.read<SmartCollectionWizardBloc>().add(
                    const UpdateWizardLogicEvent(logic: 'OR'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall(context, AppColors.secondaryText),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: AppTypography.bodyMedium(
            context,
            AppColors.darkText,
            FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLogicOption(
    BuildContext context,
    String title,
    String subtitle,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingAllM,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary10 : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.borderLight,
            width: isSelected ? 2.w : 1.w,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: AppTypography.heading2(
                context,
                isSelected ? AppColors.primaryColor : AppColors.darkText,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: AppTypography.labelSmall(context, AppColors.secondaryText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    SmartCollectionWizardState state,
  ) {
    return Container(
      padding: AppSpacing.paddingAllL,
      decoration: const BoxDecoration(
        color: AppColors.lightSurface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: Row(
        children: [
          if (state.currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  getIt<GlobalUiService>().hapticFeedback();
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  side: const BorderSide(color: AppColors.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: AppTypography.button(context, AppColors.primaryColor),
                ),
              ),
            ),
            AppSpacing.gapM,
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: state.currentStep < 2
                  ? (_canProceedToNext(state) ? _nextStep : null)
                  : () => _createCollection(context, state),
              style: ElevatedButton.styleFrom(
                backgroundColor: state.currentStep == 2
                    ? AppColors.successGreen
                    : AppColors.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                state.currentStep == 2 ? 'Create Collection' : 'Next Step',
                style: AppTypography.button(context, AppColors.lightSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    getIt<GlobalUiService>().hapticFeedback();
  }

  bool _canProceedToNext(SmartCollectionWizardState state) {
    if (state.currentStep == 0) return state.name.isNotEmpty;
    if (state.currentStep == 1) return state.rules.isNotEmpty;
    return true;
  }

  Future<void> _navigateToRuleBuilder(
    BuildContext context,
    SmartCollectionWizardState state,
  ) async {
    getIt<GlobalUiService>().hapticFeedback();
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.ruleBuilder,
      arguments: state.rules,
    );
    if (result != null && result is List<Map<String, dynamic>>) {
      context.read<SmartCollectionWizardBloc>().add(
        UpdateWizardRulesEvent(rules: result),
      );
    }
  }

  void _createCollection(
    BuildContext context,
    SmartCollectionWizardState state,
  ) {
    if (state.name.isEmpty) {
      getIt<GlobalUiService>().showWarning('Please provide a name');
      return;
    }

    context.read<SmartCollectionsBloc>().add(
      CreateSmartCollectionEvent(
        name: state.name.trim(),
        description: state.description.trim(),
        rules: state.rules
            .map(
              (r) => CollectionRule(
                type: r['field'] ?? r['type'] ?? '',
                operator: r['operator'] ?? '',
                value: r['value'] ?? '',
              ),
            )
            .toList(),
        logic: state.logic,
      ),
    );

    getIt<GlobalUiService>().showSuccess('Smart collection generated');
    getIt<GlobalUiService>().hapticFeedback();
    Navigator.pop(context);
  }
}
