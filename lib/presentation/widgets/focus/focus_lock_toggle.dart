import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mynotes/presentation/bloc/focus/focus_bloc.dart';

/// Toggle for focus lock with optional PIN setup.
class FocusLockToggle extends StatelessWidget {
  const FocusLockToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FocusBloc, FocusState>(
      buildWhen: (previous, current) {
        return previous.isLockEnabled != current.isLockEnabled ||
            previous.lockPin != current.lockPin;
      },
      builder: (context, state) {
        final controller = TextEditingController(text: state.lockPin ?? '');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              activeColor: Colors.greenAccent,
              title: const Text(
                'Lock screen during focus',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Block navigation while the timer runs',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              value: state.isLockEnabled,
              onChanged: (val) {
                context.read<FocusBloc>().add(ToggleFocusLockEvent(val));
              },
            ),
            if (state.isLockEnabled) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  controller: controller,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Optional PIN to stop',
                  ),
                  onChanged: (value) {
                    context.read<FocusBloc>().add(
                      UpdateFocusLockPinEvent(value),
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
            ],
          ],
        );
      },
    );
  }
}
