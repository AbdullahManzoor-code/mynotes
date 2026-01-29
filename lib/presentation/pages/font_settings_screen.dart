import 'package:flutter/material.dart';
import '../design_system/design_system.dart';
import '../../core/services/theme_customization_service.dart';

/// Font Settings Screen
/// Allows users to customize font family and font size scaling (THM-002, THM-003)
class FontSettingsScreen extends StatefulWidget {
  const FontSettingsScreen({super.key});

  @override
  State<FontSettingsScreen> createState() => _FontSettingsScreenState();
}

class _FontSettingsScreenState extends State<FontSettingsScreen> {
  AppFontFamily _selectedFont = AppFontFamily.system;
  FontSizeScale _selectedScale = FontSizeScale.normal;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    try {
      final font = await ThemeCustomizationService.getFontFamily();
      final scale = await ThemeCustomizationService.getFontSizeScale();
      
      setState(() {
        _selectedFont = font;
        _selectedScale = scale;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateFont(AppFontFamily font) async {
    setState(() {
      _selectedFont = font;
    });
    
    await ThemeCustomizationService.setFontFamily(font);
    AppTypography.updateFontSettings(font, _selectedScale.scale);
    
    if (mounted) {
      // Trigger a rebuild of the entire app to apply font changes
      final navigator = Navigator.of(context);
      if (navigator.mounted) {
        // Show feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Font changed to ${font.displayName}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _updateScale(FontSizeScale scale) async {
    setState(() {
      _selectedScale = scale;
    });
    
    await ThemeCustomizationService.setFontSizeScale(scale);
    AppTypography.updateFontSettings(_selectedFont, scale.scale);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Font size changed to ${scale.displayName}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Font Settings',
            style: AppTypography.heading2(context, AppColors.textPrimary(context)),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Font Settings',
          style: AppTypography.heading2(context, AppColors.textPrimary(context)),
        ),
        actions: [
          TextButton(
            onPressed: _resetToDefaults,
            child: Text(
              'Reset',
              style: AppTypography.labelMedium(context, AppColors.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Font Family Section
            _buildSectionHeader('Font Family'),
            _buildFontFamilyList(),
            
            const SizedBox(height: 32),
            
            // Font Size Section
            _buildSectionHeader('Font Size'),
            _buildFontSizeList(),
            
            const SizedBox(height: 32),
            
            // Preview Section
            _buildSectionHeader('Preview'),
            _buildPreviewSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: AppTypography.labelLarge(context, AppColors.textPrimary(context)),
      ),
    );
  }

  Widget _buildFontFamilyList() {
    return Column(
      children: AppFontFamily.values.map((font) {
        return _buildFontFamilyOption(font);
      }).toList(),
    );
  }

  Widget _buildFontFamilyOption(AppFontFamily font) {
    final isSelected = font == _selectedFont;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primary.withOpacity(0.1) 
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? AppColors.primary 
              : AppColors.border(context),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          font.displayName,
          style: font.getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary(context),
          ),
        ),
        subtitle: Text(
          'The quick brown fox jumps over the lazy dog',
          style: font.getTextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context),
          ),
        ),
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: AppColors.primary)
            : null,
        onTap: () => _updateFont(font),
      ),
    );
  }

  Widget _buildFontSizeList() {
    return Column(
      children: FontSizeScale.values.map((scale) {
        return _buildFontSizeOption(scale);
      }).toList(),
    );
  }

  Widget _buildFontSizeOption(FontSizeScale scale) {
    final isSelected = scale == _selectedScale;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primary.withOpacity(0.1) 
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? AppColors.primary 
              : AppColors.border(context),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          scale.displayName,
          style: _selectedFont.getTextStyle(
            fontSize: 16 * scale.scale,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary(context),
          ),
        ),
        subtitle: Text(
          '${(scale.scale * 100).toInt()}% of normal size',
          style: _selectedFont.getTextStyle(
            fontSize: 14,
            color: AppColors.textSecondary(context),
          ),
        ),
        trailing: isSelected 
            ? Icon(Icons.check_circle, color: AppColors.primary)
            : null,
        onTap: () => _updateScale(scale),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview Text',
            style: _selectedFont.getTextStyle(
              fontSize: 24 * _selectedScale.scale,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is how your text will look with the current font settings. The quick brown fox jumps over the lazy dog.',
            style: _selectedFont.getTextStyle(
              fontSize: 16 * _selectedScale.scale,
              color: AppColors.textPrimary(context),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Small text example for readability testing.',
            style: _selectedFont.getTextStyle(
              fontSize: 14 * _selectedScale.scale,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetToDefaults() async {
    await _updateFont(AppFontFamily.system);
    await _updateScale(FontSizeScale.normal);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Font settings reset to defaults'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}