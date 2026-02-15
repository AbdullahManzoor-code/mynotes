import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/core/services/app_logger.dart';
import 'package:mynotes/domain/entities/universal_item.dart';
import '../design_system/design_system.dart';
import '../widgets/universal_item_card.dart';
import '../../core/utils/smart_voice_parser.dart';
import '../bloc/cross_feature/cross_feature_bloc.dart';

/// Cross-Feature Integration Demo
/// Demonstrates the power of the unified Notes/Todos/Reminders system
/// Shows real-time transformation and integration capabilities
class CrossFeatureDemo extends StatefulWidget {
  const CrossFeatureDemo({super.key});

  @override
  State<CrossFeatureDemo> createState() => _CrossFeatureDemoState();
}

class _CrossFeatureDemoState extends State<CrossFeatureDemo>
    with TickerProviderStateMixin {
  late AnimationController _transformController;
  late Animation<double> _transformAnimation;
  late CrossFeatureBloc _bloc;

  // Demo scenarios (Keep for selector if needed, but Bloc has them too)
  final List<Map<String, dynamic>> _demoScenarios = [
    {
      'title': 'Meeting Note → Todo → Reminder',
      'description': 'Watch a meeting note become actionable',
    },
    {
      'title': 'Voice → Smart Everything',
      'description': 'AI-powered voice creates integrated items',
    },
    {
      'title': 'Shopping List Evolution',
      'description': 'Simple list becomes smart system',
    },
  ];

  @override
  void initState() {
    super.initState();
    AppLogger.i('CrossFeatureDemo: Initialized');
    _bloc = CrossFeatureBloc()..add(const StartScenario(0));
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _transformController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _transformAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _transformController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    AppLogger.i('CrossFeatureDemo: Disposed');
    _transformController.dispose();
    _bloc.close();
    super.dispose();
  }

  Future<void> _nextStep() async {
    AppLogger.i('CrossFeatureDemo: Moving to next step');
    _bloc.add(NextStep());

    _transformController.forward().then((_) {
      _bloc.add(CompleteTransformation());
      _transformController.reverse();
    });
  }

  void _completeDemoScenario() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Demo complete! This is the power of unified integration.',
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocListener<CrossFeatureBloc, CrossFeatureState>(
        listener: (context, state) {
          if (state.currentStep >= state.transformationSteps.length - 1 &&
              !state.isTransforming &&
              state.currentStep > 0) {
            // Check if it's the very last step and transformation just finished
            // This logic might need refinement to avoid showing snackbar on every rebuild
          }
        },
        child: BlocBuilder<CrossFeatureBloc, CrossFeatureState>(
          builder: (context, state) {
            return Scaffold(
              backgroundColor: AppColors.darkBackground,
              appBar: AppBar(
                title: const Text('Cross-Feature Demo'),
                backgroundColor: AppColors.darkBackground,
                elevation: 0,
                actions: [
                  IconButton(
                    onPressed: () {
                      AppLogger.i(
                        'CrossFeatureDemo: Refresh scenario pressed for scenario ${state.selectedScenario}',
                      );
                      _bloc.add(StartScenario(state.selectedScenario));
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              body: Column(
                children: [
                  _buildScenarioSelector(state),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDemoDescription(state),
                          SizedBox(height: 24.h),
                          _buildTransformationViewer(state),
                          SizedBox(height: 24.h),
                          _buildStepsProgress(state),
                          SizedBox(height: 32.h),
                          _buildActionButton(state),
                          SizedBox(height: 24.h),
                          _buildIntegrationExplanation(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScenarioSelector(CrossFeatureState state) {
    return Container(
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _demoScenarios.length,
        itemBuilder: (context, index) {
          final isSelected = index == state.selectedScenario;
          return GestureDetector(
            onTap: () {
              AppLogger.i('CrossFeatureDemo: Scenario $index selected');
              _bloc.add(StartScenario(index));
            },
            child: Container(
              margin: EdgeInsets.only(right: 16.w, top: 16.h, bottom: 16.h),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.darkCardBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                _demoScenarios[index]['title'],
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDemoDescription(CrossFeatureState state) {
    final scenario = _demoScenarios[state.selectedScenario];

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 12.w),
              Text(
                scenario['title'],
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            scenario['description'],
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildTransformationViewer(CrossFeatureState state) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.transform, color: AppColors.accentBlue, size: 20.sp),
              SizedBox(width: 12.w),
              Text(
                'Live Transformation',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              if (state.isTransforming) ...[
                const Spacer(),
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 20.h),

          if (state.demoItem != null)
            AnimatedBuilder(
              animation: _transformAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 - (_transformAnimation.value * 0.05),
                  child: Opacity(
                    opacity: 1.0 - (_transformAnimation.value * 0.3),
                    child: UniversalItemCard(
                      item: state.demoItem!,
                      showActions: false,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStepsProgress(CrossFeatureState state) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transformation Steps',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16.h),

          ...List.generate(state.transformationSteps.length, (index) {
            final isCompleted = index < state.currentStep;
            final isCurrent = index == state.currentStep;

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.primary.withOpacity(0.1)
                    : isCurrent
                    ? AppColors.accentBlue.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isCompleted
                      ? AppColors.primary
                      : isCurrent
                      ? AppColors.accentBlue
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primary
                          : isCurrent
                          ? AppColors.accentBlue
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check
                          : isCurrent
                          ? Icons.play_arrow
                          : Icons.circle,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      state.transformationSteps[index],
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isCompleted || isCurrent
                            ? Colors.white
                            : Colors.grey.shade500,
                        fontWeight: isCurrent
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(CrossFeatureState state) {
    final isComplete =
        state.currentStep >= state.transformationSteps.length - 1;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isComplete
            ? () {
                AppLogger.i('CrossFeatureDemo: Restarting demo scenario');
                _bloc.add(StartScenario(state.selectedScenario));
              }
            : _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: isComplete
              ? AppColors.accentGreen
              : AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isComplete ? Icons.refresh : Icons.arrow_forward, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              isComplete ? 'Restart Demo' : 'Next Step',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrationExplanation() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.accentPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.integration_instructions,
                color: AppColors.accentPurple,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Why This Matters',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _buildIntegrationPoint(
            '🔄 Seamless Conversion',
            'Any note can become a todo, any todo can get a reminder - no data loss, no friction.',
          ),

          _buildIntegrationPoint(
            '🧠 AI-Powered Intelligence',
            'Voice input automatically creates the right type of item with smart parsing and context.',
          ),

          _buildIntegrationPoint(
            '📊 Unified Analytics',
            'All your productivity data in one place, giving you complete insights across all workflows.',
          ),

          _buildIntegrationPoint(
            '⚡ Real-time Sync',
            'Changes instantly appear everywhere - todo lists, reminder feeds, search results.',
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationPoint(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.accentPurple,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade300,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
