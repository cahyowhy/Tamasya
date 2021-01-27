import 'package:geolocator/geolocator.dart';
import 'package:tamasya/model/mapbox-summary.dart';
import 'package:tamasya/util/underscore.dart';

class Location {
  Position position;

  /// _geolocator.placemarkFromCoordinates
  List<Placemark> placemarks;

  /// MapBoxService.findPlaceFromLatLng
  MapBoxSummary mapBoxReverseGeocoding;
  String mapBoxCountryName;
  String mapBoxRegionName;

  String detailLocationName;
  String previewLocation;

  Location(this.position, {this.placemarks});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
        json['position'] != null ? Position.fromMap(json['position']) : null,
        placemarks: json['placemarks'] != null
            ? List<Placemark>.from(
                json["placemarks"].map((x) => Placemark.fromMap(x)))
            : null)
      ..mapBoxReverseGeocoding = json['mapBoxReverseGeocoding'] != null
          ? MapBoxSummary.fromJson(json['mapBoxReverseGeocoding'])
          : null
      ..detailLocationName = json['detailLocationName']
      ..previewLocation = json['previewLocation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    writeNotNull(data, 'detailLocationName', this.detailLocationName);
    writeNotNull(data, 'previewLocation', this.previewLocation);
    writeNotNull(data, 'position', this.position?.toJson());
    writeNotNull(
        data, 'mapBoxReverseGeocoding', this.mapBoxReverseGeocoding?.toJson());
    writeNotNull(
        data,
        'placemarks',
        this.placemarks != null
            ? List<dynamic>.from(placemarks.map((x) => x.toJson()))
            : null);

    return data;
  }

  applyDetailLocationFromReverseGeocode() {
    if ((mapBoxReverseGeocoding?.features?.isNotEmpty) ?? false) {
      String previewLocation;
      String detailLocationName;

      mapBoxReverseGeocoding.features.forEach((element) {
        bool isAddress = element?.placeType?.first == "address";
        bool isPostcode = element.placeType?.first == "postcode";
        bool isRegion = element?.placeType?.first == "region";
        bool isCountry = element?.placeType?.first == "country";

        if (isCountry) mapBoxCountryName = element.text;
        if (isRegion) mapBoxRegionName = element.text;

        if (isRegion || (previewLocation == null && isCountry)) {
          previewLocation = element.placeName;
        } else if (isAddress || (detailLocationName == null && isPostcode)) {
          detailLocationName = element.placeName;
        }
      });

      if (previewLocation != null) this.previewLocation = previewLocation;
      if (detailLocationName != null)
        this.detailLocationName = detailLocationName;
    }
  }

  applyDetailLocationFromPlaceMarks() {
    if (placemarks?.elementAt(0) != null) {
      this.placemarks = placemarks;

      var placemark = placemarks.elementAt(0);

      List<String> places = [
        placemark.country,
        placemark.locality,
        placemark.subAdministrativeArea,
        placemark.administrativeArea,
        placemark.subLocality,
        placemark.name,
        placemark.postalCode,
      ];

      this.previewLocation = placemark.subAdministrativeArea ??
          placemark.locality ??
          placemark.country;

      int idx = 0;

      this.detailLocationName = places.fold("", (String accu, String element) {
        String formatedAccu = accu + element;

        if (idx < (places.length - 1)) {
          formatedAccu += ", ";
        }

        idx++;

        return formatedAccu;
      });
    }
  }
}
