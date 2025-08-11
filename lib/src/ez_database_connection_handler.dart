mixin EzDatabaseConnectionHandler<T> {
  late final T database;

  bool get isConnectedToDatabase;

  bool get isAuthorized;

  Future<void> openDatabaseConnection();

  Future<void> closeDatabaseConnection();
}
