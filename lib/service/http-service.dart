import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:tamasya/config/constant.dart';
import 'package:tamasya/config/env.dart';
import 'package:tamasya/main-widget-controller.dart';
import 'package:tamasya/service/custom-dio.dart';
import 'package:tamasya/service/request-info.dart';
import 'package:tamasya/service/response-service.dart';
import 'package:tamasya/util/storage.dart';

class Method {
  static const String GET = "get";
  static const String POST = "post";
  static const String PUT = "put";
  static const String DELETE = "delete";
}

class HttpBaseService {
  String baseUrl = env.amadeusApiUrl;

  final Duration durationTimeout =
      Duration(seconds: Constant.REQUEST_TIMEOUT_S);

  Future<ResponseService> find(
      {String url,
      bool isJson = true,
      Map<String, dynamic> queryParams,
      bool toast = false,
      Map<String, String> customHeader}) {
    return buildRequest(Method.GET, url ?? baseUrl,
        isJson: isJson,
        toast: toast,
        queryParams: queryParams,
        customHeader: customHeader);
  }

  Future<ResponseService> post(param,
      {String url,
      bool isJson = true,
      bool toast = true,
      Map<String, String> customHeader}) {
    return buildRequest(Method.POST, url ?? baseUrl,
        isJson: isJson, toast: toast, param: param, customHeader: customHeader);
  }

  Future<ResponseService> put(param,
      {String url,
      bool isJson = true,
      bool toast = true,
      bool isBuffer = true,
      Map<String, String> customHeader}) {
    return buildRequest(Method.PUT, url ?? baseUrl,
        isJson: isJson, toast: toast, param: param, customHeader: customHeader);
  }

  Future<ResponseService> delete(String id,
      {String url,
      bool isJson = true,
      bool toast = true,
      Map<String, String> customHeader}) {
    String finalUrl = url ?? baseUrl;
    finalUrl += "/$id";

    return buildRequest(Method.DELETE, finalUrl,
        isJson: isJson, toast: toast, customHeader: customHeader);
  }

  Future<ResponseService> buildRequest(String method, String url,
      {dynamic param,
      Map<String, dynamic> queryParams,
      bool toast = true,
      bool isJson = true,
      Map<String, String> customHeader}) async {
    Map<String, String> finalHeader = {};

    if (isJson) {
      finalHeader = {
        'Content-Type': "application/json",
        'accept': "application/json"
      };

      if (UserAuthActive.accessToken.isNotEmpty) {
        finalHeader["Authorization"] = "Bearer ${UserAuthActive.accessToken}";
      }
    }

    if (customHeader != null) {
      finalHeader.addAll(customHeader);
    }

    dio.Response response;
    ResponseService responseService;
    try {
      RequestInfo requestInfo = CustomDio.getReqInfo(url);
      requestInfo.customDio.options.method = method;
      requestInfo.customDio.options.headers = finalHeader;
      requestInfo.customDio.options.connectTimeout =
          Duration(seconds: Constant.REQUEST_TIMEOUT_S).inMilliseconds;

      /// IF NOT JSON MEAN X-UNICODE-FORM
      if (!isJson) {
        requestInfo.customDio.options.contentType =
            dio.Headers.formUrlEncodedContentType;
      }

      response = await requestInfo.customDio.request(url,
          cancelToken: requestInfo.cancelToken,
          queryParameters: queryParams,
          data: param == null ? null : (isJson ? json.encode(param) : param));
    } on dio.DioError catch (e) {
      print(e.toString());
  
      MainWidgetController.instance.onShowDialogErrorNetwork(e.response);
    }

    responseService = ResponseService(param: response, isJson: isJson);

    return responseService;
  }
}
