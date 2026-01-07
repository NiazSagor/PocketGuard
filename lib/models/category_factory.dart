import 'package:flutter/cupertino.dart';
import 'package:pocket_guard/models/category.dart';

class CategoryFactory {
  static final Map<String, Category> _cache = {};

  static Category getOrCreate(Map<String, dynamic> map) {
    final String name = map['name'] ?? 'Unknown';
    final int typeIndex = map['category_type'] ?? 0;
    final String key = "${name}_$typeIndex";

    if (!_cache.containsKey(key)) {
      _cache[key] = Category.fromMap(map);
    } else {
      final existing = _cache[key]!;
      final lastUsed = map['last_used'] as int?;
      final lastUsedDateTime = lastUsed != null
          ? _parseLastTimeUsedDateTime(lastUsed)
          : null;

      bool shouldUpdateExisting = _shouldUpdate(existing, lastUsedDateTime);

      if (shouldUpdateExisting) {
        existing.color = _parseColor(map['color']) ?? existing.color;
        existing.recordCount = (map['record_count'] != null)
            ? map['record_count'] as int
            : existing.recordCount;
        existing.sortOrder = (map['sort_order'] != null)
            ? map['sort_order'] as int
            : existing.sortOrder;
        existing.isArchived = (map['is_archived'] != null)
            ? (map['is_archived'] as int) == 1
            : existing.isArchived;
        existing.iconCodePoint = map['icon'] ?? existing.iconCodePoint;
        existing.iconEmoji = map['icon_emoji'] ?? existing.iconEmoji;
        existing.lastUsed = lastUsedDateTime;
      }
    }
    return _cache[key]!;
  }

  // UPDATE LOGIC:
  // 1. If the database has a timestamp and memory doesn't.
  // 2. OR if the database timestamp is newer.
  static bool _shouldUpdate(Category existing, DateTime? lastUsedDateTime) {
    return (existing.lastUsed == null && lastUsedDateTime != null) ||
        (lastUsedDateTime != null &&
            existing.lastUsed != null &&
            lastUsedDateTime.isAfter(existing.lastUsed!));
  }

  static DateTime? _parseLastTimeUsedDateTime(int time) {
    return DateTime.fromMillisecondsSinceEpoch(time);
  }

  static Color? _parseColor(String? serializedColor) {
    if (serializedColor == null) return null;
    List<int> components = serializedColor.split(":").map(int.parse).toList();
    return Color.fromARGB(
      components[0],
      components[1],
      components[2],
      components[3],
    );
  }

  static void clear() => _cache.clear();
}
