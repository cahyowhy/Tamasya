import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tamasya/model/airport.dart';
import 'package:tamasya/model/cache-currency.dart';
import 'package:tamasya/service/response-service.dart';
import 'package:tamasya/style/style.dart';
import 'package:tamasya/util/airport-reader.dart';
import 'package:tamasya/util/country-reader.dart';
import 'package:tamasya/util/geolocation.dart';
import 'package:tamasya/util/storage.dart';
import 'package:tamasya/model/country.dart';
import 'package:tamasya/model/location.dart';
import 'package:tamasya/model/mapbox-summary.dart';
import 'package:tamasya/model/user-auth.dart';
import 'package:tamasya/router/router.dart';
import 'package:tamasya/service/http-service.dart';
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/config/env.dart';
import 'package:tamasya/component/common-button.dart';
import 'package:tamasya/component/dialogues.dart';
import 'package:tamasya/component/input-place.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:event_hub/event_hub.dart';

class MainWidgetController extends GetxController with WidgetsBindingObserver {
  static MainWidgetController get instance => Get.find();

  EventHub globalEventOnNetworkError = EventHub();

  EventHub globalEventOnChangeUserLocation = EventHub();

  HttpBaseService httpBaseService = HttpBaseService();

  Location userLocation;

  bool isModalGpsShowed = false;

  RxString userPreviewLocation = "".obs;

  RxString userAdministrativeArea = "".obs;

  RxBool loadingData = false.obs;

  RxBool isUserLocationFetched = false.obs;

  RxList<Airport> userAirports = RxList<Airport>([]);

  Rx<Country> country = Rx<Country>();

  RxBool isNavigationChildPages = false.obs;

  RxBool isNavigationUnknown = false.obs;

  RxBool forceHideAppbarAndBottomBar = false.obs;

  CacheCurrency cacheCurrency;

  bool get finalHideAppBottomBar {
    return isNavigationUnknown.value || forceHideAppbarAndBottomBar.value;
  }

  int get maxPriceCurrency {
    if (cacheCurrency != null) {}

    return Constant.MAX_PRICE_IN_EUR;
  }

  String get currency {
    if (cacheCurrency != null) {
      return country.value.currency;
    }

    return Constant.DEFAULT_CUR;
  }

  String get currencySymbol {
    return Constant.CURRENCY_SYMBOL[currency]?.trim() ?? "";
  }

  String currentRoute = Routers.initialRoute;

  Airport get userSelectedAirport {
    if ((userAirports?.isNotEmpty) ?? false) {
      return userAirports?.firstWhere((element) => element.activeMark,
          orElse: () => null);
    }

    return null;
  }

  String get userIataCode {
    if (userSelectedAirport != null) {
      return userSelectedAirport.iata;
    }

    return null;
  }

  @override
  onInit() {
    super.onInit();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  onClose() {
    super.onClose();

    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    bool isUserAlreadyActivateGps =
        isModalGpsShowed && state == AppLifecycleState.resumed;
    if (isUserAlreadyActivateGps) {
      Geolocator().isLocationServiceEnabled().then((value) {
        if (value) {
          Get.back();
        }
      });
    }
  }

  onChangeActiveAirport(int i, {bool deleteCachedData: false}) {
    if (userAirports?.isNotEmpty ?? false) {
      int idx = 0;
      userAirports.forEach((item) {
        userAirports[idx] = userAirports[idx].copyWith(active: idx == i);

        idx++;
      });

      globalEventOnChangeUserLocation.fire(
          'onChangeUserLocation', userAirports.elementAt(i));
    }
  }

  @override
  void onReady() {
    super.onReady();
    loadingData.value = true;

    Future.wait([UserAuthActive.getUser(), doPrepareDatData()]).then((_) {
      Future.wait([doFindUserLocation(), doAuthActiveUser()])
          .whenComplete(() => loadingData.value = false);
    });
  }

  onSelectInputPlace(MapBoxResult option) async {
    List<String> splits = option.placeName.split(",");
    String countryString = splits?.last?.trim();

    splits.removeLast();
    splits = splits.map((e) => e.trim()).toList();

    userAdministrativeArea.value = splits.join(", ");
    userPreviewLocation.value = userAdministrativeArea.value;

    List<String> administratives = splits.map((e) {
      e = e.toLowerCase();
      e = e.replaceAll(new RegExp(r'special'), '');
      e = e.replaceAll(new RegExp(r'region'), '');
      e = e.replaceAll(new RegExp(r' of'), '');
      e = e.replaceAll(new RegExp(r'of '), '');

      return e.trim();
    }).toList();

    userAirports.clear();
    administratives.forEach((element) {
      if ((userAirports?.length ?? 0) == 0) {
        userAirports.addAll(AirportDataReader.searchString(element)
            .where((element) => element.iata != null)
            .cast<Airport>()
            .toList());
      }
    });

    final country = CountryReader.searchString(countryString,
        byCountry: true, byIso3: false);

    if (country?.isNotEmpty ?? false) {
      this.country.value = country.first;
    }

    Get.back();

    loadingData.value = true;
    await this.doFindCurrency();
    loadingData.value = false;

    onChangeActiveAirport(0);
  }

  onShowInputPlace() async {
    bool skipHideAppBar =
        MainWidgetController.instance.forceHideAppbarAndBottomBar.value;

    if (!skipHideAppBar)
      MainWidgetController.instance.forceHideAppbarAndBottomBar.value = true;

    await showDialogAnimation(
        Get.overlayContext,
        SingleChildScrollView(
          child: Container(
            child: InputPlace(onSelectPlace: onSelectInputPlace),
          ),
        ));

    if (!skipHideAppBar)
      MainWidgetController.instance.forceHideAppbarAndBottomBar.value = false;
  }

  Future<void> doAuthActiveUser() async {
    var param = {
      "grant_type": "client_credentials",
      "client_id": env.amadeusApiKey,
      "client_secret": env.amadeusApiSecret
    };
    String url = env.amadeusApiUrl + 'v1/security/oauth2/token';

    var responseService =
        await httpBaseService.post(param, url: url, isJson: false);

    if (responseService.jsonResponse != null) {
      UserAuthActive.setUser(UserAuth.fromJson(responseService.jsonResponse));
    }
  }

  Future<bool> onWillPopExit() async {
    forceHideAppbarAndBottomBar.value = true;
    bool onShowDialogExit = await showDialogExitApp(Get.overlayContext);
    forceHideAppbarAndBottomBar.value = false;

    return onShowDialogExit;
  }

  doRefetchData({bool isUnauthorize = false}) async {
    try {
      if (isUnauthorize) {
        await UserAuthActive.removeUser();
        await doAuthActiveUser();
        await UserAuthActive.getUser();
      }

      globalEventOnNetworkError.fire('onRefetchData');
    } catch (e) {
      print(e);
    }
  }

  onShowDialogErrorNetwork(dio.Response response) async {
    Map<String, dynamic> responseJson;

    if (response?.data != null) {
      if (response.data is String) {
        responseJson = Map<String, dynamic>.from(json.decode(response.data));
      } else {
        responseJson = Map<String, dynamic>.from(response.data);
      }

      bool isUnauthorize = response.statusCode == Constant.HTTP_UNAUTHORIZE;
      bool showDialog = isUnauthorize;

      if (!showDialog && responseJson['errors'] != null) {
        responseJson['errors'] =
            responseJson['errors']?.map((e) => e)?.toList() ?? [];
        bool validList(param) =>
            param is List && param.length > 0 && param[0] != null;

        if (validList(responseJson['errors'])) {
          List<String> skipMessageError = [
            "Primitive technical",
            "The targeted resource doesn't",
            "DATA DOMAIN NOT"
          ];

          List<int> skipCodeError = [38189, 1271, 11126];

          if (responseJson['errors'][0]['code'] != null &&
              responseJson['errors'][0]['code'] is int) {
            showDialog = !skipCodeError.fold(
                false,
                (acc, item) =>
                    acc || (responseJson['errors'][0]['code'] as int) == item);
          } else if (responseJson['errors'][0]['detail'] != null &&
              responseJson['errors'][0]['detail'] is String) {
            showDialog = !skipMessageError.fold(
                false,
                (acc, key) =>
                    acc ||
                    (responseJson['errors'][0]['detail'] as String)
                        .startsWith(key));
          }
        }
      }

      if (showDialog) {
        bool hideAppBottombar =
            MainWidgetController.instance.forceHideAppbarAndBottomBar.value;

        if (!hideAppBottombar) {
          MainWidgetController.instance.forceHideAppbarAndBottomBar.value =
              true;
        }

        await showDialogAnimation(
            Get.overlayContext,
            Center(
              child: Container(
                  constraints: BoxConstraints(maxWidth: 400, maxHeight: 350),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: Style.borderRadius(param: 12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/image/png/pict-net-errr.png",
                          width: 128),
                      SizedBox(height: 24),
                      Text("Connection Error",
                          style: TextStyle(
                              fontFamily: 'Raleway',
                              fontWeight: FontWeight.w800,
                              fontSize: 18)),
                      SizedBox(height: 12),
                      Text("Error happen when contacting server"),
                      SizedBox(height: 24),
                      CommonButton(
                          elevation: 0,
                          onPressed: () {
                            doRefetchData(isUnauthorize: isUnauthorize);
                            Get.back();
                          },
                          child: Text("Try Again")),
                    ],
                  )),
            ));

        if (!hideAppBottombar) {
          MainWidgetController.instance.forceHideAppbarAndBottomBar.value =
              false;
        }
      }
    }
  }

  Future<void> doPrepareDatData() async {
    await Future.wait([
      AirportDataReader.load('assets/dat/airports.dat'),
      CountryReader.load('assets/dat/countries.dat'),
    ]);
  }

  Future<void> doFindCurrency() async {
    this.cacheCurrency = await CacheCurrencyStorage.getCacheCurrency() ?? null;
    bool validFetchCurrency = (cacheCurrency?.currencies?.isEmpty ?? true);

    if (validFetchCurrency) {
      String endpoint =
          "https://api.currencyfreaks.com/latest?apikey=${env.currencyFreakApiKey}";
      ResponseService responseService =
          await HttpBaseService().find(url: endpoint, isJson: true);

      if (responseService?.jsonResponse != null &&
          responseService.jsonResponse is Map &&
          responseService.jsonResponse.isNotEmpty) {
        if (responseService.jsonResponse['rates'] != null) {
          CacheCurrencyStorage.setCacheCurrency(
              responseService.jsonResponse['rates']);
        }
      } else {
        print("request failed");
        return;
      }
    }
  }

  Future<void> doFindUserLocation() async {
    isUserLocationFetched.value = false;
    userAirports.clear();

    userLocation = await Geolocation.getLocation();

    bool useReverseGeocode =
        userLocation?.mapBoxReverseGeocoding?.features?.isNotEmpty ?? false;

    if (userLocation?.previewLocation != null) {
      userPreviewLocation.value = userLocation.previewLocation;
      isUserLocationFetched.value = true;
    }

    if (AirportDataReader.airportsData.isNotEmpty &&
        userLocation?.previewLocation != null) {
      String administrativeArea;
      String countryIso3;

      if (useReverseGeocode) {
        administrativeArea = userLocation.mapBoxRegionName;
        countryIso3 = userLocation.mapBoxCountryName;
      } else {
        try {
          administrativeArea = userLocation.placemarks[0].administrativeArea;
          countryIso3 = userLocation.placemarks[0]?.isoCountryCode;
        } catch (e) {
          print(e);
        }
      }

      if (administrativeArea != null) {
        userAdministrativeArea.value = administrativeArea;
      }

      if ((administrativeArea?.isNotEmpty) ?? false) {
        List<String> administratives = administrativeArea.split(' ');

        if ((administratives?.isNotEmpty) ?? false) {
          administratives.forEach((element) {
            userAirports.addAll(AirportDataReader.searchString(element)
                .where((element) => element.iata != null)
                .cast<Airport>()
                .toList());
          });
        }
      }

      onChangeActiveAirport(0);

      if (countryIso3 != null) {
        final country = CountryReader.searchString(countryIso3,
            byCountry: useReverseGeocode, byIso3: !useReverseGeocode);

        if (country?.isNotEmpty ?? false) {
          this.country.value = country.first;
        }
      }

      await doFindCurrency();
    }
  }
}
