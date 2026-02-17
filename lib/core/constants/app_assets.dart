/// All asset paths used throughout the app
/// Centralized to prevent typos and make refactoring easier
class AppAssets {
  AppAssets._();

  // ═════════════════════════════════════════════════════════════════════════
  // SVG ICONS BASE PATH
  // ═════════════════════════════════════════════════════════════════════════

  static const String _svgPath = 'assets/svg/icons';
  static const String _animPath = 'assets/animations';
  static const String _imagePath = 'assets/images';

  // ═════════════════════════════════════════════════════════════════════════
  // NAVIGATION & COMMON ICONS
  // ═════════════════════════════════════════════════════════════════════════

  static const String homeIcon = '$_svgPath/home.svg';
  static const String searchIcon = '$_svgPath/search.svg';
  static const String addIcon = '$_svgPath/add.svg';
  static const String settingsIcon = '$_svgPath/settings.svg';
  static const String profileIcon = '$_svgPath/profile.svg';
  static const String menuIcon = '$_svgPath/menu.svg';
  static const String moreIcon = '$_svgPath/more.svg';
  static const String backIcon = '$_svgPath/back.svg';
  static const String closeIcon = '$_svgPath/close.svg';

  // ═════════════════════════════════════════════════════════════════════════
  // NOTES ICONS
  // ═════════════════════════════════════════════════════════════════════════

  static const String notesIcon = '$_svgPath/notes.svg';
  static const String noteIcon = '$_svgPath/note.svg';
  static const String createNoteIcon = '$_svgPath/create_note.svg';
  static const String archiveIcon = '$_svgPath/archive.svg';
  static const String unarchiveIcon = '$_svgPath/unarchive.svg';
  static const String pinIcon = '$_svgPath/pin.svg';
  static const String unpinIcon = '$_svgPath/unpin.svg';
  static const String labelIcon = '$_svgPath/label.svg';
  static const String tagsIcon = '$_svgPath/tags.svg';

  // ═════════════════════════════════════════════════════════════════════════
  // TODOS ICONS
  // ═════════════════════════════════════════════════════════════════════════

  static const String todosIcon = '$_svgPath/todos.svg';
  static const String todoIcon = '$_svgPath/todo.svg';
  static const String checkIcon = '$_svgPath/check.svg';
  static const String checkboxIcon = '$_svgPath/checkbox.svg';
  static const String checkboxCheckedIcon = '$_svgPath/checkbox_checked.svg';
  static const String priorityIcon = '$_svgPath/priority.svg';
  static const String calendarIcon = '$_svgPath/calendar.svg';
  static const String categoryIcon = '$_svgPath/category.svg';

  // ═════════════════════════════════════════════════════════════════════════
  // ALARMS & REMINDERS ICONS
  // ═════════════════════════════════════════════════════════════════════════

  static const String alarmIcon = '$_svgPath/alarm.svg';
  static const String bellIcon = '$_svgPath/bell.svg';
  static const String notificationIcon = '$_svgPath/notification.svg';
  static const String clockIcon = '$_svgPath/clock.svg';
  static const String timerIcon = '$_svgPath/timer.svg';
  static const String repeatIcon = '$_svgPath/repeat.svg';
  static const String snoozeIcon = '$_svgPath/snooze.svg';

  // ═════════════════════════════════════════════════════════════════════════
  // MEDIA ICONS
  // ═════════════════════════════════════════════════════════════════════════

  static const String galleryIcon = '$_svgPath/gallery.svg';
  static const String cameraIcon = '$_svgPath/camera.svg';
  static const String videoIcon = '$_svgPath/video.svg';
  static const String audioIcon = '$_svgPath/audio.svg';
  static const String micIcon = '$_svgPath/mic.svg';
  static const String imageIcon = '$_svgPath/image.svg';
  static const String documentIcon = '$_svgPath/document.svg';
  static const String uploadIcon = '$_svgPath/upload.svg';
  static const String downloadIcon = '$_svgPath/download.svg';

  // ═════════════════════════════════════════════════════════════════════════
  // EDITING ICONS
  // ═════════════════════════════════════════════════════════════════════════

  static const String editIcon = '$_svgPath/edit.svg';
  static const String deleteIcon = '$_svgPath/delete.svg';
  static const String copyIcon = '$_svgPath/copy.svg';
  static const String pasteIcon = '$_svgPath/paste.svg';
  static const String cutIcon = '$_svgPath/cut.svg';
  static const String formatBoldIcon = '$_svgPath/format_bold.svg';
  static const String formatItalicIcon = '$_svgPath/format_italic.svg';
  static const String formatUnderlineIcon = '$_svgPath/format_underline.svg';
  static const String formatColorIcon = '$_svgPath/format_color.svg';
  static const String linkIcon = '$_svgPath/link.svg';
  static const String attachmentIcon = '$_svgPath/attachment.svg';

  // ═════════════════════════════════════════════════════════════════════════
  // FILTER & SORT ICONS
  // ═════════════════════════════════════════════════════════════════════════

  static const String filterIcon = '$_svgPath/filter.svg';
  static const String sortIcon = '$_svgPath/sort.svg';
  static const String sortAscIcon = '$_svgPath/sort_asc.svg';
  static const String sortDescIcon = '$_svgPath/sort_desc.svg';
  static const String viewListIcon = '$_svgPath/view_list.svg';
  static const String viewGridIcon = '$_svgPath/view_grid.svg';

  // ═════════════════════════════════════════════════════════════════════════
  // UTILITY ICONS
  // ═════════════════════════════════════════════════════════════════════════

  static const String shareIcon = '$_svgPath/share.svg';
  static const String exportIcon = '$_svgPath/export.svg';
  static const String importIcon = '$_svgPath/import.svg';
  static const String printIcon = '$_svgPath/print.svg';
  static const String helpIcon = '$_svgPath/help.svg';
  static const String infoIcon = '$_svgPath/info.svg';
  static const String warningIcon = '$_svgPath/warning.svg';
  static const String errorIcon = '$_svgPath/error.svg';
  static const String successIcon = '$_svgPath/success.svg';
  static const String lockIcon = '$_svgPath/lock.svg';
  static const String unlockIcon = '$_svgPath/unlock.svg';

  // ═════════════════════════════════════════════════════════════════════════
  // THEME ICONS
  // ═════════════════════════════════════════════════════════════════════════

  static const String moonIcon = '$_svgPath/moon.svg';
  static const String sunIcon = '$_svgPath/sun.svg';
  static const String themeIcon = '$_svgPath/theme.svg';
  static const String fontIcon = '$_svgPath/font.svg';
  static const String colorIcon = '$_svgPath/color.svg';

  // ═════════════════════════════════════════════════════════════════════════
  // ANIMATIONS (.json from Lottie)
  // ═════════════════════════════════════════════════════════════════════════

  static const String loadingAnimation = '$_animPath/loading.json';
  static const String emptyStateAnimation = '$_animPath/empty_state.json';
  static const String successAnimation = '$_animPath/success.json';
  static const String errorAnimation = '$_animPath/error.json';
  static const String celebrationAnimation = '$_animPath/celebration.json';
  static const String checkAnimation = '$_animPath/check.json';
  static const String alarmAnimation = '$_animPath/alarm.json';
  static const String timerAnimation = '$_animPath/timer.json';

  // ═════════════════════════════════════════════════════════════════════════
  // IMAGES
  // ═════════════════════════════════════════════════════════════════════════

  static const String appLogo = '$_imagePath/logo.png';
  static const String appLogoWhite = '$_imagePath/logo_white.png';
  static const String placeholderImage = '$_imagePath/placeholder.png';
  static const String noCoverImage = '$_imagePath/no_cover.png';
  static const String noImageIcon = '$_imagePath/no_image.png';
  static const String onboardingImage1 = '$_imagePath/onboarding_1.png';
  static const String onboardingImage2 = '$_imagePath/onboarding_2.png';
  static const String onboardingImage3 = '$_imagePath/onboarding_3.png';

  // ═════════════════════════════════════════════════════════════════════════
  // NOTE COLOR ICONS
  // ═════════════════════════════════════════════════════════════════════════

  static const String colorDefaultIcon = '$_svgPath/color_default.svg';
  static const String colorRedIcon = '$_svgPath/color_red.svg';
  static const String colorPinkIcon = '$_svgPath/color_pink.svg';
  static const String colorPurpleIcon = '$_svgPath/color_purple.svg';
  static const String colorBlueIcon = '$_svgPath/color_blue.svg';
  static const String colorGreenIcon = '$_svgPath/color_green.svg';
  static const String colorYellowIcon = '$_svgPath/color_yellow.svg';
  static const String colorOrangeIcon = '$_svgPath/color_orange.svg';
  static const String colorBrownIcon = '$_svgPath/color_brown.svg';
  static const String colorGreyIcon = '$_svgPath/color_grey.svg';

  // ═════════════════════════════════════════════════════════════════════════
  // SOCIAL ICONS
  // ═════════════════════════════════════════════════════════════════════════

  static const String googleIcon = '$_svgPath/google.svg';
  static const String facebookIcon = '$_svgPath/facebook.svg';
  static const String twitterIcon = '$_svgPath/twitter.svg';
  static const String linkedinIcon = '$_svgPath/linkedin.svg';
  static const String githubIcon = '$_svgPath/github.svg';
}
