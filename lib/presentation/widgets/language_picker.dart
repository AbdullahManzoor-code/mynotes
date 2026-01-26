import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/language_service.dart';

/// Language picker dialog widget
class LanguagePicker extends StatefulWidget {
  final String currentLocale;
  final Function(String) onLanguageSelected;

  const LanguagePicker({
    Key? key,
    required this.currentLocale,
    required this.onLanguageSelected,
  }) : super(key: key);

  @override
  State<LanguagePicker> createState() => _LanguagePickerState();

  /// Show language picker dialog
  static Future<String?> show(
    BuildContext context, {
    required String currentLocale,
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguagePicker(
        currentLocale: currentLocale,
        onLanguageSelected: (locale) {
          Navigator.pop(context, locale);
        },
      ),
    );
  }
}

class _LanguagePickerState extends State<LanguagePicker> {
  final LanguageService _languageService = LanguageService();
  final TextEditingController _searchController = TextEditingController();
  List<LanguageOption> _filteredLanguages = [];
  String _selectedLocale = '';

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.currentLocale;
    _filteredLanguages = _languageService.getLanguageOptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLanguages(String query) {
    setState(() {
      _filteredLanguages = _languageService.searchLanguages(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  color: AppColors.primaryColor,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              controller: _searchController,
              onChanged: _filterLanguages,
              decoration: InputDecoration(
                hintText: 'Search languages...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Popular languages section (if no search)
          if (_searchController.text.isEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Popular',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            _buildPopularLanguages(isDark),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'All Languages',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],

          // Language list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: _filteredLanguages.length,
              itemBuilder: (context, index) {
                final language = _filteredLanguages[index];
                final isSelected = language.localeId == _selectedLocale;

                return _buildLanguageTile(
                  language: language,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () {
                    setState(() => _selectedLocale = language.localeId);
                    widget.onLanguageSelected(language.localeId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularLanguages(bool isDark) {
    final popular = _languageService.getPopularLanguages();

    return SizedBox(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: popular.length,
        itemBuilder: (context, index) {
          final language = popular[index];
          final isSelected = language.localeId == _selectedLocale;

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(language.displayName.split('(')[0].trim()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedLocale = language.localeId);
                  widget.onLanguageSelected(language.localeId);
                }
              },
              selectedColor: AppColors.primaryColor,
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade100,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLanguageTile({
    required LanguageOption language,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : (isDark
                    ? Colors.grey.shade800.withOpacity(0.3)
                    : Colors.transparent),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              language.displayName,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? AppColors.primaryColor
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
