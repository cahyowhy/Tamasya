import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamasya/component/common-button.dart';
import 'package:tamasya/component/dash-line.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/model/flight-destination.dart';
import 'package:tamasya/screen/flight-offer-screen.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/type-def.dart';

class FlightDestinationItem extends StatelessWidget {
  const FlightDestinationItem(this.flightDestination, {Key key})
      : super(key: key);
  final FlightDestination flightDestination;

  Widget oriDestInfo({bool isDest = false}) {
    return Column(
        crossAxisAlignment:
            isDest ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: toList(() sync* {
          yield Text(
              isDest
                  ? flightDestination.formatDateReturn
                  : flightDestination.formatDateDeparture,
              style: TextStyle(fontSize: 12, color: Style.greyDark));

          yield Text(
            isDest ? flightDestination.destination : flightDestination.origin,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
          );

          if (flightDestination.detailDestination != null &&
              flightDestination.detailOrigin != null) {
            SizedBox(height: 4);
            yield Text(
                isDest
                    ? flightDestination.detailDestination
                    : flightDestination.detailOrigin,
                style: TextStyle(fontSize: 12, color: Style.greyDark));
          }
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Style.maxWidth(),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: Style.commonBoxShadows,
          borderRadius: Style.borderRadius(param: 12)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: toList(() sync* {
          Widget topSection = Text(
              "${MainWidgetController.instance.currencySymbol} ${flightDestination?.price?.total}",
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700));

          topSection = Column(children: [
            Text("Estimate price",
                style: TextStyle(fontSize: 12, color: Style.greyDark)),
            topSection
          ]);

          yield topSection;
          yield SizedBox(height: 12);
          yield Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [oriDestInfo(), oriDestInfo(isDest: true)]);
          yield SizedBox(height: 12);
          yield Row(children: [
            Icon(Icons.radio_button_unchecked, color: Style.greyDark),
            Expanded(
                child: DashLine(
                    centerWidget:
                        Icon(Icons.flight_takeoff, color: Style.greyDark),
                    color: Style.greyDark)),
            Icon(Icons.radio_button_checked, color: Style.greyDark),
          ]);

          if (flightDestination?.links?.flightOffers?.isNotEmpty ?? false) {
            yield SizedBox(height: 16);
            yield CommonButton(
                elevation: 0,
                minWidth: double.infinity,
                child: Text("See Offers"),
                onPressed: () {
                  Uri uri = Uri.parse(flightDestination.links.flightOffers);

                  Get.offNamed(FlightOfferScreen.RouteName,
                      arguments: uri.queryParameters);
                });
          }
        }),
      ),
    );
  }
}
