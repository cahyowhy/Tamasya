import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/config/env.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/service/response-service.dart';
import 'package:tamasya/style/string-util.dart';

String formatDate({DateTime date, String format}) {
  return DateFormat(format ?? Constant.SIMPLE_DATE_FORMATED)
      .format(date ?? DateTime.now());
}

String getMapBoxRasterMap(double lat, double lng,
    {int zoom = Constant.DEFAULT_MAP_ZOOM, double width, double height}) {
  int finalWidth = (width ?? Get.width).floor();
  int finalHeight = (height ?? 300).floor();

  return "https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/$lng,$lat,$zoom/${finalWidth}x$finalHeight?access_token=${env.mapBoxApiKey}";
}

/// USD was default base curr from currency freak API
/// Target was current country currency
Map<String, dynamic> convertCurrency(var value, String paramCurrency) {
  double valueFinal;

  if (value != null) {
    if (value is String) {
      valueFinal = double.tryParse(value);
    } else if (value is int) {
      valueFinal = value.toDouble();
    } else if (value is double) {
      valueFinal = value;
    }
  }

  if (valueFinal == null) {
    return {"value": null, "success": false};
  }

  bool hasCachedCurrency = ((MainWidgetController
              .instance.cacheCurrency?.currencies?.isNotEmpty) ??
          false) &&
      ((MainWidgetController.instance.country?.value?.currency?.isNotEmpty) ??
          false);

  if (paramCurrency == null || !hasCachedCurrency) {
    return {"value": valueFinal.round(), "success": false};
  }

  String countryCurrency = MainWidgetController.instance.currency;
  double countryTargetCurrencyUsd = tryParseDouble(
      MainWidgetController.instance.cacheCurrency.currencies[countryCurrency] ??
          (0.0));
  double paramTargetCurrencyUsd = tryParseDouble(
      MainWidgetController.instance.cacheCurrency.currencies[paramCurrency] ??
          (0.0));

  if (countryTargetCurrencyUsd == null || paramTargetCurrencyUsd == null) {
    return {"value": valueFinal.round(), "success": false};
  }

  return {
    "value": ((valueFinal / paramTargetCurrencyUsd) * countryTargetCurrencyUsd)
        .round(),
    "success": true
  };
}

double tryParseDouble(var value) {
  double newValue;

  if (!(value is double)) {
    if (value is String) {
      newValue = double.parse(value);
    } else if (value is int) {
      newValue = value.toDouble();
    }
  } else {
    newValue = value;
  }

  return newValue;
}

/// target current country currency
String convertFormatCurrency(var value, String currency) {
  var convertCurrencyParam = convertCurrency(value, currency);
  String symbol = convertCurrencyParam['success']
      ? Constant.CURRENCY_SYMBOL[MainWidgetController.instance.currency]
      : Constant.CURRENCY_SYMBOL[currency ?? Constant.DEFAULT_CUR];

  return formatCurrency(convertCurrencyParam['value'], symbol: symbol);
}

Map timeouts = {};
void debounce(int timeoutMS, Function target, List arguments) {
  if (timeouts.containsKey(target)) {
    timeouts[target].cancel();
  }

  Timer timer = Timer(Duration(milliseconds: timeoutMS), () {
    Function.apply(target, arguments);
  });

  timeouts[target] = timer;
}

void writeNotNull(Map val, String key, dynamic value) {
  if (value != null) {
    val[key] = value;
  }
}

bool isSameDates(List<DateTime> params) {
  if ((params?.length ?? 0) > 0) {
    int i = -1;

    return params.fold(true, (bool accu, DateTime item) {
      i++;

      if (i > 0) {
        DateTime itemBefore = params.elementAt(i - 1);

        bool valid = accu &&
            itemBefore.day == item.day &&
            itemBefore.month == item.month &&
            itemBefore.year == item.year;

        return valid;
      }

      return accu;
    });
  }

  return false;
}

List responseDatas(ResponseService responseService) {
  bool hasDatas = responseService != null;
  List datas = [];

  if (hasDatas) {
    datas = responseService.getData(defaultValue: []);
    hasDatas = datas != null && datas is List && datas.length > 0;
  }

  return datas ?? [];
}

dynamic mapGet(Map map, List path, {defaultValue = "-"}) {
  assert(path.length > 0);
  var m = map ?? const {};
  for (int i = 0; i < path.length - 1; i++) {
    m = m[path[i]] ?? const {};
  }

  return m[path.last] ?? defaultValue;
}

dynamic stringToJsonMap(String param, {defaultValue}) {
  if ((param ?? "").isNotEmpty) {
    try {
      return json.decode(param);
    } catch (e) {
      print(e.toString());

      return defaultValue;
    }
  }

  return defaultValue;
}

List<DateTime> getRangeDates(DateTime firstDate, DateTime lastDate) {
  assert(lastDate != null);
  assert(firstDate != null);
  assert(lastDate.millisecondsSinceEpoch > firstDate.millisecondsSinceEpoch);

  DateTime finalFirstDate;
  DateTime finalLastDate;

  if (lastDate.millisecondsSinceEpoch > firstDate.millisecondsSinceEpoch) {
    finalFirstDate = firstDate;
    finalLastDate = lastDate;
  } else {
    finalFirstDate = lastDate;
    finalLastDate = firstDate;
  }

  Duration diff = finalLastDate.difference(finalFirstDate);

  if (diff.inDays > 0) {
    List<DateTime> params = [];
    for (int i = 0; i <= diff.inDays; i++) {
      params.add(DateTime(
          finalFirstDate.year, finalFirstDate.month, finalFirstDate.day + i));
    }

    return params;
  }

  return [];
}
