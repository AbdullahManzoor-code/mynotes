import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';
import '../widgets/universal_item_card.dart';
import '../../core/utils/smart_voice_parser.dart';

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

  UniversalItem? _demoItem;
  List<String> _transformationSteps = [];
  int _currentStep = 0;
  bool _isTransforming = false;

  // Demo scenarios
  final List<Map<String, dynamic>> _demoScenarios = [
    {
      'title': 'Meeting Note → Todo → Reminder',
      'description': 'Watch a meeting note become actionable',
      'steps': [
        'Create meeting note with agenda',
        'Convert to todo: "Follow up with client"',
        'Add reminder for tomorrow at 2 PM',
        'See unified integration in action',
      ],
      'initialText':
          'Team meeting notes:\n- Discussed Q1 targets\n- Client wants proposal by Friday\n- Need to schedule follow-up',
    },
    {
      'title': 'Voice → Smart Everything',
      'description': 'AI-powered voice creates integrated items',
      'steps': [
        'Voice: "Remind me to buy groceries tomorrow at 5 PM"',
        'AI creates todo with reminder automatically',
        'Shows in both Todos and Reminders views',
        'Cross-feature integration complete',
      ],
      'initialText': 'Remind me to buy groceries tomorrow at 5 PM',
    },
    {
      'title': 'Shopping List Evolution',
      'description': 'Simple list becomes smart system',
      'steps': [
        'Start with basic shopping list note',
        'Convert items to individual todos',
        'Add location-based reminders',
        'Track completion across categories',
      ],
      'initialText':
          'Shopping list:\n- Milk and bread\n- Vegetables for dinner\n- Birthday gift for mom',
    },
  ];

  int _selectedScenario = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _startDemoScenario();
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
    _transformController.dispose();
    super.dispose();
  }

  void _startDemoScenario() {
    final scenario = _demoScenarios[_selectedScenario];

    setState(() {
      _currentStep = 0;
      _transformationSteps = List<String>.from(scenario['steps']);
      _isTransforming = false;
    });

    // Create initial demo item
    _createInitialItem(scenario['initialText']);
  }

  void _createInitialItem(String text) {
    final parsed = SmartVoiceParser.parseVoiceInput(text);
    setState(() {
      _demoItem = parsed;
    });
  }

  Future<void> _nextStep() async {
    if (_currentStep >= _transformationSteps.length - 1) {
      _completeDemoScenario();
      return;
    }

    setState(() {
      _isTransforming = true;
      _currentStep++;
    });

    _transformController.forward().then((_) {
      _performTransformation();
      _transformController.reverse();
    });
  }

  void _performTransformation() {
    if (_demoItem == null) return;

    switch (_selectedScenario) {
      case 0: // Meeting Note → Todo → Reminder
        _transformMeetingNote();
        break;
      case 1: // Voice → Smart Everything
        _transformVoiceInput();
        break;
      case 2: // Shopping List Evolution
        _transformShoppingList();
        break;
    }
  }

  void _transformMeetingNote() {
    switch (_currentStep) {
      case 1: // Convert to todo
        setState(() {
          _demoItem = _demoItem!.copyWith(
            title: 'Follow up with client',
            isTodo: true,
            category: 'Work',
          );
        });
        break;
      case 2: // Add reminder
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final reminderTime = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          14,
          0,
        );
        setState(() {
          _demoItem = _demoItem!.copyWith(
            reminderTime: reminderTime,
            category: 'Work',
          );
        });
        break;
      case 3: // Show integration
        break;
    }
  }

  void _transformVoiceInput() {
    switch (_currentStep) {
      case 1: // AI parsing
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final reminderTime = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          17,
          0,
        );
        setState(() {
          _demoItem = _demoItem!.copyWith(
            title: 'Buy groceries',
            isTodo: true,
            reminderTime: reminderTime,
            category: 'Shopping',
            hasVoiceNote: true,
          );
        });
        break;
      case 2: // Show in both views
      case 3: // Integration complete
        break;
    }
  }

  void _transformShoppingList() {
    switch (_currentStep) {
      case 1: // Convert to todos
        setState(() {
          _demoItem = _demoItem!.copyWith(
            title: 'Milk and bread',
            isTodo: true,
            category: 'Shopping',
          );
        });
        break;
      case 2: // Add location reminder
        final today = DateTime.now();
        final reminderTime = DateTime(
          today.year,
          today.month,
          today.day,
          18,
          0,
        );
        setState(() {
          _demoItem = _demoItem!.copyWith(
            reminderTime: reminderTime,
            content: 'Pick up at grocery store on Main Street',
          );
        });
        break;
      case 3: // Track completion
        setState(() {
          _demoItem = _demoItem!.copyWith(isCompleted: true);
        });
        break;
    }
  }

  void _completeDemoScenario() {
    setState(() {
      _isTransforming = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Demo complete! This is the power of unified integration.',
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Cross-Feature Demo'),
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        actions: [
          IconButton(onPressed: _startDemoScenario, icon: Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          _buildScenarioSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDemoDescription(),
                  SizedBox(height: 24.h),
                  _buildTransformationViewer(),
                  SizedBox(height: 24.h),
                  _buildStepsProgress(),
                  SizedBox(height: 32.h),
                  _buildActionButton(),
                  SizedBox(height: 24.h),
                  _buildIntegrationExplanation(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioSelector() {
    return Container(
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _demoScenarios.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedScenario;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedScenario = index;
              });
              _startDemoScenario();
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

  Widget _buildDemoDescription() {
    final scenario = _demoScenarios[_selectedScenario];

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

  Widget _buildTransformationViewer() {
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
              if (_isTransforming) ...[
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

          if (_demoItem != null)
            AnimatedBuilder(
              animation: _transformAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 - (_transformAnimation.value * 0.05),
                  child: Opacity(
                    opacity: 1.0 - (_transformAnimation.value * 0.3),
                    child: UniversalItemCard(
                      item: _demoItem!,
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

  Widget _buildStepsProgress() {
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

          ...List.generate(_transformationSteps.length, (index) {
            final isCompleted = index < _currentStep;
            final isCurrent = index == _currentStep;

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
                      _transformationSteps[index],
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

  Widget _buildActionButton() {
    final isComplete = _currentStep >= _transformationSteps.length - 1;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isComplete ? _startDemoScenario : _nextStep,
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

