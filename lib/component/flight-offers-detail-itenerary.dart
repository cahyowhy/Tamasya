import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tamasya/component/column-builder.dart';
import 'package:tamasya/component/measure-size.dart';
import 'package:tamasya/model/airport.dart';
import 'package:tamasya/model/flight-offer.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/airport-reader.dart';
import 'package:tamasya/util/type-def.dart';

class FlightOffersDetailItenerary extends StatefulWidget {
  FlightOffersDetailItenerary({Key key, this.iteneraries}) : super(key: key);
  final List<Itinerary> iteneraries;

  @override
  _FlightOffersDetailIteneraryState createState() =>
      _FlightOffersDetailIteneraryState();
}

class _FlightOffersDetailIteneraryState
    extends State<FlightOffersDetailItenerary> {
  List<double> stateRowHeights = [];

  @override
  void initState() {
    super.initState();

    (widget.iteneraries ?? []).forEach((Itinerary itenerary) {
      (itenerary?.segments ?? []).forEach((_) {
        stateRowHeights.add(0);
        stateRowHeights.add(0);
      });
    });
  }

  List<Itinerary> get itineraries {
    if (widget.iteneraries?.isNotEmpty ?? false) {
      return widget.iteneraries;
    }

    return [];
  }

  Widget renderSegmentSection(Segment segment, int i,
      {bool isDeparture = false}) {
    Widget dotWidget = Style.renderDotTimeline();

    dotWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: toList(() sync* {
        if (isDeparture) yield dotWidget;
        yield Container(
            height: stateRowHeights[i], width: 1.0, color: Style.textColor);
        if (!isDeparture) yield dotWidget;
      }),
    );

    Widget infoWidget = Row(
        crossAxisAlignment:
            isDeparture ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Expanded(
              child: renderInfoSegment(segment,
                  isDeparture: isDeparture, isHour: true)),
          Expanded(child: renderInfoSegment(segment, isDeparture: isDeparture)),
        ]);

    infoWidget = Expanded(
      child: MeasureSize(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(
                top: !isDeparture ? 12 : 0, bottom: isDeparture ? 12 : 0),
            child: infoWidget,
          ),
          onChange: (size) => setState(
              () => stateRowHeights[i] = (size.height - Style.dotSize))),
    );

    Widget row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [dotWidget, SizedBox(width: 24), infoWidget],
    );

    if (!isDeparture) {
      var boxDecor = BoxDecoration(
          border: Border(bottom: BorderSide(color: Style.backgroundGreyLight)));

      row = Stack(
        alignment: Alignment.topRight,
        children: [
          Container(decoration: boxDecor, width: Get.width - 100),
          row
        ],
      );
    }

    return row;
  }

  Widget renderInfoSegment(Segment segment,
      {bool isDeparture = false, bool isHour = false}) {
    String left;
    String right;

    if (isHour) {
      String terminal = ((isDeparture
              ? segment?.departure?.terminal
              : segment?.arrival?.terminal) ??
          "-");
      left = (isDeparture
              ? segment?.departure?.formatHourAt
              : segment?.arrival?.formatHourAt) ??
          '-';
      right = "Terminal  :  $terminal";
    } else {
      Airport airport = AirportDataReader.searchIata(isDeparture
          ? segment?.departure?.iataCode
          : segment?.arrival?.iataCode);
      left = (isDeparture
              ? segment?.departure?.formatDateAt
              : segment?.arrival?.formatDateAt) ??
          '-';

      right = airport?.name ?? '-';
    }

    TextStyle leftTextStyle = TextStyle(color: Style.textColor);
    TextStyle rightTextStyle = TextStyle(color: Style.greyDark, fontSize: 12);

    if (isHour) {
      leftTextStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.w500);
      rightTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(left, style: leftTextStyle),
          SizedBox(height: 4),
          Text(right, style: rightTextStyle)
        ]);
  }

  Widget commonContainer(Widget child,
      {bool isBottRad = false,
      bool isTopRad = false,
      Color color,
      double padTop = 0,
      double padBot = 0}) {
    Radius rad = Radius.circular(12);
    Radius radZero = Radius.circular(0);

    return Container(
      width: Get.width - 38,
      child: child,
      padding:
          EdgeInsets.only(left: 16, right: 16, bottom: padBot, top: padTop),
      decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.only(
              bottomLeft: isBottRad ? rad : radZero,
              bottomRight: isBottRad ? rad : radZero,
              topLeft: isTopRad ? rad : radZero,
              topRight: isTopRad ? rad : radZero)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColumnBuilder(
        itemCount: itineraries.length,
        itemBuilder: (_, int i) {
          Itinerary itenerary = itineraries[i];
          int segmentLength = itenerary.segments.length;

          Widget infoItenerary = commonContainer(
              Row(
                children: [
                  Icon(Icons.flag),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Itinerary ${i + 1}",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16)),
                        Text("Total Duration  :  ${itenerary.durationFormated}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
              padBot: 12,
              padTop: 12,
              isTopRad: true,
              color: Style.backgroundGreyLight);

          return Container(
            margin:
                EdgeInsets.only(bottom: i < (itineraries.length - 1) ? 24 : 0),
            decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: Style.commonBoxShadows,
                borderRadius: Style.borderRadius(param: 12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                infoItenerary,
                ColumnBuilder(
                  itemCount: segmentLength,
                  itemBuilder: (_, int segmentIdx) {
                    Segment segment = itenerary.segments[segmentIdx];
                    int idxFinal = (i * 2) + (segmentIdx * 2);

                    Widget infoTop = commonContainer(
                        Row(children: [
                          Icon(Icons.access_time),
                          SizedBox(width: 16),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Duration",
                                  style: TextStyle(
                                      fontSize: 12, color: Style.greyDark)),
                              Text(segment.durationFormated,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ))
                        ]),
                        padTop: 12);

                    int numberStop = segment?.numberOfStops ?? 0;
                    Widget infoContent = commonContainer(
                        Flex(
                          direction: Axis.vertical,
                          children: [
                            SizedBox(height: 16),
                            renderSegmentSection(segment, idxFinal + 1,
                                isDeparture: true),
                            renderSegmentSection(segment, idxFinal),
                            Container(
                                height: 1,
                                color: Style.backgroundGreyLight,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16)),
                            Style.renderLabelInfo(
                                "Carrier", segment?.carrierDetail ?? "-",
                                bottom: 4),
                            Style.renderLabelInfo(
                                "Number", segment?.number ?? "-",
                                bottom: 4),
                            Style.renderLabelInfo("Aircraft",
                                segment?.aircraft?.codeDetail ?? "-",
                                bottom: numberStop > 0 ? 4 : 0),
                            numberStop > 0
                                ? Style.renderLabelInfo(
                                    "Number of Stop", numberStop.toString(),
                                    bottom: 4)
                                : SizedBox(),
                          ],
                        ),
                        padBot: 16,
                        isBottRad: segmentIdx == segmentLength - 1);

                    bool showSeparator = segmentIdx < (segmentLength - 1);

                    return Container(
                      decoration: showSeparator
                          ? BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Style.backgroundGreyLight,
                                      width: 1)))
                          : null,
                      child: Column(
                        children: [infoTop, infoContent],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        });
  }
}
