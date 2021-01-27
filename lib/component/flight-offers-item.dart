import 'package:flutter/material.dart';
import 'package:tamasya/component/common-button.dart';
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/model/flight-offer.dart';
import 'package:tamasya/style/string-util.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/type-def.dart';
import 'package:tamasya/util/underscore.dart';

class FlightOffersItem extends StatelessWidget {
  final FlightOffer flightOffer;
  final Function() onClickDetail;
  final bool showDetail;

  const FlightOffersItem(this.flightOffer,
      {Key key, this.onClickDetail, this.showDetail = false})
      : super(key: key);

  Widget renderContainer(Widget child,
      {BorderRadius borderRadius,
      EdgeInsets edgeInsets,
      List<BoxShadow> boxShadows,
      Color color,
      double width,
      double height}) {
    return Container(
        child: child,
        width: width,
        padding:
            edgeInsets ?? EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: color ?? Colors.white,
            boxShadow: boxShadows,
            borderRadius: borderRadius ?? Style.borderRadius(param: 0)));
  }

  Widget renderIconInfo(IconData icons, String title, String desc) {
    return Row(
      children: [
        renderContainer(Icon(icons, size: 20),
            edgeInsets: EdgeInsets.all(8),
            borderRadius: Style.borderRadius(param: 12)),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                  overflow: TextOverflow.ellipsis),
              Text(
                desc,
                style: TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: toList(() sync* {
          Widget topSection =
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Price",
                style: TextStyle(fontSize: 12, color: Style.greyDark)),
            Text(
                convertFormatCurrency(flightOffer?.price?.grandTotal,
                    flightOffer?.price?.currency),
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700))
          ]);

          if (onClickDetail != null || showDetail) {
            topSection = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: toList(() sync* {
                  yield topSection;

                  if (onClickDetail != null) {
                    yield CommonButton(
                        color: Style.accent,
                        child: Text("Detail"),
                        onPressed: onClickDetail,
                        elevation: 0);
                  } else if (showDetail) {
                    yield Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Price without Taxes",
                              style: TextStyle(
                                  fontSize: 12, color: Style.greyDark)),
                          Text(
                              formatCurrency(double.tryParse(
                                      flightOffer?.price?.base ?? '0')
                                  ?.floor()),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700))
                        ]);
                  }
                }));
          }

          const radius = Radius.circular(12);

          topSection = renderContainer(topSection,
              borderRadius:
                  BorderRadius.only(topLeft: radius, topRight: radius));

          int itinerary = flightOffer?.itineraries?.length ?? 0;
          int bookableSeats = flightOffer?.numberOfBookableSeats ?? 0;
          bool instantTicket = (flightOffer?.instantTicketingRequired ?? false);

          Widget botttomSection = Column(children: [
            renderContainer(
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Expanded(
                      child: renderIconInfo(Icons.outlined_flag,
                          "$itinerary Itenerary", "Info Iteneraries")),
                  Expanded(
                      child: renderIconInfo(Icons.featured_play_list,
                          "$bookableSeats Books", "Max. Bookable"))
                ]),
                color: Style.backgroundGreyLight),
            renderContainer(
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Expanded(
                      child: renderIconInfo(
                          Icons.date_range,
                          formatDate(
                              date: flightOffer?.lastTicketingDate,
                              format: Constant.SIMPLEST_DATE_FORMATED_2),
                          "Last Ticket date")),
                  Expanded(
                      child: renderIconInfo(
                          instantTicket ? Icons.check : Icons.close,
                          instantTicket ? "Yes" : "No",
                          "Instant ticketing"))
                ]),
                color: Style.backgroundGreyLight,
                borderRadius:
                    BorderRadius.only(bottomLeft: radius, bottomRight: radius))
          ]);

          yield renderContainer(Column(children: [topSection, botttomSection]),
              boxShadows: Style.commonBoxShadows,
              borderRadius: Style.borderRadius(param: 12),
              width: Style.maxWidth(),
              edgeInsets: EdgeInsets.all(0));
        }));
  }
}
