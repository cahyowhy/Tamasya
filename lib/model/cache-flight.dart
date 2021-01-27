import 'package:tamasya/model/base_model.dart';
import 'package:tamasya/model/filter-flight-offer.dart';
import 'package:tamasya/model/flight-offer.dart';

class CacheFlight extends BaseModel {
  final FilterFlightOffer lastFilter;
  final List<FlightOffer> lastFlightOffers;
  final int lastTime;

  CacheFlight({this.lastFilter, this.lastFlightOffers, this.lastTime});

  fromJson(json) {
    return CacheFlight.fromJson(json);
  }

  factory CacheFlight.fromJson(Map<String, dynamic> json) {
    return CacheFlight(
      lastFilter: json['lastFilter'] != null
          ? FilterFlightOffer.fromJson(json['lastFilter'])
          : null,
      lastFlightOffers: json['lastFlightOffers'] != null
          ? List<FlightOffer>.from(
              json["lastFlightOffers"].map((x) => FlightOffer.fromJson(x)))
          : null,
      lastTime: json['lastTime'] ?? null,
    );
  }

  Map<String, dynamic> toJson() => {
        "lastTime": lastTime ?? null,
        "lastFilter": lastFilter == null ? null : lastFilter.toJson(),
        "lastFlightOffers": lastFlightOffers == null
            ? null
            : List<dynamic>.from(lastFlightOffers.map((x) => x.toJson()))
      };
}
