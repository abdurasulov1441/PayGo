import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:taksi/app/router.dart';
import 'package:taksi/services/db/cache.dart';
import 'package:taksi/services/utils/errors.dart';

final class RequestHelper {
  final logger = Logger();
  final baseUrl = 'https://paygo.app-center.uz';
  final dio = Dio();

  void logMethod(String message) {
    log(message);
  }

  String get token {
    final token = cache.getString("user_token");

    if (token != null) return token;
    // router.go(Routes.loginPage);
    throw UnauthenticatedError();
  }

  Future<dynamic> get(
    String path, {
    bool log = false,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      baseUrl + path,
      cancelToken: cancelToken,
    );

    if (log) {
      logger.d([
        'GET',
        path,
        response.statusCode,
        response.statusMessage,
        response.data,
      ]);

      logMethod(jsonEncode(response.data));
    }

    return response.data;
  }

  Future<dynamic> getNews(
    String path, {
    bool log = false,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      "https://qbb.uz$path",
      cancelToken: cancelToken,
    );

    if (log) {
      logger.d([
        'GET',
        path,
        response.statusCode,
        response.statusMessage,
        response.data,
      ]);

      logMethod(jsonEncode(response.data));
    }

    return response.data;
  }

  Future<dynamic> getHeaderStatistic(String path,
      {bool log = false,
      CancelToken? cancelToken,
      Map<String, dynamic>? headers}) async {
    final options = Options(headers: headers);

    final response = await dio.get(
      "$baseUrl$path",
      cancelToken: cancelToken,
      options: options,
    );

    if (log) {
      logger.d([
        'GET',
        path,
        response.statusCode,
        response.statusMessage,
        response.data,
      ]);

      logMethod(jsonEncode(response.data));
    }

    return response.data;
  }

  Future<dynamic> getWithAuth(
    String path, {
    bool log = false,
    CancelToken? cancelToken,
  }) async {
    try {
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await dio.get(
        baseUrl + path,
        cancelToken: cancelToken,
        options: Options(
          headers: headers,
        ),
      );

      if (log) {
        logger.d([
          'GET',
          path,
          headers,
          response.statusCode,
          response.statusMessage,
          response.data,
        ]);

        logMethod(jsonEncode(response.data));
      }

      return response.data;
    } on DioException catch (e) {
      logger.d([
        'GET',
        path,
        e.response?.statusCode,
        e.response?.statusMessage,
        e.response?.data,
      ]);

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        router.go(Routes.roleSelect);
        throw UnauthenticatedError();
      }

      return e.response?.data;
    } catch (_) {
      rethrow;
    }
  }

  Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    bool log = false,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.post(
        baseUrl + path,
        cancelToken: cancelToken,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (log) {
        logger.d([
          'POST',
          path,
          body,
          response.statusCode,
          response.statusMessage,
          response.data,
        ]);

        logMethod(jsonEncode(response.data));
      }

      return response.data;
    } on DioException catch (e) {
      logger.d([
        'POST',
        path,
        body,
        e.response?.statusCode,
        e.response?.statusMessage,
        e.response?.data,
      ]);

      if (e.response?.statusCode == 400) {
        throw e.response?.data['response']['message'];
      }

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        router.go(Routes.roleSelect);
        if (path == "/services/platon-core/api/mobile/v1/auth/legal/register") {
          router.go(Routes.roleSelect);
          throw Unauthenticated();
        }
        throw UnauthenticatedError();
      }

      throw e.response?.data['message'];
    } catch (_) {
      rethrow;
    }
  }

  Future<dynamic> postWithAuth(
    String path,
    Map<String, dynamic> body, {
    bool log = false,
    CancelToken? cancelToken,
    String? languageCode,
  }) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final response = await dio.post(
        baseUrl + path,
        cancelToken: cancelToken,
        data: body,
        options: Options(
          headers: headers,
        ),
      );

      if (log) {
        logger.d([
          'POST',
          path,
          headers,
          body,
          response.statusCode,
          response.statusMessage,
          response.data,
        ]);

        logMethod(jsonEncode(response.data));
      }

      return response.data;
    } on DioException catch (e) {
      logger.d([
        'POST',
        path,
        headers,
        body,
        e.response?.statusCode,
        e.response?.statusMessage,
        e.response?.data,
        languageCode
      ]);

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        router.go(Routes.roleSelect);
        throw UnauthenticatedError();
      }

      switch (languageCode) {
        case 'ru':
          throw e.response?.data['translates']['ru'];
        case 'uz':
          throw e.response?.data['translates']['uz'];
        case 'uk':
          throw e.response?.data['translates']['oz'];
        default:
          throw e.response?.data['message'];
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<dynamic> put(
    String path,
    Map<String, dynamic> body, {
    bool log = false,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.put(
        baseUrl + path,
        cancelToken: cancelToken,
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (log) {
        logger.d([
          'PUT',
          path,
          body,
          response.statusCode,
          response.statusMessage,
          response.data,
        ]);
      }

      return response.data;
    } on DioException catch (e) {
      logger.d([
        'POST',
        path,
        body,
        e.response?.statusCode,
        e.response?.statusMessage,
        e.response?.data,
      ]);
      return e.response?.data;
    } catch (_) {
      rethrow;
    }
  }

  Future<dynamic> putWithAuth(
    String path,
    Map<String, dynamic> body, {
    bool log = false,
    CancelToken? cancelToken,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'lang': 'uz',
      // 'Authorization': 'Basic OTk4OTAwOTYxNzA0OjEyMzQ1Njc4OQ==',
    };

    try {
      final response = await dio.put(
        baseUrl + path,
        cancelToken: cancelToken,
        data: body,
        options: Options(
          headers: headers,
        ),
      );

      if (log) {
        logger.d([
          'PUT',
          path,
          headers,
          body,
          response.statusCode,
          response.statusMessage,
          response.data,
        ]);
      }

      return response.data;
    } on DioException catch (e) {
      logger.d([
        'PUT',
        path,
        headers,
        body,
        e.response?.statusCode,
        e.response?.statusMessage,
        e.response?.data,
      ]);

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        router.go(Routes.roleSelect);
        throw UnauthenticatedError();
      }

      throw e.response?.data['message'];
    } catch (_) {
      rethrow;
    }
  }

  Future<dynamic> delete(
    String path, {
    bool log = false,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.delete(
        baseUrl + path,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (log) {
        logger.d([
          'DELETE',
          path,
          response.statusCode,
          response.statusMessage,
          response.data,
        ]);
      }

      return response.data;
    } on DioException catch (e) {
      logger.d([
        'DELETE',
        path,
        e.response?.statusCode,
        e.response?.statusMessage,
        e.response?.data,
      ]);
      return e.response?.data;
    } catch (_) {
      rethrow;
    }
  }

  Future<dynamic> deleteWithAuth(
    String path, {
    bool log = false,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.delete(
        baseUrl + path,
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (log) {
        logger.d([
          'DELETE',
          path,
          response.statusCode,
          response.statusMessage,
          response.data,
        ]);
      }

      return response.data;
    } on DioException catch (e) {
      logger.d([
        'DELETE',
        path,
        e.response?.statusCode,
        e.response?.statusMessage,
        e.response?.data,
      ]);

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        router.go(Routes.roleSelect);
        throw UnauthenticatedError();
      }

      return e.response?.data;
    } catch (_) {
      rethrow;
    }
  }
}

final requestHelper = RequestHelper();
