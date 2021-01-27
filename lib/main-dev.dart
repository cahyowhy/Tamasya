import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:catcher/catcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tamasya/main-app.dart';
import 'config/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnv().load('.env');

  BuildEnvironment.init(
      amadeusApiUrl: DotEnv().env['AMADEUS_API_URL'],
      amadeusApiKey: DotEnv().env['AMADEUS_API_KEY'],
      amadeusApiSecret: DotEnv().env['AMADEUS_API_SECRET'],
      flavor: BuildFlavor.development,
      bugEmailReport: DotEnv().env['BUG_EMAIL_REPORT'],
      mapBoxApiKey: DotEnv().env['MAP_BOX_API_KEY'],
      currencyFreakApiKey: DotEnv().env['CURR_FREAK_API_KEY']);
  assert(env != null);

  CatcherOptions debugOptions =
      CatcherOptions(SilentReportMode(), [ConsoleHandler()]);
  CatcherOptions releaseOptions = CatcherOptions(DialogReportMode(), [
    EmailManualHandler([env.bugEmailReport])
  ]);

  Catcher(MainApp.getMainApp(),
      debugConfig: debugOptions, releaseConfig: releaseOptions);
}
