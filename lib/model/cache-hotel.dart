import 'package:tamasya/model/base_model.dart';
import 'package:tamasya/model/filter-hotel-offer.dart';
import 'package:tamasya/model/hotel-offer.dart';

class CacheHotel extends BaseModel {
  final FilterHotelOffer lastFilter;
  final List<HotelOffer> lastHotelOffers;
  final int lastTime;

  CacheHotel({this.lastFilter, this.lastHotelOffers, this.lastTime});

  fromJson(json) {
    return CacheHotel.fromJson(json);
  }

  factory CacheHotel.fromJson(Map<String, dynamic> json) {
    return CacheHotel(
      lastFilter: json['lastFilter'] != null
          ? FilterHotelOffer.fromJson(json['lastFilter'])
          : null,
      lastHotelOffers: json['lastHotelOffers'] != null
          ? List<HotelOffer>.from(json["lastHotelOffers"].map((x) => HotelOffer.fromJson(x)))
          : null,
      lastTime: json['lastTime'] ?? null,
    );
  }

  Map<String, dynamic> toJson() => {
        "lastTime": lastTime ?? null,
        "lastFilter": lastFilter == null ? null : lastFilter.toJson(),
        "lastHotelOffers": lastHotelOffers == null
            ? null
            : List<dynamic>.from(lastHotelOffers.map((x) => x.toJson()))
      };
}
