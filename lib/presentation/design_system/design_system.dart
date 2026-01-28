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
