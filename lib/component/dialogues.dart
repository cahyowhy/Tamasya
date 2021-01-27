import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tamasya/component/common-button.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/type-def.dart';

Future<bool> showAlertDialog(String title, String content, BuildContext context,
    {List<Widget> actions,
    bool hideClose,
    String closeText,
    void Function() fnAction,
    void Function() fnClose,
    bool barrierDismissible = true,
    Color acceptColor,
    Color closeColor}) {
  final Color finalAcceptColor = acceptColor ?? Style.primaryBlue;
  final Color finalCloseColor = closeColor ?? Style.textColor;
  String closeTextFinal = closeText ?? 'Tutup';

  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible ?? true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: new Text(title),
        content: new Text(content),
        actions: toList(() sync* {
          if (actions != null) {
            yield* actions;
          } else if (fnAction != null) {
            yield FlatButton(
              child: Text("Ya", style: TextStyle(color: finalAcceptColor)),
              onPressed: fnAction,
            );
          } else {
            yield SizedBox(width: 0, height: 0);
          }

          if (!(hideClose ?? false)) {
            yield FlatButton(
              child: Text(closeTextFinal,
                  style: TextStyle(color: finalCloseColor)),
              onPressed: fnClose ?? () => Get.back(result: false),
            );
          }
        }),
      );
    },
  );
}

Future<bool> showDialogExitApp(BuildContext context,
    {bool skipCanPop = false}) async {
  bool canPop = Get.key.currentState.canPop();

  /// return true if there is more screen behind this screen
  /// so the app wont closed
  if (canPop && !skipCanPop) {
    return true;
  }

  return await showAlertDialog(
          "Info", "Apakah anda ingin menutup aplikasi", context,
          hideClose: true,
          actions: [
            CommonButton(
              elevation: 0,
              child: Text("Ya"),
              color: Colors.transparent,
              textColor: Style.primaryBlue,
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
            CommonButton(
              elevation: 0,
              color: Style.danger,
              child: Text("Tidak"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            )
          ]) ??
      false;
}

Future<dynamic> showDialogAnimation(BuildContext context, Widget child,
    {bool vertical = false,
    int duration = 250,
    bool barrierDismissible = true}) async {
  return await showGeneralDialog(
          barrierColor: Colors.black.withOpacity(0.5),
          transitionBuilder: (context, a1, a2, widget) {
            final curvedValue =
                (Curves.easeInOutBack.transform(a1.value) - 1.0) * 200;

            return Transform(
                transform: Matrix4.translationValues(
                    vertical ? 0 : curvedValue, vertical ? curvedValue : 0, 0),
                child: child);
          },
          transitionDuration: Duration(milliseconds: duration),
          barrierDismissible: barrierDismissible,
          barrierLabel: '',
          context: context,
          pageBuilder: (BuildContext context, Animation animation,
              Animation secondaryAnimation) {}) ??
      false;
}
