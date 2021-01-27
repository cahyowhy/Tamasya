import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tamasya/style/style.dart';

enum NotificationType { INFO, DANGER, SUCCESS, WARNING }

class Notification {
  static showNotification(
      {String message,
      String title,
      NotificationType notificationType,
      bool status = false}) {
    var typeNotif = type(notificationType);

    Color backgroundColor = typeNotif["SUCCESS"]
        ? Style.primary
        : typeNotif["DANGER"]
            ? Style.danger
            : typeNotif["INFO"]
                ? Style.primaryBlue
                : typeNotif["WARNING"] ? Style.accent : Colors.white;

    Color colorText = typeNotif["INFO"] ? Style.primaryBlueDark : Colors.white;

    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: backgroundColor,
        textColor: colorText,
        fontSize: 16.0);
  }

  static dynamic type(NotificationType notificationType) {
    return {
      "INFO": notificationType == NotificationType.INFO,
      "WARNING": notificationType == NotificationType.WARNING,
      "DANGER": notificationType == NotificationType.DANGER,
      "SUCCESS": notificationType == NotificationType.SUCCESS,
    };
  }
}
