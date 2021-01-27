import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamasya/component/main-tab-navigation.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/model/airport.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/type-def.dart';

class MainWidget extends StatelessWidget {
  final Widget widget;
  const MainWidget(this.widget, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget titleAppbar = Obx(
      () {
        if (MainWidgetController.instance.finalHideAppBottomBar) {
          return SizedBox();
        }

        bool isChildPages =
            MainWidgetController.instance.isNavigationChildPages.value;

        if (!MainWidgetController.instance.loadingData.value) {
          String location =
              MainWidgetController.instance.userPreviewLocation.value;
          if (location.isEmpty) location = "Jakarta";

          Widget titleAppbarWidget = Text(location,
              style: TextStyle(
                  color: isChildPages ? Colors.white : Style.textColor));

          if (isChildPages) {
            titleAppbarWidget = Row(
              children: [
                InkWell(
                  onTap: () {
                    // if ([
                    //   InspirationSearch.RouteName,
                    //   CheapestFlightOffer.RouteName
                    // ].contains(MainWidgetController.instance.currentRoute)) {
                    //   Get.offNamed(FlightScreen.RouteName);
                    // }
                  },
                  child: Image.asset("assets/image/png/icon-menu.png",
                      width: 24, height: 24),
                ),
                SizedBox(width: 16),
                Expanded(child: titleAppbarWidget)
              ],
            );
          }

          return titleAppbarWidget;
        }

        return Container(
          height: 18,
          width: 200,
          decoration: BoxDecoration(
              color: Style.backgroundGreyLight,
              borderRadius: Style.borderRadius()),
        );
      },
    );

    Widget userAirports = Obx(() {
      if (MainWidgetController.instance.finalHideAppBottomBar) {
        return SizedBox();
      }

      bool isChildPages =
          MainWidgetController.instance.isNavigationChildPages.value;
      bool showUserAirPorts =
          MainWidgetController.instance.userAirports.isNotEmpty &&
              !isChildPages &&
              MainWidgetController.instance.userAirports.isNotEmpty;

      if (showUserAirPorts) {
        return Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: MainWidgetController.instance.userAirports.length,
                itemBuilder: (_, i) {
                  Airport airport =
                      MainWidgetController.instance.userAirports[i];
                  int length =
                      MainWidgetController.instance.userAirports.length;

                  return InkWell(
                    onTap: () =>
                        MainWidgetController.instance.onChangeActiveAirport(i),
                    child: Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      margin: EdgeInsets.only(right: i < length - 1 ? 8 : 0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: Style.borderRadius(param: 12),
                        color:
                            airport.activeMark ? Style.accent : Style.greyLight,
                      ),
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Icon(airport.activeMark ? Icons.check : Icons.close,
                              color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            airport?.iata ?? "",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  );
                }));
      }

      return SizedBox();
    });

    Widget appBar = Obx(() {
      if (MainWidgetController.instance.finalHideAppBottomBar) {
        return SizedBox();
      }

      bool isChildPages =
          MainWidgetController.instance.isNavigationChildPages.value;

      return AppBar(
        title: titleAppbar,
        backgroundColor: isChildPages ? Style.primary : Colors.white,
        elevation: 0,
        actions: toList(() sync* {
          if (!isChildPages) {
            yield InkWell(
              onTap: () async {
                if (!MainWidgetController.instance.loadingData.value) {
                  MainWidgetController.instance.loadingData.value = true;
                  await MainWidgetController.instance.doFindUserLocation();
                  MainWidgetController.instance.loadingData.value = false;
                }
              },
              child: Container(
                width: 42,
                alignment: Alignment.center,
                child: Icon(Icons.gps_fixed,
                    color: isChildPages ? Colors.white : Style.textColor),
              ),
            );

            yield SizedBox(width: 8);
          }
          yield InkWell(
            onTap: () {
              if (!MainWidgetController.instance.loadingData.value) {
                MainWidgetController.instance.onShowInputPlace();
              }
            },
            child: Container(
              width: 42,
              alignment: Alignment.center,
              child: Icon(Icons.search,
                  color: isChildPages ? Colors.white : Style.textColor),
            ),
          );
        }),
      );
    });

    return SafeArea(
      child: Scaffold(
        backgroundColor: Style.background,
        body: Column(
          children: [
            appBar,
            userAirports,
            Expanded(
              child: Obx(() => Padding(
                    padding: EdgeInsets.only(
                        top: MainWidgetController.instance.finalHideAppBottomBar
                            ? 0
                            : 16),
                    child: this.widget,
                  )),
            ),
          ],
        ),
        bottomNavigationBar: Obx(() {
          if (MainWidgetController.instance.finalHideAppBottomBar) {
            return SizedBox();
          }

          return MainTabNavigation();
        }),
      ),
    );
  }
}
