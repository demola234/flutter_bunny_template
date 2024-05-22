part of 'api.dart';

class DioClient {
  late String baseURL;
  late Dio? dio;

  DioClient({this.dio, required this.baseURL});

  Future<Dio?> getDio() async {
    dio!.options = BaseOptions(baseUrl: baseURL);

    if (!kReleaseMode) {
      // ITS DEBUG MODE SO PRINT APP LOGS
      dio!.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
      ));

      RetryInterceptor(
        dio: dio!,
        retryableExtraStatuses: {401},
        logPrint: (message) => debugPrint(message),
        retries: 2,
      );

      dio!.interceptors.add(CurlLoggerDioInterceptor(printOnSuccess: true));
    }

    return dio;
  }
}
