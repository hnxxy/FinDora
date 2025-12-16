import 'package:flutter/material.dart';

class BatteryIndicator extends StatelessWidget {
  final int level;
  final double width;
  final double height;
  final Color fillColor;

  const BatteryIndicator({
    super.key,
    required this.level,
    required this.width,
    required this.height,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: fillColor, width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: (level / 100) * (width - 2),
          height: height - 2,
          color: fillColor,
        ),
      ),
    );
  }
}
