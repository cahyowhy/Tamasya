class BaseModel {
  fromJson(Map<String, dynamic> json) {
    return null;
  }

  Map<String, dynamic> toJson() {
    return null;
  }

  static deleteEmptyVal(Map<String, dynamic> json,
      {List<String> keys, bool deleteFalseValue = false}) {
    json.keys
        .where(
            (String k) => (keys?.isNotEmpty ?? false) ? keys.contains(k) : true)
        .toList()
        .forEach((i) {
      if (json[i] != null) {
        if (json[i] is String && json[i].isEmpty) {
          json.remove(i);
        } else if ((json[i] is int || json[i] is double) && json[i] == 0) {
          json.remove(i);
        } else if (json[i] is Map && json[i].isEmpty) {
          json.remove(i);
        } else if (json[i] is List && json[i].isEmpty) {
          json.remove(i);
        } else if (deleteFalseValue &&
            json[i] is bool &&
            json[i] != null &&
            !json[i]) {
          json.remove(i);
        }
      } else {
        json.remove(i);
      }
    });
  }
}
