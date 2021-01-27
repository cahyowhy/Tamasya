import 'package:flutter/services.dart';
import 'package:tamasya/model/country.dart';

class CountryReader {
  static List<Country> countries = [];

  static Future<List<Country>> load(String path) async {
    if (countries.isEmpty) {
      final data = await rootBundle.loadString(path);

      countries =
          data.split('\n').map((line) => Country.fromLine(line)).toList();
    }

    return countries;
  }

  static List<Country> searchString(String string,
      {bool byCountry = true, bool byIso3 = false}) {
    string = string.toLowerCase();
    return countries.where((item) {
      if (byIso3) {
        final iso3 = item.iso3 ?? '';
        final iso2 = item.iso2 ?? '';

        return (iso3.isNotEmpty || iso2.isNotEmpty) &&
            (iso3.toLowerCase().trim() == string ||
                iso2.toLowerCase().trim() == string);
      }

      final country = item.country ?? '';

      return country.toLowerCase().contains(string);
    }).toList();
  }
}
