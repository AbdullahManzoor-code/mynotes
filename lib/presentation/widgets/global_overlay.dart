import 'package:flutter/material.dart';
import 'package:mynotes/core/services/global_ui_service.dart';
import 'package:mynotes/injection_container.dart';
import '../design_system/design_system.dart';

/// Global Overlay Wrapper
/// Provides global loading indicator and other overlays
class GlobalOverlay extends StatelessWidget {
  final Widget child;

  const GlobalOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final uiService = getIt<GlobalUiService>();

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        ValueListenableBuilder<bool>(
          valueListenable: uiService.loadingListenable,
          builder: (context, isLoading, _) {
            if (!isLoading) return const SizedBox.shrink();

            return Container(
              color: Colors.black45,
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(height: 16.h),
                        Text(
                          'Loading...',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
