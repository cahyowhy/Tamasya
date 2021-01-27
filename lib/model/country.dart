import 'package:tamasya/util/underscore.dart';

class Country {
  final String country;
  final String iso2;
  final String callPreffix;
  final String iso3;
  final String ioc;
  final String currency;
  final String lang;
  final String cctld;
  final String status;

  Country(
      {this.country,
      this.iso2,
      this.callPreffix,
      this.iso3,
      this.ioc,
      this.currency,
      this.lang,
      this.cctld,
      this.status});

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    writeNotNull(val, "country", country);
    writeNotNull(val, "iso2", iso2);
    writeNotNull(val, "callPreffix", callPreffix);
    writeNotNull(val, "iso3", iso3);
    writeNotNull(val, "ioc", ioc);
    writeNotNull(val, "currency", currency);
    writeNotNull(val, "lang", lang);
    writeNotNull(val, "cctld", cctld);
    writeNotNull(val, "status", status);

    return val;
  }

  factory Country.fromLine(String line) {
    final components = line.split(",");
    if (components.length < 8) {
      return null;
    }

    String country = unescapeString(components[0]);
    String iso2 = unescapeString(components[1]);
    String callPreffix = unescapeString(components[2]);
    String iso3 = unescapeString(components[3]);
    String ioc = unescapeString(components[4]);
    String currency = unescapeString(components[5]);
    String lang = unescapeString(components[6]);
    String cctld = unescapeString(components[7]);
    String status = unescapeString(components[8]);

    return Country(
      country: country,
      iso2: iso2,
      callPreffix: callPreffix,
      iso3: iso3,
      ioc: ioc,
      currency: currency,
      lang: lang,
      cctld: cctld,
      status: status,
    );
  }

  // All fields are escaped with double quotes. This method deals with them
  static String unescapeString(dynamic value) {
    if (value is String) {
      return value.replaceAll('"', '');
    }
    return null;
  }
}
