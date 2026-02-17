import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/core/constants/app_colors.dart';
import 'package:mynotes/core/services/dnd_service.dart';
import 'package:mynotes/presentation/bloc/focus/focus_bloc.dart';

/// DND permission/status banner for the focus session screen.
class DndPermissionBanner extends StatelessWidget {
  const DndPermissionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!DndService.isPlatformSupported) return const SizedBox.shrink();

    return FutureBuilder<bool>(
      future: DndService.isDndPermissionGranted(),
      builder: (context, snapshot) {
        final hasPermission = snapshot.data ?? false;
        return BlocBuilder<FocusBloc, FocusState>(
          buildWhen: (previous, current) {
            return previous.distractionFreeMode !=
                current.distractionFreeMode ||
                previous.status != current.status;
          },
          builder: (context, state) {
            final showBanner =
                state.distractionFreeMode &&
                state.status != FocusStatus.completed;

            if (!showBanner) return const SizedBox.shrink();

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              child: GestureDetector(
                onTap: hasPermission
                    ? null
                    : () async {
                      await DndService.openDndSettings();
                    },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: hasPermission
                        ? AppColors.focusAccentGreen.withOpacity(0.15)
                        : Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: hasPermission
                          ? AppColors.focusAccentGreen.withOpacity(0.4)
                          : Colors.orange.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasPermission ? Icons.check_circle : Icons.warning,
                        color: hasPermission
                            ? AppColors.focusAccentGreen
                            : Colors.orange,
                        size: 18.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          hasPermission
                              ? 'DND permission granted'
                              : 'DND permission needed',
                          style: TextStyle(
                            color: hasPermission
                                ? AppColors.focusAccentGreen
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      if (!hasPermission) ...[
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.orange,
                          size: 16.sp,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
