import 'dart:async';

mixin EzDatabaseConnectionHandler<T> {
  T get database;

  bool get isConnectedToDatabase;

  FutureOr<bool> isAuthorized();

  /*  Future<void> openDatabaseConnection();

  Future<void> closeDatabaseConnection();*/
}
