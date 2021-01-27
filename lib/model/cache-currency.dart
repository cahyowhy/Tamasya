import 'dart:collection';

import 'package:tamasya/model/base_model.dart';
import 'package:tamasya/util/underscore.dart';

class CacheCurrency extends BaseModel {
  final Map<String, dynamic> currencies;

  final int lastTime;

  CacheCurrency({this.currencies, this.lastTime});

  fromJson(json) {
    return CacheCurrency.fromJson(json);
  }

  factory CacheCurrency.fromJson(Map<String, dynamic> json) {
    var currenciesJson = json['currencies'];

    if (currenciesJson is String) {
      currenciesJson = stringToJsonMap(currenciesJson);
    } else if (currenciesJson is LinkedHashMap) {
      currenciesJson = Map<String, dynamic>.from(currenciesJson);
    }

    return CacheCurrency(
      lastTime: json['lastTime'] ?? null,
      currencies: currenciesJson ?? null,
    );
  }

  Map<String, dynamic> toJson() => {
        "lastTime": lastTime ?? null,
        "currencies": currencies ?? null,
      };
}
