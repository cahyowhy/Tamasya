import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamasya/component/column-builder.dart';
import 'package:tamasya/component/common-map.dart';
import 'package:tamasya/component/empty-content.dart';
import 'package:tamasya/component/info-screen.dart';
import 'package:tamasya/component/placeholder-item.dart';
import 'package:tamasya/component/tour-activity-item.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/model/location.dart';
import 'package:tamasya/model/tour-activity.dart';
import 'package:tamasya/service/tour-activities-service.dart';
import 'package:latlong/latlong.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/storage.dart';
import 'package:tamasya/util/underscore.dart' as Underscore;

class TourActivitiyScreenController extends GetxController {
  TourActivityService tourActivityService = TourActivityService.instance;

  StreamSubscription subscription;

  RxBool isLoading = false.obs;

  RxDouble latitude = (0.0).obs;

  RxDouble longitude = (0.0).obs;

  RxDouble radius = (20.0).obs;

  Rx<Location> userLocation = Rx<Location>();

  RxList<TourActivity> tourActivities = RxList<TourActivity>([]);

  bool get hasUserLatLng {
    return this.latitude?.value != null && this.longitude?.value != null;
  }

  @override
  onClose() {
    super.onClose();
    if (subscription != null) subscription.cancel();
  }

  List<LatLng> get tourLatLngs {
    if (tourActivities.length > 0) {
      return tourActivities
          .map((item) {
            if (item?.geoCode?.latitude != null &&
                item?.geoCode?.longitude != null) {
              return LatLng(
                  item.geoCode.latitudeFmt, item.geoCode.longitudeFmt);
            }

            return null;
          })
          .where((element) => element != null)
          .toList();
    }

    return [];
  }

  @override
  onReady() {
    super.onReady();

    subscription = MainWidgetController.instance.globalEventOnNetworkError
        .on('onRefetchData', (_) => this.doFindTourActivities());

    if (MainWidgetController.instance.userLocation != null) {
      this.userLocation.value = Location.fromJson(
          MainWidgetController.instance.userLocation.toJson());

      this.latitude.value = this.userLocation.value.position.latitude;
      this.longitude.value = this.userLocation.value.position.longitude;
      this.userLocation.refresh();

      CacheTourStorage.getCacheTour().then((value) {
        if (value?.lat != null && value?.lng != null && value?.rad != null) {
          this.latitude.value = value.lat;
          this.longitude.value = value.lng;
          this.radius.value = value.rad;
        }

        if ((value?.lastToursActivities?.length ?? 0) > 0) {
          value.lastToursActivities.forEach((element) {
            this.tourActivities.add(TourActivity.fromJson(element.toJson()));
          });
        }
      }).whenComplete(() {
        if (this.tourActivities.length == 0) {
          this.doFindTourActivities();
        }
      });
    }
  }

  @override
  onInit() {
    super.onInit();

    this.doFindTourActivities();
  }

  doFindTourActivities() async {
    double latitude = this.latitude?.value;
    double longitude = this.longitude?.value;
    double radius = this.radius?.value ?? 20;

    if (!isLoading.value &&
        latitude != null &&
        longitude != null &&
        radius != null) {
      isLoading.value = true;
      tourActivities.clear();

      List<TourActivity> tourActivitiesResponse = await tourActivityService
          .getTourActivities(latitude, longitude, radius);

      tourActivities.addAll(tourActivitiesResponse);

      isLoading.value = false;

      CacheTourStorage.setCacheTour(
          latitude, longitude, radius, this.tourActivities.toList());
    }
  }

  onMapPositionChange(double rad, LatLng latLng) async {
    this.radius.value = rad;
    this.latitude.value = latLng.latitude;
    this.longitude.value = latLng.longitude;

    await Future.delayed(Duration(milliseconds: 100));
    Underscore.debounce(800, this.doFindTourActivities, []);
  }
}

class TourActivitiyScreen extends StatelessWidget {
  TourActivitiyScreen({Key key}) : super(key: key);

  static const String RouteName = "Tours and Activities";
  static const String Subtitle = "Find tour and activities near you";

  Widget build(BuildContext context) {
    return GetBuilder(
        init: TourActivitiyScreenController(),
        builder: (TourActivitiyScreenController controller) {
          Widget loadingItem = Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.only(bottom: 16),
            child: PlaceholderWidget(
                paddingTop: 32, paddingForRestItem: 12, repeat: 3),
          );

          return Container(
            color: Style.background,
            width: double.infinity,
            alignment: Alignment.center,
            child: ListView(padding: EdgeInsets.all(0), children: [
              InfoScreen(title: RouteName, subtitle: Subtitle),
              Obx(() {
                if (MainWidgetController.instance.loadingData.value) {
                  return loadingItem;
                }

                return SizedBox(height: 24);
              }),
              Obx(() => controller.hasUserLatLng &&
                      MainWidgetController.instance.loadingData.value
                  ? SizedBox()
                  : Align(
                      alignment: Alignment.center,
                      child: CommonMap(
                        latLng: LatLng(controller.latitude.value,
                            controller.longitude.value),
                        showBtnSearchPlace: true,
                        hideMainMarker: true,
                        borderRadiusMap: 6,
                        markers: controller.tourLatLngs,
                        width: Style.maxWidth(),
                        height: Style.maxWidth() / (3 / 4),
                        interactive: true,
                        onCurrentLocationFetched: (Location loc) {
                          controller.latitude.value = loc.position.latitude;
                          controller.longitude.value = loc.position.longitude;
                        },
                        onTapLocation: (double lat, double lng) {
                          controller.latitude.value = lat;
                          controller.longitude.value = lng;
                        },
                        onPositionChange: controller.onMapPositionChange,
                      ),
                    )),
              Obx(() {
                if (MainWidgetController.instance.loadingData.value) {
                  return SizedBox();
                }

                if (controller.isLoading.value) {
                  return loadingItem;
                } else if ((controller?.tourActivities?.length ?? 0) <= 0) {
                  return EmptyContent(
                      text: "No Tour & activities found",
                      child: Text("Try another location",
                          style:
                              TextStyle(fontSize: 12, color: Style.greyLight)));
                }

                var tourActivities = controller.tourActivities;

                return ColumnBuilder(
                  itemCount: tourActivities.length,
                  itemBuilder: (_, i) {
                    var e = tourActivities[i];
                    var padding = EdgeInsets.only(
                        top: i == 0 ? 32 : 0,
                        bottom: i == (tourActivities.length - 1) ? 60 : 24);

                    return Padding(
                        padding: padding,
                        child: TourActivityItem(tourActivity: e));
                  },
                );
              })
            ]),
          );
        });
  }
}
