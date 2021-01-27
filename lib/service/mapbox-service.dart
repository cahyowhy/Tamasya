import 'package:tamasya/config/env.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/model/mapbox-summary.dart';
import 'package:tamasya/service/http-service.dart';
import 'package:tamasya/service/response-service.dart';

class MapBoxService extends HttpBaseService {
  static MapBoxService _instance;

  static MapBoxService get instance {
    if (_instance == null) {
      _instance = MapBoxService();
    }

    return _instance;
  }

  Future<MapBoxSummary> findSugestion(String query,
      {bool allCountries = false}) async {
    String finalUrl =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json';
    Map<String, dynamic> queryFinal = {};

    queryFinal["access_token"] = env.mapBoxApiKey;
    queryFinal["autocomplete"] = "true";
    queryFinal["limit"] = "16";

    if (allCountries) {
      queryFinal["types"] = "place";
    } else {
      queryFinal["country"] =
          MainWidgetController?.instance?.country?.value?.iso2?.toLowerCase();
    }

    ResponseService responseService =
        await super.find(url: finalUrl, queryParams: queryFinal);
    var jsonResponse = responseService.jsonResponse;

    return MapBoxSummary.fromJson(jsonResponse);
  }

  Future<MapBoxSummary> findPlaceFromLatLng(double lat, double lng) async {
    String finalUrl =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$lng,$lat.json';

    Map<String, dynamic> queryFinal = {};
    queryFinal["access_token"] = env.mapBoxApiKey;
    queryFinal["autocomplete"] = "true";

    ResponseService responseService =
        await super.find(url: finalUrl, queryParams: queryFinal);

    var jsonResponse = responseService.jsonResponse;

    return MapBoxSummary.fromJson(jsonResponse);
  }
}
