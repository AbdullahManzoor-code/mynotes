/// Design System
/// Complete design system for MyNotes app
/// Includes colors, typography, spacing, animations, and components
library;

// Core Design System
// Re-export flutter_screenutil so files importing the design system
// have access to the `.h/.w/.r/.sp` extension getters.
export 'package:flutter_screenutil/flutter_screenutil.dart';
export 'app_colors.dart';
export 'app_typography.dart';
export 'app_spacing.dart';
export 'app_animations.dart';

// Components
export 'components/components.dart';

// Modern Utilities
export '../../core/services/global_ui_service.dart';
export '../../core/services/app_logger.dart';
export '../../core/services/connectivity_service.dart';
export '../../core/utils/form_validators.dart';
