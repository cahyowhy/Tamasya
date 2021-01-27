import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamasya/style/style.dart';

class FormHead extends StatelessWidget {
  final String title;
  final String rightTitle;
  final Widget rightWidget;
  final Widget leftWidget;
  final double bottom;
  final double height;
  final Function() onBack;
  final Color bgColor;
  final Color textColor;
  final List<BoxShadow> boxShadows;

  const FormHead(
      {Key key,
      this.title,
      this.rightTitle,
      this.rightWidget,
      this.leftWidget,
      this.bottom = 8,
      this.bgColor = Colors.white,
      this.textColor = Style.textColor,
      this.height = 52,
      this.boxShadows,
      this.onBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: EdgeInsets.only(bottom: this.bottom),
      padding: EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      decoration: BoxDecoration(
          color: bgColor,
          boxShadow: boxShadows ??
              [
                BoxShadow(
                  blurRadius: 10,
                  color: Color.fromRGBO(0, 0, 0, .12),
                  offset: new Offset(0, 1),
                )
              ]),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leftWidget ??
                InkWell(
                  onTap: onBack ?? Get.back,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(Icons.arrow_back),
                  ),
                ),
            Expanded(
                child: Text(
              title,
              style: TextStyle(
                  fontSize: 18, color: textColor, fontWeight: FontWeight.w500),
            )),
            rightWidget != null
                ? rightWidget
                : rightTitle != null
                    ? Text(rightTitle,
                        style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                            fontWeight: FontWeight.bold))
                    : SizedBox(width: 0)
          ]),
    );
  }
}
