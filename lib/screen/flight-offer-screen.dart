import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamasya/component/column-builder.dart';
import 'package:tamasya/component/dialogues.dart';
import 'package:tamasya/component/empty-content.dart';
import 'package:tamasya/component/flight-offers-item.dart';
import 'package:tamasya/component/info-screen.dart';
import 'package:tamasya/component/placeholder-item.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/model/filter-flight-offer.dart';
import 'package:tamasya/model/flight-offer.dart';
import 'package:tamasya/component/flight-offer-filter.dart';
import 'package:tamasya/component/flight-offers-detail.dart';
import 'package:tamasya/service/flight-offer-service.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/storage.dart';
import 'package:tamasya/util/type-def.dart';

class FlightOfferScreenController extends GetxController {
  FlightOfferService flightOfferService = FlightOfferService.instance;

  StreamSubscription subscription;

  RxList<FlightOffer> flightOffers = RxList<FlightOffer>([]);

  RxBool isLoading = false.obs;

  Rx<FilterFlightOffer> filter = Rx<FilterFlightOffer>(FilterFlightOffer());

  @override
  void onInit() {
    super.onInit();

    var args = Get.arguments;
    if (args is Map && args != null) {
      this.filter.value = FilterFlightOffer.fromJson(args, fromUriParse: true);
      this.filter.refresh();

      this.doFindFlightOffer();
    }
  }

  @override
  onReady() {
    super.onReady();

    subscription = MainWidgetController.instance.globalEventOnNetworkError
        .on('onRefetchData', (_) => this.doFindFlightOffer());

    CacheFlightStorage.getCacheFlight().then((value) {
      if (value?.lastFilter != null) {
        this.filter.value =
            FilterFlightOffer.fromJson(value.lastFilter.toJson());

        FlightOfferFilterController flightFilterCtrl = Get.find();

        if (flightFilterCtrl != null) {
          flightFilterCtrl.onSetFilter(value.lastFilter);
        }

        if ((value?.lastFlightOffers?.length ?? 0) > 0) {
          value.lastFlightOffers.forEach((element) {
            this.flightOffers.add(FlightOffer.fromJson(element.toJson()));
          });
        }
      }
    });
  }

  @override
  onClose() {
    super.onClose();
    if (subscription != null) subscription.cancel();
  }

  doFindFlightOffer() async {
    if (!isLoading.value) {
      isLoading.value = true;
      flightOffers.clear();

      var queryParams = filter.value.toJson(toParamSearch: true);
      List<FlightOffer> flightOffersResponse =
          await flightOfferService.getFlightOffers(queryParams);

      flightOffers.addAll(flightOffersResponse);

      isLoading.value = false;

      CacheFlightStorage.setCacheFlight(
          this.filter.value, this.flightOffers.toList());
    }
  }

  onShowDetailFlightOffers(FlightOffer flightOffer) async {
    MainWidgetController.instance.forceHideAppbarAndBottomBar.value = true;

    await showDialogAnimation(Get.overlayContext,
        FlightOffersDetail(filter: filter.value, flightOffer: flightOffer));

    MainWidgetController.instance.forceHideAppbarAndBottomBar.value = false;
  }
}

class FlightOfferScreen extends StatelessWidget {
  const FlightOfferScreen({Key key}) : super(key: key);

  static const String RouteName = "Flight Offer";
  static const String Subtitle =
      "Find the cheapest flights for a given itinerary";

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: FlightOfferScreenController(),
      builder: (FlightOfferScreenController controller) => Container(
        color: Style.background,
        child: ListView(
            padding: const EdgeInsets.all(0),
            children: toList(() sync* {
              Widget loadingItem = Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                margin: const EdgeInsets.only(bottom: 16),
                child: PlaceholderWidget(
                    paddingTop: 32, paddingForRestItem: 12, repeat: 3),
              );

              yield InfoScreen(title: RouteName, subtitle: Subtitle);
              yield Obx(() {
                if (MainWidgetController.instance.loadingData.value) {
                  return loadingItem;
                }

                return SizedBox(height: 24);
              });

              yield Obx(() => MainWidgetController.instance.loadingData.value
                  ? SizedBox()
                  : FlightOfferFilter(
                      filter: controller.filter.value,
                      onFindFlightOffers: (param) async {
                        if (param != null) {
                          controller.filter.value =
                              FilterFlightOffer.fromJson(param.toJson());
                          controller.filter.refresh();

                          await controller.doFindFlightOffer();
                        }
                      },
                    ));

              yield Obx(() {
                if (MainWidgetController.instance.loadingData.value) {
                  return SizedBox();
                }

                if (!controller.isLoading.value) {
                  if (controller.flightOffers.isEmpty) {
                    return EmptyContent(
                        child: Text("Try press search or use another query",
                            style: TextStyle(
                                fontSize: 12, color: Style.greyLight)));
                  }

                  var flightOffers = controller.flightOffers;

                  return ColumnBuilder(
                    itemCount: flightOffers.length,
                    itemBuilder: (_, i) {
                      var e = flightOffers[i];

                      return Padding(
                          padding:
                              EdgeInsets.only(top: i == 0 ? 32 : 0, bottom: 24),
                          child: FlightOffersItem(e,
                              onClickDetail: () =>
                                  controller.onShowDetailFlightOffers(e)));
                    },
                  );
                }

                return loadingItem;
              });
            })),
      ),
    );
  }
}
