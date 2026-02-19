import 'package:flutter/material.dart';
import 'package:mynotes/presentation/design_system/design_system.dart';

class RadiusSelectorWidget extends StatelessWidget {
  final double radius;
  final ValueChanged<double> onChanged;

  const RadiusSelectorWidget({
    super.key,
    required this.radius,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trigger Radius',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _formatRadius(radius),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Slider(
          value: radius,
          min: 50,
          max: 500,
          divisions: 9,
          label: _formatRadius(radius),
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              '50m',
              style: TextStyle(fontSize: 12, color: AppColors.grey500),
            ),
            Text(
              '500m',
              style: TextStyle(fontSize: 12, color: AppColors.grey500),
            ),
          ],
        ),
      ],
    );
  }

  static String _formatRadius(double meters) {
    if (meters < 1000) {
      return '${meters.toInt()}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }
}
