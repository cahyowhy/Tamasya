import 'package:meta/meta.dart';
import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:tamasya/model/base_model.dart';
import 'package:tamasya/util/underscore.dart';

class ResponseService extends BaseModel {
  dio.Response response;

  bool isSuccess = false;

  Map<String, dynamic> jsonResponse;

  DateTime lastTimeFetched = DateTime.now();

  ResponseService({dio.Response param, bool isJson = true}) {
    if (param != null) {
      response = param;
      isSuccess =
          (param?.statusCode ?? 0) >= 200 && (param?.statusCode ?? 0) <= 200;

      processResponse();
    }
  }

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('isSuccess', isSuccess);
    writeNotNull('jsonResponse', json.encode(jsonResponse));
    writeNotNull('lastTimeFetched', lastTimeFetched?.millisecondsSinceEpoch);

    return val;
  }

  fromJson(json) {
    return ResponseService.fromJson(json);
  }

  factory ResponseService.fromJson(Map<String, dynamic> json) {
    ResponseService responseService = ResponseService()
      ..isSuccess = json['isSuccess'] as bool
      ..lastTimeFetched = json['lastTimeFetched'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastTimeFetched'])
          : DateTime.now();

    if (json['jsonResponse'] != null) {
      if (json['jsonResponse'] is String) {
        responseService.jsonResponse = stringToJsonMap(json['jsonResponse']);
      } else if (json['jsonResponse'] is Map) {
        responseService.jsonResponse = json['jsonResponse'];
      }
    }

    return responseService;
  }

  /// this assume if your class was HttpResponse {data, status}
  processResponse() {
    try {
      if (response.data != null) {
        if (response.data is String) {
          jsonResponse = Map<String, dynamic>.from(json.decode(response.data));
        } else {
          jsonResponse = Map<String, dynamic>.from(response.data);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  getData({dynamic defaultValue}) {
    return getJsonProp('data', defaultValue: defaultValue);
  }

  getJsonProp(String path, {dynamic defaultValue}) {
    if ((jsonResponse?.isNotEmpty) ?? false) {
      return jsonResponse[path];
    }

    return defaultValue;
  }

  BaseModel getDeserializeResponse(BaseModel object, {@required defaultValue}) {
    if (isSuccess) {
      return object.fromJson(getData(defaultValue: defaultValue));
    }

    return defaultValue;
  }

  /// Uncasted, casted from another page
  List getListDeserialize(BaseModel object) {
    return getData(defaultValue: [])?.map((e) {
          if (e == null) {
            return null;
          }

          return object.fromJson(e as Map<String, dynamic>);
        })?.toList() ??
        [];
  }

  bool get containData {
    return (jsonResponse?.isNotEmpty) ?? false;
  }
}
