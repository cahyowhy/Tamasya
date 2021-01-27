import 'package:tamasya/model/base_model.dart';
import 'package:tamasya/model/tour-activity.dart';

class CacheTour extends BaseModel {
  final double lat;
  final double lng;
  final double rad;
  final int lastTime;
  final List<TourActivity> lastToursActivities;

  CacheTour(
      {this.lastTime, this.lat, this.lng, this.rad, this.lastToursActivities});

  fromJson(json) {
    return CacheTour.fromJson(json);
  }

  factory CacheTour.fromJson(Map<String, dynamic> json) {
    return CacheTour(
      lastToursActivities: json['lastToursActivities'] != null
          ? List<TourActivity>.from(
              json["lastToursActivities"].map((x) => TourActivity.fromJson(x)))
          : null,
      lat: json['lat'] ?? null,
      lastTime: json['lastTime'] ?? null,
      lng: json['lng'] ?? null,
      rad: json['rad'] ?? null,
    );
  }

  Map<String, dynamic> toJson() => {
        "lat": lat ?? null,
        "lng": lng ?? null,
        "lastTime": lastTime ?? null,
        "rad": rad ?? null,
        "lastToursActivities": lastToursActivities == null
            ? null
            : List<dynamic>.from(lastToursActivities.map((x) => x.toJson()))
      };
}
