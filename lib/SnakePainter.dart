import 'dart:ui';

import 'package:flutter/material.dart';
class SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final String foodEmoji;

  SnakePainter(this.snake, this.food, this.foodEmoji);

  @override
  void paint(Canvas canvas, Size size) {
    // ✅ Draw the food emoji clearly
    final textStyle = TextStyle(
      fontSize: 30,
      color: Colors.white, // Ensure visible on black background
    );

    final textSpan = TextSpan(text: foodEmoji, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    // Offset correction to center emoji
    final foodOffset = Offset(
      food.dx - textPainter.width / 2,
      food.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, foodOffset);

    // ✅ Draw the snake
    for (int i = 0; i < snake.length; i++) {
      double t = i / snake.length;
      final color = HSVColor.lerp(
        HSVColor.fromAHSV(1.0, 280, 1, 1),
        HSVColor.fromAHSV(1.0, 360, 1, 1),
        t,
      )!
          .toColor();
      final paint = Paint()..color = color;
      canvas.drawCircle(snake[i], 6, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
