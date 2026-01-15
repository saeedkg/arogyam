import 'package:flutter/material.dart';

/// Represents the four corner positions where the minimized call widget can snap to
enum CornerPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;

  /// Gets the offset for this corner position given screen and widget dimensions
  /// 
  /// [screenSize] - The size of the screen
  /// [widgetSize] - The size of the minimized widget
  /// [padding] - The padding from screen edges (default 16px)
  Offset getOffset(Size screenSize, Size widgetSize, double padding) {
    switch (this) {
      case CornerPosition.topLeft:
        return Offset(padding, padding);
      case CornerPosition.topRight:
        return Offset(
          screenSize.width - widgetSize.width - padding,
          padding,
        );
      case CornerPosition.bottomLeft:
        return Offset(
          padding,
          screenSize.height - widgetSize.height - padding,
        );
      case CornerPosition.bottomRight:
        return Offset(
          screenSize.width - widgetSize.width - padding,
          screenSize.height - widgetSize.height - padding,
        );
    }
  }

  /// Finds the nearest corner position to the given position on the screen
  /// 
  /// [position] - The current position to find the nearest corner for
  /// [screenSize] - The size of the screen
  /// 
  /// Returns the corner position that is closest to the given position
  static CornerPosition findNearest(Offset position, Size screenSize) {
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;

    final isLeft = position.dx < centerX;
    final isTop = position.dy < centerY;

    if (isTop && isLeft) return CornerPosition.topLeft;
    if (isTop && !isLeft) return CornerPosition.topRight;
    if (!isTop && isLeft) return CornerPosition.bottomLeft;
    return CornerPosition.bottomRight;
  }

  /// Returns a human-readable name for this corner position
  String get displayName {
    switch (this) {
      case CornerPosition.topLeft:
        return 'Top Left';
      case CornerPosition.topRight:
        return 'Top Right';
      case CornerPosition.bottomLeft:
        return 'Bottom Left';
      case CornerPosition.bottomRight:
        return 'Bottom Right';
    }
  }
}
