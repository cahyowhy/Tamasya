import 'package:flutter/material.dart';
import 'package:tamasya/component/flight-offer-travel-pricing.dart';
import 'package:tamasya/component/flight-offers-filter-info.dart';
import 'package:tamasya/component/flight-offers-detail-itenerary.dart';
import 'package:tamasya/component/flight-offers-item.dart';
import 'package:tamasya/component/form-head.dart';
import 'package:tamasya/model/filter-flight-offer.dart';
import 'package:tamasya/model/flight-offer.dart';

class FlightOffersDetail extends StatelessWidget {
  const FlightOffersDetail(
      {Key key, @required this.flightOffer, @required this.filter})
      : super(key: key);
  final FlightOffer flightOffer;
  final FilterFlightOffer filter;

  @override
  Widget build(BuildContext context) {
    Widget flightOfferItem = Align(
        child: FlightOffersItem(flightOffer, showDetail: true),
        alignment: Alignment.center);

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(double.infinity, 56),
          child: FormHead(title: "Flight Offer Details")),
      body: ListView(
        children: [
          SizedBox(height: 12),
          FlightOfferFilterInfo(filter: filter, flightOffer: flightOffer),
          SizedBox(height: 24),
          flightOfferItem,
          SizedBox(height: 24),
          FlightOfferTravelPricing(
              listTravelPricing: flightOffer.travelerPricings),
          SizedBox(height: 24),
          FlightOffersDetailItenerary(iteneraries: flightOffer.itineraries),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
