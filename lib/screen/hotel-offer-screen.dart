import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamasya/component/column-builder.dart';
import 'package:tamasya/component/common-button.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/util/storage.dart';
import 'package:tamasya/util/underscore.dart' as Underscore;
import 'package:tamasya/component/common-map.dart';
import 'package:tamasya/component/empty-content.dart';
import 'package:tamasya/component/hotel-offer-filter.dart';
import 'package:tamasya/component/hotel-offers-item.dart';
import 'package:tamasya/component/info-screen.dart';
import 'package:tamasya/component/placeholder-item.dart';
import 'package:tamasya/model/arrow-expand.dart';
import 'package:tamasya/model/filter-hotel-offer.dart';
import 'package:tamasya/model/hotel-offer.dart';
import 'package:tamasya/model/location.dart';
import 'package:tamasya/service/hotel-offer-service.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/type-def.dart';
import 'package:latlong/latlong.dart';

class HotelOfferScreenController extends GetxController {
  HotelOfferService hottelOfferService = HotelOfferService.instance;

  final GlobalKey commonMapKey = new GlobalKey();

  StreamSubscription subscription;

  RxList<HotelOffer> hotelOffers = RxList<HotelOffer>([]);

  RxBool isLoading = false.obs;

  RxBool isMapExpanded = false.obs;

  RxBool showFilterMap = false.obs;

  RxBool showInputPlace = false.obs;

  Rx<FilterHotelOffer> filter = Rx<FilterHotelOffer>(FilterHotelOffer());

  RxBool mainFilterExpanded = false.obs;

  RxBool additionalFilterExpanded = false.obs;

  RxBool hasLoadMore = true.obs;

  Rx<StateActive> stateActive = Rx<StateActive>(StateActive.none);

  List<LatLng> get hotelLatLngs {
    if (hotelOffers.length > 0) {
      return hotelOffers
          .map((item) {
            if (item?.hotel?.latitude != null &&
                item?.hotel?.longitude != null) {
              return LatLng(item.hotel.latitude, item.hotel.longitude);
            }

            return null;
          })
          .where((element) => element != null)
          .toList();
    }

    return [];
  }

  bool get hasUserLatLng {
    return this.filter.value.latitude != null &&
        this.filter.value.longitude != null;
  }

  onToggleMapExpanded() {
    isMapExpanded.value = !isMapExpanded.value;

    MainWidgetController.instance.forceHideAppbarAndBottomBar.value =
        isMapExpanded.value;
  }

  @override
  onReady() {
    super.onReady();

    subscription = MainWidgetController.instance.globalEventOnNetworkError
        .on('onRefetchData', (_) => this.doFindHotelOffer());

    if (MainWidgetController.instance.userLocation != null) {
      var location = Location.fromJson(
          MainWidgetController.instance.userLocation.toJson());

      this.filter.update((val) {
        val.latitude = location.position.latitude;
        val.longitude = location.position.longitude;
        val.searchByMap = false;
      });
    }

    CacheHotelStorage.getCacheHotel().then((value) {
      if (value?.lastFilter != null) {
        this.filter.value =
            FilterHotelOffer.fromJson(value.lastFilter.toJson());

        HotelOfferFilterController hotelFilterCtrl = Get.find();

        if (hotelFilterCtrl != null) {
          hotelFilterCtrl.onSetFilter(value.lastFilter);
        }
      }

      if ((value?.lastHotelOffers?.length ?? 0) > 0) {
        value.lastHotelOffers.forEach((element) {
          this.hotelOffers.add(HotelOffer.fromJson(element.toJson()));
        });
      }
    });
  }

  @override
  onClose() {
    super.onClose();
    if (subscription != null) subscription.cancel();
  }

  doFindHotelOffer() async {
    if (!isLoading.value) {
      isLoading.value = true;
      if ((filter.value.offset ?? 0) == 0) hotelOffers.clear();

      var queryParams = filter.value.toJson(toParamSearch: true);
      List<HotelOffer> hotelOffersResponse =
          await hottelOfferService.getHotelOffers(queryParams);
      int hotelLength = hotelOffersResponse?.length ?? 0;
      bool hasLoadMore =
          hotelLength > 0 && (filter.value.limit % hotelLength == 0);

      hotelOffers.addAll(hotelOffersResponse);
      isLoading.value = false;
      this.hasLoadMore.value = hasLoadMore;

      if (filter.value.offset == 0) {
        CacheHotelStorage.setCacheHotel(
            this.filter.value, this.hotelOffers.toList());
      }
    }
  }

  onMapChangeLatlng(double lat, double lon) {
    filter.update((val) {
      val.latitude = lat;
      val.longitude = lon;
    });
  }

  onMapPositionChange(double rad, LatLng latLng) async {
    filter.update((val) {
      val.radius = rad.floor();
      val.latitude = latLng.latitude;
      val.longitude = latLng.longitude;
      val.setDefaultValue(searchByMap: true);
    });

    await Future.delayed(Duration(milliseconds: 100));
    Underscore.debounce(800, this.onFindAfterPositionChange, []);
  }

  onFindAfterPositionChange() async {
    await this.doFindHotelOffer();
    var commonMapState = (commonMapKey.currentState as CommonMapState);

    if (hotelOffers?.isNotEmpty ?? false) {
      await Future.delayed(Duration(milliseconds: 100));
      commonMapState?.fitToBounds(emitChange: true);
    }
  }
}

class HotelOfferScreen extends StatelessWidget {
  const HotelOfferScreen({Key key}) : super(key: key);

  static const String RouteName = "Hotel Offer";
  static const String Subtitle = "Finds the best deals for a given itinerary";

  final double arrowExpandMapHeight = 52;

  double get fixHeightMap {
    return Get.height -
        (arrowExpandMapHeight +
            MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .padding
                .top +
            MediaQueryData.fromWindow(WidgetsBinding.instance.window)
                .padding
                .bottom);
  }

  Widget renderFilterMap(HotelOfferScreenController controller) {
    var decoration = BoxDecoration(
        color: Style.primary,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24), topRight: Radius.circular(24)));
    bool showFilterMap = controller.showFilterMap.value;
    bool isLoading = controller.isLoading.value;

    return Container(
        decoration: decoration,
        width: Get.width,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: toList(() sync* {
            yield Row(children: [
              Icon(Icons.settings, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                  child: Text(isLoading ? 'Searching...' : 'Filters',
                      style: TextStyle(fontSize: 24, color: Colors.white))),
              SizedBox(width: 16),
              InkWell(
                child: Icon(
                    showFilterMap
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 32,
                    color: Colors.white),
                onTap: () => controller.showFilterMap.value = !showFilterMap,
              )
            ]);

            if (showFilterMap) {
              yield SizedBox(height: 16);
              yield Container(
                height: 42,
                child: ListView(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  children: [
                    buttonSearchMap(
                        controller,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.date_range,
                                color: Style.primaryDark, size: 18),
                            SizedBox(width: 6),
                            Text(controller.filter.value.labelCheckinCheckout,
                                style: TextStyle(color: Style.primaryDark))
                          ],
                        ),
                        StateActive.date),
                    SizedBox(width: 8),
                    buttonSearchMap(
                        controller,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.monetization_on,
                                color: Style.primaryDark, size: 18),
                            SizedBox(width: 6),
                            Text(controller.filter.value.labelPrice,
                                style: TextStyle(color: Style.primaryDark))
                          ],
                        ),
                        StateActive.price),
                    SizedBox(width: 8),
                    buttonSearchMap(
                        controller,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person,
                                color: Style.primaryDark, size: 18),
                            SizedBox(width: 6),
                            Text("${controller.filter.value.adults} Adults",
                                style: TextStyle(color: Style.primaryDark))
                          ],
                        ),
                        StateActive.adults),
                    SizedBox(width: 8),
                    buttonSearchMap(
                        controller,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.room,
                                color: Style.primaryDark, size: 18),
                            SizedBox(width: 6),
                            Text(
                                "${controller.filter.value.roomQuantity} Rooms",
                                style: TextStyle(color: Style.primaryDark))
                          ],
                        ),
                        StateActive.roomQty),
                    SizedBox(width: 8),
                    buttonSearchMap(
                        controller,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.room_service,
                                color: Style.primaryDark, size: 18),
                            SizedBox(width: 6),
                            Text("Amenities",
                                style: TextStyle(color: Style.primaryDark))
                          ],
                        ),
                        StateActive.amenities),
                    SizedBox(width: 8),
                    buttonSearchMap(
                        controller,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star,
                                color: Style.primaryDark, size: 18),
                            SizedBox(width: 6),
                            Text(controller.filter.value.labelRating,
                                style: TextStyle(color: Style.primaryDark))
                          ],
                        ),
                        StateActive.rating),
                    SizedBox(width: 8),
                    buttonSearchMap(
                        controller,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home,
                                color: Style.primaryDark, size: 18),
                            SizedBox(width: 6),
                            Text("BoardType",
                                style: TextStyle(color: Style.primaryDark))
                          ],
                        ),
                        StateActive.boardType),
                  ],
                ),
              );
              yield SizedBox(height: 12);
              yield buttonSearchMap(
                  controller,
                  controller.isLoading.value
                      ? SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                          height: 18,
                          width: 18)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 8),
                            Text("SEARCH",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                  StateActive.none,
                  color: Style.accent);
            }
          }),
        ));
  }

  Widget renderPreviewMap(HotelOfferScreenController controller) {
    return CommonMap(
        showBtnSearchPlace: true,
        hideMainMarker: true,
        key: controller.commonMapKey,
        markers: controller.hotelLatLngs,
        width: Get.width,
        height: fixHeightMap,
        interactive: true,
        onCurrentLocationFetched: (Location loc) {
          controller.onMapChangeLatlng(
              loc.position.latitude, loc.position.longitude);
        },
        popupBuilder: (_, var marker) {
          int idxAt = controller.hotelOffers
              .indexWhere((item) => item?.sameLatLng(marker?.point) ?? false);

          if (idxAt > -1) {
            return HotelOffersItem(
              simple: true,
              hotelOffer: controller.hotelOffers.elementAt(idxAt),
            );
          }

          return SizedBox();
        },
        onTapLocation: controller.onMapChangeLatlng,
        onPositionChange: controller.onMapPositionChange,
        child: renderFilterMap(controller),
        latLng: LatLng(controller.filter.value.latitude,
            controller.filter.value.longitude));
  }

  InkWell buttonSearchMap(HotelOfferScreenController controller, Widget child,
      StateActive stateActive,
      {Color color}) {
    return InkWell(
      onTap: () async {
        controller.stateActive.value = stateActive;

        if ([StateActive.roomQty, StateActive.adults].contains(stateActive)) {
          controller.mainFilterExpanded.value = true;
          controller.additionalFilterExpanded.value = false;
        } else if ([StateActive.boardType, StateActive.amenities]
            .contains(stateActive)) {
          controller.additionalFilterExpanded.value = true;
          controller.mainFilterExpanded.value = false;
        }

        if (stateActive == StateActive.none) {
          var commonMapState =
              (controller.commonMapKey.currentState as CommonMapState);

          if (commonMapState?.currentPoint != null) {
            controller.filter.update((val) {
              val.latitude = commonMapState.currentPoint.latitude;
              val.longitude = commonMapState.currentPoint.longitude;
            });
          }

          await Future.delayed(Duration(milliseconds: 250));
          controller.filter
              .update((val) => val.setDefaultValue(searchByMap: true));

          await controller.doFindHotelOffer();
          await Future.delayed(Duration(milliseconds: 250));

          if (controller?.hotelOffers?.isNotEmpty ?? false) {
            commonMapState?.fitToBounds();
          }
        } else {
          controller.onToggleMapExpanded();
          HotelOfferFilterController hotelFilterCtrl = Get.find();

          if (hotelFilterCtrl != null) {
            hotelFilterCtrl.mainFilterExpanded.value =
                controller.mainFilterExpanded.value;

            hotelFilterCtrl.additionalFilterExpanded.value =
                controller.additionalFilterExpanded.value;

            hotelFilterCtrl.stateActive.value = controller.stateActive.value;

            await Future.delayed(Duration(milliseconds: 100));
            var key = hotelFilterCtrl.scrollKey[stateActive];

            if (key != null) {
              Scrollable.ensureVisible(key.currentContext);
            }
          }
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: 42,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: child,
        decoration: BoxDecoration(
            color: color ?? Colors.white, borderRadius: Style.borderRadius()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingItem = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      child:
          PlaceholderWidget(paddingTop: 32, paddingForRestItem: 12, repeat: 3),
    );

    return GetBuilder(
        init: HotelOfferScreenController(),
        builder: (HotelOfferScreenController controller) {
          return WillPopScope(
            onWillPop: () {
              if (controller.isMapExpanded.value) {
                controller.onToggleMapExpanded();

                return Future.value(false);
              }

              return MainWidgetController.instance.onWillPopExit();
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                    color: Style.background,
                    child: ListView(
                      children: [
                        Obx(() =>
                            MainWidgetController.instance.loadingData.value
                                ? loadingItem
                                : SizedBox()),
                        Obx(() => MainWidgetController
                                .instance.loadingData.value
                            ? SizedBox()
                            : InfoScreen(title: RouteName, subtitle: Subtitle)),
                        Obx(() => MainWidgetController
                                .instance.loadingData.value
                            ? SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: HotelOfferFilter(
                                  mainFilterExpanded:
                                      controller.mainFilterExpanded.value,
                                  additionalFilterExpanded:
                                      controller.additionalFilterExpanded.value,
                                  stateActive: controller.stateActive.value,
                                  filter: controller.filter.value,
                                  onFindHotelOffers: (param) async {
                                    if (param != null) {
                                      var filter = FilterHotelOffer.fromJson(
                                          param.toJson());
                                      filter.latitude =
                                          controller.filter.value.latitude;
                                      filter.longitude =
                                          controller.filter.value.longitude;

                                      controller.filter.value = filter;
                                      controller.filter.refresh();

                                      await controller.doFindHotelOffer();
                                    }
                                  },
                                ),
                              )),
                        Obx(() {
                          if (MainWidgetController.instance.loadingData.value) {
                            return SizedBox();
                          } else if (controller.isLoading.value) {
                            return loadingItem;
                          }

                          var hotelOffers = controller.hotelOffers;

                          if (hotelOffers.isNotEmpty) {
                            return ColumnBuilder(
                              itemCount: hotelOffers.length,
                              itemBuilder: (_, i) {
                                var e = hotelOffers[i];
                                var padding = EdgeInsets.only(
                                    top: i == 0 ? 32 : 0,
                                    bottom: i == (hotelOffers.length - 1)
                                        ? 60
                                        : 24);

                                return Padding(
                                    padding: padding,
                                    child: HotelOffersItem(
                                        hotelOffer: e, onTap: () {}));
                              },
                            );
                          }

                          return EmptyContent(
                              child: Text(
                                  "Try press search or use another query",
                                  style: TextStyle(
                                      fontSize: 12, color: Style.greyLight)));
                        }),
                        Obx(() {
                          var hotelOffers = controller.hotelOffers;
                          bool hasLoadMore = controller.hasLoadMore.value;

                          if (hasLoadMore && hotelOffers.isNotEmpty) {
                            return CommonButton(
                              child: Text("Load more"),
                              loading: controller.isLoading.value,
                              onPressed: () {
                                controller.filter.update((val) {
                                  val.offset += val.limit;
                                });

                                controller.doFindHotelOffer();
                              },
                            );
                          }

                          return SizedBox();
                        })
                      ],
                    )),
                Obx(() {
                  bool isExpanded = controller.isMapExpanded.value;
                  bool hasUserLatLng = controller.hasUserLatLng ?? false;

                  if (!hasUserLatLng) {
                    return SizedBox();
                  }

                  Widget arrowExpand = ArrowExpand(
                      height: arrowExpandMapHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("Search from Map",
                          style: Style.labelStyleSection(
                              color:
                                  isExpanded ? Style.textColor : Colors.white)),
                      onTap: controller.onToggleMapExpanded,
                      color: isExpanded ? Colors.white : Style.accent,
                      iconColor: isExpanded ? Style.textColor : Colors.white,
                      isReverse: true,
                      borderRadius:
                          isExpanded ? Style.borderRadius(param: 0) : null,
                      boxShadows: Style.commonBoxShadows,
                      isExpanded: isExpanded);

                  if (isExpanded) {
                    Widget commonMap = renderPreviewMap(controller);

                    return ListView(children: [
                      arrowExpand,
                      Container(height: fixHeightMap, child: commonMap),
                    ]);
                  }

                  return arrowExpand;
                })
              ],
            ),
          );
        });
  }
}
