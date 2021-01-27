import 'package:dio/dio.dart' as dio;

class RequestInfo {
  RequestInfo({this.url, this.route});
  dio.Dio customDio = dio.Dio();
  dio.CancelToken cancelToken = dio.CancelToken();

  String url;
  String route;
  bool isDone = false;

  String showinfo() {
    return "$url, $route, $isDone";
  }
}