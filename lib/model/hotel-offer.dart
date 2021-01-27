import 'package:tamasya/config/constant.dart';
import 'package:tamasya/model/base_model.dart';
import 'package:tamasya/style/string-util.dart';
import 'package:latlong/latlong.dart';

class HotelOffer extends BaseModel {
  HotelOffer({
    this.type,
    this.hotel,
    this.available,
    this.offers,
    this.self,
  });

  String type;
  Hotel hotel;
  bool available;
  List<Offer> offers;
  String self;

  String get addresFmt {
    if (hotel?.address != null) {
      String fmt = "";
      if (hotel.address.lines?.isNotEmpty ?? false) {
        fmt = hotel.address.lines.join(", ");
      }

      if (hotel.address?.cityName?.isNotEmpty ?? false) {
        if (fmt.isNotEmpty) fmt += ", ";
        fmt += "${hotel.address.cityName}.";

        if (hotel.address?.postalCode?.isNotEmpty ?? false) {
          fmt += " Postal code ${hotel.address.postalCode}";
        }
      }

      return fmt;
    }

    return "";
  }

  bool sameLatLng(LatLng latlng) {
    if (latlng != null && hotel?.latitude != null && hotel.longitude != null) {
      return hotel.latitude == latlng.latitude &&
          hotel.longitude == latlng.longitude;
    }

    return false;
  }

  bool get hasBath {
    if (hotel?.amenities?.isNotEmpty ?? false) {
      return hotel.amenities
              .where((element) => element.toLowerCase().contains('bath'))
              .length >
          0;
    }

    return true;
  }

  bool get hasWifi {
    if (hotel?.amenities?.isNotEmpty ?? false) {
      return hotel.amenities
              .where((element) =>
                  element.toLowerCase().contains('wifi') ||
                  element.toLowerCase().contains('wi-fi') ||
                  element.toLowerCase().contains('wireless_connectivity'))
              .length >
          0;
    }

    return true;
  }

  String get urlMedia {
    if (hotel?.media?.isNotEmpty ?? false) {
      return hotel?.media?.first?.uri ?? "";
    }

    return "";
  }

  Map<String, int> get cheapestInfo {
    if (offers?.isNotEmpty ?? false) {
      int parseIt(String val) {
        var param = double.tryParse(val ?? '0');

        return param?.round() ?? 0;
      }

      int idx = -1;
      int cheapestIdx = -1;
      int cheapest = offers.fold(0, (previousValue, element) {
        idx += 1;

        if (previousValue == 0 ||
            (parseIt(element?.price?.total) < previousValue)) {
          cheapestIdx = idx;
          return parseIt(element?.price?.total);
        }

        return 0;
      });

      return {"price": cheapest, "cheapestIdx": cheapestIdx};
    }

    return null;
  }

  String get cheapestPriceFmt {
    if (cheapestInfo != null) {
      int cheapest = cheapestInfo["price"];

      try {
        String symbol = Constant.CURRENCY_SYMBOL[
            offers.elementAt(cheapestInfo["cheapestIdx"])?.price?.currency];

        return formatCurrency(cheapest, symbol: symbol);
      } catch (e) {
        print(e);
      }

      return formatCurrency(cheapest);
    }

    return "";
  }

  int get totalBedCheapestOffer {
    if (cheapestInfo != null) {
      return offers[cheapestInfo["cheapestIdx"]]?.room?.typeEstimated?.beds ??
          0;
    }

    return 0;
  }

  factory HotelOffer.fromJson(Map<String, dynamic> json) => HotelOffer(
        type: json["type"] == null ? null : json["type"],
        hotel: json["hotel"] == null ? null : Hotel.fromJson(json["hotel"]),
        available: json["available"] == null ? null : json["available"],
        offers: json["offers"] == null
            ? null
            : List<Offer>.from(json["offers"].map((x) => Offer.fromJson(x))),
        self: json["self"] == null ? null : json["self"],
      );

  Map<String, dynamic> toJson() => {
        "type": type == null ? null : type,
        "hotel": hotel == null ? null : hotel.toJson(),
        "available": available == null ? null : available,
        "offers": offers == null
            ? null
            : List<dynamic>.from(offers.map((x) => x.toJson())),
        "self": self == null ? null : self,
      };

  fromJson(json) {
    return HotelOffer.fromJson(json);
  }
}

class Hotel extends BaseModel {
  Hotel({
    this.type,
    this.hotelId,
    this.chainCode,
    this.dupeId,
    this.name,
    this.rating,
    this.cityCode,
    this.latitude,
    this.longitude,
    this.hotelDistance,
    this.address,
    this.contact,
    this.amenities,
    this.media,
  });

  String type;
  String hotelId;
  String chainCode;
  String dupeId;
  String name;
  String rating;
  String cityCode;
  double latitude;
  double longitude;
  HotelDistance hotelDistance;
  Address address;
  Contact contact;
  List<String> amenities;
  List<Media> media;

  factory Hotel.fromJson(Map<String, dynamic> json) => Hotel(
        type: json["type"] == null ? null : json["type"],
        hotelId: json["hotelId"] == null ? null : json["hotelId"],
        chainCode: json["chainCode"] == null ? null : json["chainCode"],
        dupeId: json["dupeId"] == null ? null : json["dupeId"],
        name: json["name"] == null ? null : json["name"],
        rating: json["rating"] == null ? null : json["rating"],
        cityCode: json["cityCode"] == null ? null : json["cityCode"],
        latitude: json["latitude"] == null ? null : json["latitude"].toDouble(),
        longitude:
            json["longitude"] == null ? null : json["longitude"].toDouble(),
        hotelDistance: json["hotelDistance"] == null
            ? null
            : HotelDistance.fromJson(json["hotelDistance"]),
        address:
            json["address"] == null ? null : Address.fromJson(json["address"]),
        contact:
            json["contact"] == null ? null : Contact.fromJson(json["contact"]),
        amenities: json["amenities"] == null
            ? null
            : List<String>.from(json["amenities"].map((x) => x)),
        media: json["media"] == null
            ? null
            : List<Media>.from(json["media"].map((x) => Media.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "type": type == null ? null : type,
        "hotelId": hotelId == null ? null : hotelId,
        "chainCode": chainCode == null ? null : chainCode,
        "dupeId": dupeId == null ? null : dupeId,
        "name": name == null ? null : name,
        "rating": rating == null ? null : rating,
        "cityCode": cityCode == null ? null : cityCode,
        "latitude": latitude == null ? null : latitude,
        "longitude": longitude == null ? null : longitude,
        "hotelDistance": hotelDistance == null ? null : hotelDistance.toJson(),
        "address": address == null ? null : address.toJson(),
        "contact": contact == null ? null : contact.toJson(),
        "amenities": amenities == null
            ? null
            : List<dynamic>.from(amenities.map((x) => x)),
        "media": media == null
            ? null
            : List<dynamic>.from(media.map((x) => x.toJson())),
      };

  fromJson(json) {
    return Hotel.fromJson(json);
  }
}

class Address extends BaseModel {
  Address({
    this.lines,
    this.cityName,
    this.postalCode,
    this.countryCode,
  });

  List<String> lines;
  String cityName;
  String countryCode;
  String postalCode;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        lines: json["lines"] == null
            ? null
            : List<String>.from(json["lines"].map((x) => x)),
        cityName: json["cityName"] == null ? null : json["cityName"],
        postalCode: json["postalCode"] == null ? null : json["postalCode"],
        countryCode: json["countryCode"] == null ? null : json["countryCode"],
      );

  Map<String, dynamic> toJson() => {
        "lines": lines == null ? null : List<dynamic>.from(lines.map((x) => x)),
        "cityName": cityName == null ? null : cityName,
        "postalCode": postalCode == null ? null : postalCode,
        "countryCode": countryCode == null ? null : countryCode,
      };

  fromJson(json) {
    return Address.fromJson(json);
  }
}

class Contact extends BaseModel {
  Contact({
    this.phone,
    this.fax,
  });

  String phone;
  String fax;

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
        phone: json["phone"] == null ? null : json["phone"],
        fax: json["fax"] == null ? null : json["fax"],
      );

  Map<String, dynamic> toJson() => {
        "phone": phone == null ? null : phone,
        "fax": fax == null ? null : fax,
      };

  fromJson(json) {
    return Contact.fromJson(json);
  }
}

class HotelDistance extends BaseModel {
  HotelDistance({
    this.distance,
    this.distanceUnit,
  });

  double distance;
  String distanceUnit;

  factory HotelDistance.fromJson(Map<String, dynamic> json) => HotelDistance(
        distance: json["distance"] == null ? null : json["distance"].toDouble(),
        distanceUnit:
            json["distanceUnit"] == null ? null : json["distanceUnit"],
      );

  Map<String, dynamic> toJson() => {
        "distance": distance == null ? null : distance,
        "distanceUnit": distanceUnit == null ? null : distanceUnit,
      };

  fromJson(json) {
    return HotelDistance.fromJson(json);
  }
}

class Media extends BaseModel {
  Media({
    this.uri,
    this.category,
  });

  String uri;
  String category;

  factory Media.fromJson(Map<String, dynamic> json) => Media(
        uri: json["uri"] == null ? null : json["uri"],
        category: json["category"] == null ? null : json["category"],
      );

  Map<String, dynamic> toJson() => {
        "uri": uri == null ? null : uri,
        "category": category == null ? null : category,
      };

  fromJson(json) {
    return Media.fromJson(json);
  }
}

class Offer extends BaseModel {
  Offer({
    this.id,
    this.rateCode,
    this.room,
    this.guests,
    this.price,
  });

  String id;
  String rateCode;
  Room room;
  Guests guests;
  Price price;

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
        id: json["id"] == null ? null : json["id"],
        rateCode: json["rateCode"] == null ? null : json["rateCode"],
        room: json["room"] == null ? null : Room.fromJson(json["room"]),
        guests: json["guests"] == null ? null : Guests.fromJson(json["guests"]),
        price: json["price"] == null ? null : Price.fromJson(json["price"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "rateCode": rateCode == null ? null : rateCode,
        "room": room == null ? null : room.toJson(),
        "guests": guests == null ? null : guests.toJson(),
        "price": price == null ? null : price.toJson(),
      };

  fromJson(json) {
    return Offer.fromJson(json);
  }
}

class Guests extends BaseModel {
  Guests({
    this.adults,
  });

  int adults;

  factory Guests.fromJson(Map<String, dynamic> json) => Guests(
        adults: json["adults"] == null ? null : json["adults"],
      );

  Map<String, dynamic> toJson() => {
        "adults": adults == null ? null : adults,
      };

  fromJson(json) {
    return Guests.fromJson(json);
  }
}

class Price extends BaseModel {
  Price({
    this.currency,
    this.base,
    this.total,
    this.variations,
  });

  String currency;
  String base;
  String total;
  Variations variations;

  factory Price.fromJson(Map<String, dynamic> json) => Price(
        currency: json["currency"] == null ? null : json["currency"],
        base: json["base"] == null ? null : json["base"],
        total: json["total"] == null ? null : json["total"],
        variations: json["variations"] == null
            ? null
            : Variations.fromJson(json["variations"]),
      );

  Map<String, dynamic> toJson() => {
        "currency": currency == null ? null : currency,
        "base": base == null ? null : base,
        "total": total == null ? null : total,
        "variations": variations == null ? null : variations.toJson(),
      };

  fromJson(json) {
    return Price.fromJson(json);
  }
}

class Variations extends BaseModel {
  Variations({
    this.average,
    this.changes,
  });

  Average average;
  List<Change> changes;

  factory Variations.fromJson(Map<String, dynamic> json) => Variations(
        average:
            json["average"] == null ? null : Average.fromJson(json["average"]),
        changes: json["changes"] == null
            ? null
            : List<Change>.from(json["changes"].map((x) => Change.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "average": average == null ? null : average.toJson(),
        "changes": changes == null
            ? null
            : List<dynamic>.from(changes.map((x) => x.toJson())),
      };

  fromJson(json) {
    return Variations.fromJson(json);
  }
}

class Average extends BaseModel {
  Average({
    this.base,
  });

  String base;

  factory Average.fromJson(Map<String, dynamic> json) => Average(
        base: json["base"] == null ? null : json["base"],
      );

  Map<String, dynamic> toJson() => {
        "base": base == null ? null : base,
      };

  fromJson(json) {
    return Average.fromJson(json);
  }
}

class Change extends BaseModel {
  Change({
    this.startDate,
    this.endDate,
    this.base,
  });

  DateTime startDate;
  DateTime endDate;
  String base;

  factory Change.fromJson(Map<String, dynamic> json) => Change(
        startDate: json["startDate"] == null
            ? null
            : DateTime.parse(json["startDate"]),
        endDate:
            json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        base: json["base"] == null ? null : json["base"],
      );

  Map<String, dynamic> toJson() => {
        "startDate": startDate == null
            ? null
            : "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "endDate": endDate == null
            ? null
            : "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
        "base": base == null ? null : base,
      };

  fromJson(json) {
    return Change.fromJson(json);
  }
}

class Room extends BaseModel {
  Room({
    this.type,
    this.typeEstimated,
    this.description,
  });

  String type;
  TypeEstimated typeEstimated;
  Description description;

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        type: json["type"] == null ? null : json["type"],
        typeEstimated: json["typeEstimated"] == null
            ? null
            : TypeEstimated.fromJson(json["typeEstimated"]),
        description: json["description"] == null
            ? null
            : Description.fromJson(json["description"]),
      );

  Map<String, dynamic> toJson() => {
        "type": type == null ? null : type,
        "typeEstimated": typeEstimated == null ? null : typeEstimated.toJson(),
        "description": description == null ? null : description.toJson(),
      };

  fromJson(json) {
    return Room.fromJson(json);
  }
}

class Description extends BaseModel {
  Description({
    this.lang,
    this.text,
  });

  String lang;
  String text;

  factory Description.fromJson(Map<String, dynamic> json) => Description(
        lang: json["lang"] == null ? null : json["lang"],
        text: json["text"] == null ? null : json["text"],
      );

  Map<String, dynamic> toJson() => {
        "lang": lang == null ? null : lang,
        "text": text == null ? null : text,
      };

  fromJson(json) {
    return Description.fromJson(json);
  }
}

class TypeEstimated extends BaseModel {
  TypeEstimated({
    this.category,
    this.beds,
    this.bedType,
  });

  String category;
  int beds;
  String bedType;

  factory TypeEstimated.fromJson(Map<String, dynamic> json) => TypeEstimated(
        category: json["category"] == null ? null : json["category"],
        beds: json["beds"] == null ? null : json["beds"],
        bedType: json["bedType"] == null ? null : json["bedType"],
      );

  Map<String, dynamic> toJson() => {
        "category": category == null ? null : category,
        "beds": beds == null ? null : beds,
        "bedType": bedType == null ? null : bedType,
      };

  fromJson(json) {
    return TypeEstimated.fromJson(json);
  }
}
