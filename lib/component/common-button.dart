import 'package:flutter/material.dart';
import 'package:tamasya/style/style.dart';

class CommonButton extends StatelessWidget {
  final void Function() onPressed;
  final Widget child;
  final Color color;
  final Color textColor;
  final bool loading;
  final ShapeBorder shape;
  final double minWidth;
  final double height;
  final double elevation;

  CommonButton(
      {Key key,
      this.shape,
      this.onPressed,
      this.elevation,
      this.child,
      this.minWidth,
      this.height,
      this.loading = false,
      this.color = Style.primaryBlue,
      this.textColor = Colors.white})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: minWidth,
      shape: shape ??
          RoundedRectangleBorder(borderRadius: Style.borderRadius()),
      elevation: elevation,
      height: height ?? Style.fieldhHeight,
      textTheme: ButtonTheme.of(context).textTheme,
      child: loading
          ? SizedBox(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
              height: 18,
              width: 18)
          : child,
      color: color,
      textColor: color == null ? Colors.black87 : textColor,
      onPressed: loading ? () => {} : onPressed,
    );
  }
}
