import 'package:flutter/foundation.dart';
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/config/env.dart';
import 'package:tamasya/model/tour-activity.dart';
import 'package:tamasya/service/http-service.dart';
import 'package:tamasya/service/response-service.dart';
import 'package:tamasya/util/underscore.dart';
import 'package:tamasya/util/computable-function.dart' as ComputeFunction;

class TourActivityService extends HttpBaseService {
  String baseUrl = env.amadeusApiUrl + "v1/shopping/activities";

  static TourActivityService _instance;

  static TourActivityService get instance {
    if (_instance == null) {
      _instance = TourActivityService();
    }

    return _instance;
  }

  Future<List<TourActivity>> getTourActivities(
      double latitude, double longitude, double radius) async {
    double radiusFinal = radius > 20 ? 20 : radius;

    Map<String, dynamic> queryParams = {
      "latitude": latitude.toStringAsFixed(3),
      "longitude": longitude.toStringAsFixed(3),
      "radius": radiusFinal.toStringAsFixed(3),
    };

    ResponseService responseService =
        await super.find(queryParams: queryParams);

    List datas = responseDatas(responseService);
    if (datas?.isNotEmpty ?? false) {
      bool useCompute = datas.length >= Constant.MAX_DATA_USE_COMPUTE;

      if (useCompute) {
        return compute(
            ComputeFunction.parseTourActivities, responseService.jsonResponse);
      }

      return ComputeFunction.parseTourActivities(responseService.jsonResponse);
    }

    return List<TourActivity>();
  }
}
