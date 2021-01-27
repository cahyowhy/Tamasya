import 'package:flutter/material.dart';
import 'package:tamasya/component/measure-size.dart';
import 'package:tamasya/model/filter-flight-offer.dart';
import 'package:tamasya/model/flight-offer.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/underscore.dart';

class FlightOfferFilterInfo extends StatefulWidget {
  FlightOfferFilterInfo(
      {Key key, @required this.filter, @required this.flightOffer})
      : super(key: key);

  final FilterFlightOffer filter;
  final FlightOffer flightOffer;

  @override
  _FlightOfferFilterInfoState createState() => _FlightOfferFilterInfoState();
}

class _FlightOfferFilterInfoState extends State<FlightOfferFilterInfo> {
  double firstRowHeight = 0;

  String get fromDateDetail {
    if (widget?.flightOffer?.itineraries?.isNotEmpty ?? false) {
      DateTime firstDate =
          widget.flightOffer.itineraries.first.segments?.first?.arrival?.at;
      DateTime secondDate =
          widget.flightOffer.itineraries.first.segments?.first?.departure?.at;

      if ((firstDate?.millisecondsSinceEpoch ?? 0) <
          (secondDate?.millisecondsSinceEpoch ?? 0)) {
        return formatDate(date: firstDate);
      }

      return formatDate(date: secondDate);
    }

    return null;
  }

  String get toDateDetail {
    if (widget?.flightOffer?.itineraries?.isNotEmpty ?? false) {
      DateTime firstDate =
          widget.flightOffer.itineraries.first.segments?.last?.arrival?.at;
      DateTime secondDate =
          widget.flightOffer.itineraries.first.segments?.last?.departure?.at;

      if ((firstDate?.millisecondsSinceEpoch ?? 0) >
          (secondDate?.millisecondsSinceEpoch ?? 0)) {
        return formatDate(date: firstDate);
      }

      return formatDate(date: secondDate);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget leftTimelineWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Style.renderDotTimeline(),
          Container(height: firstRowHeight, width: 1.0, color: Style.textColor),
          Style.renderDotTimeline(),
        ]);

    bool showInfoDate = fromDateDetail != null && toDateDetail != null;

    Widget renderInfoLocation(String country, String iata) {
      return RichText(
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
            text: country ?? '-',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                fontFamily: 'Poppins',
                color: Style.textColor),
            children: [
              TextSpan(text: "  •  ", style: TextStyle(fontSize: 14)),
              TextSpan(
                  text: iata ?? '-',
                  style: TextStyle(color: Style.greyDark, fontSize: 14))
            ]),
      );
    }

    Widget infoWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MeasureSize(
          onChange: (size) =>
              setState(() => firstRowHeight = (size.height - Style.dotSize)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("from",
                  style: TextStyle(fontSize: 12, color: Style.greyDark)),
              renderInfoLocation(
                  widget.filter?.origin?.country, widget.filter?.origin?.iata),
              Text(widget.filter?.origin?.name ?? '-',
                  style: TextStyle(fontSize: 12), softWrap: true),
              showInfoDate
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(fromDateDetail,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Style.primaryBlue)),
                    )
                  : SizedBox(),
              SizedBox(height: 24),
              Text("to", style: TextStyle(fontSize: 12, color: Style.greyDark)),
            ],
          ),
        ),
        renderInfoLocation(widget.filter?.destination?.country,
            widget.filter?.destination?.iata),
        Text(widget.filter?.destination?.name ?? '-',
            style: TextStyle(fontSize: 12), softWrap: true),
        showInfoDate
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(toDateDetail,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Style.primaryBlue)),
              )
            : SizedBox(),
      ],
    );

    Widget icon = Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Style.primaryBlue,
          borderRadius: Style.borderRadius(param: 12)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.arrow_downward, size: 20, color: Colors.white),
        Icon(Icons.arrow_upward, size: 20, color: Colors.white)
      ]),
    );

    int adults = widget.filter?.adults ?? 1;
    bool hasMorePassenger = adults > 1;
    String infoPassenger = "$adults Adults";

    if ((widget.filter?.children ?? 0) > 0) {
      infoPassenger += ", ${widget.filter.children} Childrens";
      hasMorePassenger = true;
    }

    if ((widget.filter?.infants ?? 0) > 0) {
      infoPassenger += ", ${widget.filter.infants} Infants";
      hasMorePassenger = true;
    }

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: Style.maxWidth(),
        constraints: BoxConstraints(maxWidth: Style.maxWidth()),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            borderRadius: Style.borderRadius(param: 12),
            color: Colors.white,
            boxShadow: Style.commonBoxShadows),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        leftTimelineWidget,
                        SizedBox(width: 16),
                        Expanded(child: infoWidget),
                      ]),
                ),
                SizedBox(width: 16),
                icon
              ],
            ),
            Divider(color: Style.greyLight, height: 24),
            Row(
              children: [
                Icon(hasMorePassenger ? Icons.group : Icons.person),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Passengers",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16)),
                      Text(infoPassenger,
                          style:
                              TextStyle(color: Style.greyDark, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
