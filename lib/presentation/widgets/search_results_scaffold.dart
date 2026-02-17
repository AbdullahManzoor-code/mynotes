import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class SearchResultsScaffold extends StatelessWidget {
  final String title;
  final bool isLoading;
  final String? errorMessage;
  final bool isEmpty;
  final Widget emptyState;
  final Widget resultsHeader;
  final Widget resultsList;
  final Color backgroundColor;
  final Color appBarColor;
  final IconThemeData iconTheme;

  const SearchResultsScaffold({
    super.key,
    required this.title,
    required this.isLoading,
    required this.errorMessage,
    required this.isEmpty,
    required this.emptyState,
    required this.resultsHeader,
    required this.resultsList,
    required this.backgroundColor,
    required this.appBarColor,
    required this.iconTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: AppTypography.displayMedium(
            context,
            iconTheme.color ?? AppColors.darkText,
          ),
        ),
        centerTitle: true,
        backgroundColor: appBarColor,
        elevation: 0,
        iconTheme: iconTheme,
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: AppSpacing.paddingAllL,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 48,
              ),
              AppSpacing.gapM,
              Text(
                errorMessage!,
                style: AppTypography.bodyMedium(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (isEmpty) {
      return emptyState;
    }

    return Column(
      children: [
        resultsHeader,
        Expanded(child: resultsList),
      ],
    );
  }
}
