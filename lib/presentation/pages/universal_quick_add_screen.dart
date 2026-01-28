import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../design_system/design_system.dart';
import '../widgets/universal_item_card.dart';
import '../../core/utils/smart_voice_parser.dart';
import '../../data/repositories/unified_repository.dart';

/// Universal Quick Add Smart Input Screen
/// Advanced smart input interface with real-time parsing and suggestions
/// Based on universal_quick_add_smart_input_1 template
class UniversalQuickAddScreen extends StatefulWidget {
  const UniversalQuickAddScreen({super.key});

  @override
  State<UniversalQuickAddScreen> createState() =>
      _UniversalQuickAddScreenState();
}

class _UniversalQuickAddScreenState extends State<UniversalQuickAddScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _cursorController;
  late AnimationController _slideController;
  late AnimationController _parsingController;
  late AnimationController _voiceController;

  // Voice recognition
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  bool _isVoiceAvailable = false;
  bool _showPreview = false;

  // Parsed components using smart parser
  UniversalItem? _previewItem;
  double _parseConfidence = 0.0;
  List<UniversalItem> _suggestions = [];
  List<String> _quickSuggestions = [];
  List<String> _recentInputs = [];

  // Repository
  final _repository = UnifiedRepository.instance;

  @override
  void initState() {
    super.initState();

    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _parsingController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _voiceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _controller.addListener(_onTextChanged);
    _focusNode.requestFocus();

    _initializeVoice();
    _loadQuickSuggestions();
    _loadRecentInputs();

    // Auto-show with animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _slideController.dispose();
    _parsingController.dispose();
    _voiceController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;

    if (text.isEmpty) {
      setState(() {
        _showPreview = false;
        _previewItem = null;
        _parseConfidence = 0.0;
        _suggestions.clear();
      });
      return;
    }

    // Use smart parser for intelligent parsing
    final parseResult = SmartVoiceParser.parseComplexVoice(text);

    setState(() {
      _previewItem = parseResult['item'];
      _parseConfidence = parseResult['confidence'];
      _suggestions = parseResult['suggestions'];
      _showPreview = true;
    });

    if (!_showPreview) {
      _parsingController.forward();
    }
  }

  // Voice recognition initialization and methods
  Future<void> _initializeVoice() async {
    _speechToText = stt.SpeechToText();
    _isVoiceAvailable = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'notListening' && _isListening) {
          setState(() {
            _isListening = false;
          });
          _voiceController.reverse();
        }
      },
      onError: (error) => _handleVoiceError(error),
    );
  }

  Future<void> _startListening() async {
    if (!_isVoiceAvailable) return;

    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      _showErrorSnackbar('Microphone permission required');
      return;
    }

    setState(() {
      _isListening = true;
    });
    _voiceController.forward();

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _controller.text = result.recognizedWords;
        });
        _onTextChanged();
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 2),
    );
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    _voiceController.reverse();
  }

  void _handleVoiceError(dynamic error) {
    setState(() {
      _isListening = false;
    });
    _voiceController.reverse();
    _showErrorSnackbar('Voice recognition error: $error');
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // Load suggestions and recent inputs
  Future<void> _loadQuickSuggestions() async {
    // In a real app, these would come from preferences or analytics
    setState(() {
      _quickSuggestions = [
        'Buy groceries',
        'Call mom tomorrow',
        'Workout at 6pm',
        'Meeting notes',
        'Weekend plans',
        'Book dentist appointment',
        'Pay bills',
        'Project ideas',
      ];
    });
  }

  Future<void> _loadRecentInputs() async {
    // In a real app, load from shared preferences
    setState(() {
      _recentInputs = [
        'Buy milk and bread',
        'Call dentist tomorrow at 2pm',
        'Workout plan for next week',
      ];
    });
  }

  void _toggleVoiceInput() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }

    HapticFeedback.lightImpact();
  }

  void _handleSubmit() async {
    if (_controller.text.isEmpty || _previewItem == null) return;

    try {
      // Save to unified repository
      await _repository.createItem(_previewItem!);

      // Save to recent inputs
      if (!_recentInputs.contains(_controller.text)) {
        _recentInputs.insert(0, _controller.text);
        if (_recentInputs.length > 3) {
          _recentInputs.removeLast();
        }
        // TODO: Save to shared preferences
      }

      // Success feedback
      HapticFeedback.mediumImpact();

      // Show success message based on type
      String message;
      if (_previewItem!.isTodo) {
        message = 'Todo created successfully!';
      } else if (_previewItem!.isReminder) {
        message = 'Reminder set successfully!';
      } else {
        message = 'Note saved successfully!';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      _showErrorSnackbar('Failed to save: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
            // Background blur overlay
            _buildBackgroundContent(),

            // Main quick add interface
            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _slideController,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildQuickAddPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.0),
            Colors.black.withOpacity(0.6),
          ],
        ),
      ),
      child: Positioned.fill(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              SizedBox(height: 80.h),

              // Mock app content (blurred background)
              Expanded(
                child: Opacity(
                  opacity: 0.2,
                  child: Column(
                    children: [
                      // Mock header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 24.h,
                            width: 128.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          Container(
                            height: 40.w,
                            width: 40.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 40.h),

                      // Mock cards
                      ...List.generate(
                        3,
                        (index) => Container(
                          height: 128.h,
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 24.h),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
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

  Widget _buildQuickAddPanel() {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 428.w),
      margin: EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.r),
          topRight: Radius.circular(40.r),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 12.h),
            height: 4.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          if (_controller.text.isEmpty) _buildHeader(),

          // Input section
          _buildInputSection(),

          // Voice feedback
          if (_isListening) _buildVoiceListening(),

          // Parsing preview
          if (_showPreview) _buildParsingPreview(),

          // Suggestions (when empty)
          if (_controller.text.isEmpty && !_isListening) _buildSuggestions(),

          // Submit button
          if (_controller.text.isNotEmpty) _buildSubmitButton(),

          SizedBox(height: MediaQuery.of(context).viewPadding.bottom + 16.h),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: 100.h),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.3,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: _isListening
                      ? "Listening..."
                      : "What's on your mind?",
                  hintStyle: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w500,
                    color: _isListening
                        ? AppColors.primary.withOpacity(0.7)
                        : Colors.grey.shade500,
                  ),
                ),
                onSubmitted: (_) => _handleSubmit(),
              ),
            ),
          ),

          SizedBox(width: 16.w),

          // Voice input button
          GestureDetector(
            onTap: _isVoiceAvailable ? _toggleVoiceInput : null,
            child: AnimatedBuilder(
              animation: _voiceController,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(top: 16.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: _isListening
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedScale(
                    scale: _isListening ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_outlined,
                      color: _isListening
                          ? Colors.white
                          : (_isVoiceAvailable
                                ? Colors.grey.shade400
                                : Colors.grey.shade600),
                      size: 24.sp,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParsingPreview() {
    if (_previewItem == null) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _parsingController,
      child: Container(
        margin: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with confidence indicator
            Row(
              children: [
                Text(
                  'SMART PREVIEW',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Colors.grey.shade500.withOpacity(0.8),
                  ),
                ),
                const Spacer(),
                // Confidence indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.psychology,
                        color: _getConfidenceColor(),
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${(_parseConfidence * 100).round()}%',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: _getConfidenceColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Universal Item Card Preview
            UniversalItemCard(
              item: _previewItem!,
              showActions: false,
              onTap: () {
                // Maybe show edit options?
              },
            ),

            // Alternative suggestions
            if (_suggestions.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Text(
                'ALTERNATIVE SUGGESTIONS',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.grey.shade500.withOpacity(0.8),
                ),
              ),
              SizedBox(height: 8.h),
              ...List.generate(_suggestions.length, (index) {
                final suggestion = _suggestions[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: GestureDetector(
                    onTap: () => _selectSuggestion(suggestion),
                    child: UniversalItemCard(
                      item: suggestion,
                      showActions: false,
                      isSelected: false,
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor() {
    if (_parseConfidence >= 0.8) return Colors.green;
    if (_parseConfidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _selectSuggestion(UniversalItem suggestion) {
    setState(() {
      _previewItem = suggestion;
      _parseConfidence = 0.9; // High confidence for manual selection
      _suggestions.clear();
    });
    HapticFeedback.selectionClick();
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.bolt, color: AppColors.primary, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Add',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Smart AI parsing • Voice input • Quick actions',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceListening() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            RotationTransition(
              turns: _voiceController,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Icon(Icons.mic, color: Colors.white, size: 20.sp),
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Listening...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Speak naturally and I\'ll parse it for you',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            Spacer(),
            GestureDetector(
              onTap: _stopListening,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.stop, color: Colors.red, size: 18.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Suggestions',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _quickSuggestions.map((suggestion) {
              return GestureDetector(
                onTap: () {
                  _controller.text = suggestion;
                  _onTextChanged();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),

          // Recent inputs
          if (_recentInputs.isNotEmpty) ...[
            Text(
              'Recent',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 8.h),
            ..._recentInputs.map((recent) {
              return GestureDetector(
                onTap: () {
                  _controller.text = recent;
                  _onTextChanged();
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: Colors.grey.shade500,
                        size: 16.sp,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          recent,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _handleSubmit,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getPreviewIcon(), color: Colors.white, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      _getCreateButtonText(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for UI
  IconData _getPreviewIcon() {
    if (_previewItem == null) return Icons.note_add;
    if (_previewItem!.isTodo) return Icons.task_alt;
    if (_previewItem!.isReminder) return Icons.alarm;
    return Icons.note;
  }

  String _getCreateButtonText() {
    if (_previewItem == null) return 'Create Note';
    if (_previewItem!.isTodo) return 'Create Todo';
    if (_previewItem!.isReminder) return 'Set Reminder';
    return 'Save Note';
  }
}
