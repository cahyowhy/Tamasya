import 'package:tamasya/model/airport.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:string_similarity/string_similarity.dart';

class AirportDataReader {
  static List<Airport> airportsData = [];

  static Future<List<Airport>> load(String path) async {
    if (airportsData.isEmpty) {
      final data = await rootBundle.loadString(path);

      airportsData = data
          .split('\n')
          .map((line) => Airport.fromLine(line))
          .where((airport) => airport?.iata != null)
          .toList();
    }

    return airportsData;
  }

  static Airport searchIata(String iata) {
    return airportsData.firstWhere((element) {
      return element?.iata?.toLowerCase() == iata.toLowerCase();
    }, orElse: () => null);
  }

  static List<Airport> searchString(String string, {bool reverse = false}) {
    string = string.toLowerCase();
    final matching = airportsData.where((airport) {
      final iata = airport.iata ?? '';
      return iata.toLowerCase() == string ||
          airport.name.toLowerCase() == string ||
          airport.city.toLowerCase() == string ||
          airport.country.toLowerCase() == string;
    }).toList();

    // found exact matches
    if (matching.length > 0) {
      return matching;
    }

    // search again with less strict criteria
    final matching2 = airportsData.where((airport) {
      final iata = airport.iata ?? '';

      String iataFmt = iata.toLowerCase();
      String nameFmt = airport.name.toLowerCase();
      String cityFmt = airport.city.toLowerCase();
      String countryFmt = airport.country.toLowerCase();

      if (reverse) {
        return string.contains(nameFmt) ||
            string.contains(cityFmt) ||
            string.contains(countryFmt);
      }

      return iataFmt.contains(string) ||
          nameFmt.contains(string) ||
          cityFmt.contains(string) ||
          countryFmt.contains(string);
    }).toList();

    if (matching2.length > 0) {
      return matching2;
    }

    return airportsData.where((airport) {
      if (reverse) {
        return string.similarityTo(airport.name) >= 0.6 ||
            string.similarityTo(airport.city) >= 0.6 ||
            string.similarityTo(airport.country) >= 0.6;
      }

      return airport.name.toLowerCase().similarityTo(string) >= 0.6 ||
          airport.city.toLowerCase().similarityTo(string) >= 0.6 ||
          airport.country.toLowerCase().similarityTo(string) >= 0.6;
    })?.toList();
  }
}
