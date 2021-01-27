import 'package:meta/meta.dart';

enum BuildFlavor { production, development, staging }

BuildEnvironment get env => _env;
BuildEnvironment _env;

class BuildEnvironment {
  final String amadeusApiUrl;
  final String amadeusApiKey;
  final String amadeusApiSecret;
  final String mapBoxApiKey;
  final String currencyFreakApiKey;
  final BuildFlavor flavor;
  final String bugEmailReport;

  BuildEnvironment._init(
      this.flavor,
      this.amadeusApiUrl,
      this.amadeusApiKey,
      this.amadeusApiSecret,
      this.bugEmailReport,
      this.mapBoxApiKey,
      this.currencyFreakApiKey);

  static void init(
          {@required flavor,
          @required amadeusApiUrl,
          @required amadeusApiKey,
          @required amadeusApiSecret,
          @required bugEmailReport,
          @required mapBoxApiKey,
          @required currencyFreakApiKey}) =>
      _env ??= BuildEnvironment._init(flavor, amadeusApiUrl, amadeusApiKey,
          amadeusApiSecret, bugEmailReport, mapBoxApiKey, currencyFreakApiKey);
}
