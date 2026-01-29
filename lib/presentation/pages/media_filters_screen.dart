import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../design_system/design_system.dart';

/// Media Filters & Effects Screen
/// Apply filters to images: Grayscale, Sepia, Blur, Brightness, etc.
class MediaFiltersScreen extends StatefulWidget {
  final String imagePath;
  final String imageTitle;

  const MediaFiltersScreen({
    super.key,
    required this.imagePath,
    required this.imageTitle,
  });

  @override
  State<MediaFiltersScreen> createState() => _MediaFiltersScreenState();
}

class _MediaFiltersScreenState extends State<MediaFiltersScreen> {
  late FilterController _filterController;
  FilterType _selectedFilter = FilterType.none;
  double _filterIntensity = 50;
  bool _showPreview = true;

  @override
  void initState() {
    super.initState();
    _filterController = FilterController();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildFilterAppBar(context),
      body: Column(
        children: [
          // Image Preview
          Expanded(child: _buildImagePreview(context)),
          // Filter Controls
          _buildFilterControls(context),
          // Filter Grid
          _buildFilterGrid(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildFilterAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Edit Photo',
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
      actions: [
        TextButton(
          onPressed: () => _saveFilteredImage(),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Placeholder image
          Container(
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 64, color: Colors.grey[600]),
                  SizedBox(height: 16.h),
                  Text(
                    'Image Preview',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  if (_selectedFilter != FilterType.none)
                    Column(
                      children: [
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            '${_selectedFilter.name.toUpperCase()}: ${_filterIntensity.toInt()}%',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          // Before/After Toggle
          if (_showPreview)
            Positioned(
              top: 12.h,
              right: 12.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'After',
                  style: TextStyle(fontSize: 12.sp, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterControls(BuildContext context) {
    if (_selectedFilter == FilterType.none) {
      return SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(top: BorderSide(color: AppColors.divider(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Intensity',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
              Text(
                '${_filterIntensity.toInt()}%',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Slider(
            value: _filterIntensity,
            onChanged: (value) {
              setState(() => _filterIntensity = value);
              _filterController.setIntensity(value);
            },
            min: 0,
            max: 100,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() => _filterIntensity = 0);
                  _filterController.reset();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // Compare before/after
                  setState(() => _showPreview = !_showPreview);
                },
                icon: const Icon(Icons.compare),
                label: const Text('Compare'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterGrid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filters = [
      FilterOption(FilterType.none, 'None', Icons.image),
      FilterOption(FilterType.grayscale, 'Grayscale', Icons.tonality),
      FilterOption(FilterType.sepia, 'Sepia', Icons.landscape),
      FilterOption(FilterType.blur, 'Blur', Icons.blur_on),
      FilterOption(FilterType.brightness, 'Bright', Icons.wb_sunny),
      FilterOption(FilterType.contrast, 'Contrast', Icons.brightness_high),
      FilterOption(FilterType.saturation, 'Saturate', Icons.palette),
      FilterOption(FilterType.invert, 'Invert', Icons.invert_colors),
      FilterOption(FilterType.vintage, 'Vintage', Icons.camera_alt),
    ];

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(top: BorderSide(color: AppColors.divider(context))),
      ),
      child: SizedBox(
        height: 100.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = _selectedFilter == filter.type;

            return Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter.type;
                    _filterIntensity = 50;
                  });
                  _filterController.applyFilter(filter.type);
                },
                child: Column(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.primaryColor,
                                width: 2,
                              )
                            : Border.all(color: AppColors.divider(context)),
                        color: Colors.grey[300],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            filter.icon,
                            size: 24.sp,
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.grey[600],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            filter.name,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _saveFilteredImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Filtered Image'),
        content: const Text('Save this filtered image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filtered image saved successfully'),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Filter Types
enum FilterType {
  none,
  grayscale,
  sepia,
  blur,
  brightness,
  contrast,
  saturation,
  invert,
  vintage,
}

// Filter Option Model
class FilterOption {
  final FilterType type;
  final String name;
  final IconData icon;

  FilterOption(this.type, this.name, this.icon);
}

// Filter Controller
class FilterController {
  FilterType _currentFilter = FilterType.none;
  double _currentIntensity = 50;

  void applyFilter(FilterType type) {
    _currentFilter = type;
  }

  void setIntensity(double intensity) {
    _currentIntensity = intensity;
  }

  void reset() {
    _currentFilter = FilterType.none;
    _currentIntensity = 0;
  }

  void dispose() {
    // Cleanup
  }
}

