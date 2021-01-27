import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tamasya/component/dialogues.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/main-widget.dart';
import 'package:tamasya/router/router.dart';
import 'package:tamasya/service/custom-dio.dart';
import 'package:tamasya/style/style.dart';

class MainApp {
  static StatelessWidget _mainApp;

  static Future<bool> _requestLocationPermission(
      {Function onPermissionDenied}) async {
    var granted = await _requestPermission(Permission.location) ?? false;
    if (!granted) {
      _requestLocationPermission();
    }

    return granted;
  }

  static Future<bool> _requestPermission(Permission permission) async {
    bool granted = await Permission.location.request().isGranted;

    return granted ?? false;
  }

  static Future<void> _checkGps() async {
    MainWidgetController.instance.isModalGpsShowed = true;

    String title = "Can't get gurrent location";
    String subtitle = "Please make sure you enable GPS and try again";

    showAlertDialog(title, subtitle, Get.overlayContext,
            closeText: "Close Application", fnClose: () {
      SystemNavigator.pop();
    }, fnAction: _onActionGpsChecked, barrierDismissible: false)
        .then((_) {
      MainWidgetController.instance.isModalGpsShowed = false;
    });
  }

  static _onActionGpsChecked() {
    final AndroidIntent intent =
        AndroidIntent(action: 'android.settings.LOCATION_SOURCE_SETTINGS');
    // Navigator.of(Get.overlayContext, rootNavigator: true).pop();
    intent.launch();
    Get.back();
    _gpsService();
  }

  static Future<void> _gpsService() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      _checkGps();
    }
  }

  static StatelessWidget getMainApp() {
    Intl.defaultLocale = "id_ID";
    initializeDateFormatting('id_ID');

    if (_mainApp == null) {
      _mainApp = GetMaterialApp(
          navigatorKey: Get.key,
          transitionDuration: Duration(milliseconds: 309),
          defaultTransition: Transition.noTransition,
          debugShowCheckedModeBanner: false,
          theme: Style.theme,
          initialRoute: Routers.initialRoute,
          builder: (_, widget) => MainWidget(widget),
          getPages: Routers.pages,
          onInit: () {
            _requestLocationPermission().then((value) => value
                ? _gpsService()
                : showAlertDialog(
                    "Oops",
                    "Can't start application without gps permission",
                    Get.overlayContext,
                    barrierDismissible: false, fnClose: () {
                    SystemNavigator.pop();
                  }));
          },
          initialBinding: MainBinding(),
          routingCallback: (Routing routing) {
            bool isUnknown = (routing.current?.isEmpty ?? true);
            MainWidgetController.instance.isNavigationUnknown.value = isUnknown;
            MainWidgetController.instance.currentRoute = routing.current;
            CustomDio.cancelRequest();
          });
    }

    return _mainApp;
  }
}

class MainBinding implements Bindings {
  @override
  dependencies() {
    Get.put(MainWidgetController());
  }
}
