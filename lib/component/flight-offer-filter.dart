import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamasya/component/airport-iata-picker.dart';
import 'package:tamasya/component/button-count.dart';
import 'package:tamasya/component/calendar-picker-dialog.dart';
import 'package:tamasya/component/common-button.dart';
import 'package:tamasya/component/dialogues.dart';
import 'package:tamasya/component/measure-size.dart';
import 'package:tamasya/component/money-field.dart';
import 'package:tamasya/component/pickdate-label.dart';
import 'package:tamasya/component/select-options.dart';
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/model/airport.dart';
import 'package:tamasya/model/arrow-expand.dart';
import 'package:tamasya/model/filter-flight-offer.dart';
import 'package:tamasya/style/string-util.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/type-def.dart';
import 'package:tamasya/component/notification.dart' as NotifToast;

class FlightOfferFilterController extends GetxController {
  FlightOfferFilterController(
      {FilterFlightOffer filter,
      Future Function(FilterFlightOffer filter) onFindFlightOffers}) {
    if (filter != null) {
      this.filter.value = FilterFlightOffer.fromJson(filter.toJson());
      this.filter.refresh();
    }

    if (onFindFlightOffers != null) {
      this.onFindFlightOffers = onFindFlightOffers;
    }
  }

  Future Function(FilterFlightOffer filter) onFindFlightOffers;

  StreamSubscription subscription;

  Rx<FilterFlightOffer> filter = Rx<FilterFlightOffer>(FilterFlightOffer());

  RxString airportIataOriginKey = randomString(strlen: 4).obs;

  RxString airportIataDestionationKey = randomString(strlen: 4).obs;

  RxDouble firstRowHeight = (0.0).obs;

  RxBool isExpanded = false.obs;

  RxBool isLoading = false.obs;

  doFindFlightOffers() async {
    bool valid = filter.value.origin?.iata != null &&
        filter.value.destination?.iata != null &&
        filter.value.departureDateStart != null;

    if (valid && onFindFlightOffers != null) {
      isLoading.value = true;
      await onFindFlightOffers(filter.value);
      isLoading.value = false;
    } else {
      String message;
      if (filter.value.destination?.iata == null) {
        message = "Destination still empty";
      } else if (filter.value.origin?.iata == null) {
        message = "Origin still empty";
      } else if (filter.value.departureDateStart == null) {
        message = "Departure date still empty";
      } else {
        message = "Some field are still empty";
      }

      NotifToast.Notification.showNotification(
          message: message,
          notificationType: NotifToast.NotificationType.DANGER);
    }
  }

  onSetFilter(FilterFlightOffer param) {
    filter.value = FilterFlightOffer.fromJson(param.toJson());
    airportIataOriginKey.value = randomString(strlen: 4);
    airportIataDestionationKey.value = randomString(strlen: 4);
  }

  @override
  onInit() {
    super.onInit();
    Airport airportSelected = MainWidgetController.instance.userSelectedAirport;

    if (airportSelected != null) {
      filter.update((val) => val.origin = airportSelected);
    }
  }

  @override
  onReady() {
    super.onReady();

    subscription = MainWidgetController.instance.globalEventOnChangeUserLocation
        .on('onChangeUserLocation', (dynamic param) {
      if (param != null && param is Airport && param?.iata != null) {
        filter.value.origin = Airport.fromJson(param?.toJson());
        airportIataOriginKey.value = randomString(strlen: 4);
      }
    });
  }

  @override
  onClose() {
    super.onClose();
    if (subscription != null) subscription.cancel();
  }

  onSelectAirport(Airport param, {bool isDestination = false}) {
    if (param?.iata != null) {
      filter.update((val) {
        if (isDestination) {
          val.destination = Airport.fromJson(param.toJson());
        } else {
          val.origin = Airport.fromJson(param.toJson());
        }
      });
    }
  }

  onOpenCalendar({bool isReturnDate = false}) async {
    MainWidgetController.instance.forceHideAppbarAndBottomBar.value = true;

    DateTime now = DateTime.now();
    DateTime minDate =
        DateTime(now.year, now.month, now.day, 0, 0).add(Duration(days: 1));

    var paramFirstDate;
    var paramLastDate;

    if (isReturnDate) {
      paramFirstDate = filter.value.returnDateStart;

      if (paramFirstDate == null) {
        DateTime departureDate =
            filter.value.departureDateEnd ?? filter.value.departureDateStart;

        paramFirstDate =
            DateTime(departureDate.year, departureDate.month, departureDate.day)
                .add(Duration(days: 14));

        paramLastDate = paramFirstDate;
      } else {
        paramLastDate =
            filter.value.returnDateEnd ?? filter.value.returnDateStart;
      }

      minDate =
          filter.value.departureDateEnd ?? filter.value.departureDateStart;
    } else {
      paramFirstDate = filter.value.departureDateStart;
      paramLastDate =
          filter.value.departureDateEnd ?? filter.value.departureDateStart;
    }

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
        if (isReturnDate) {
          val.returnDateStart = dateTimes[0];

          if (dateTimes.length > 1) {
            val.returnDateEnd = dateTimes[1];
          } else {
            val.returnDateEnd = dateTimes[0];
          }
        } else {
          val.departureDateStart = dateTimes[0];

          if (dateTimes.length > 1) {
            val.departureDateEnd = dateTimes[1];
          } else {
            val.departureDateEnd = dateTimes[0];
          }
        }
      });
    }

    MainWidgetController.instance.forceHideAppbarAndBottomBar.value = false;
  }
}

class FlightOfferFilter extends StatelessWidget {
  final Future Function(FilterFlightOffer filter) onFindFlightOffers;
  final FilterFlightOffer filter;

  const FlightOfferFilter({Key key, this.onFindFlightOffers, this.filter})
      : super(key: key);

  Widget renderOriginDestination(FlightOfferFilterController controller) {
    Widget content = Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MeasureSize(
              onChange: (size) => controller.firstRowHeight.value =
                  (size.height - Style.dotSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("* ",
                          style: Style.labelStyleSection(color: Style.danger)),
                      Text("from", style: Style.labelStyleSection()),
                    ],
                  ),
                  SizedBox(height: 4),
                  AirportIataPicker(
                      key: Key(controller.airportIataOriginKey.value),
                      asBigLabel: true,
                      airport: controller.filter.value.origin,
                      onSelectAirport: controller.onSelectAirport),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text("* ",
                          style: Style.labelStyleSection(color: Style.danger)),
                      Text("to", style: Style.labelStyleSection())
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            AirportIataPicker(
                key: Key(controller.airportIataDestionationKey.value),
                asBigLabel: true,
                airport: controller.filter.value.destination,
                onSelectAirport: (param) =>
                    controller.onSelectAirport(param, isDestination: true)),
          ],
        ));

    Widget leftTimelineWidget = Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Style.renderDotTimeline(),
              Container(
                  height: controller.firstRowHeight.value,
                  width: 1.0,
                  color: Style.textColor),
              Style.renderDotTimeline(),
            ]));

    return Container(
        padding: Style.paddingSection(),
        decoration: Style.boxDecorSection(),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          leftTimelineWidget,
          SizedBox(width: 16),
          Expanded(child: content),
        ]));
  }

  Widget renderChooseDates(FlightOfferFilterController controller) {
    Widget child = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Choose dates", style: Style.labelStyleSection()),
        SizedBox(height: 16),
        Obx(
          () => PickdateLabel(
            iconData: Icons.flight_takeoff,
            onTap: () => controller.onOpenCalendar(),
            startDate: controller.filter.value.departureDateStart,
            endDate: controller.filter.value.departureDateEnd,
            isRequired: true,
            placeholder: 'Pick departure date',
          ),
        ),
        SizedBox(height: 16),
        Obx(
          () => PickdateLabel(
            iconData: Icons.flight_land,
            onTap: () => controller.onOpenCalendar(isReturnDate: true),
            startDate: controller.filter.value.returnDateStart,
            endDate: controller.filter.value.returnDateEnd,
            placeholder: 'Pick return date',
          ),
        ),
      ],
    );

    return Container(
        padding: Style.paddingSection(),
        decoration: Style.boxDecorSection(),
        child: child);
  }

  Widget renderWhosComing(FlightOfferFilterController controller) {
    return Obx(() {
      if (!controller.isExpanded.value) {
        return SizedBox();
      }

      Widget child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Who's coming ?", style: Style.labelStyleSection()),
          SizedBox(height: 16),
          Style.renderFormSection(
              ButtonCount(
                  value: controller.filter.value.adults,
                  minValue: 1,
                  onChange: (param) =>
                      controller.filter.update((val) => val.adults = param)),
              "Adults",
              isRequired: true),
          Style.renderFormSection(
              ButtonCount(
                  value: controller.filter.value.children,
                  onChange: (param) =>
                      controller.filter.update((val) => val.children = param)),
              "Childrens"),
          Style.renderFormSection(
              ButtonCount(
                  value: controller.filter.value.infants,
                  onChange: (param) =>
                      controller.filter.update((val) => val.infants = param)),
              "Infants",
              pra: 0),
        ],
      );

      return Container(
          padding: Style.paddingSection(),
          decoration: Style.boxDecorSection(),
          child: child);
    });
  }

  Widget renderAdditionalFilter(FlightOfferFilterController controller) {
    return Obx(() {
      if (!controller.isExpanded.value) {
        return SizedBox();
      }

      Widget child =
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Additional Filter", style: Style.labelStyleSection()),
        SizedBox(height: 16),
        Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 64,
            child: SwitchListTile(
              contentPadding: EdgeInsets.all(0),
              title: const Text('Non Stop'),
              onChanged: (bool param) {
                controller.filter.update((val) => val.nonStop = param);
              },
              subtitle: Text("only flights origin to destination, no stop",
                  style: TextStyle(color: Style.greyDark, fontSize: 12)),
              value: controller.filter.value.nonStop,
            )),
        Style.formSection(
            MoneyField(
              value: controller.filter.value.maxPrice.toDouble(),
              inputDecoration: Style.commonInputDecoration(hintText: 'Price'),
              onNumberValueChange: (double param) => controller.filter
                  .update((val) => val.maxPrice = (param ?? 0).toInt()),
            ),
            pra: 16,
            pre: 0,
            labelHorSpace: 6,
            label: 'Max Price'),
        Style.formSection(
            Container(
                width: double.infinity,
                child: SelectOption(
                  options: Constant.TRAVEL_CLASS,
                  value: controller.filter.value.travelClass,
                  onChange: (param) => controller.filter
                      .update((val) => val.travelClass = param),
                )),
            pra: 16,
            pre: 0,
            labelHorSpace: 6,
            label: "Travel Class")
      ]);

      return Container(
          padding: Style.paddingSection(),
          decoration: Style.boxDecorSection(),
          child: child);
    });
  }

  @override
  Widget build(BuildContext context) {
    FlightOfferFilterController controller = Get.put(
        FlightOfferFilterController(
            filter: filter, onFindFlightOffers: onFindFlightOffers));

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: Style.maxWidth(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: toList(() sync* {
            yield renderOriginDestination(controller);
            yield SizedBox(height: 16);
            yield renderChooseDates(controller);
            yield Obx(
                () => SizedBox(height: controller.isExpanded.value ? 16 : 0));
            yield renderWhosComing(controller);
            yield Obx(
                () => SizedBox(height: controller.isExpanded.value ? 16 : 0));
            yield renderAdditionalFilter(controller);
            yield SizedBox(height: 16);
            yield Obx(() {
              Widget buttonSearch = CommonButton(
                  minWidth: double.infinity,
                  child: Text("Search"),
                  loading: controller.isLoading.value,
                  onPressed: controller.doFindFlightOffers);

              return Row(children: [
                ArrowExpand(
                    isExpanded: controller.isExpanded.value,
                    borderRadius: Style.borderRadius(param: 6),
                    onTap: () => controller.isExpanded.value =
                        !controller.isExpanded.value,
                    width: Style.fieldhHeight,
                    height: Style.fieldhHeight),
                SizedBox(width: 16),
                Expanded(child: buttonSearch)
              ]);
            });
          }),
        ),
      ),
    );
  }
}
