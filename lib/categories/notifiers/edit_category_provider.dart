import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pocket_guard/models/category-icons.dart';
import 'package:pocket_guard/models/category-type.dart';
import 'package:pocket_guard/models/category.dart';
import 'package:pocket_guard/services/database/database-interface.dart';

class EditCategoryProvider extends ChangeNotifier {

  final DatabaseInterface database;

  late Category _category;
  late List<IconData?> _availableIcons;

  int? _chosenColorIndex;
  int? _chosenIconIndex;
  Color? _pickedColor;
  String _currentEmoji = '😎';
  String _categoryName = "";
  bool _isEmojiMode = false;
  bool _isSaving = false;

  // 2. Immutable Getters
  // We return a "copy" or the reference, but since the fields are
  // accessed via getters, the UI treats them as read-only.
  Category get category => _category;
  List<IconData?> get availableIcons => List.unmodifiable(_availableIcons);

  int? get chosenColorIndex => _chosenColorIndex;
  int? get chosenIconIndex => _chosenIconIndex;
  Color? get pickedColor => _pickedColor;
  String get currentEmoji => _currentEmoji;
  bool get isEmojiMode => _isEmojiMode;
  bool get isSaving => _isSaving;

  EditCategoryProvider({
    Category? passedCategory,
    CategoryType? categoryType,
    required bool isPremium,
    required this.database,
  }) {
    _initialize(passedCategory, categoryType, isPremium);
  }

  void _initialize(Category? passed, CategoryType? type, bool isPremium) {
    // Set available icons based on premium status
    _availableIcons = isPremium
        ? CategoryIcons.pro_category_icons
        : CategoryIcons.free_category_icons;

    if (passed == null) {
      // Initialize New Category
      _category = Category(null);
      _category.color = Category.colors[0];
      _category.icon = FontAwesomeIcons.question;
      _category.iconCodePoint = category.icon!.codePoint;
      _category.categoryType = type ?? CategoryType.expense;
    } else {
      // Clone existing category (assuming you have a copy method or fromMap)
      _category = Category.fromMap(passed.toMap());
      _categoryName = passed.name!;
    }

    // Determine initial Icon/Emoji state
    if (category.icon == null && category.iconEmoji != null) {
      _chosenIconIndex = -1;
      _currentEmoji = category.iconEmoji!;
      _isEmojiMode = true;
    } else {
      _chosenIconIndex = availableIcons.indexOf(category.icon);
      _isEmojiMode = false;
    }

    // Determine initial Color state
    _chosenColorIndex = Category.colors.indexOf(category.color);
    if (chosenColorIndex == -1) {
      _pickedColor = category.color;
    }
    if (chosenColorIndex == -2) {
      _pickedColor = null;
    }
  }

  // --- ACTIONS ---

  void updateCategoryName(String name) {
    _categoryName = name;
  }

  void selectIcon(int index) {
    _isEmojiMode = false; // hide emoji picker
    _category.icon = availableIcons[index];
    _category.iconCodePoint = category.icon?.codePoint;
    _category.iconEmoji = null;
    _chosenIconIndex = index;
    notifyListeners();
  }

  void selectColor(int index) {
    _category.color = Category.colors[index];
    _chosenColorIndex = index;
    // pickedColor = null; // Reset custom color if a preset is picked
    notifyListeners();
  }

  void resetColorCircle() {
    _category.color = null;
    _chosenColorIndex = -2;
    _pickedColor = null;
    notifyListeners();
  }

  Future<bool> saveCategory() async {
    _isSaving = true;
    notifyListeners();

    try {
      if (_category.name == null) {
        _category.name = _categoryName;
        await database.addCategory(category);
      } else {
        String? existingName = _category.name;
        var existingType = _category.categoryType;
        _category.name = _categoryName;
        await database.updateCategory(existingName, existingType, category);
      }
      return true;
    } catch (e) {
      debugPrint("Save Error: $e");
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // for premium users
  void setCustomColor(Color color) {
    _category.color = color;
    _chosenColorIndex = -1;
    _pickedColor = color;
    notifyListeners();
  }

  // for premium users
  void selectEmoji(String emoji) {
    _isEmojiMode = false;
    _category.iconEmoji = emoji;
    _category.icon = null;
    _category.iconCodePoint = null;
    _currentEmoji = emoji;
    _chosenIconIndex = -1;
    _currentEmoji = emoji;
    notifyListeners();
  }

  // for premium users
  void toggleEmojiShowing() {
    _isEmojiMode = !_isEmojiMode;
    notifyListeners();
  }
}
