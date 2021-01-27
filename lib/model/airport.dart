import 'package:meta/meta.dart';
import 'package:tamasya/util/underscore.dart';

class LocationCoordinate2D {
  LocationCoordinate2D({this.latitude, this.longitude});
  final double latitude;
  final double longitude;

  @override
  String toString() {
    return "($latitude, $longitude)";
  }

  factory LocationCoordinate2D.fromJson(Map<String, dynamic> json) {
    return LocationCoordinate2D(
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    writeNotNull(val, "latitude", latitude);
    writeNotNull(val, "longitude", longitude);

    return val;
  }
}

class Airport {
  Airport(
      {@required this.name,
      @required this.city,
      @required this.country,
      @required this.location,
      this.iata,
      this.icao,
      this.activeMark = false});
  final String name;
  final String city;
  final String country;
  final String iata;
  final String icao;
  final bool activeMark;
  final LocationCoordinate2D location;

  Airport copyWith({
    String name,
    String city,
    String country,
    String iata,
    String icao,
    bool active,
    LocationCoordinate2D location,
  }) {
    return Airport(
      name: name ?? this.name,
      city: city ?? this.city,
      country: country ?? this.country,
      iata: iata ?? this.iata,
      icao: icao ?? this.icao,
      activeMark: active ?? this.activeMark ?? false,
      location: location ?? this.location,
    );
  }

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
        name: json['name'],
        city: json['city'],
        country: json['country'],
        iata: json['iata'],
        icao: json['icao'],
        activeMark: json['active'],
        location: json['location'] != null
            ? LocationCoordinate2D.fromJson(json['location'])
            : null);
  }

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    writeNotNull(val, "name", name);
    writeNotNull(val, "city", city);
    writeNotNull(val, "country", country);
    writeNotNull(val, "iata", iata);
    writeNotNull(val, "icao", icao);
    writeNotNull(val, "active", activeMark);
    writeNotNull(val, "location", location?.toJson());

    return val;
  }

  factory Airport.fromLine(String line) {
    final components = line.split(",");
    if (components.length < 8) {
      return null;
    }
    String name = unescapeString(components[1]);
    String city = unescapeString(components[2]);
    String country = unescapeString(components[3]);
    String iata = unescapeString(components[4]);
    if (iata == '\\N') {
      // placeholder for missing iata code
      iata = null;
    }
    String icao = unescapeString(components[5]);
    try {
      double latitude = double.parse(unescapeString(components[6]));
      double longitude = double.parse(unescapeString(components[7]));
      final location =
          LocationCoordinate2D(latitude: latitude, longitude: longitude);

      return Airport(
          name: name,
          city: city,
          country: country,
          iata: iata,
          icao: icao,
          location: location,
          activeMark: false);
    } catch (e) {
      try {
        // sometimes, components[6] is a String and the lat-long are stored
        // at index 7 and 8
        double latitude = double.parse(unescapeString(components[7]));
        double longitude = double.parse(unescapeString(components[8]));
        final location =
            LocationCoordinate2D(latitude: latitude, longitude: longitude);

        return Airport(
            name: name,
            city: city,
            country: country,
            iata: iata,
            location: location,
            activeMark: false);
      } catch (e) {
        print(e);
        return null;
      }
    }
  }

  // All fields are escaped with double quotes. This method deals with them
  static String unescapeString(dynamic value) {
    if (value is String) {
      return value.replaceAll('"', '');
    }
    return null;
  }

  @override
  String toString() {
    return "($iata, $icao) -> $name, $city, $country, ${location.toString()}";
  }
}
