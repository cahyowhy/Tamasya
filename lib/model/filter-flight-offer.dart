import 'package:intl/intl.dart';
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/model/airport.dart';
import 'package:tamasya/model/base_model.dart';
import 'package:tamasya/util/airport-reader.dart';
import 'package:tamasya/util/underscore.dart';

class FilterFlightOffer extends BaseModel {
  Airport destination;
  Airport origin;
  DateTime departureDateStart = DateTime.now().add(Duration(days: 7));
  DateTime departureDateEnd;
  DateTime returnDateStart;
  DateTime returnDateEnd;
  int adults;
  int children;
  int infants;
  String travelClass;
  bool nonStop;
  int maxPrice;

  /// hold
  String includedAirlineCodes;
  String excludedAirlineCodes;
  String currencyCode = MainWidgetController.instance.currency;

  FilterFlightOffer(
      {this.adults = 1,
      this.children = 0,
      this.infants = 0,
      this.travelClass = "",
      this.nonStop = false,
      this.maxPrice = 0,
      this.includedAirlineCodes,
      this.excludedAirlineCodes,
      this.currencyCode});

  fromJson(json) {
    return FilterFlightOffer.fromJson(json);
  }

  factory FilterFlightOffer.fromJson(Map<String, dynamic> json,
      {bool fromUriParse = false}) {
    var travelClass = json['travelClass'];
    var adults,
        children,
        infants,
        maxPrice,
        currencyCode,
        nonStop,
        departureDateStart,
        returnDateStart,
        destination,
        origin,
        departureDateEnd,
        returnDateEnd;

    if (fromUriParse) {
      adults = int.parse(json['adults'] ?? '1');
      children = int.parse(json['children'] ?? '0');
      infants = int.parse(json['infants'] ?? '0');
      maxPrice = int.parse(json['maxPrice'] ?? '0');
      currencyCode = MainWidgetController.instance.currency;
      nonStop = json['nonStop'] == 'true';

      if (json['departureDate'] != null) {
        departureDateStart = DateFormat(Constant.DATE_FORMAT_SEARCH)
            .parseLoose(json['departureDate']);
      }

      if (json['returnDate'] != null) {
        returnDateStart = DateFormat(Constant.DATE_FORMAT_SEARCH)
            .parseLoose(json['returnDate']);
      }

      if (json['destinationLocationCode'] != null) {
        destination =
            AirportDataReader.searchIata(json['destinationLocationCode']);
      }

      if (json['originLocationCode'] != null) {
        origin = AirportDataReader.searchIata(json['originLocationCode']);
      }
    } else {
      adults = json['adults'];
      children = json['children'];
      infants = json['infants'];
      nonStop = json['nonStop'];
      maxPrice = json['maxPrice'];

      if (json['departureDateStart'] != null) {
        departureDateStart =
            DateTime.fromMillisecondsSinceEpoch(json['departureDateStart']);
      }

      if (json['departureDateEnd'] != null) {
        departureDateEnd =
            DateTime.fromMillisecondsSinceEpoch(json['departureDateEnd']);
      }

      if (json['returnDateStart'] != null) {
        returnDateStart =
            DateTime.fromMillisecondsSinceEpoch(json['returnDateStart']);
      }

      if (json['returnDateEnd'] != null) {
        returnDateEnd =
            DateTime.fromMillisecondsSinceEpoch(json['returnDateEnd']);
      }

      if (json['destination'] != null) {
        destination = Airport.fromJson(json['destination']);
      }

      if (json['origin'] != null) {
        origin = Airport.fromJson(json['origin']);
      }
    }

    return FilterFlightOffer(
        adults: adults,
        children: children,
        infants: infants,
        maxPrice: maxPrice,
        currencyCode: currencyCode,
        nonStop: nonStop)
      ..departureDateStart = departureDateStart
      ..returnDateStart = returnDateStart
      ..destination = destination
      ..origin = origin
      ..departureDateEnd = departureDateEnd
      ..returnDateEnd = returnDateEnd
      ..travelClass = travelClass;
  }

  Map<String, dynamic> toJson({bool toParamSearch = false}) {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    writeNotNull(data, 'travelClass', this.travelClass);
    writeNotNull(data, 'adults', this.adults);
    writeNotNull(data, 'children', this.children);
    writeNotNull(data, 'infants', this.infants);
    writeNotNull(data, 'nonStop', this.nonStop);
    writeNotNull(data, 'maxPrice', this.maxPrice);
    writeNotNull(data, 'currencyCode', this.currencyCode);

    if (toParamSearch) {
      if (departureDateStart != null) {
        data['departureDate'] = formatDate(
            date: departureDateStart, format: Constant.DATE_FORMAT_SEARCH);
      }

      if (departureDateEnd != null &&
          !isSameDates([departureDateEnd, departureDateStart])) {
        data['departureDate'] +=
            ",${formatDate(date: departureDateStart, format: Constant.DATE_FORMAT_SEARCH)}";
      }

      if (returnDateStart != null) {
        data['returnDate'] = formatDate(
            date: returnDateStart, format: Constant.DATE_FORMAT_SEARCH);
      }

      if (returnDateEnd != null &&
          !isSameDates([returnDateEnd, returnDateStart])) {
        data['returnDate'] +=
            ",${formatDate(date: returnDateEnd, format: Constant.DATE_FORMAT_SEARCH)}";
      }

      if (this.destination?.iata != null) {
        data['destinationLocationCode'] = this.destination.iata;
      }

      if (this.origin?.iata != null) {
        data['originLocationCode'] = this.origin.iata;
      }

      BaseModel.deleteEmptyVal(data, deleteFalseValue: true);
    } else {
      writeNotNull(data, 'departureDateStart',
          departureDateStart?.millisecondsSinceEpoch);
      writeNotNull(
          data, 'departureDateEnd', departureDateEnd?.millisecondsSinceEpoch);

      writeNotNull(
          data, 'returnDateStart', returnDateStart?.millisecondsSinceEpoch);
      writeNotNull(
          data, 'returnDateEnd', returnDateEnd?.millisecondsSinceEpoch);

      writeNotNull(data, 'destination', this.destination?.toJson());
      writeNotNull(data, 'origin', this.origin?.toJson());
    }

    return data;
  }
}
