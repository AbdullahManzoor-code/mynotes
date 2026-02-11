import 'package:flutter/material.dart';

class AnnotationStroke {
  final List<Offset> points; // Normalized (0.0 - 1.0)
  final Color color;
  final double strokeWidth;

  AnnotationStroke({
    required this.points,
    this.color = Colors.red,
    this.strokeWidth = 3.0,
  });

  Map<String, dynamic> toJson() => {
    'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
    'color': color.value,
    'strokeWidth': strokeWidth,
  };

  factory AnnotationStroke.fromJson(Map<String, dynamic> json) {
    return AnnotationStroke(
      points: (json['points'] as List)
          .map(
            (p) =>
                Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble()),
          )
          .toList(),
      color: Color(json['color'] as int),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
    );
  }
}
