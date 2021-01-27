import 'package:tamasya/config/constant.dart';
import 'package:tamasya/model/base_model.dart';
import 'package:tamasya/util/underscore.dart';

class FlightOffer extends BaseModel {
  FlightOffer({
    this.type,
    this.id,
    this.source,
    this.instantTicketingRequired,
    this.nonHomogeneous,
    this.oneWay,
    this.lastTicketingDate,
    this.numberOfBookableSeats,
    this.itineraries,
    this.price,
    this.pricingOptions,
    this.validatingAirlineCodes,
    this.travelerPricings,
  });

  String type;
  String id;
  String source;
  bool instantTicketingRequired;
  bool nonHomogeneous;
  bool oneWay;
  DateTime lastTicketingDate;
  int numberOfBookableSeats;
  List<Itinerary> itineraries;
  FlightOfferPrice price;
  PricingOptions pricingOptions;
  List<String> validatingAirlineCodes;
  List<TravelerPricing> travelerPricings;

  fromJson(json) {
    return FlightOffer.fromJson(json);
  }

  factory FlightOffer.fromJson(Map<String, dynamic> json) => FlightOffer(
        type: json["type"] == null ? null : json["type"],
        id: json["id"] == null ? null : json["id"],
        source: json["source"] == null ? null : json["source"],
        instantTicketingRequired: json["instantTicketingRequired"] == null
            ? null
            : json["instantTicketingRequired"],
        nonHomogeneous:
            json["nonHomogeneous"] == null ? null : json["nonHomogeneous"],
        oneWay: json["oneWay"] == null ? null : json["oneWay"],
        lastTicketingDate: json["lastTicketingDate"] == null
            ? null
            : DateTime.parse(json["lastTicketingDate"]),
        numberOfBookableSeats: json["numberOfBookableSeats"] == null
            ? null
            : json["numberOfBookableSeats"],
        itineraries: json["itineraries"] == null
            ? null
            : List<Itinerary>.from(
                json["itineraries"].map((x) => Itinerary.fromJson(x))),
        price: json["price"] == null
            ? null
            : FlightOfferPrice.fromJson(json["price"]),
        pricingOptions: json["pricingOptions"] == null
            ? null
            : PricingOptions.fromJson(json["pricingOptions"]),
        validatingAirlineCodes: json["validatingAirlineCodes"] == null
            ? null
            : List<String>.from(json["validatingAirlineCodes"].map((x) => x)),
        travelerPricings: json["travelerPricings"] == null
            ? null
            : List<TravelerPricing>.from(json["travelerPricings"]
                .map((x) => TravelerPricing.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "type": type == null ? null : type,
        "id": id == null ? null : id,
        "source": source == null ? null : source,
        "instantTicketingRequired":
            instantTicketingRequired == null ? null : instantTicketingRequired,
        "nonHomogeneous": nonHomogeneous == null ? null : nonHomogeneous,
        "oneWay": oneWay == null ? null : oneWay,
        "lastTicketingDate": lastTicketingDate == null
            ? null
            : "${lastTicketingDate.year.toString().padLeft(4, '0')}-${lastTicketingDate.month.toString().padLeft(2, '0')}-${lastTicketingDate.day.toString().padLeft(2, '0')}",
        "numberOfBookableSeats":
            numberOfBookableSeats == null ? null : numberOfBookableSeats,
        "itineraries": itineraries == null
            ? null
            : List<dynamic>.from(itineraries.map((x) => x.toJson())),
        "price": price == null ? null : price.toJson(),
        "pricingOptions":
            pricingOptions == null ? null : pricingOptions.toJson(),
        "validatingAirlineCodes": validatingAirlineCodes == null
            ? null
            : List<dynamic>.from(validatingAirlineCodes.map((x) => x)),
        "travelerPricings": travelerPricings == null
            ? null
            : List<dynamic>.from(travelerPricings.map((x) => x.toJson())),
      };
}

class Itinerary extends BaseModel {
  Itinerary({
    this.duration,
    this.segments,
  });

  String duration;
  List<Segment> segments;

  fromJson(json) {
    return Itinerary.fromJson(json);
  }

  String get durationFormated {
    return duration.replaceFirst('PT', '');
  }

  factory Itinerary.fromJson(Map<String, dynamic> json) => Itinerary(
        duration: json["duration"] == null ? null : json["duration"],
        segments: json["segments"] == null
            ? null
            : List<Segment>.from(
                json["segments"].map((x) => Segment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "duration": duration == null ? null : duration,
        "segments": segments == null
            ? null
            : List<dynamic>.from(segments.map((x) => x.toJson())),
      };
}

class Segment extends BaseModel {
  Segment({
    this.departure,
    this.arrival,
    this.carrierCode,
    this.carrierDetail,
    this.number,
    this.aircraft,
    this.operating,
    this.duration,
    this.id,
    this.numberOfStops,
    this.blacklistedInEu,
  });

  Arrival departure;
  Arrival arrival;
  String carrierCode;
  String carrierDetail;
  String number;
  Aircraft aircraft;
  Operating operating;
  String duration;
  String id;
  int numberOfStops;
  bool blacklistedInEu;

  String get durationFormated {
    return duration.replaceFirst('PT', '');
  }

  fromJson(json) {
    return Segment.fromJson(json);
  }

  factory Segment.fromJson(Map<String, dynamic> json) => Segment(
        departure: json["departure"] == null
            ? null
            : Arrival.fromJson(json["departure"]),
        arrival:
            json["arrival"] == null ? null : Arrival.fromJson(json["arrival"]),
        carrierCode: json["carrierCode"] == null ? null : json["carrierCode"],
        carrierDetail:
            json["carrierDetail"] == null ? null : json["carrierDetail"],
        number: json["number"] == null ? null : json["number"],
        aircraft: json["aircraft"] == null
            ? null
            : Aircraft.fromJson(json["aircraft"]),
        operating: json["operating"] == null
            ? null
            : Operating.fromJson(json["operating"]),
        duration: json["duration"] == null ? null : json["duration"],
        id: json["id"] == null ? null : json["id"],
        numberOfStops:
            json["numberOfStops"] == null ? null : json["numberOfStops"],
        blacklistedInEu:
            json["blacklistedInEU"] == null ? null : json["blacklistedInEU"],
      );

  Map<String, dynamic> toJson() => {
        "departure": departure == null ? null : departure.toJson(),
        "arrival": arrival == null ? null : arrival.toJson(),
        "carrierCode": carrierCode == null ? null : carrierCode,
        "carrierDetail": carrierDetail == null ? null : carrierDetail,
        "number": number == null ? null : number,
        "aircraft": aircraft == null ? null : aircraft.toJson(),
        "operating": operating == null ? null : operating.toJson(),
        "duration": duration == null ? null : duration,
        "id": id == null ? null : id,
        "numberOfStops": numberOfStops == null ? null : numberOfStops,
        "blacklistedInEU": blacklistedInEu == null ? null : blacklistedInEu,
      };
}

class Aircraft extends BaseModel {
  Aircraft({
    this.code,
    this.codeDetail,
  });

  String code;
  String codeDetail;

  fromJson(json) {
    return Aircraft.fromJson(json);
  }

  factory Aircraft.fromJson(Map<String, dynamic> json) => Aircraft(
        code: json["code"] == null ? null : json["code"],
        codeDetail: json["codeDetail"] == null ? null : json["codeDetail"],
      );

  Map<String, dynamic> toJson() => {
        "code": code == null ? null : code,
        "codeDetail": codeDetail == null ? null : codeDetail,
      };
}

class Arrival extends BaseModel {
  Arrival({
    this.iataCode,
    this.terminal,
    this.at,
  });

  String iataCode;
  String terminal;
  DateTime at;

  String get formatDateAt {
    if (at != null) {
      return formatDate(date: at);
    }

    return "-";
  }

  String get formatHourAt {
    if (at != null) {
      return formatDate(date: at, format: Constant.HOUR_FORMATED);
    }

    return "-";
  }

  fromJson(json) {
    return Arrival.fromJson(json);
  }

  factory Arrival.fromJson(Map<String, dynamic> json) => Arrival(
        iataCode: json["iataCode"] == null ? null : json["iataCode"],
        terminal: json["terminal"] == null ? null : json["terminal"],
        at: json["at"] == null ? null : DateTime.parse(json["at"]),
      );

  Map<String, dynamic> toJson() => {
        "iataCode": iataCode == null ? null : iataCode,
        "terminal": terminal == null ? null : terminal,
        "at": at == null ? null : at.toIso8601String(),
      };
}

class Operating extends BaseModel {
  Operating({
    this.carrierCode,
    this.carrierDetail,
  });

  String carrierCode;
  String carrierDetail;

  fromJson(json) {
    return Operating.fromJson(json);
  }

  factory Operating.fromJson(Map<String, dynamic> json) => Operating(
      carrierCode: json["carrierCode"] == null ? null : json["carrierCode"],
      carrierDetail:
          json["carrierDetail"] == null ? null : json["carrierDetail"]);

  Map<String, dynamic> toJson() => {
        "carrierCode": carrierCode == null ? null : carrierCode,
        "carrierDetail": carrierDetail == null ? null : carrierDetail,
      };
}

class FlightOfferPrice extends BaseModel {
  FlightOfferPrice({
    this.currency,
    this.total,
    this.base,
    this.fees,
    this.grandTotal,
  });

  String currency;
  String total;
  String base;
  List<Fee> fees;
  String grandTotal;

  fromJson(json) {
    return FlightOfferPrice.fromJson(json);
  }

  factory FlightOfferPrice.fromJson(Map<String, dynamic> json) =>
      FlightOfferPrice(
        currency: json["currency"] == null ? null : json["currency"],
        total: json["total"] == null ? null : json["total"],
        base: json["base"] == null ? null : json["base"],
        fees: json["fees"] == null
            ? null
            : List<Fee>.from(json["fees"].map((x) => Fee.fromJson(x))),
        grandTotal: json["grandTotal"] == null ? null : json["grandTotal"],
      );

  Map<String, dynamic> toJson() => {
        "currency": currency == null ? null : currency,
        "total": total == null ? null : total,
        "base": base == null ? null : base,
        "fees": fees == null
            ? null
            : List<dynamic>.from(fees.map((x) => x.toJson())),
        "grandTotal": grandTotal == null ? null : grandTotal,
      };
}

class Fee extends BaseModel {
  Fee({
    this.amount,
    this.type,
  });

  String amount;
  String type;

  fromJson(json) {
    return Fee.fromJson(json);
  }

  factory Fee.fromJson(Map<String, dynamic> json) => Fee(
        amount: json["amount"] == null ? null : json["amount"],
        type: json["type"] == null ? null : json["type"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount == null ? null : amount,
        "type": type == null ? null : type,
      };
}

class PricingOptions extends BaseModel {
  PricingOptions({
    this.fareType,
    this.includedCheckedBagsOnly,
  });

  List<String> fareType;
  bool includedCheckedBagsOnly;

  fromJson(json) {
    return PricingOptions.fromJson(json);
  }

  factory PricingOptions.fromJson(Map<String, dynamic> json) => PricingOptions(
        fareType: json["fareType"] == null
            ? null
            : List<String>.from(json["fareType"].map((x) => x)),
        includedCheckedBagsOnly: json["includedCheckedBagsOnly"] == null
            ? null
            : json["includedCheckedBagsOnly"],
      );

  Map<String, dynamic> toJson() => {
        "fareType": fareType == null
            ? null
            : List<dynamic>.from(fareType.map((x) => x)),
        "includedCheckedBagsOnly":
            includedCheckedBagsOnly == null ? null : includedCheckedBagsOnly,
      };
}

class TravelerPricing extends BaseModel {
  TravelerPricing({
    this.travelerId,
    this.fareOption,
    this.travelerType,
    this.price,
    this.fareDetailsBySegment,
  });

  String travelerId;
  String fareOption;
  String travelerType;
  TravelerPricingPrice price;
  List<FareDetailsBySegment> fareDetailsBySegment;

  fromJson(json) {
    return TravelerPricing.fromJson(json);
  }

  factory TravelerPricing.fromJson(Map<String, dynamic> json) =>
      TravelerPricing(
        travelerId: json["travelerId"] == null ? null : json["travelerId"],
        fareOption: json["fareOption"] == null ? null : json["fareOption"],
        travelerType:
            json["travelerType"] == null ? null : json["travelerType"],
        price: json["price"] == null
            ? null
            : TravelerPricingPrice.fromJson(json["price"]),
        fareDetailsBySegment: json["fareDetailsBySegment"] == null
            ? null
            : List<FareDetailsBySegment>.from(json["fareDetailsBySegment"]
                .map((x) => FareDetailsBySegment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "travelerId": travelerId == null ? null : travelerId,
        "fareOption": fareOption == null ? null : fareOption,
        "travelerType": travelerType == null ? null : travelerType,
        "price": price == null ? null : price.toJson(),
        "fareDetailsBySegment": fareDetailsBySegment == null
            ? null
            : List<dynamic>.from(fareDetailsBySegment.map((x) => x.toJson())),
      };
}

class FareDetailsBySegment extends BaseModel {
  FareDetailsBySegment({
    this.segmentId,
    this.cabin,
    this.fareBasis,
    this.fareDetailsBySegmentClass,
    this.includedCheckedBags,
  });

  String segmentId;
  String cabin;
  String fareBasis;
  String fareDetailsBySegmentClass;
  IncludedCheckedBags includedCheckedBags;

  fromJson(json) {
    return FareDetailsBySegment.fromJson(json);
  }

  factory FareDetailsBySegment.fromJson(Map<String, dynamic> json) =>
      FareDetailsBySegment(
        segmentId: json["segmentId"] == null ? null : json["segmentId"],
        cabin: json["cabin"] == null ? null : json["cabin"],
        fareBasis: json["fareBasis"] == null ? null : json["fareBasis"],
        fareDetailsBySegmentClass: json["class"] == null ? null : json["class"],
        includedCheckedBags: json["includedCheckedBags"] == null
            ? null
            : IncludedCheckedBags.fromJson(json["includedCheckedBags"]),
      );

  Map<String, dynamic> toJson() => {
        "segmentId": segmentId == null ? null : segmentId,
        "cabin": cabin == null ? null : cabin,
        "fareBasis": fareBasis == null ? null : fareBasis,
        "class": fareDetailsBySegmentClass == null
            ? null
            : fareDetailsBySegmentClass,
        "includedCheckedBags":
            includedCheckedBags == null ? null : includedCheckedBags.toJson(),
      };
}

class IncludedCheckedBags extends BaseModel {
  IncludedCheckedBags({
    this.weight,
    this.weightUnit,
  });

  int weight;
  String weightUnit;

  fromJson(json) {
    return IncludedCheckedBags.fromJson(json);
  }

  factory IncludedCheckedBags.fromJson(Map<String, dynamic> json) =>
      IncludedCheckedBags(
        weight: json["weight"] == null ? null : json["weight"],
        weightUnit: json["weightUnit"] == null ? null : json["weightUnit"],
      );

  Map<String, dynamic> toJson() => {
        "weight": weight == null ? null : weight,
        "weightUnit": weightUnit == null ? null : weightUnit,
      };
}

class TravelerPricingPrice extends BaseModel {
  TravelerPricingPrice({
    this.currency,
    this.total,
    this.base,
  });

  String currency;
  String total;
  String base;

  fromJson(json) {
    return TravelerPricingPrice.fromJson(json);
  }

  factory TravelerPricingPrice.fromJson(Map<String, dynamic> json) =>
      TravelerPricingPrice(
        currency: json["currency"] == null ? null : json["currency"],
        total: json["total"] == null ? null : json["total"],
        base: json["base"] == null ? null : json["base"],
      );

  Map<String, dynamic> toJson() => {
        "currency": currency == null ? null : currency,
        "total": total == null ? null : total,
        "base": base == null ? null : base,
      };
}
