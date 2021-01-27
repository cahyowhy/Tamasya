import 'package:tamasya/model/flight-offer.dart';
import 'package:tamasya/model/hotel-offer.dart';
import 'package:tamasya/model/tour-activity.dart';
import 'package:tamasya/util/underscore.dart';

List<HotelOffer> parseHotelOffers(jsonResponse) {
  return mapGet(jsonResponse, ["data"], defaultValue: [])
      .map((e) {
        if (e == null) {
          return null;
        }

        return HotelOffer.fromJson(e as Map<String, dynamic>);
      })
      .cast<HotelOffer>()
      .toList();
}

List<TourActivity> parseTourActivities(jsonResponse) {
  return mapGet(jsonResponse, ["data"], defaultValue: [])
      .map((e) {
        if (e == null) {
          return null;
        }

        return TourActivity.fromJson(e as Map<String, dynamic>);
      })
      .cast<TourActivity>()
      .toList();
}

List<FlightOffer> parseFlightOffers(jsonResponse) {
  Map<String, dynamic> dictCarier = Map<String, dynamic>.from(
      mapGet(jsonResponse, ["dictionaries", "carriers"], defaultValue: {}));

  Map<String, dynamic> dictAirCraft = Map<String, dynamic>.from(
      mapGet(jsonResponse, ["dictionaries", "aircraft"], defaultValue: {}));

  return mapGet(jsonResponse, ["data"], defaultValue: [])
      .map((e) {
        if (e == null) {
          return null;
        }

        FlightOffer flightOffer =
            FlightOffer.fromJson(e as Map<String, dynamic>);

        flightOffer.itineraries =
            (flightOffer.itineraries ?? []).map((Itinerary itinerary) {
          itinerary.segments =
              (itinerary.segments ?? []).map((Segment segment) {
            String segCarrierCode = segment?.carrierCode;
            if (segCarrierCode != null) {
              segment.carrierDetail = dictCarier[segCarrierCode] ?? "-";
            }

            String opCarrierCode = segment?.operating?.carrierCode;
            if (opCarrierCode != null) {
              segment.operating.carrierDetail =
                  dictCarier[segCarrierCode] ?? "-";
            }

            String aircraftCode = segment?.aircraft?.code;
            if (aircraftCode != null) {
              segment.aircraft.codeDetail = dictAirCraft[aircraftCode] ?? "-";
            }

            return segment;
          }).toList();

          return itinerary;
        }).toList();

        return flightOffer;
      })
      .cast<FlightOffer>()
      .toList();
}
