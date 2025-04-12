import 'dart:io';

import 'package:mason/mason.dart';

import 'integrate_network_generator.dart';

/// Generates a network layer service if the Network Layer module is selected
void generateNetworkLayerService(
    HookContext context, String projectName, List<dynamic> modules) {
  // Check if Network Layer is in the selected modules
  if (!modules.contains('Network Layer')) {
    context.logger.info(
        'Network Layer module not selected, skipping network layer generation');
    return;
  }

  context.logger.info('Generating network layer for $projectName');

  // Create directory structure
  final directories = [
    'lib/core/network',
    'lib/core/network/models',
    'lib/core/network/interceptors',
    'lib/core/network/exceptions',
  ];

  for (final dir in directories) {
    final directory = Directory('$projectName/$dir');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
      context.logger.info('Created directory: $dir');
    }
  }

  // Generate network layer files
  _generateApiClientFile(context, projectName);
  _generateNetworkExceptionFile(context, projectName);
  _generateApiResponseModelFile(context, projectName);
  _generateLoggingInterceptorFile(context, projectName);
  _generateAuthInterceptorFile(context, projectName);
  // _generateConnectivityServiceFile(context, projectName);
  _generateApiConstantsFile(context, projectName);
  // _generateNetworkReadmeFile(context, projectName);
  _generateNetworkInfoFile(context, projectName);

  // Add a sample API service to showcase how to implement a service
  // _generateSampleApiServiceFile(context, projectName);

  // Integrate with main.dart
  integrateNetworkLayer(context, projectName);

  context.logger.success('Network layer generated successfully!');
}

/// Generates the API client file using Dio
void _generateApiClientFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/network/api_client.dart';
  final content = '''
import 'dart:io';
import 'package:dio/dio.dart';

import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'models/api_response.dart';
import 'exceptions/network_exceptions.dart';

/// API client for handling network requests
class ApiClient {
  late final Dio _dio;
  
  /// Base URL for all API requests
  final String baseUrl;
  
  /// Default timeout in milliseconds
  final int timeout;
  
  /// Whether to use authentication interceptor
  final bool useAuth;
  
  /// API client constructor
  ApiClient({
    required this.baseUrl,
    this.timeout = 30000,
    this.useAuth = true,
  }) {
    _initDio();
  }
  
  /// Initialize Dio client with base options and interceptors
  void _initDio() {
    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: timeout),
      receiveTimeout: Duration(milliseconds: timeout),
      responseType: ResponseType.json,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    _dio = Dio(options);
    
    // Add interceptors
    _dio.interceptors.add(LoggingInterceptor());
    
    if (useAuth) {
      _dio.interceptors.add(AuthInterceptor());
    }
  }
  
  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      return ApiResponse<T>.withError(_handleError(e));
    }
  }
  
  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      return ApiResponse<T>.withError(_handleError(e));
    }
  }
  
  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      return ApiResponse<T>.withError(_handleError(e));
    }
  }
  
  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      return ApiResponse<T>.withError(_handleError(e));
    }
  }
  
  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      return ApiResponse<T>.fromResponse(response);
    } catch (e) {
      return ApiResponse<T>.withError(_handleError(e));
    }
  }
  
  /// Download file
  Future<ApiResponse<String>> download(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    Options? options,
  }) async {
    try {
      final response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        options: options,
      );
      
      return ApiResponse<String>.fromResponse(response, data: savePath);
    } catch (e) {
      return ApiResponse<String>.withError(_handleError(e));
    }
  }
  
  /// Handle all possible errors from Dio
  NetworkExceptions _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return const NetworkExceptions.requestTimeout();
        case DioExceptionType.sendTimeout:
          return const NetworkExceptions.sendTimeout();
        case DioExceptionType.receiveTimeout:
          return const NetworkExceptions.receiveTimeout();
        case DioExceptionType.cancel:
          return const NetworkExceptions.requestCancelled();
        case DioExceptionType.badResponse:
          return _handleBadResponse(error);
        case DioExceptionType.connectionError:
          return const NetworkExceptions.noInternetConnection();
        case DioExceptionType.badCertificate:
          return const NetworkExceptions.badCertificate();
        default:
          return const NetworkExceptions.unexpectedError();
      }
    } else if (error is SocketException) {
      return const NetworkExceptions.noInternetConnection();
    } else {
      return const NetworkExceptions.unexpectedError();
    }
  }
  
  /// Handle bad responses with different status codes
  NetworkExceptions _handleBadResponse(DioException error) {
    if (error.response == null) {
      return const NetworkExceptions.unexpectedError();
    }
    
    switch (error.response!.statusCode) {
      case 400:
        return const NetworkExceptions.badRequest();
      case 401:
        return const NetworkExceptions.unauthorizedRequest();
      case 403:
        return const NetworkExceptions.forbiddenRequest();
      case 404:
        return const NetworkExceptions.notFound();
      case 409:
        return const NetworkExceptions.conflict();
      case 408:
        return const NetworkExceptions.requestTimeout();
      case 500:
        return const NetworkExceptions.internalServerError();
      case 503:
        return const NetworkExceptions.serviceUnavailable();
      default:
        return NetworkExceptions.defaultError(
          'Error with status code: \${error.response!.statusCode}',
        );
    }
  }
  
  /// Get raw Dio client (use with caution)
  Dio get dio => _dio;
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the network exceptions file
void _generateNetworkExceptionFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/network/exceptions/network_exceptions.dart';
  final content = '''
import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_exceptions.freezed.dart';

/// Custom exception class to handle various network-related errors
@freezed
class NetworkExceptions with _\$NetworkExceptions {
  const factory NetworkExceptions.requestCancelled() = RequestCancelled;
  
  const factory NetworkExceptions.unauthorizedRequest() = UnauthorizedRequest;
  
  const factory NetworkExceptions.badRequest() = BadRequest;
  
  const factory NetworkExceptions.forbidden() = Forbidden;
  
  const factory NetworkExceptions.forbiddenRequest() = ForbiddenRequest;
  
  const factory NetworkExceptions.notFound() = NotFound;
  
  const factory NetworkExceptions.methodNotAllowed() = MethodNotAllowed;
  
  const factory NetworkExceptions.notAcceptable() = NotAcceptable;
  
  const factory NetworkExceptions.requestTimeout() = RequestTimeout;
  
  const factory NetworkExceptions.receiveTimeout() = ReceiveTimeout;
  
  const factory NetworkExceptions.sendTimeout() = SendTimeout;
  
  const factory NetworkExceptions.conflict() = Conflict;
  
  const factory NetworkExceptions.internalServerError() = InternalServerError;
  
  const factory NetworkExceptions.notImplemented() = NotImplemented;
  
  const factory NetworkExceptions.serviceUnavailable() = ServiceUnavailable;
  
  const factory NetworkExceptions.noInternetConnection() = NoInternetConnection;
  
  const factory NetworkExceptions.formatException() = FormatException;
  
  const factory NetworkExceptions.unableToProcess() = UnableToProcess;
  
  const factory NetworkExceptions.defaultError(String error) = DefaultError;
  
  const factory NetworkExceptions.unexpectedError() = UnexpectedError;
  
  const factory NetworkExceptions.badCertificate() = BadCertificate;

  /// Returns a message associated with the exception type
  static String getErrorMessage(NetworkExceptions networkExceptions) {
    var errorMessage = "";
    
    networkExceptions.when(
      requestCancelled: () {
        errorMessage = "Request was cancelled";
      },
      unauthorizedRequest: () {
        errorMessage = "Unauthorized request";
      },
      badRequest: () {
        errorMessage = "Bad request";
      },
      forbidden: () {
        errorMessage = "Forbidden";
      },
      forbiddenRequest: () {
        errorMessage = "Forbidden request";
      },
      notFound: () {
        errorMessage = "The requested resource could not be found";
      },
      methodNotAllowed: () {
        errorMessage = "Method not allowed";
      },
      notAcceptable: () {
        errorMessage = "The request is not acceptable";
      },
      requestTimeout: () {
        errorMessage = "Request timeout";
      },
      receiveTimeout: () {
        errorMessage = "Receive timeout";
      },
      sendTimeout: () {
        errorMessage = "Send timeout";
      },
      conflict: () {
        errorMessage = "Resource conflict";
      },
      internalServerError: () {
        errorMessage = "Internal server error";
      },
      notImplemented: () {
        errorMessage = "Not implemented";
      },
      serviceUnavailable: () {
        errorMessage = "Service unavailable";
      },
      noInternetConnection: () {
        errorMessage = "No internet connection";
      },
      formatException: () {
        errorMessage = "Format exception";
      },
      unableToProcess: () {
        errorMessage = "Unable to process the data";
      },
      defaultError: (String error) {
        errorMessage = error;
      },
      unexpectedError: () {
        errorMessage = "An unexpected error occurred";
      },
      badCertificate: () {
        errorMessage = "Bad certificate";
      },
    );
    
    return errorMessage;
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
  context.logger.info(
      'Note: Run "flutter pub run build_runner build --delete-conflicting-outputs" to generate the freezed code');
}

/// Generates the API response model file
void _generateApiResponseModelFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/network/models/api_response.dart';
  final content = '''
import 'package:dio/dio.dart';

import '../exceptions/network_exceptions.dart';

/// Status of the API response
enum ApiStatus {
  success,
  error,
  loading,
}

/// Wrapper class for API responses to handle success and error states
class ApiResponse<T> {
  final ApiStatus status;
  final T? data;
  final NetworkExceptions? error;
  final Response<dynamic>? response;
  
  ApiResponse({
    required this.status,
    this.data,
    this.error,
    this.response,
  });
  
  /// Create a successful response
  factory ApiResponse.success(T data, {Response<dynamic>? response}) {
    return ApiResponse<T>(
      status: ApiStatus.success,
      data: data,
      response: response,
    );
  }
  
  /// Create an error response
  factory ApiResponse.withError(NetworkExceptions error) {
    return ApiResponse<T>(
      status: ApiStatus.error,
      error: error,
    );
  }
  
  /// Create a loading response
  factory ApiResponse.loading() {
    return ApiResponse<T>(status: ApiStatus.loading);
  }
  
  /// Create a response from a Dio response
  factory ApiResponse.fromResponse(
    Response<dynamic> response, {
    T? data,
  }) {
    return ApiResponse<T>(
      status: ApiStatus.success,
      data: data ?? response.data as T,
      response: response,
    );
  }
  
  /// Check if the response is successful
  bool get isSuccess => status == ApiStatus.success;
  
  /// Check if the response has an error
  bool get isError => status == ApiStatus.error;
  
  /// Check if the response is loading
  bool get isLoading => status == ApiStatus.loading;
  
  /// Get the HTTP status code if available
  int? get statusCode => response?.statusCode;
  
  /// Get the error message if available
  String get errorMessage => error != null 
    ? NetworkExceptions.getErrorMessage(error!)
    : 'Unknown error';
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the logging interceptor file
void _generateLoggingInterceptorFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/network/interceptors/logging_interceptor.dart';
  final content = '''
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor for logging requests, responses, and errors
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final method = options.method.toUpperCase();
      final url = options.uri.toString();
      
      print('\\n--> \$method \$url');
      
      if (options.headers.isNotEmpty) {
        print('Headers:');
        options.headers.forEach((key, value) => print('\$key: \$value'));
      }
      
      if (options.data != null) {
        print('Request Body:');
        _prettyPrintJson(options.data);
      }
      
      if (options.queryParameters.isNotEmpty) {
        print('Query Parameters:');
        options.queryParameters.forEach((key, value) => print('\$key: \$value'));
      }
    }
    
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final statusCode = response.statusCode;
      final method = response.requestOptions.method.toUpperCase();
      final url = response.requestOptions.uri.toString();
      
      print('\\n<-- \$statusCode \$method \$url');
      
      if (response.headers.map.isNotEmpty) {
        print('Headers:');
        response.headers.forEach((name, values) => print('\$name: \${values.join(',')}'));
      }
      
      print('Response Body:');
      _prettyPrintJson(response.data);
    }
    
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final statusCode = err.response?.statusCode;
      final method = err.requestOptions.method.toUpperCase();
      final url = err.requestOptions.uri.toString();
      
      print('\\n<-- Error \$statusCode \$method \$url');
      print('Error: \${err.error}');
      
      if (err.response != null) {
        print('Response Body:');
        _prettyPrintJson(err.response!.data);
      }
    }
    
    super.onError(err, handler);
  }
  
  /// Helper method to pretty print JSON data
  void _prettyPrintJson(dynamic data) {
    if (data == null) {
      print('null');
      return;
    }
    
    if (data is Map || data is List) {
      try {
        // Try to use json.encode for nice formatting
        // but this might not work for all data types
        print(data.toString());
      } catch (e) {
        print(data.toString());
      }
    } else {
      print(data.toString());
    }
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the auth interceptor file
void _generateAuthInterceptorFile(HookContext context, String projectName) {
  final filePath =
      '$projectName/lib/core/network/interceptors/auth_interceptor.dart';
  final content = '''
import 'package:dio/dio.dart';

/// Interceptor to add authentication headers to requests
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: Replace with your authentication logic
    // For example, get the token from a secure storage
    
    // This is just a placeholder. In a real app, you would get the token from
    // a secure storage like flutter_secure_storage
    final token = _getToken();
    
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer \$token';
    }
    
    super.onRequest(options, handler);
  }
  
  /// Get the authentication token
  String? _getToken() {
    // TODO: Implement your token retrieval logic
    // For example:
    // final secureStorage = FlutterSecureStorage();
    // return await secureStorage.read(key: 'auth_token');
    
    return null;
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle the response
    // For example, check if the token needs to be refreshed
    super.onResponse(response, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle authentication errors
    if (err.response?.statusCode == 401) {
      // TODO: Handle token expiration and refresh
      // For example:
      // _refreshToken().then((_) {
      //   // Retry the request with the new token
      //   _retryRequest(err.requestOptions, handler);
      // }).catchError((_) {
      //   // Token refresh failed, handle logout
      //   _handleLogout();
      //   handler.next(err);
      // });
    } else {
      handler.next(err);
    }
  }
  
  /// Retry a request with updated options
  Future<void> _retryRequest(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    
    final token = _getToken();
    
    if (token != null && token.isNotEmpty) {
      options.headers?['Authorization'] = 'Bearer \$token';
    }
    
    try {
      final dio = Dio();
      final response = await dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options,
      );
      
      handler.resolve(response);
    } catch (e) {
      handler.next(DioException(
        requestOptions: requestOptions,
        error: e.toString(),
      ));
    }
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the API constants file
void _generateApiConstantsFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/network/api_constants.dart';
  final content = '''
/// API constants for the application
class ApiConstants {
  /// Base URL for the API
  static const String baseUrl = 'https://api.example.com';
  
  /// API version
  static const String apiVersion = 'v1';
  
  /// Timeout in milliseconds
  static const int timeout = 30000;
  
  /// Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/user/profile';
  static const String products = '/products';
  
  /// Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  /// Get a full endpoint URL
  static String getEndpoint(String endpoint) {
    return '\$baseUrl/\$apiVersion\$endpoint';
  }
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

/// Generates the network info file
void _generateNetworkInfoFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/network/network_info.dart';
  final content = '''
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Interface for checking network connectivity
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Implementation of NetworkInfo using internet_connection_checker
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;
  
  NetworkInfoImpl(this.connectionChecker);
  
  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
}

// /// Generates a sample API service file to show how to use the API client
// void _generateSampleApiServiceFile(HookContext context, String projectName) {
//   final filePath =
//       '$projectName/lib/core/network/services/sample_api_service.dart';
//   final content = '''
// import '../api_client.dart';
// import '../api_constants.dart';
// import '../models/api_response.dart';

// /// Example API service for user-related operations
// class UserApiService {
//   final ApiClient _apiClient;

//   UserApiService() : _apiClient = ApiClient(
//     baseUrl: ApiConstants.baseUrl,
//     timeout: ApiConstants.timeout,
//     useAuth: true,
//   );

//   /// Login with email and password
//   Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
//     try {
//       final response = await _apiClient.post(
//         ApiConstants.login,
//         data: {
//           'email': email,
//           'password': password,
//         },
//       );

//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Register a new user
//   Future<ApiResponse<Map<String, dynamic>>> register({
//     required String email,
//     required String password,
//     required String name,
//   }) async {
//     try {
//       final response = await _apiClient.post(
//         ApiConstants.register,
//         data: {
//           'email': email,
//           'password': password,
//           'name': name,
//         },
//       );

//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Get user profile
//   Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
//     try {
//       final response = await _apiClient.get(ApiConstants.profile);
//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Update user profile
//   Future<ApiResponse<Map<String, dynamic>>> updateProfile({
//     String? name,
//     String? avatar,
//   }) async {
//     try {
//       final response = await _apiClient.put(
//         ApiConstants.profile,
//         data: {
//           if (name != null) 'name': name,
//           if (avatar != null) 'avatar': avatar,
//         },
//       );

//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }
// }

// /// Example API service for product-related operations
// class ProductApiService {
//   final ApiClient _apiClient;

//   ProductApiService() : _apiClient = ApiClient(
//     baseUrl: ApiConstants.baseUrl,
//     timeout: ApiConstants.timeout,
//     useAuth: true,
//   );

//   /// Get all products
//   Future<ApiResponse<List<dynamic>>> getProducts({
//     int page = 1,
//     int limit = 10,
//     String? category,
//   }) async {
//     try {
//       final response = await _apiClient.get(
//         ApiConstants.products,
//         queryParameters: {
//           'page': page,
//           'limit': limit,
//           if (category != null) 'category': category,
//         },
//       );

//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Get a single product by ID
//   Future<ApiResponse<Map<String, dynamic>>> getProductById(String id) async {
//     try {
//       final response = await _apiClient.get('\${ApiConstants.products}/\$id');
//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Create a new product
//   Future<ApiResponse<Map<String, dynamic>>> createProduct({
//     required String name,
//     required double price,
//     required String description,
//     required String category,
//   }) async {
//     try {
//       final response = await _apiClient.post(
//         ApiConstants.products,
//         data: {
//           'name': name,
//           'price': price,
//           'description': description,
//           'category': category,
//         },
//       );

//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Update a product
//   Future<ApiResponse<Map<String, dynamic>>> updateProduct({
// required String id,
//     String? name,
//     double? price,
//     String? description,
//     String? category,
//   }) async {
//     try {
//       final response = await _apiClient.put(
//         '\${ApiConstants.products}/\$id',
//         data: {
//           if (name != null) 'name': name,
//           if (price != null) 'price': price,
//           if (description != null) 'description': description,
//           if (category != null) 'category': category,
//         },
//       );

//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Delete a product
//   Future<ApiResponse<Map<String, dynamic>>> deleteProduct(String id) async {
//     try {
//       final response = await _apiClient.delete('\${ApiConstants.products}/\$id');
//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
// ''';

//   final file = File(filePath);
//   file.writeAsStringSync(content);
//   context.logger.info('Created file: $filePath');
// }

/// Update pubspec.yaml to add network-related dependencies
void _updatePubspecForNetwork(HookContext context, String projectName) {
  final pubspecFile = File('$projectName/pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    context.logger
        .warn('pubspec.yaml not found, skipping adding network dependencies');
    return;
  }

  String content = pubspecFile.readAsStringSync();

  // Check if the dependencies are already added
  if (!content.contains('dio:') || !content.contains('connectivity_plus:')) {
    // Find the end of the dependencies section
    final dependenciesMatch =
        RegExp(r'dependencies:\s*\n((\s{2}[\w_]+:.*\n)+)').firstMatch(content);

    if (dependenciesMatch != null) {
      final endOfDependencies = dependenciesMatch.end;

      // Network dependencies to add
      final networkDependencies = '''

  # Network dependencies
  dio: ^5.3.3
  
  internet_connection_checker: ^3.0.1
''';

      // Insert dependencies
      content = content.substring(0, endOfDependencies) +
          networkDependencies +
          content.substring(endOfDependencies);

      // Write updated content back to file
      pubspecFile.writeAsStringSync(content);
      context.logger.success('Added network dependencies to pubspec.yaml');
    } else {
      context.logger
          .warn('Could not find dependencies section in pubspec.yaml');
    }
  } else {
    context.logger.info('Network dependencies already exist in pubspec.yaml');
  }
}

/// Generate a README file with network layer usage instructions
void _generateNetworkReadmeFile(HookContext context, String projectName) {
  final filePath = '$projectName/lib/core/network/README.md';
  final content = '''
# Network Layer

This network layer provides a robust and flexible way to handle API requests using Dio.

## Features

- 🚀 Built with Dio for powerful HTTP requests
- 🔒 Authentication handling with interceptors
- 🌐 Connectivity monitoring
- 🧩 Easy-to-use API client
- 📝 Comprehensive logging
- ⚠️ Detailed error handling
- 📊 Structured API responses

## Usage

### Basic Setup

Make sure you have the required dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.3.3
  
  internet_connection_checker: ^3.0.1
  freezed_annotation: ^2.4.1
```

### Making API Requests

```dart
// Create an API client instance
final apiClient = ApiClient(
  baseUrl: ApiConstants.baseUrl,
  timeout: ApiConstants.timeout,
  useAuth: true, // Set to false if you don't need authentication
);

// Make a GET request
final response = await apiClient.get<Map<String, dynamic>>('/endpoint');

// Check if the request was successful
if (response.isSuccess) {
  final data = response.data;
  // Process the data
} else {
  final errorMessage = response.errorMessage;
  // Handle the error
}

// Make a POST request with data
final postResponse = await apiClient.post<Map<String, dynamic>>(
  '/endpoint',
  data: {
    'key': 'value',
  },
);
```

### Creating API Services

It's recommended to create service classes for different API endpoints. See the `sample_api_service.dart` file for an example.

```dart
class UserApiService {
  final ApiClient _apiClient;
  
  UserApiService() : _apiClient = ApiClient(
    baseUrl: ApiConstants.baseUrl,
    useAuth: true,
  );
  
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    return await _apiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }
  
  // Add more methods for different endpoints
}
```

### Handling Errors

The network layer includes a comprehensive error handling system using `NetworkExceptions`.

```dart
try {
  final response = await apiService.login('email', 'password');
  
  if (response.isSuccess) {
    // Success handling
  } else {
    // Handle different error types
    final error = response.error;
    final message = NetworkExceptions.getErrorMessage(error!);
    
  }
} catch (e) {

}
```

### Checking Connectivity

The `ConnectivityService` can be used to check and monitor network connectivity.

```dart
final connectivityService = ConnectivityService();

// Check if currently connected
final isConnected = await connectivityService.isConnected();

// Listen for connectivity changes
connectivityService.connectionStatusStream.listen((ConnectivityResult result) {
  if (result == ConnectivityResult.none) {
    print('No internet connection');
  } else {
    print('Connected to the internet');
  }
});
```

## Advanced Features

### Adding Custom Interceptors

You can create custom interceptors for Dio by extending the `Interceptor` class.

```dart
class CustomInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Modify request
    super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Modify response
    super.onResponse(response, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle error
    super.onError(err, handler);
  }
}

// Add it to the API client
final apiClient = ApiClient(...);
apiClient.dio.interceptors.add(CustomInterceptor());
```

### Uploading Files

```dart
final file = File('path/to/file.jpg');
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(
    file.path,
    filename: 'image.jpg',
  ),
  'additional_field': 'value',
});

final response = await apiClient.post<Map<String, dynamic>>(
  '/upload',
  data: formData,
);
```

### Downloading Files

```dart
final response = await apiClient.download(
  'https://example.com/file.pdf',
  '/path/to/save/file.pdf',
  onReceiveProgress: (received, total) {
    final progress = (received / total) * 100;
    print('Download progress: ${'progress'}%');
  },
);

if (response.isSuccess) {
  final filePath = response.data;
  print('File downloaded to: $filePath');
}
```
''';

  final file = File(filePath);
  file.writeAsStringSync(content);
  context.logger.info('Created file: $filePath');
  context.logger.info(
      'Run "flutter pub run build_runner build" to generate freezed files');
}
