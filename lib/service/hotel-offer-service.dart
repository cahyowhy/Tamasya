import 'package:flutter/foundation.dart';
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/config/env.dart';
import 'package:tamasya/model/hotel-offer.dart';
import 'package:tamasya/service/http-service.dart';
import 'package:tamasya/service/response-service.dart';
import 'package:tamasya/util/underscore.dart';
import 'package:tamasya/util/computable-function.dart' as ComputeFunction;

class HotelOfferService extends HttpBaseService {
  String baseUrl = env.amadeusApiUrl + "v2/shopping/hotel-offers";

  static HotelOfferService _instance;

  static HotelOfferService get instance {
    if (_instance == null) {
      _instance = HotelOfferService();
    }

    return _instance;
  }

  Future<List<HotelOffer>> getHotelOffers(
      Map<String, dynamic> queryParams) async {
    ResponseService responseService =
        await super.find(queryParams: queryParams);

    List datas = responseDatas(responseService);
    if (datas?.isNotEmpty ?? false) {
      bool useCompute = datas.length >= Constant.MAX_DATA_USE_COMPUTE;

      if (useCompute) {
        return compute(
            ComputeFunction.parseHotelOffers, responseService.jsonResponse);
      }

      return ComputeFunction.parseHotelOffers(responseService.jsonResponse);
    }

    return List<HotelOffer>();
  }
}
