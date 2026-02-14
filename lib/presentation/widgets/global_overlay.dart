import 'package:flutter/material.dart';
import 'package:mynotes/core/services/global_ui_service.dart';
import 'package:mynotes/injection_container.dart';

/// Global Overlay Wrapper
/// Provides global loading indicator and other overlays
class GlobalOverlay extends StatelessWidget {
  final Widget child;

  const GlobalOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final uiService = getIt<GlobalUiService>();

    return Stack(
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
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
