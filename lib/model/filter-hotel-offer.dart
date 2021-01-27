import 'dart:math';

import 'package:tamasya/config/constant.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/model/airport.dart';
import 'package:tamasya/model/base_model.dart';
import 'package:tamasya/style/string-util.dart';
import 'package:tamasya/util/underscore.dart';

/// Mandatory parameter for a search by geocodes
/// Should be used together with latitude+longitude+radius+radiusUnit (required)
///
/// Mandatory parameter for a city search
/// Should be used together with cityCode+radius+radiusUnit (required)
///
/// Mandatory parameter for a price range
/// Should be used together with priceRange+currency (required)
class FilterHotelOffer extends BaseModel {
  /// priority
  Airport destination;
  DateTime checkinDate = DateTime.now().add(Duration(days: 7));
  DateTime checkoutDate;
  int radius;
  int adults;
  int roomQuantity;
  String radiusUnit;

  /// implement if use map
  double latitude;
  double longitude;

  /// aditional
  List<String> amenities = [];
  int lowestPrice;
  int highestPrice;
  int lowRating;
  int hightRating;
  String boardType;
  String hotelName;

  /// paging
  int limit;
  int offset;
  String sort;

  /// latter
  String currency = MainWidgetController.instance.currency;

  /// flag
  bool searchByMap = false;

  FilterHotelOffer({
    this.radius = Constant.DEFAULT_RADIUS_MAP,
    this.adults = 1,
    this.roomQuantity = 1,
    this.radiusUnit = 'KM',
    this.latitude,
    this.longitude,
    this.amenities,
    this.lowestPrice = 0,
    this.highestPrice = 0,
    this.lowRating = 1,
    this.hightRating = 5,
    this.boardType,
    this.hotelName,
    this.limit = Constant.PAGING_LIMIT,
    this.offset = 0,
    this.currency,
    this.searchByMap = false,
  });

  String get labelCheckinCheckout {
    String label = "Pick Check In date";
    if (this.checkinDate != null) {
      label = formatDate(date: checkinDate);

      if (checkoutDate != null) {
        label += " - ${formatDate(date: checkoutDate)}";
      }
    }

    return label;
  }

  String get labelRating {
    if ((lowRating ?? 0) > 0 && (hightRating ?? 0) > 0) {
      return "$lowRating - $hightRating";
    } else if ((lowRating ?? 0) > 0) {
      return ">$lowRating";
    } else if ((hightRating ?? 0) > 0) {
      return "<$hightRating";
    }

    return "1 - 5";
  }

  String get labelPrice {
    if (lowestPrice > 0 || highestPrice > 0) {
      int minVal = min(lowestPrice, highestPrice);
      int maxVal = max(lowestPrice, highestPrice);

      return "${formatCurrency(minVal, symbol: '')} - ${formatCurrency(maxVal, symbol: '')}";
    }

    return "All price";
  }

  setDefaultValue({bool searchByMap = false}) {
    this.offset = 0;
    this.searchByMap = searchByMap;
    this.limit = searchByMap ? Constant.MAX_LIMIT : Constant.PAGING_LIMIT;

    if (this.radius != null && this.radius > Constant.MAX_RADIUS_MAP) {
      this.radius = Constant.MAX_RADIUS_MAP;
    } else if (this.radius == null) {
      this.radius = Constant.DEFAULT_RADIUS_MAP;
    }
  }

  fromJson(json) {
    return FilterHotelOffer.fromJson(json);
  }

  factory FilterHotelOffer.fromJson(Map<String, dynamic> json) {
    var radius = json['radius'] ?? Constant.DEFAULT_RADIUS_MAP;
    var adults = json['adults'] ?? 1;
    var roomQuantity = json['roomQuantity'] ?? 1;
    var radiusUnit = json['radiusUnit'] ?? 'KM';
    var latitude = json['latitude'];
    var longitude = json['longitude'];
    var lowestPrice = json['lowestPrice'] ?? 0;
    var highestPrice = json['highestPrice'] ?? 0;
    var lowRating = json['lowRating'] ?? 1;
    var hightRating = json['hightRating'] ?? 5;
    var boardType = json['boardType'];
    var hotelName = json['hotelName'];
    var limit = json['limit'] ?? Constant.PAGING_LIMIT;
    var offset = json['offset'] ?? 0;
    var sort = json['sort'];
    var currency = json['currency'] ?? MainWidgetController.instance.currency;
    var amenities, checkinDate, checkoutDate, destination;

    if (json['amenities'] != null) {
      amenities = List<String>.from(json["amenities"]);
    }

    if (json['checkinDate'] != null) {
      checkinDate = DateTime.fromMillisecondsSinceEpoch(json['checkinDate']);
    }

    if (json['checkoutDate'] != null) {
      checkoutDate = DateTime.fromMillisecondsSinceEpoch(json['checkoutDate']);
    }

    if (json['destination'] != null) {
      destination = Airport.fromJson(json['destination']);
    }

    return FilterHotelOffer(
        radius: radius,
        adults: adults,
        roomQuantity: roomQuantity,
        radiusUnit: radiusUnit,
        latitude: latitude,
        longitude: longitude,
        lowestPrice: lowestPrice,
        highestPrice: highestPrice,
        lowRating: lowRating,
        hightRating: hightRating,
        boardType: boardType,
        hotelName: hotelName,
        limit: limit,
        offset: offset,
        currency: currency,
        amenities: amenities)
      ..sort = sort
      ..checkinDate = checkinDate
      ..checkoutDate = checkoutDate
      ..destination = destination;
  }

  Map<String, dynamic> toJson({bool toParamSearch = false}) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    double latitude = this.latitude;
    double longitude = this.longitude;

    if (toParamSearch && latitude != null) {
      latitude = double.parse(latitude.toStringAsFixed(2));
    }

    if (toParamSearch && longitude != null) {
      longitude = double.parse(longitude.toStringAsFixed(2));
    }

    writeNotNull(data, 'radius', this.radius);
    writeNotNull(data, 'adults', this.adults);
    writeNotNull(data, 'roomQuantity', this.roomQuantity);
    writeNotNull(data, 'radiusUnit', this.radiusUnit);
    writeNotNull(data, 'latitude', latitude);
    writeNotNull(data, 'longitude', longitude);
    writeNotNull(data, 'boardType', this.boardType);
    writeNotNull(data, 'hotelName', this.hotelName);
    writeNotNull(data, 'amenities', this.amenities);
    writeNotNull(data, toParamSearch ? 'page[limit]' : 'limit', this.limit);
    writeNotNull(data, 'sort', this.sort);
    writeNotNull(data, 'currency', this.currency);

    if (toParamSearch) {
      if (checkinDate != null) {
        data['checkinDate'] =
            formatDate(date: checkinDate, format: Constant.DATE_FORMAT_SEARCH);
      }

      if (checkoutDate != null) {
        data['checkoutDate'] =
            formatDate(date: checkoutDate, format: Constant.DATE_FORMAT_SEARCH);
      }

      if (this.destination?.iata != null) {
        data['cityCode'] = this.destination.iata;
      }

      String priceRange;

      if ((lowestPrice ?? 0) > 0 && (highestPrice ?? 0) > 0) {
        priceRange = "$lowestPrice-$highestPrice";
      } else if ((lowestPrice ?? 0) > 0) {
        priceRange = "-$lowestPrice";
      } else if ((highestPrice ?? 0) > 0) {
        priceRange = "$highestPrice";
      }

      writeNotNull(data, 'priceRange', priceRange);

      List<int> ratings = [];
      if ((lowRating ?? 0) > 0 && (hightRating ?? 0) > 0) {
        ratings = List<int>.generate(
            (hightRating - lowRating) + 1, (index) => index + 1);
      } else if ((lowRating ?? 0) > 0) {
        ratings = [lowRating];
      } else if ((hightRating ?? 0) > 0) {
        ratings = [hightRating];
      }

      if (ratings.length > 0) writeNotNull(data, 'ratings', ratings);
      BaseModel.deleteEmptyVal(data, deleteFalseValue: true);

      writeNotNull(
          data, toParamSearch ? 'page[offset]' : 'offset', this.offset);
    } else {
      writeNotNull(data, 'lowestPrice', this.lowestPrice);
      writeNotNull(data, 'highestPrice', this.highestPrice);
      writeNotNull(data, 'lowRating', this.lowRating);
      writeNotNull(data, 'hightRating', this.hightRating);
      writeNotNull(data, 'checkinDate', checkinDate?.millisecondsSinceEpoch);
      writeNotNull(data, 'checkoutDate', checkoutDate?.millisecondsSinceEpoch);
      writeNotNull(data, 'destination', this.destination?.toJson());
    }

    if (toParamSearch) {
      if (this.latitude != null && this.longitude != null && this.searchByMap) {
        data.remove('cityCode');
      } else {
        data.remove('latitude');
        data.remove('longitude');
      }

      if (data['radius'] != null && data['radius'] > Constant.MAX_RADIUS_MAP) {
        data['radius'] = Constant.MAX_RADIUS_MAP;
      }
    }

    return data;
  }
}
