import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../design_system/design_system.dart';
import '../widgets/universal_item_card.dart';
import '../../core/utils/smart_voice_parser.dart';
import '../../data/repositories/unified_repository.dart';
import '../../injection_container.dart' show getIt;

/// Fixed Universal Quick Add Screen
/// Fully working manual and voice input with proper UI
class FixedUniversalQuickAddScreen extends StatefulWidget {
  const FixedUniversalQuickAddScreen({super.key});

  @override
  State<FixedUniversalQuickAddScreen> createState() =>
      _FixedUniversalQuickAddScreenState();
}

class _FixedUniversalQuickAddScreenState
    extends State<FixedUniversalQuickAddScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _slideController;
  late AnimationController _voiceController;

  // Voice recognition
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  bool _isVoiceAvailable = false;

  // State
  UniversalItem? _previewItem;
  double _parseConfidence = 0.0;
  bool _showPreview = false;
  bool _isSaving = false;

  final _repository = UnifiedRepository.instance;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVoice();
    _initializeRepository();
    _focusNode.requestFocus();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _voiceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController.forward();
  }

  Future<void> _initializeRepository() async {
    try {
      await _repository.initialize();
    } catch (e) {
      AppLogger.e('Repository init error: $e');
    }
  }

  Future<void> _initializeVoice() async {
    try {
      _speechToText = stt.SpeechToText();
      _isVoiceAvailable = await _speechToText.initialize(
        onStatus: (status) {
          AppLogger.i('Voice status: $status');
          if (status == 'notListening' && _isListening) {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (error) {
          AppLogger.e('Voice error: $error');
          _handleVoiceError(error);
        },
      );
      setState(() {});
    } catch (e) {
      AppLogger.e('Voice init error: $e');
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _voiceController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    _speechToText.stop();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;

    if (text.isEmpty) {
      setState(() {
        _showPreview = false;
        _previewItem = null;
        _parseConfidence = 0.0;
      });
      return;
    }

    // Parse the text
    try {
      final parseResult = SmartVoiceParser.parseComplexVoice(text);
      setState(() {
        _previewItem = parseResult['item'] as UniversalItem;
        _parseConfidence = parseResult['confidence'] as double;
        _showPreview = true;
      });
    } catch (e) {
      AppLogger.e('Parse error: $e');
    }
  }

  Future<void> _startListening() async {
    if (!_isVoiceAvailable) {
      _showErrorSnackbar('Voice not available');
      return;
    }

    final permission = await Permission.microphone.request();
    if (permission != PermissionStatus.granted) {
      _showErrorSnackbar('Microphone permission required');
      return;
    }

    try {
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
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
      );
    } catch (e) {
      AppLogger.e('Listen error: $e');
      _handleVoiceError(e);
    }
  }

  void _stopListening() {
    try {
      _speechToText.stop();
      setState(() {
        _isListening = false;
      });
      _voiceController.reverse();
    } catch (e) {
      AppLogger.e('Stop listening error: $e');
    }
  }

  void _handleVoiceError(dynamic error) {
    setState(() {
      _isListening = false;
    });
    _voiceController.reverse();
    _showErrorSnackbar('Voice error: $error');
  }

  Future<void> _handleSubmit() async {
    if (_controller.text.isEmpty || _previewItem == null) {
      _showErrorSnackbar('Please enter something');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _repository.createItem(_previewItem!);

      if (mounted) {
        getIt<GlobalUiService>().showSuccess(_getSuccessMessage());
        Navigator.pop(context, true);
      }
    } catch (error) {
      AppLogger.e('Save error: $error');
      _showErrorSnackbar('Failed to save: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _getSuccessMessage() {
    if (_previewItem!.isTodo && _previewItem!.isReminder) {
      return 'Todo with reminder created!';
    } else if (_previewItem!.isTodo) {
      return 'Todo created!';
    } else if (_previewItem!.isReminder) {
      return 'Reminder set!';
    } else {
      return 'Note saved!';
    }
  }

  void _showErrorSnackbar(String message) {
    getIt<GlobalUiService>().showError(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
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
                child: GestureDetector(
                  onTap: () {}, // Prevent dismissal when tapping sheet
                  child: _buildBottomSheet(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            _buildInputSection(),
            if (_showPreview) ...[SizedBox(height: 16.h), _buildPreview()],
            _buildActionButtons(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Container(
        width: 48.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Add',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Add a note, todo, or reminder',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Text input
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.1),
                width: 2,
              ),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (_) => _onTextChanged(),
              maxLines: 4,
              minLines: 1,
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade500,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Voice button
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _isListening ? _stopListening : _startListening,
                  child: AnimatedBuilder(
                    animation: _voiceController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_voiceController.value * 0.1),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: _isListening
                                ? AppColors.primary.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: _isListening
                                  ? AppColors.primary
                                  : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isListening)
                                SizedBox(
                                  width: 16.w,
                                  height: 16.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      AppColors.primary,
                                    ),
                                  ),
                                )
                              else
                                Icon(
                                  Icons.mic_outlined,
                                  color: Colors.grey.shade300,
                                  size: 20.sp,
                                ),
                              SizedBox(width: 8.w),
                              Text(
                                _isListening ? 'Listening...' : 'Voice Input',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: _isListening
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              GestureDetector(
                onTap: () {
                  _controller.clear();
                  _onTextChanged();
                },
                child: Container(
                  padding: EdgeInsets.all(12.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade300,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_previewItem == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade400,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getConfidenceColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6.r),
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
          UniversalItemCard(
            item: _previewItem!,
            showActions: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  'Cancel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: _isSaving ? null : _handleSubmit,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: _isSaving
                      ? AppColors.primary.withOpacity(0.5)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSaving)
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    else
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    SizedBox(width: 8.w),
                    Text(
                      _isSaving ? 'Saving...' : 'Save',
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

  Color _getConfidenceColor() {
    if (_parseConfidence >= 0.8) return AppColors.accentGreen;
    if (_parseConfidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
