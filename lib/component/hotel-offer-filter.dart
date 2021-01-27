import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamasya/component/airport-iata-picker.dart';
import 'package:tamasya/component/button-count.dart';
import 'package:tamasya/component/common-button.dart';
import 'package:tamasya/component/dialogues.dart';
import 'package:tamasya/component/pickdate-label.dart';
import 'package:tamasya/component/select-options.dart';
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/model/airport.dart';
import 'package:tamasya/model/arrow-expand.dart';
import 'package:tamasya/model/filter-hotel-offer.dart';
import 'package:tamasya/style/string-util.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/type-def.dart';
import 'package:tamasya/component/notification.dart' as NotifToast;
import 'package:tamasya/component/calendar-picker-dialog.dart';
import 'package:tamasya/component/common-slider.dart';
import 'package:tamasya/util/underscore.dart';

enum StateActive {
  none,
  date,
  price,
  amenities,
  rating,
  boardType,
  adults,
  roomQty
}

class HotelOfferFilterController extends GetxController {
  HotelOfferFilterController(
      {FilterHotelOffer filter,
      Future Function(FilterHotelOffer filter) onFindHotelOffers,
      StateActive stateActive,
      bool mainFilterExpanded,
      bool additionalFilterExpanded}) {
    if (filter != null) {
      this.filter.value = FilterHotelOffer.fromJson(filter.toJson());
    }

    this.mainFilterExpanded.value = mainFilterExpanded ?? false;
    this.additionalFilterExpanded.value = additionalFilterExpanded ?? false;
    this.stateActive.value = stateActive ?? StateActive.none;

    if (onFindHotelOffers != null) {
      this.onFindHotelOffers = onFindHotelOffers;
    }

    hotelNameController = TextEditingController(text: filter?.hotelName ?? '');
  }

  final Map<StateActive, GlobalKey> scrollKey = {
    StateActive.none: null,
    StateActive.date: GlobalKey(),
    StateActive.price: GlobalKey(),
    StateActive.amenities: GlobalKey(),
    StateActive.rating: GlobalKey(),
    StateActive.boardType: GlobalKey(),
    StateActive.adults: GlobalKey(),
    StateActive.roomQty: GlobalKey(),
  };

  Future Function(FilterHotelOffer filter) onFindHotelOffers;

  Rx<FilterHotelOffer> filter = Rx<FilterHotelOffer>(FilterHotelOffer());

  RxString airportIataKey = randomString(strlen: 4).obs;

  RxBool mainFilterExpanded = false.obs;

  RxBool isLoading = false.obs;

  RxBool additionalFilterExpanded = false.obs;

  Rx<StateActive> stateActive = Rx<StateActive>(StateActive.none);

  TextEditingController hotelNameController;

  onSetFilter(FilterHotelOffer param) {
    filter.value = FilterHotelOffer.fromJson(param.toJson());
    airportIataKey.value = randomString(strlen: 4);
  }

  onSelectAirport(Airport param, {bool isDestination = false}) {
    if (param?.iata != null) {
      filter
          .update((val) => val.destination = Airport.fromJson(param.toJson()));
    }
  }

  onOpenCalendar() async {
    MainWidgetController.instance.forceHideAppbarAndBottomBar.value = true;

    DateTime now = DateTime.now();
    DateTime minDate =
        DateTime(now.year, now.month, now.day, 0, 0).add(Duration(days: 1));

    var paramFirstDate = filter.value.checkinDate;
    var paramLastDate = filter.value.checkoutDate ?? filter.value.checkinDate;

    var dateTimes = await showDialogAnimation(
        Get.overlayContext,
        CalendarPickerDialog(
          minDate: minDate,
          firstDate: paramFirstDate,
          lastDate: paramLastDate,
          maxDate: DateTime.now().add(Duration(days: 180)),
        ));
    bool valid = dateTimes != null &&
        dateTimes is List<DateTime> &&
        dateTimes.length > 0;

    if (valid) {
      filter.update((val) {
        val.checkinDate = dateTimes[0];

        if (dateTimes.length > 1) {
          val.checkoutDate = dateTimes[1];
        } else {
          val.checkoutDate = dateTimes[0];
        }
      });
    }

    MainWidgetController.instance.forceHideAppbarAndBottomBar.value = false;
  }

  doFindHotelOffers() {
    bool validGeoCode =
        filter.value.latitude != null && filter.value.longitude != null;
    bool validCity = filter.value.destination?.iata != null;
    bool validLoc = filter.value.radius > 0 &&
        filter.value.radiusUnit != null &&
        (validGeoCode || validCity);
    stateActive.value = StateActive.none;

    if (validLoc && !isLoading.value) {
      filter.update((val) => val.setDefaultValue());
      isLoading.value = true;

      onFindHotelOffers(filter.value)
          .whenComplete(() => isLoading.value = false);
    } else {
      NotifToast.Notification.showNotification(
          message: 'City / Latitude / Longitude. cannot be empty',
          notificationType: NotifToast.NotificationType.DANGER);
    }
  }
}

class HotelOfferFilter extends StatelessWidget {
  final FilterHotelOffer filter;
  final bool mainFilterExpanded;
  final bool additionalFilterExpanded;
  final StateActive stateActive;
  final Future Function(FilterHotelOffer filter) onFindHotelOffers;
  const HotelOfferFilter(
      {Key key,
      this.filter,
      this.onFindHotelOffers,
      this.mainFilterExpanded,
      this.additionalFilterExpanded,
      this.stateActive})
      : super(key: key);

  Widget renderMainFilter(HotelOfferFilterController controller) {
    Widget cityCode = Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("* ", style: Style.labelStyleSection(color: Style.danger)),
                Text("city", style: Style.labelStyleSection())
              ],
            ),
            SizedBox(height: 8),
            AirportIataPicker(
                key: Key(controller.airportIataKey.value),
                asBigLabel: true,
                airport: controller.filter.value.destination,
                onSelectAirport: controller.onSelectAirport),
          ],
        ));

    return Container(
        padding: Style.paddingSection(bottom: 4),
        decoration: Style.boxDecorSection(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cityCode,
          SizedBox(height: 16),
          Container(color: Style.backgroundGreyLight, height: 1),
          SizedBox(height: 16),
          Obx(() {
            bool active = controller.stateActive.value == StateActive.date;

            return Container(
              key: controller.scrollKey[StateActive.date],
              padding: EdgeInsets.all(active ? 4 : 0),
              decoration:
                  Style.boxDecorSection(skipShadow: true, markActive: active),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("* ",
                          style: Style.labelStyleSection(color: Style.danger)),
                      Text("Check In - Check Out date",
                          style: Style.labelStyleSection())
                    ],
                  ),
                  SizedBox(height: 8),
                  Obx(
                    () => PickdateLabel(
                      iconData: Icons.calendar_today,
                      onTap: () => controller.onOpenCalendar(),
                      startDate: controller.filter.value.checkinDate,
                      endDate: controller.filter.value.checkoutDate,
                      isRequired: true,
                      placeholder: 'Pick Check In - Check Out date',
                    ),
                  ),
                ],
              ),
            );
          }),
          Obx(() {
            bool isExpanded = controller.mainFilterExpanded.value;

            Widget arrowExpand = ArrowExpand(
                isExpanded: isExpanded,
                onTap: () => controller.mainFilterExpanded.value = !isExpanded);

            if (!isExpanded) {
              return arrowExpand;
            }

            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Container(color: Style.backgroundGreyLight, height: 1),
                  SizedBox(height: 16),
                  Obx(() {
                    bool active =
                        controller.stateActive.value == StateActive.adults;

                    return Container(
                      key: controller.scrollKey[StateActive.adults],
                      decoration: Style.boxDecorSection(
                          markActive: active, skipShadow: true),
                      padding: EdgeInsets.all(active ? 4 : 0),
                      child: Style.renderFormSection(
                          ButtonCount(
                              value: controller.filter.value.adults,
                              minValue: 1,
                              onChange: (param) => controller.filter
                                  .update((val) => val.adults = param)),
                          "Adults"),
                    );
                  }),
                  Obx(() {
                    bool active =
                        controller.stateActive.value == StateActive.roomQty;

                    return Container(
                      key: controller.scrollKey[StateActive.roomQty],
                      decoration: Style.boxDecorSection(
                          markActive: active, skipShadow: true),
                      padding: EdgeInsets.all(active ? 4 : 0),
                      child: Style.renderFormSection(
                          ButtonCount(
                              value: controller.filter.value.roomQuantity,
                              minValue: 1,
                              onChange: (param) => controller.filter
                                  .update((val) => val.roomQuantity = param)),
                          "Room Quantity"),
                    );
                  }),
                  arrowExpand
                ]);
          })
        ]));
  }

  Widget renderAdditionalFilter(HotelOfferFilterController controller) {
    return Container(
        padding: Style.paddingSection(bottom: 4),
        decoration: Style.boxDecorSection(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Obx(() {
            double lowest =
                controller?.filter?.value?.lowestPrice?.toDouble() ?? 0;
            double highest =
                controller?.filter?.value?.highestPrice?.toDouble() ?? 0;

            String labelMin = formatCurrency(lowest.floor());
            String labelMax = formatCurrency(highest.floor());
            RangeLabels rangeLabels = RangeLabels(
                formatCurrency(lowest.toInt()),
                formatCurrency(highest.toInt()));

            bool active = controller.stateActive.value == StateActive.price;
            int maxPrice = convertCurrency(Constant.MAX_PRICE_IN_EUR,
                MainWidgetController.instance.currency)["value"];

            return Container(
              key: controller.scrollKey[StateActive.price],
              decoration:
                  Style.boxDecorSection(markActive: active, skipShadow: true),
              padding: EdgeInsets.all(active ? 4 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Prices", style: Style.labelStyleSection()),
                  SizedBox(height: 8),
                  CommonSlider(
                    valueLowest: lowest,
                    valueHighest: highest,
                    min: 0,
                    max: maxPrice.toDouble(),
                    divisions: 2000,
                    labelMin: labelMin,
                    labelMax: labelMax,
                    rangeLabels: rangeLabels,
                    onChangeRanges: (param) {
                      controller.filter.update((val) {
                        val.lowestPrice = param.start?.floor();
                        val.highestPrice = param.end?.floor();
                      });
                    },
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 16),
          Container(color: Style.backgroundGreyLight, height: 1),
          SizedBox(height: 16),
          Obx(() {
            double lowest =
                controller?.filter?.value?.lowRating?.toDouble() ?? 0;
            double highest =
                controller?.filter?.value?.hightRating?.toDouble() ?? 0;

            Widget labelMin = Row(children: [
              Icon(Icons.star_border, color: Style.primaryBlue),
              SizedBox(width: 4),
              Text(lowest.floor().toString(),
                  style: TextStyle(color: Style.primaryBlue))
            ]);

            Widget labelMax = Row(children: [
              Icon(Icons.star, color: Style.primaryBlue),
              SizedBox(width: 4),
              Text(highest.floor().toString(),
                  style: TextStyle(color: Style.primaryBlue))
            ]);

            RangeLabels rangeLabels = RangeLabels(
                lowest.floor().toString(), highest.floor().toString());
            bool active = controller.stateActive.value == StateActive.rating;
            bool showReset = lowest.floor() != 1 || highest.floor() != 5;

            return Column(
              key: controller.scrollKey[StateActive.rating],
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rating", style: Style.labelStyleSection()),
                SizedBox(height: 8),
                Container(
                  decoration: Style.boxDecorSection(
                      markActive: active, skipShadow: true),
                  padding: EdgeInsets.all(active ? 4 : 0),
                  child: CommonSlider(
                    valueLowest: lowest,
                    valueHighest: highest,
                    min: 1,
                    max: 5,
                    divisions: 5,
                    showReset: showReset,
                    labelWidgetMin: labelMin,
                    labelWidgetMax: labelMax,
                    rangeLabels: rangeLabels,
                    onChangeRanges: (param) {
                      controller.filter.update((val) {
                        val.lowRating = param.start?.floor();
                        val.hightRating = param.end?.floor();
                      });
                    },
                  ),
                ),
              ],
            );
          }),
          Obx(() {
            bool isExpanded = controller.additionalFilterExpanded.value;

            Widget arrowExpand = ArrowExpand(
                isExpanded: isExpanded,
                onTap: () =>
                    controller.additionalFilterExpanded.value = !isExpanded);

            if (!isExpanded) {
              return arrowExpand;
            }

            bool activeBoardType =
                controller.stateActive.value == StateActive.boardType;
            bool activeAmenities =
                controller.stateActive.value == StateActive.amenities;

            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Style.formSection(
                      TextField(
                        controller: controller.hotelNameController,
                        decoration:
                            Style.commonInputDecoration(hintText: 'Hotel name'),
                        onChanged: (param) => controller.filter
                            .update((val) => val.hotelName = param),
                      ),
                      labelHorSpace: 6,
                      useLabelStyleSection: true,
                      label: 'Hotel Name'),
                  Container(color: Style.backgroundGreyLight, height: 1),
                  Container(
                    key: controller.scrollKey[StateActive.boardType],
                    padding: EdgeInsets.all(activeBoardType ? 4 : 0),
                    decoration: Style.boxDecorSection(
                        markActive: activeBoardType, skipShadow: true),
                    child: Style.formSection(
                        Container(
                            width: double.infinity,
                            child: SelectOption(
                              options: Constant.HOTEL_BOARD_TYPE.keys.toList(),
                              value: controller.filter.value.boardType,
                              renderChild: (String item, same) => Text(
                                  Constant.HOTEL_BOARD_TYPE[item],
                                  style: TextStyle(
                                      color: same
                                          ? Colors.white
                                          : Style.textColor)),
                              onChange: (param) => controller.filter
                                  .update((val) => val.boardType = param),
                            )),
                        labelHorSpace: 6,
                        useLabelStyleSection: true,
                        label: "Board Type"),
                  ),
                  Container(color: Style.backgroundGreyLight, height: 1),
                  Container(
                    key: controller.scrollKey[StateActive.amenities],
                    padding: EdgeInsets.all(activeAmenities ? 4 : 0),
                    decoration: Style.boxDecorSection(
                        markActive: activeAmenities, skipShadow: true),
                    child: Style.formSection(
                        Container(
                            width: double.infinity,
                            child: SelectOption(
                              options: Constant.HOTEL_AMENITIES,
                              values: controller.filter.value.amenities,
                              onChangeValues: (param) => controller.filter
                                  .update((val) => val.amenities = param),
                            )),
                        labelHorSpace: 6,
                        useLabelStyleSection: true,
                        label: "Amenities"),
                  ),
                  Container(color: Style.backgroundGreyLight, height: 1),
                  SizedBox(height: 16),
                  arrowExpand
                ]);
          })
        ]));
  }

  @override
  Widget build(BuildContext context) {
    HotelOfferFilterController controller = Get.put(HotelOfferFilterController(
        filter: filter,
        onFindHotelOffers: onFindHotelOffers,
        mainFilterExpanded: mainFilterExpanded,
        stateActive: stateActive,
        additionalFilterExpanded: additionalFilterExpanded));

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: Style.maxWidth(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: toList(() sync* {
            yield renderMainFilter(controller);
            yield SizedBox(height: 16);
            yield renderAdditionalFilter(controller);
            yield SizedBox(height: 16);
            yield Obx(
              () => CommonButton(
                  loading: controller.isLoading.value,
                  minWidth: double.infinity,
                  child: Text("Search"),
                  onPressed: controller.doFindHotelOffers),
            );
          }),
        ),
      ),
    );
  }
}
