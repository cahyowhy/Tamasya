import 'package:flutter/foundation.dart';
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/config/env.dart';
import 'package:tamasya/model/flight-offer.dart';
import 'package:tamasya/service/http-service.dart';
import 'package:tamasya/service/response-service.dart';
import 'package:tamasya/util/computable-function.dart' as ComputeFunction;
import 'package:tamasya/util/underscore.dart';

class FlightOfferService extends HttpBaseService {
  String baseUrl = env.amadeusApiUrl + "v2/shopping/flight-offers";

  static FlightOfferService _instance;

  static FlightOfferService get instance {
    if (_instance == null) {
      _instance = FlightOfferService();
    }

    return _instance;
  }

  Future<List<FlightOffer>> getFlightOffers(
      Map<String, dynamic> queryParams) async {
    ResponseService responseService =
        await super.find(queryParams: queryParams);

    List datas = responseDatas(responseService);
    if (datas?.isNotEmpty ?? false) {
      bool useCompute = datas.length >= Constant.MAX_DATA_USE_COMPUTE;

      if (useCompute) {
        return compute(
            ComputeFunction.parseFlightOffers, responseService.jsonResponse);
      }

      return ComputeFunction.parseFlightOffers(responseService.jsonResponse);
    }

    return List<FlightOffer>();
  }
}
