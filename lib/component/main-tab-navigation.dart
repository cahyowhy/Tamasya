import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/screen/flight-offer-screen.dart';
import 'package:tamasya/screen/hotel-offer-screen.dart';
import 'package:tamasya/screen/tour-activitiy-screen.dart';
import 'package:tamasya/style/style.dart';

class TabSection {
  TabSection(this.icon, this.name, {this.active = false});
  IconData icon;
  String name;
  bool active;

  TabSection copyWith({String icon, String name, bool active = false}) {
    return TabSection(icon ?? this.icon, name ?? this.name)..active = active;
  }
}

class MainTabNavigationController extends GetxController {
  RxList<TabSection> tabSections = RxList<TabSection>([]);

  @override
  void onInit() {
    super.onInit();

    String currRoute = Get.rawRoute.settings.name;

    tabSections.value = [
      TabSection(Icons.flight_takeoff, FlightOfferScreen.RouteName,
          active: currRoute == FlightOfferScreen.RouteName),
      TabSection(Icons.hotel, HotelOfferScreen.RouteName,
          active: currRoute == HotelOfferScreen.RouteName),
      TabSection(Icons.directions_walk, TourActivitiyScreen.RouteName,
          active: currRoute == TourActivitiyScreen.RouteName),
    ];
  }

  onNavigateTo(String routeName) {
    int idxAt = tabSections.indexWhere((element) => element.name == routeName);

    if (idxAt > -1) {
      int idx = 0;

      tabSections.forEach((element) {
        tabSections[idx] = tabSections[idx].copyWith(active: idx == idxAt);

        idx += 1;
      });
    }

    Get.offNamed(routeName);
  }
}

class MainTabNavigation extends StatelessWidget {
  const MainTabNavigation({Key key}) : super(key: key);

  Widget iconContent(
      TabSection tabSection, MainTabNavigationController controller) {
    Widget child = Icon(tabSection.icon,
        size: 28, color: tabSection.active ? Style.primary : Colors.white);

    if (tabSection.active) {
      bool isCenter = tabSection.name == HotelOfferScreen.RouteName;
      bool isEnd = tabSection.name == TourActivitiyScreen.RouteName;

      child = Container(
        height: 64,
        child: child,
        decoration: BoxDecoration(
            color: Style.primaryLight,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isCenter || !isEnd ? 0 : 250),
                bottomLeft: Radius.circular(isCenter || !isEnd ? 0 : 250),
                topRight: Radius.circular(isCenter || isEnd ? 0 : 250),
                bottomRight: Radius.circular(isCenter || isEnd ? 0 : 250))),
      );
    }
    return Expanded(
      child: InkWell(
        onTap: () => controller.onNavigateTo(tabSection.name),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainTabNavigationController>(
      init: MainTabNavigationController(),
      builder: (controller) => Obx(() {
        bool loading = MainWidgetController.instance.loadingData.value;

        return Container(
            height: 64,
            alignment: Alignment.center,
            child: loading
                ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        borderRadius: Style.borderRadius(),
                        color: Style.backgroundGreyLight),
                    height: 32)
                : Row(
                    children: controller.tabSections
                        .map((item) => iconContent(item, controller))
                        .toList(),
                  ),
            decoration: BoxDecoration(
                color: loading ? Colors.white : Style.primary,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    color: Color.fromRGBO(0, 0, 0, .4),
                    offset: new Offset(0, 3),
                  )
                ]));
      }),
    );
  }
}
