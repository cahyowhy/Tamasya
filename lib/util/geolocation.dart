import 'package:geolocator/geolocator.dart';
import 'package:tamasya/model/location.dart';
import 'package:tamasya/service/mapbox-service.dart';

class Geolocation {
  static Geolocator _geolocator = Geolocator();

  static MapBoxService mapBoxService = MapBoxService.instance;

  static Future<Location> getLocation() async {
    Location location;

    try {
      Position position = await _geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      location = Location(position);

      if (position != null) {
        location.placemarks = await _geolocator.placemarkFromCoordinates(
            position.latitude, position.longitude);
        location.applyDetailLocationFromPlaceMarks();

        return location;
      }
    } catch (e) {
      print(e);

      if (location != null) {
        try {
          location.mapBoxReverseGeocoding =
              await mapBoxService.findPlaceFromLatLng(
                  location.position.latitude, location.position.longitude);

                  location.applyDetailLocationFromReverseGeocode();
        } catch (e) {
          print(e);
        }
      }
    }

    return location;
  }
}
