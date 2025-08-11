mixin EzDatabaseConnectionHandler<T> {
  T get database;

  bool get isConnectedToDatabase;

  bool get isAuthorized;

  Future<void> openDatabaseConnection();

  Future<void> closeDatabaseConnection();
}
