import 'package:flutter/material.dart';
import 'package:tamasya/style/style.dart';

class ArrowExpand extends StatelessWidget {
  final Function onTap;
  final bool isExpanded;
  final bool isReverse;
  final Color color;
  final Color iconColor;
  final double height;
  final double width;
  final List<BoxShadow> boxShadows;
  final EdgeInsets padding;
  final Widget child;
  final BorderRadius borderRadius;
  const ArrowExpand(
      {Key key,
      @required this.onTap,
      this.isExpanded = false,
      this.isReverse = false,
      this.color,
      this.height = 32,
      this.boxShadows,
      this.child,
      this.padding,
      this.iconColor,
      this.borderRadius,
      this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget containerChild = Icon(
        isExpanded
            ? (isReverse ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up)
            : (isReverse ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
        color: iconColor ?? Style.textColor);

    if (child != null) {
      containerChild = Row(
        children: [Expanded(child: child), containerChild],
      );
    }
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        padding: padding,
        child: containerChild,
        decoration: BoxDecoration(
            boxShadow: boxShadows,
            color: color ?? Colors.white,
            borderRadius: borderRadius ??
                BorderRadius.only(
                    topLeft: Radius.circular(isReverse ? 12 : 0),
                    topRight: Radius.circular(isReverse ? 12 : 0),
                    bottomLeft: Radius.circular(isReverse ? 0 : 12),
                    bottomRight: Radius.circular(isReverse ? 0 : 12))),
      ),
    );
  }
}
