import 'dart:async';

mixin EzDatabaseConnectionHandler<T> {
  late final T database;

  bool get isConnectedToDatabase;

  FutureOr<bool> isAuthorized();

  Future<void> openDatabaseConnection();

  Future<void> closeDatabaseConnection();
}
