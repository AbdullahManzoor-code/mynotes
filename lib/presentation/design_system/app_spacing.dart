import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Design System Spacing extracted from HTML templates
/// Follows 4px base unit system (4, 8, 12, 16, 20, 24, 32, 40, 48...)
class AppSpacing {
  AppSpacing._();

  // ==================== Base Spacing Units ====================

  /// Base unit: 4px
  static double get unit => 4.w;

  /// 4px - Smallest spacing
  static double get xs => 4.w;

  /// 8px - Extra small spacing
  static double get sm => 8.w;

  /// 12px - Small spacing
  static double get md => 12.w;

  /// 16px - Medium spacing (most common)
  static double get lg => 16.w;

  /// 20px - Large spacing
  static double get xl => 20.w;

  /// 24px - Extra large spacing
  static double get xxl => 24.w;

  /// 32px - Section spacing
  static double get xxxl => 32.w;

  /// 40px - Major section spacing
  static double get huge => 40.w;

  /// 48px - Extra huge spacing
  static double get massive => 48.w;

  // ==================== Specific Use-Case Spacing ====================

  /// Screen edge padding (horizontal)
  static double get screenPaddingHorizontal => 16.w; // 16px

  /// Screen edge padding (vertical)
  static double get screenPaddingVertical => 20.h; // 20px

  /// Card padding
  static double get cardPadding => 16.w; // 16px

  /// Card padding (larger variant)
  static double get cardPaddingLarge => 20.w; // 20px

  /// List item padding
  static double get listItemPadding => 16.w; // 16px

  /// Section margin (between major sections)
  static double get sectionMargin => 24.h; // 24px

  /// Section margin (large)
  static double get sectionMarginLarge => 32.h; // 32px

  /// Element gap (between related items)
  static double get elementGap => 8.w; // 8px

  /// Element gap (larger)
  static double get elementGapLarge => 12.w; // 12px

  /// List item gap (vertical spacing between list items)
  static double get listItemGap => 12.h; // 12px

  /// Grid item gap
  static double get gridItemGap => 12.w; // 12px

  /// Bottom navigation height
  static double get bottomNavHeight => 64.h; // 64px

  /// App bar height
  static double get appBarHeight => 56.h; // 56px

  /// Button height (default)
  static double get buttonHeight => 48.h; // 48px

  /// Button height (large)
  static double get buttonHeightLarge => 56.h; // 56px

  /// Button height (small)
  static double get buttonHeightSmall => 40.h; // 40px

  /// Text field height
  static double get textFieldHeight => 48.h; // 48px

  /// Icon size (small)
  static double get iconSizeSmall => 16.r; // 16px

  /// Icon size (medium)
  static double get iconSizeMedium => 20.r; // 20px

  /// Icon size (large)
  static double get iconSizeLarge => 24.r; // 24px

  /// Icon size (extra large)
  static double get iconSizeXLarge => 28.r; // 28px

  /// Icon size (huge)
  static double get iconSizeHuge => 32.r; // 32px

  /// Avatar size (small)
  static double get avatarSizeSmall => 32.r; // 32px

  /// Avatar size (medium)
  static double get avatarSizeMedium => 40.r; // 40px

  /// Avatar size (large)
  static double get avatarSizeLarge => 48.r; // 48px

  /// Avatar size (extra large)
  static double get avatarSizeXLarge => 64.r; // 64px

  /// Chip height
  static double get chipHeight => 24.h; // 24px

  /// Chip padding horizontal
  static double get chipPaddingHorizontal => 8.w; // 8px

  /// Tag height
  static double get tagHeight => 20.h; // 20px

  /// Tag padding horizontal
  static double get tagPaddingHorizontal => 8.w; // 8px

  /// Bottom sheet handle width
  static double get bottomSheetHandleWidth => 40.w; // 40px

  /// Bottom sheet handle height
  static double get bottomSheetHandleHeight => 4.h; // 4px

  /// Bottom sheet handle top spacing
  static double get bottomSheetHandleTopSpacing => 12.h; // 12px

  // ==================== Border Radius Values ====================

  /// Border radius (default) - 8px
  static double get radiusDefault => 8.r;

  /// Border radius (small) - 4px
  static double get radiusSmall => 4.r;

  /// Border radius (medium) - 8px
  static double get radiusMedium => 8.r;

  /// Border radius (large) - 12px
  static double get radiusLarge => 12.r;

  /// Border radius (extra large) - 16px
  static double get radiusXLarge => 16.r;

  /// Border radius (extra extra large) - 20px
  static double get radiusXXLarge => 20.r;

  /// Border radius (huge) - 24px
  static double get radiusHuge => 24.r;

  /// Border radius (circular) - 9999px
  static double get radiusCircular => 9999.r;

  /// Border radius for cards
  static double get radiusCard => 12.r; // 12px

  /// Border radius for buttons
  static double get radiusButton => 12.r; // 12px

  /// Border radius for text fields
  static double get radiusTextField => 8.r; // 8px

  /// Border radius for chips
  static double get radiusChip => 12.r; // 12px (full rounded)

  /// Border radius for bottom sheet
  static double get radiusBottomSheet => 24.r; // 24px (top corners)

  // ==================== Elevation/Shadow Blur Values ====================

  /// Shadow blur (small)
  static double get shadowBlurSmall => 4.r; // 4px

  /// Shadow blur (medium)
  static double get shadowBlurMedium => 8.r; // 8px

  /// Shadow blur (large)
  static double get shadowBlurLarge => 12.r; // 12px

  /// Shadow blur (extra large)
  static double get shadowBlurXLarge => 20.r; // 20px

  /// Shadow offset Y (small)
  static double get shadowOffsetSmall => 2.h; // 2px

  /// Shadow offset Y (medium)
  static double get shadowOffsetMedium => 4.h; // 4px

  /// Shadow offset Y (large)
  static double get shadowOffsetLarge => 8.h; // 8px

  // ==================== Padding Presets ====================

  /// Screen padding (all sides)
  static EdgeInsets get screenPadding => EdgeInsets.symmetric(
    horizontal: screenPaddingHorizontal,
    vertical: screenPaddingVertical,
  );

  /// Screen padding (horizontal only)
  static EdgeInsets get screenPaddingH =>
      EdgeInsets.symmetric(horizontal: screenPaddingHorizontal);

  /// Screen padding (vertical only)
  static EdgeInsets get screenPaddingV =>
      EdgeInsets.symmetric(vertical: screenPaddingVertical);

  // ==================== Legacy compatibility aliases ====================
  // Older components expect these names; map them to current ones.
  static double get xxs => 2.w;

  // Radius aliases
  static double get radiusLg => radiusLarge;
  static double get radiusMd => radiusMedium;
  static double get radiusSm => radiusSmall;
  static double get radiusXl => radiusXLarge;

  // Deprecated convenience names mapping
  static double get screenPaddingHorizontalOld => screenPaddingHorizontal;
  static double get screenPaddingVerticalOld => screenPaddingVertical;

  /// Card padding (all sides)
  static EdgeInsets get cardPaddingAll => EdgeInsets.all(cardPadding);

  /// Card padding (large, all sides)
  static EdgeInsets get cardPaddingLargeAll => EdgeInsets.all(cardPaddingLarge);

  /// List item padding (all sides)
  static EdgeInsets get listItemPaddingAll => EdgeInsets.all(listItemPadding);

  /// Button padding (horizontal)
  static EdgeInsets get buttonPadding =>
      EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h);

  /// Button padding (large)
  static EdgeInsets get buttonPaddingLarge =>
      EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h);

  /// Button padding (small)
  static EdgeInsets get buttonPaddingSmall =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);

  /// Chip padding
  static EdgeInsets get chipPadding =>
      EdgeInsets.symmetric(horizontal: chipPaddingHorizontal, vertical: 4.h);

  /// Tag padding
  static EdgeInsets get tagPadding =>
      EdgeInsets.symmetric(horizontal: tagPaddingHorizontal, vertical: 2.h);

  /// Dialog padding
  static EdgeInsets get dialogPadding => EdgeInsets.all(24.w);

  /// Bottom sheet padding
  static EdgeInsets get bottomSheetPadding => EdgeInsets.all(24.w);

  /// App bar padding
  static EdgeInsets get appBarPadding =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);

  // ==================== Gap Helpers ====================

  /// Vertical gap (SizedBox with height)
  static SizedBox verticalGap(double height) => SizedBox(height: height.h);

  /// Horizontal gap (SizedBox with width)
  static SizedBox horizontalGap(double width) => SizedBox(width: width.w);

  /// Extra small vertical gap (4px)
  static SizedBox get vGapXS => SizedBox(height: xs);

  /// Small vertical gap (8px)
  static SizedBox get vGapSM => SizedBox(height: sm);

  /// Medium vertical gap (12px)
  static SizedBox get vGapMD => SizedBox(height: md);

  /// Large vertical gap (16px)
  static SizedBox get vGapLG => SizedBox(height: lg);

  /// Extra large vertical gap (20px)
  static SizedBox get vGapXL => SizedBox(height: xl);

  /// Extra extra large vertical gap (24px)
  static SizedBox get vGapXXL => SizedBox(height: xxl);

  /// Huge vertical gap (32px)
  static SizedBox get vGapHuge => SizedBox(height: xxxl);

  /// Extra small horizontal gap (4px)
  static SizedBox get hGapXS => SizedBox(width: xs);

  /// Small horizontal gap (8px)
  static SizedBox get hGapSM => SizedBox(width: sm);

  /// Medium horizontal gap (12px)
  static SizedBox get hGapMD => SizedBox(width: md);

  /// Large horizontal gap (16px)
  static SizedBox get hGapLG => SizedBox(width: lg);

  /// Extra large horizontal gap (20px)
  static SizedBox get hGapXL => SizedBox(width: xl);

  /// Extra extra large horizontal gap (24px)
  static SizedBox get hGapXXL => SizedBox(width: xxl);

  /// Huge horizontal gap (32px)
  static SizedBox get hGapHuge => SizedBox(width: xxxl);

  // ==================== Border Radius Helpers ====================

  /// All corners rounded (default)
  static BorderRadius get borderRadiusDefault =>
      BorderRadius.circular(radiusDefault);

  /// All corners rounded (small)
  static BorderRadius get borderRadiusSmall =>
      BorderRadius.circular(radiusSmall);

  /// All corners rounded (medium)
  static BorderRadius get borderRadiusMedium =>
      BorderRadius.circular(radiusMedium);

  /// All corners rounded (large)
  static BorderRadius get borderRadiusLarge =>
      BorderRadius.circular(radiusLarge);

  /// All corners rounded (extra large)
  static BorderRadius get borderRadiusXLarge =>
      BorderRadius.circular(radiusXLarge);

  /// All corners rounded (card style - 12px)
  static BorderRadius get borderRadiusCard => BorderRadius.circular(radiusCard);

  /// Top corners rounded (for bottom sheets)
  static BorderRadius get borderRadiusTopSheet => BorderRadius.only(
    topLeft: Radius.circular(radiusBottomSheet),
    topRight: Radius.circular(radiusBottomSheet),
  );

  /// Top corners rounded (card style)
  static BorderRadius get borderRadiusTop => BorderRadius.only(
    topLeft: Radius.circular(radiusCard),
    topRight: Radius.circular(radiusCard),
  );

  /// Bottom corners rounded
  static BorderRadius get borderRadiusBottom => BorderRadius.only(
    bottomLeft: Radius.circular(radiusCard),
    bottomRight: Radius.circular(radiusCard),
  );

  /// Left corners rounded
  static BorderRadius get borderRadiusLeft => BorderRadius.only(
    topLeft: Radius.circular(radiusCard),
    bottomLeft: Radius.circular(radiusCard),
  );

  /// Right corners rounded
  static BorderRadius get borderRadiusRight => BorderRadius.only(
    topRight: Radius.circular(radiusCard),
    bottomRight: Radius.circular(radiusCard),
  );

  /// Circular border radius
  static BorderRadius get borderRadiusCircular =>
      BorderRadius.circular(radiusCircular);

  // ==================== Custom Helpers ====================

  /// Create custom EdgeInsets
  static EdgeInsets all(double value) => EdgeInsets.all(value.w);

  /// Create symmetric EdgeInsets
  static EdgeInsets symmetric({double? horizontal, double? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal?.w ?? 0,
      vertical: vertical?.h ?? 0,
    );
  }

  /// Create only EdgeInsets
  static EdgeInsets only({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    return EdgeInsets.only(
      left: left?.w ?? 0,
      top: top?.h ?? 0,
      right: right?.w ?? 0,
      bottom: bottom?.h ?? 0,
    );
  }

  /// Create custom BorderRadius
  static BorderRadius radius(double value) => BorderRadius.circular(value.r);

  /// Create custom vertical gap
  static Widget vGap(double height) => SizedBox(height: height.h);

  /// Create custom horizontal gap
  static Widget hGap(double width) => SizedBox(width: width.w);
}

/// Extension on num for spacing utilities
extension AppSpacingExtensions on num {
  /// Create EdgeInsets.all
  EdgeInsets get paddingAll => EdgeInsets.all(toDouble());

  /// Create horizontal padding
  EdgeInsets get paddingH => EdgeInsets.symmetric(horizontal: toDouble());

  /// Create vertical padding
  EdgeInsets get paddingV => EdgeInsets.symmetric(vertical: toDouble());

  /// Create left padding
  EdgeInsets get paddingL => EdgeInsets.only(left: toDouble());

  /// Create top padding
  EdgeInsets get paddingT => EdgeInsets.only(top: toDouble());

  /// Create right padding
  EdgeInsets get paddingR => EdgeInsets.only(right: toDouble());

  /// Create bottom padding
  EdgeInsets get paddingB => EdgeInsets.only(bottom: toDouble());

  /// Create vertical gap
  SizedBox get verticalSpace => SizedBox(height: toDouble());

  /// Create horizontal gap
  SizedBox get horizontalSpace => SizedBox(width: toDouble());

  /// Create BorderRadius.circular
  BorderRadius get borderRadius => BorderRadius.circular(toDouble());
}

