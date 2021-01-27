import 'package:flutter/material.dart';

class DashLine extends StatelessWidget {
  final double height;
  final Color color;
  final Widget centerWidget;

  const DashLine(
      {this.height = 1, this.color = Colors.black, this.centerWidget});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashWidth = 10.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (int i) {
            Widget childWidget =
                i == (dashCount / 2).floor() && centerWidget != null
                    ? centerWidget
                    : SizedBox(
                        width: dashWidth,
                        height: dashHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: color),
                        ),
                      );

            return childWidget;
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}
