import 'package:flutter/material.dart';
import 'package:tamasya/component/rating.dart';
import 'package:tamasya/model/hotel-offer.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/type-def.dart';

class HotelOffersItem extends StatelessWidget {
  const HotelOffersItem(
      {Key key, @required this.hotelOffer, this.onTap, this.simple = false})
      : super(key: key);
  final HotelOffer hotelOffer;
  final Function onTap;
  final bool simple;

  @override
  Widget build(BuildContext context) {
    double wh = simple ? 60 : Style.maxWidth();
    double hh = simple ? 60 : Style.maxWidth() / (9 / 6);

    Widget image = Style.renderImage(
        hotelOffer.urlMedia, hotelOffer.hotel.name, wh,
        hh: hh);
    Widget title = Text(hotelOffer.hotel.name,
        overflow: simple ? TextOverflow.ellipsis : TextOverflow.visible,
        style: TextStyle(
            fontSize: simple ? 16 : 18,
            fontWeight: simple ? FontWeight.w500 : FontWeight.w700));
    Widget rating = Rating(
        rating: int.tryParse(hotelOffer?.hotel?.rating ?? '0') ?? 0,
        size: simple ? 11 : 16);
    Widget price = Text(hotelOffer.cheapestPriceFmt,
        textAlign: TextAlign.right,
        style: TextStyle(
            fontSize: simple ? 16 : 20,
            fontWeight: FontWeight.w700,
            color: Style.primary));
    Widget addresFmt = Text(hotelOffer.addresFmt,
        overflow: simple ? TextOverflow.ellipsis : TextOverflow.visible,
        style: TextStyle(fontSize: 14, color: Style.greyDark));

    if (simple) {
      return Container(
        constraints:
            BoxConstraints(maxHeight: 120, maxWidth: Style.maxWidth() - 32),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            borderRadius: Style.borderRadius(), color: Colors.white),
        child: Row(
          children: [
            image,
            SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    SizedBox(height: 2),
                    rating,
                    SizedBox(height: 4),
                    addresFmt,
                    SizedBox(height: 8),
                    price
                  ]),
            )
          ],
        ),
      );
    }

    Widget widget =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      image,
      SizedBox(height: 16),
      Container(
        width: Style.maxWidth(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            SizedBox(height: 2),
            rating,
            SizedBox(height: 8),
            addresFmt,
            SizedBox(height: 16),
            Row(
              children: toList(() sync* {
                if (hotelOffer.cheapestInfo != null) {
                  yield Image.asset("assets/image/png/icon-bed.png", width: 20);
                  yield SizedBox(width: 8);
                  yield Text(hotelOffer.totalBedCheapestOffer.toString(),
                      style: TextStyle(color: Style.greyDark, fontSize: 14));
                  yield SizedBox(width: 16);
                }

                if (hotelOffer.hasBath) {
                  yield Image.asset("assets/image/png/icon-bathtub.png",
                      width: 20);
                  yield SizedBox(width: 16);
                }

                if (hotelOffer.hasWifi) {
                  yield Image.asset("assets/image/png/icon-wifi.png",
                      width: 20);
                  yield SizedBox(width: 16);
                }

                yield Expanded(child: price);
              }),
            ),
          ],
        ),
      ),
    ]);

    if (onTap != null) {
      widget = InkWell(child: widget, onTap: onTap);
    }

    return widget;
  }
}
