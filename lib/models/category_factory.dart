import 'package:pocket_guard/models/category.dart';

class CategoryFactory {
   static final Map<String, Category> _cache = {};

  static Category getOrCreate(Map<String, dynamic> map) {
    final String name = map['name'] ?? 'Unknown';
    final int typeIndex = map['category_type'] ?? 0;
    final String key = "${name}_$typeIndex";

    if (!_cache.containsKey(key)) {
      _cache[key] = Category.fromMap(map);
    }
    return _cache[key]!;
  }

  static void clear() => _cache.clear();
}
