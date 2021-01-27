import 'package:tamasya/config/constant.dart';
import 'package:tamasya/model/base_model.dart';
import 'package:tamasya/style/string-util.dart';

class TourActivity extends BaseModel {
  TourActivity({
    this.id,
    this.type,
    this.self,
    this.name,
    this.shortDescription,
    this.geoCode,
    this.rating,
    this.pictures,
    this.bookingLink,
    this.price,
  });

  String id;
  String type;
  Self self;
  String name;
  String shortDescription;
  GeoCode geoCode;
  String rating;
  List<String> pictures;
  String bookingLink;
  Price price;

  String get imageLink {
    return pictures?.first ?? '';
  }

  String get priceFmt {
    int parseIt(String val) {
      var param = double.tryParse(val ?? '0');

      return param?.round() ?? 0;
    }

    int amount;
    String symbol;
    if (price?.amount != null) {
      amount = parseIt(price.amount);
    }

    if (price?.currencyCode != null) {
      symbol = Constant.CURRENCY_SYMBOL[price.currencyCode];
    }

    if (amount != null && symbol != null) {
      return formatCurrency(amount, symbol: symbol);
    }

    return "-";
  }

  factory TourActivity.fromJson(Map<String, dynamic> json) => TourActivity(
        id: json["id"],
        type: json["type"],
        self: json["self"] != null ? Self.fromJson(json["self"]) : null,
        name: json["name"],
        shortDescription: json["shortDescription"],
        geoCode:
            json["geoCode"] != null ? GeoCode.fromJson(json["geoCode"]) : null,
        rating: json["rating"],
        pictures: json["pictures"] != null
            ? List<String>.from(json["pictures"].map((x) => x))
            : null,
        bookingLink: json["bookingLink"],
        price: json["price"] != null ? Price.fromJson(json["price"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "self": self?.toJson(),
        "name": name,
        "shortDescription": shortDescription,
        "geoCode": geoCode?.toJson(),
        "rating": rating,
        "pictures": pictures != null
            ? List<dynamic>.from(pictures.map((x) => x))
            : null,
        "bookingLink": bookingLink,
        "price": price?.toJson(),
      };

  fromJson(json) {
    return TourActivity.fromJson(json);
  }
}

class GeoCode extends BaseModel {
  GeoCode({
    this.latitude,
    this.longitude,
  });

  String latitude;
  double latitudeFmt;
  String longitude;
  double longitudeFmt;

  factory GeoCode.fromJson(Map<String, dynamic> json) {
    var geocode = GeoCode(
      latitude: json["latitude"],
      longitude: json["longitude"],
    );

    if (geocode.latitude != null) {
      geocode.latitudeFmt = double.tryParse(geocode.latitude);
    }

    if (geocode.longitude != null) {
      geocode.longitudeFmt = double.tryParse(geocode.longitude);
    }

    return geocode;
  }

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };

  fromJson(json) {
    return GeoCode.fromJson(json);
  }
}

class Price extends BaseModel {
  Price({
    this.currencyCode,
    this.amount,
  });

  String currencyCode;
  String amount;

  factory Price.fromJson(Map<String, dynamic> json) => Price(
        currencyCode: json["currencyCode"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "currencyCode": currencyCode,
        "amount": amount,
      };

  fromJson(json) {
    return Price.fromJson(json);
  }
}

class Self extends BaseModel {
  Self({
    this.href,
    this.methods,
  });

  String href;
  List<String> methods;

  factory Self.fromJson(Map<String, dynamic> json) => Self(
        href: json["href"],
        methods: json["methods"] != null
            ? List<String>.from(json["methods"].map((x) => x))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "href": href,
        "methods":
            methods != null ? List<dynamic>.from(methods.map((x) => x)) : null,
      };

  fromJson(json) {
    return Self.fromJson(json);
  }
}
