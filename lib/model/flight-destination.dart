import 'package:intl/intl.dart';
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/model/base_model.dart';
import 'package:tamasya/model/flight-links.dart';
import 'package:tamasya/model/price.dart';
import 'package:tamasya/util/underscore.dart';

class FlightDestination extends BaseModel {
  String type;
  String origin;
  String destination;
  String detailOrigin;
  String detailDestination;
  String departureDate;
  String returnDate;
  Price price;
  FlightLinks links;

  String get formatDateDeparture {
    if (departureDate != null) {
      DateTime departureDateTime =
          DateFormat(Constant.DATE_FORMAT_SEARCH).parseLoose(departureDate);

      return formatDate(
              date: departureDateTime, format: Constant.SIMPLE_DATE_FORMATED) ??
          "-";
    }

    return "-";
  }

  String get formatDateReturn {
    if (departureDate != null) {
      DateTime returnDateTime =
          DateFormat(Constant.DATE_FORMAT_SEARCH).parseLoose(returnDate);

      return formatDate(
              date: returnDateTime, format: Constant.SIMPLE_DATE_FORMATED) ??
          "-";
    }

    return "-";
  }

  FlightDestination(
      {this.type,
      this.origin,
      this.destination,
      this.detailOrigin,
      this.detailDestination,
      this.departureDate,
      this.returnDate,
      this.price,
      this.links});

  fromJson(json) {
    return FlightDestination.fromJson(json);
  }

  factory FlightDestination.fromJson(Map<String, dynamic> json) {
    return FlightDestination(
        type: json['type'],
        origin: json['origin'],
        destination: json['destination'],
        departureDate: json['departureDate'],
        detailOrigin: json['detailOrigin'],
        detailDestination: json['detailDestination'],
        returnDate: json['returnDate'],
        price: json['price'] != null ? new Price.fromJson(json['price']) : null,
        links: json['links'] != null
            ? new FlightLinks.fromJson(json['links'])
            : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['origin'] = this.origin;
    data['destination'] = this.destination;
    data['departureDate'] = this.departureDate;
    data['returnDate'] = this.returnDate;
    data['detailOrigin'] = this.detailOrigin;
    data['detailDestination'] = this.detailDestination;

    if (this.price != null) {
      data['price'] = this.price.toJson();
    }

    if (this.links != null) {
      data['links'] = this.links.toJson();
    }

    return data;
  }
}
