class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class FirebaseException implements Exception {
  final String message;
  const FirebaseException(this.message);
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);
}
