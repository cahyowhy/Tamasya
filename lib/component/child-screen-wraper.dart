import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/type-def.dart';
import 'package:tamasya/util/underscore.dart';

class ChildScreenWraper extends StatelessWidget {
  final Widget child;

  const ChildScreenWraper({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Radius radius = Radius.circular(48);
    Widget userInfoLocation = Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(MainWidgetController.instance.userPreviewLocation.value,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w200)),
            SizedBox(height: 4),
            Text(MainWidgetController.instance.userAdministrativeArea.value,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w800)),
            SizedBox(height: 24),
          ],
        ));

    return Stack(
      children: [
        Container(
          height: (Get.height / 2) - 64,
          decoration: BoxDecoration(
              color: Style.primary,
              borderRadius:
                  BorderRadius.only(bottomLeft: radius, bottomRight: radius)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            children: toList(() sync* {
              yield Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: userInfoLocation),
                  SizedBox(width: 16),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(formatDate(date: DateTime.now()),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500)),
                  )
                ],
              );

              if (child != null) {
                yield SizedBox(width: 24);
                yield child;
              }
            }),
          ),
        )
      ],
    );
  }
}
