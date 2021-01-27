import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:tamasya/config/env.dart';
import 'package:tamasya/service/request-info.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class CustomDio {
  static List<RequestInfo> requests = [];

  static RequestInfo getReqInfo(String url) {
    String routeName = Get.rawRoute.settings.name;
    RequestInfo req = RequestInfo(url: url, route: routeName);

    if (env.flavor == BuildFlavor.development) {
      req.customDio.interceptors.addAll([PrettyDioLogger(responseBody: false)]);
    }

    req.customDio.interceptors.add(dio.InterceptorsWrapper(
      onResponse: (dio.Response res) {
        int idx = requests.indexWhere((RequestInfo req) {
          return res.request.uri.toString() == req.url &&
              res.request.method.toLowerCase() == "get";
        });

        if (idx > -1) {
          requests[idx].isDone = true;
        }

        return res;
      },
      onError: (dio.DioError err) {
        int idx = requests.indexWhere((RequestInfo req) {
          return err.request.uri.toString() == req.url &&
              err.request.method.toLowerCase() == "get";
        });

        if (idx > -1) {
          requests[idx].isDone = true;
        }

        return err;
      },
    ));

    requests.add(req);

    return req;
  }

  static void cancelRequest({dynamic msg}) {
    String routeName = Get.rawRoute.settings.name;

    requests.forEach((RequestInfo req) {
      if (!req.isDone && routeName != req.route) {
        print(req.showinfo());

        try {
          req.cancelToken.cancel(msg);
        } catch (e) {
          print(e);
        }
      }
    });

    requests = requests.where((RequestInfo req) {
      return routeName == req.route;
    }).toList();
  }
}
