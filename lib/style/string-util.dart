import 'dart:math';

import 'package:intl/intl.dart';
import 'package:tamasya/main-widget-controller.dart';

String formatCurrency(int value, {String symbol, bool useDecimal = false}) {
  String symbolFinal = symbol ?? MainWidgetController.instance.currencySymbol;
  String pattern = "#,##0";

  if (useDecimal) {
    pattern += '.00';
  }

  final NumberFormat currency = new NumberFormat(pattern);

  String fmt = currency.format((value ?? 0).abs());

  if (symbolFinal?.isNotEmpty ?? false) {
    return "$symbolFinal $fmt";
  }

  return fmt;
}

String capitalize(String param) {
  assert(param?.isNotEmpty ?? false);

  return "${param[0].toUpperCase()}${param.substring(1).toLowerCase()}";
}

String startCase(String param) {
  String fmt = param.replaceAll("_", " ");
  fmt = fmt.replaceAll("-", " ");
  fmt = fmt.trim();

  return fmt.split(" ").map((String e) => capitalize(e)).join(" ");
}

String randomString({int strlen = 12}) {
  const chars =
      "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

  Random rnd = new Random(new DateTime.now().microsecondsSinceEpoch);
  String result = "";

  for (var i = 0; i < strlen; i++) {
    result += chars[rnd.nextInt(chars.length)];
  }

  return result;
}
