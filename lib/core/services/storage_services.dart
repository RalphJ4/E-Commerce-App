class StorageService {
  StorageService._();

  static double get xpPerLevel => 500;

  static int calculateLevel(int xp) {
    return (xp / xpPerLevel).floor() + 1;
  }

  static double xpProgressInLevel(int xp) {
    final level = calculateLevel(xp);
    final xpInLevel = xp - (level - 1) * xpPerLevel;
    return xpInLevel / xpPerLevel;
  }

  static double xpForNextLevel(int xp) {
    final level = calculateLevel(xp);
    final xpInLevel = xp - (level - 1) * xpPerLevel;
    return xpPerLevel - xpInLevel;
  }

  static String levelTitle(int level) {
    if (level <= 3) return 'Newcomer';
    if (level <= 5) return 'Shopper';
    if (level <= 8) return 'Collector';
    if (level <= 12) return 'Hunter';
    if (level <= 16) return 'Veteran';
    if (level <= 20) return 'Elite';
    return 'Legend';
  }
}
