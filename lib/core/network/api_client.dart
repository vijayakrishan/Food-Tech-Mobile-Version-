import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';

class ApiClient {
  late final Dio _dio;
  void Function()? onUnauthorized;

  ApiClient({this.onUnauthorized}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 25),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Keep base URL synced with any runtime host/port updates
          options.baseUrl = ApiConfig.baseUrl;

          final token = await SecureStorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await SecureStorageService.clearAuth();
            onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // GET
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  // POST
  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  // PUT
  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  // DELETE
  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'An unexpected error occurred: $e');
    }
  }

  ApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Unable to connect to the server at ${ApiConfig.baseUrl}. Please check your connection and server configuration.',
        statusCode: null,
      );
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode;
      String message = 'Request failed with status $statusCode';

      if (response.data is Map<String, dynamic>) {
        final map = response.data as Map<String, dynamic>;
        if (map.containsKey('message') && map['message'] != null) {
          message = map['message'].toString();
        } else if (map.containsKey('error') && map['error'] != null) {
          message = map['error'].toString();
        }
      }

      if (statusCode == 401) {
        return ApiException(
          message: message.isNotEmpty ? message : 'Invalid credentials or session expired.',
          statusCode: 401,
          details: response.data,
        );
      } else if (statusCode == 403) {
        return ApiException(
          message: 'Access denied: You do not have permission to perform this action.',
          statusCode: 403,
          details: response.data,
        );
      } else if (statusCode == 404) {
        return ApiException(
          message: message.isNotEmpty ? message : 'The requested resource was not found.',
          statusCode: 404,
          details: response.data,
        );
      } else if (statusCode != null && statusCode >= 500) {
        return ApiException(
          message: 'Server error: $message',
          statusCode: statusCode,
          details: response.data,
        );
      }

      return ApiException(
        message: message,
        statusCode: statusCode,
        details: response.data,
      );
    }

    return ApiException(
      message: error.message ?? 'A network communication error occurred.',
      statusCode: null,
    );
  }
}
