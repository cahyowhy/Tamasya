import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/type-def.dart';

class EmptyContent extends StatelessWidget {
  final String text;
  final Widget child;
  final Color fontColor;
  final double fontSize;
  final double fontSpacing;
  final String asset;
  final FontWeight fontWeight;
  EmptyContent(
      {this.text,
      Key key,
      this.child,
      this.fontColor,
      this.fontSize,
      this.fontWeight,
      this.fontSpacing,
      this.asset = "assets/image/png/pict-empty.png"})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      
      width: double.infinity,
      height: Get.height / 2 - 80,
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
          color: Style.background, 
          borderRadius: Style.borderRadius(param: 12)),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: toList(() sync* {
            yield Image.asset(
              asset,
              width: 96,
            );
            yield Text(
              text ?? "No more content to load",
              textAlign: TextAlign.center,
              style: TextStyle(
                  letterSpacing: fontSpacing ?? 1,
                  fontWeight: fontWeight ?? FontWeight.normal,
                  color: fontColor ?? Style.greyLight,
                  fontSize: fontSize ?? 18),
            );

            if (child != null) {
              yield child;
            }
          })),
    );
  }
}
