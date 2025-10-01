// ignore_for_file: public_member_api_docs

import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';

import 'ez_database_connection_handler.dart';
import 'order.dart';

abstract class EzRequestHandler<T> with EzDatabaseConnectionHandler<T> {
  EzRequestHandler({required this.requestContext});

  final RequestContext requestContext;

  String? get authenticationToken =>
      requestContext.request.headers['authorization'];

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
    return handleUnimplementedMethod();
  }

  Future<Response> handleGet() async {
    return handleUnimplementedMethod();
  }

  Future<Response> handlePut() async {
    return handleUnimplementedMethod();
  }

  Future<Response> handleDelete() async {
    return handleUnimplementedMethod();
  }

  Future<Response> handlePatch() async {
    return handleUnimplementedMethod();
  }

  Response handleUnimplementedMethod() {
    return Response(
      body: jsonEncode({'details': 'Method not allowed'}),
      statusCode: 405,
    );
  }

  Future<Response> handleResponse({bool requiresAuthentication = true}) async {
    if (requiresAuthentication) {
      final auth = await isAuthorized();
      if (!auth) return _notAuthorized;
    }

    try {
      //await openDatabaseConnection();
    } catch (e) {
      return _couldNotConnectResponse;
    }

    if (isConnectedToDatabase) {
      return _handleMethod()
          .catchError((onError, st) async {
            //await closeDatabaseConnection();
            return errorResponse(onError, st);
          })
          .whenComplete(() async {
            //await closeDatabaseConnection();
          })
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () async {
              //await closeDatabaseConnection();
              return _connectionTimeout;
            },
          );
    } else {
      // Close connection
      return handleCouldNotConnectResponse();
    }
  }

  Future<Response> handleCouldNotConnectResponse() async {
    //await closeDatabaseConnection();
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

  Response errorResponse(dynamic e, dynamic st) => _defaultErrorResponse(e);

  Response _defaultErrorResponse(dynamic e) => Response(
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
