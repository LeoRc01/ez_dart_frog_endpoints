// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import 'ez_database_connection_handler.dart';
import 'order.dart';

abstract class EzRequestHandler with EzDatabaseConnectionHandler {
  EzRequestHandler({required this.requestContext});

  final RequestContext requestContext;

  String? get authenticationToken =>
      requestContext.request.headers['authentication'];

  final int _defaultLimit = 100;
  final int _defaultOffset = 0;
  final Order _defaultOrder = Order.desc;

  Order get order {
    final orderString = requestContext.request.uri.queryParameters['order'];
    if (orderString == null) {
      return _defaultOrder;
    }
    try {
      return Order.fromName(orderString);
    } catch (e) {
      return _defaultOrder;
    }
  }

  int get limit {
    final limitString = requestContext.request.uri.queryParameters['limit'];
    if (limitString == null) {
      return _defaultLimit;
    }
    try {
      return int.parse(limitString);
    } catch (e) {
      return _defaultLimit;
    }
  }

  int get offset {
    final offsetString = requestContext.request.uri.queryParameters['offset'];
    if (offsetString == null) {
      return _defaultOffset;
    }
    try {
      return int.parse(offsetString);
    } catch (e) {
      return _defaultOffset;
    }
  }

  Future<Response> handlePost() async {
    return _handleUnimplementedMethod();
  }

  Future<Response> handleGet() async {
    return _handleUnimplementedMethod();
  }

  Future<Response> handlePut() async {
    return _handleUnimplementedMethod();
  }

  Future<Response> handleDelete() async {
    return _handleUnimplementedMethod();
  }

  Future<Response> handlePatch() async {
    return _handleUnimplementedMethod();
  }

  Response _handleUnimplementedMethod() {
    return Response(
      body: jsonEncode({'details': 'Method not allowed'}),
      statusCode: 405,
    );
  }

  Future<Response> handleResponse({bool requiresToken = true}) async {
    /*
    if (requiresToken) {
      FirebaseVerifyToken.projectId = 'intech-52fc1';

      final isValid = authenticationToken != null
          ? await FirebaseVerifyToken.verify(authenticationToken!)
          : false;

      if (!isValid) {
        return _notAuthorized;
      }
    }
 */

    try {
      await openDatabaseConnection();
    } catch (e) {
      return _couldNotConnectResponse;
    }

    if (isConnectedToDatabase) {
      if (!isAuthorized) {
        return _notAuthorized;
      }

      return _handleMethod()
          .catchError((onError, st) async {
            await closeDatabaseConnection();
            return _errorResponse(onError);
          })
          .whenComplete(() async {
            await closeDatabaseConnection();
          })
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () async {
              await closeDatabaseConnection();
              return _connectionTimeout;
            },
          );
    } else {
      // Close connection
      return handleCouldNotConnectResponse();
    }
  }

  Future<Response> handleCouldNotConnectResponse() async {
    await closeDatabaseConnection();
    return _couldNotConnectResponse;
  }

  Future<Response> _handleMethod() async {
    switch (requestContext.request.method) {
      case HttpMethod.get:
        return handleGet.call();
      case HttpMethod.delete:
        return handleDelete.call();
      case HttpMethod.post:
        return handlePost.call();
      case HttpMethod.put:
        return handlePut.call();
      case HttpMethod.patch:
        return handlePatch.call();
      case HttpMethod.head:
      case HttpMethod.options:
        throw UnimplementedError();
    }
  }

  Response _errorResponse(dynamic e) => Response(
    statusCode: 404,
    body: jsonEncode({
      'details': 'Something went wrong.',
      'message': e.toString(),
    }),
  );

  final _connectionTimeout = Response(
    statusCode: 408,
    body: jsonEncode({'details': 'Request timeout.'}),
  );

  final _notAuthorized = Response(
    statusCode: 401,
    body: jsonEncode({'details': 'Not authorized.'}),
  );

  final _couldNotConnectResponse = Response(
    statusCode: 401,
    body: jsonEncode({'details': 'Could not connect to Database.'}),
  );
}
