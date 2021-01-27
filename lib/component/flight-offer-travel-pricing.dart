import 'package:flutter/material.dart';
import 'package:tamasya/component/column-builder.dart';
import 'package:tamasya/model/flight-offer.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/type-def.dart';
import 'package:tamasya/util/underscore.dart';

class FlightOfferTravelPricing extends StatefulWidget {
  final List<TravelerPricing> listTravelPricing;
  FlightOfferTravelPricing({Key key, this.listTravelPricing}) : super(key: key);

  @override
  _FlightOfferTravelPricingState createState() =>
      _FlightOfferTravelPricingState();
}

class _FlightOfferTravelPricingState extends State<FlightOfferTravelPricing> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    Radius rad = Radius.circular(12);

    Widget title = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: Style.backgroundGreyLight,
          borderRadius: BorderRadius.only(topLeft: rad, topRight: rad)),
      child: Row(
        children: [
          Icon(Icons.card_travel),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Traveler Pricings",
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                Text("Fare information for each traveler/segment",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Style.greyDark, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );

    return Align(
      alignment: Alignment.center,
      child: Container(
        width: Style.maxWidth(),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: Style.borderRadius(param: 12),
            boxShadow: Style.commonBoxShadows),
        child: Column(
          children: toList(() sync* {
            yield title;

            int listLength = widget.listTravelPricing.length;
            int finalLength = isExpanded ? listLength : 1;
            for (int i = 0; i < finalLength; i++) {
              TravelerPricing item = widget.listTravelPricing[i];
              String currency = item?.price?.currency;
              String priceFmt = convertFormatCurrency(item?.price?.total, currency);

              Widget price = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Price",
                        style: TextStyle(fontSize: 12, color: Style.greyDark)),
                    Text(priceFmt,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700))
                  ]);

              Widget priceNoTax =
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text("Price without Taxes",
                    style: TextStyle(fontSize: 12, color: Style.greyDark)),
                Text(convertFormatCurrency(item?.price?.base, currency),
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))
              ]);

              Widget priceInfo = Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [price, priceNoTax]);

              Widget travelerPricingWidget = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    priceInfo,
                    SizedBox(height: 16),
                    Style.renderLabelInfo(
                        "Fare Option", item?.fareOption ?? '-',
                        bottom: 4),
                    Style.renderLabelInfo(
                        "Traveler Type", item?.travelerType ?? '-',
                        bottom: 4)
                  ]);

              int fareSegLength = item.fareDetailsBySegment.length;
              Widget fareDetailSegmentWidget = ColumnBuilder(
                  itemCount: fareSegLength,
                  itemBuilder: (_, int i) {
                    var e = item.fareDetailsBySegment[i];
                    Widget column = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Style.renderLabelInfo("Cabin", e?.cabin ?? '-',
                            bottom: 4),
                        Style.renderLabelInfo("Fare Basis", e?.fareBasis ?? '-',
                            bottom: 4),
                        Style.renderLabelInfo(
                            "Class", e?.fareDetailsBySegmentClass ?? '-',
                            bottom: 4),
                        Style.renderLabelInfo("Checked Bags",
                            '${e?.includedCheckedBags?.weight ?? '0'} ${e?.includedCheckedBags?.weightUnit ?? 'Kg'}',
                            bottom: 4),
                      ],
                    );

                    if (i < fareSegLength - 1) {
                      column = Column(children: [
                        column,
                        Divider(height: 16, color: Style.greyLight),
                      ]);
                    }

                    return column;
                  });

              yield Container(
                  padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: i == (finalLength - 1) ? 16 : 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: i == 0 ? 12 : 24),
                        travelerPricingWidget,
                        SizedBox(height: 16),
                        fareDetailSegmentWidget
                      ]));
            }

            if (listLength > 1) {
              yield InkWell(
                onTap: () => setState(() => isExpanded = !isExpanded),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomLeft: rad, bottomRight: rad),
                    color: Style.backgroundGreyLight,
                  ),
                  height: 32,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Icon(isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}
