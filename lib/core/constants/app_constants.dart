class AppConstants {
  static const String appName = 'ShopEase';
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String reviewsCollection = 'reviews';
  static const String avatarsPath = 'avatars';
  static const String productsPath = 'products';

  static const int xpPerCartItem = 10;
  static const int xpPerOrder = 50;
  static const int xpFirstOrderOfDay = 100;
  static const int xpPerLevel = 500;
  static const int maxAvatarSize = 2 * 1024 * 1024;

  static List<String> categories = [
    'Electronics',
    'Fashion',
    'Food',
    'Gaming',
    'Books',
  ];

  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
}
