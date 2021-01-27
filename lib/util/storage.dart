import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/model/base_model.dart';
import 'package:tamasya/model/cache-currency.dart';
import 'package:tamasya/model/cache-flight.dart';
import 'package:tamasya/model/cache-hotel.dart';
import 'package:tamasya/model/cache-tour.dart';
import 'package:tamasya/model/filter-flight-offer.dart';
import 'package:tamasya/model/filter-hotel-offer.dart';
import 'package:tamasya/model/flight-offer.dart';
import 'package:tamasya/model/hotel-offer.dart';
import 'package:tamasya/model/tour-activity.dart';
import 'package:tamasya/model/user-auth.dart';

class Storage {
  static FlutterSecureStorage _storage;

  static FlutterSecureStorage getStorage() {
    if (_storage == null) {
      _storage = new FlutterSecureStorage();
    }

    return _storage;
  }

  static Future<BaseModel> getParsedData(String key, BaseModel entity) async {
    try {
      String dataStorage = await readValue(key: key);

      if (dataStorage != null) {
        return entity.fromJson(json.decode(dataStorage));
      }
    } catch (e) {
      print(e);
    }

    return null;
  }

  static Future<dynamic> readValue({String key}) async {
    if ((key ?? "").isEmpty) {
      return await getStorage().readAll();
    }

    return await getStorage().read(key: key);
  }

  static Future<void> deleteValue({String key}) async {
    if ((key ?? "").isEmpty) {
      await getStorage().deleteAll();
    } else {
      await getStorage().delete(key: key);
    }
  }

  static Future<void> writeValue(String key, dynamic value) async {
    String finalValue;

    if (value is String) {
      finalValue = value;
    } else {
      finalValue = json.encode(value);
    }

    await getStorage().write(key: key, value: finalValue);
  }
}

class CacheHotelStorage {
  static CacheHotel _cacheHotel;

  static Future<CacheHotel> getCacheHotel() async {
    if (CacheHotelStorage._cacheHotel == null) {
      CacheHotelStorage._cacheHotel = await Storage.getParsedData(
          Constant.STORAGE_FILTER_HOTEL_KEY, CacheHotel());

      if (CacheHotelStorage._cacheHotel?.lastTime != null) {
        var dur = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(
            CacheHotelStorage._cacheHotel?.lastTime));

        bool shouldDeleteCache =
            (dur?.inHours ?? 0) > Constant.MAX_EXPIRED_CACHE_HOUR;

        if (shouldDeleteCache) {
          CacheHotelStorage._cacheHotel = null;
        }
      }
    }

    return CacheHotelStorage._cacheHotel;
  }

  static Future<void> setCacheHotel(
      FilterHotelOffer filter, List<HotelOffer> hotels) async {
    var cacheHotel = CacheHotel(
        lastTime: DateTime.now().millisecondsSinceEpoch,
        lastFilter: filter,
        lastHotelOffers: hotels);

    await Storage.writeValue(Constant.STORAGE_FILTER_HOTEL_KEY, cacheHotel);

    CacheHotelStorage._cacheHotel = cacheHotel;
  }
}

class CacheCurrencyStorage {
  static CacheCurrency _cachecurrency;

  static Future<CacheCurrency> getCacheCurrency() async {
    if (CacheCurrencyStorage._cachecurrency == null) {
      CacheCurrencyStorage._cachecurrency = await Storage.getParsedData(
          Constant.STORAGE_FILTER_CURRENCY_KEY, CacheCurrency());

      if (CacheCurrencyStorage._cachecurrency?.lastTime != null) {
        var dur = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(
            CacheCurrencyStorage._cachecurrency?.lastTime));

        bool shouldDeleteCache =
            (dur?.inDays ?? 0) > Constant.MAX_EXPIRED_CACHE_CURRENCY_DAY;

        if (shouldDeleteCache) {
          CacheCurrencyStorage._cachecurrency = null;
        }
      }
    }

    return CacheCurrencyStorage._cachecurrency;
  }

  static Future<void> setCacheCurrency(Map<String, dynamic> currencies) async {
    var cacheCurrency = CacheCurrency(
        currencies: currencies,
        lastTime: DateTime.now().millisecondsSinceEpoch);

    await Storage.writeValue(
        Constant.STORAGE_FILTER_CURRENCY_KEY, cacheCurrency);

    CacheCurrencyStorage._cachecurrency = cacheCurrency;
  }
}

class CacheTourStorage {
  static CacheTour _cacheTour;

  static Future<CacheTour> getCacheTour() async {
    if (CacheTourStorage._cacheTour == null) {
      CacheTourStorage._cacheTour = await Storage.getParsedData(
          Constant.STORAGE_FILTER_TOUR_KEY, CacheTour());

      if (CacheTourStorage._cacheTour?.lastTime != null) {
        var dur = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(
            CacheTourStorage._cacheTour?.lastTime));

        bool shouldDeleteCache =
            (dur?.inHours ?? 0) > Constant.MAX_EXPIRED_CACHE_HOUR;

        if (shouldDeleteCache) {
          CacheTourStorage._cacheTour = null;
        }
      }
    }

    return CacheTourStorage._cacheTour;
  }

  static Future<void> setCacheTour(
      double lat, double lng, double rad, List<TourActivity> tours) async {
    var cacheTour = CacheTour(
        lastTime: DateTime.now().millisecondsSinceEpoch,
        lat: lat,
        lng: lng,
        rad: rad,
        lastToursActivities: tours);

    await Storage.writeValue(Constant.STORAGE_FILTER_TOUR_KEY, cacheTour);

    CacheTourStorage._cacheTour = cacheTour;
  }
}

class CacheFlightStorage {
  static CacheFlight _cacheFlight;

  static Future<CacheFlight> getCacheFlight() async {
    if (CacheFlightStorage._cacheFlight == null) {
      CacheFlightStorage._cacheFlight = await Storage.getParsedData(
          Constant.STORAGE_FILTER_FLIGHT_KEY, CacheFlight());

      if (CacheFlightStorage._cacheFlight?.lastTime != null) {
        var dur = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(
            CacheFlightStorage._cacheFlight?.lastTime));

        bool shouldDeleteCache =
            (dur?.inHours ?? 0) > Constant.MAX_EXPIRED_CACHE_HOUR;

        if (shouldDeleteCache) {
          CacheFlightStorage._cacheFlight = null;
        }
      }
    }

    return CacheFlightStorage._cacheFlight;
  }

  static Future<void> setCacheFlight(
      FilterFlightOffer filter, List<FlightOffer> flights) async {
    var cacheFlight = CacheFlight(
        lastTime: DateTime.now().millisecondsSinceEpoch,
        lastFilter: filter,
        lastFlightOffers: flights);

    await Storage.writeValue(Constant.STORAGE_FILTER_FLIGHT_KEY, cacheFlight);

    CacheFlightStorage._cacheFlight = cacheFlight;
  }
}

class UserAuthActive {
  static UserAuth _userAuth;

  static Future<UserAuth> getUser() async {
    if (UserAuthActive._userAuth == null) {
      UserAuthActive._userAuth =
          await Storage.getParsedData(Constant.STORAGE_USER_KEY, UserAuth());

      return UserAuthActive._userAuth;
    }

    return UserAuthActive._userAuth;
  }

  static Future<void> setUser(UserAuth user) async {
    await Storage.writeValue(Constant.STORAGE_USER_KEY, user.toJson());

    UserAuthActive._userAuth = user;
  }

  static String get accessToken {
    return _userAuth?.accessToken ?? "";
  }

  static Future<void> removeUser() async {
    _userAuth = null;
    await Storage.deleteValue(key: Constant.STORAGE_USER_KEY);
  }
}
