import 'package:flutter/foundation.dart' hide Category;
import 'package:pocket_guard/models/category-type.dart';
import 'package:pocket_guard/models/category.dart';
import 'package:pocket_guard/services/database/database-interface.dart';

class CategoryProvider extends ChangeNotifier {

  final DatabaseInterface database;
  bool _showArchived = false;
  String _title = 'Categories';
  List<Category?> _categories = [];
  bool _isLoading = false;

  List<Category?>? get categories => _categories;

  bool get isLoading => _isLoading;

  String get title => _title;

  bool get showArchived => _showArchived;

  List<Category> get expenseCategories => _categories
      .where((e) => e != null &&
      e.categoryType == CategoryType.expense &&
      e.isArchived == _showArchived)
      .cast<Category>()
      .toList();

  List<Category> get incomeCategories => _categories
      .where((e) => e != null &&
      e.categoryType == CategoryType.income &&
      e.isArchived == _showArchived)
      .cast<Category>()
      .toList();

  CategoryProvider({required this.database});

  void loadAllCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await database.getAllCategories();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleShowArchive() {
    _showArchived = !_showArchived;
    if (_showArchived) {
      _title = 'Archived Categories';
    } else {
      _title = 'Categories';
    }
    notifyListeners();
  }
}
