import 'dart:async';
import 'package:pocket_guard/models/category-type.dart';
import 'package:pocket_guard/models/category.dart';
import 'package:pocket_guard/models/record.dart';
import 'package:pocket_guard/models/record-tag-association.dart';
import 'package:pocket_guard/models/recurrent-record-pattern.dart';
import 'package:pocket_guard/models/template.dart';

abstract class DatabaseInterface {
  /// DatabaseInterface is an interface that the database classes
  /// must implement. It contains basic CRUD methods for categories and records

  /// Category CRUD
  Future<List<Category?>> getAllCategories();
  Future<List<Category?>> getCategoriesByType(CategoryType categoryType);
  Future<Category?> getCategory(String categoryName, CategoryType categoryType);
  Future<int> addCategory(Category? category);
  Future<int> updateCategory(String? existingCategoryName,
      CategoryType? existingCategoryType, Category? updatedCategory);
  Future<void> deleteCategory(String? name, CategoryType? categoryType);
  Future<void> archiveCategory(
      String categoryName, CategoryType categoryType, bool isArchived);
  Future<void> resetCategoryOrderIndexes(List<Category> orderedCategories);

  /// Record CRUD
  Future<Record?> getRecordById(int id);
  Future<void> deleteRecordById(int? id);
  Future<int> addRecord(Record? record);
  Future<int> addTemplate(Template? template);
  Future<void> addRecordsInBatch(List<Record?> records);
  Future<int?> updateRecordById(int? recordId, Record? newRecord);
  Future<DateTime?> getDateTimeFirstRecord();
  Future<List<Record?>> getAllRecords();
  Future<List<Template?>> getTemplates();
  Future<List<Record?>> getAllRecordsInInterval(DateTime? from, DateTime? to);
  Future<Record?> getMatchingRecord(Record? record);
  Future<void> deleteFutureRecordsByPatternId(
      String recurrentPatternId, DateTime startingTime);
  Future<List<String>> suggestedRecordTitles(
      String search, String categoryName);
  Future<List<String>> getTagsForRecord(int recordId);
  Future<Set<String>> getAllTags();
  Future<Set<String>> getRecentlyUsedTags();
  Future<Set<String>> getMostUsedTagsForCategory(
      String categoryName, CategoryType categoryType);
  Future<List<Map<String, dynamic>>> getAggregatedRecordsByTagInInterval(
      DateTime? from, DateTime? to);

  // New methods for record tag associations
  Future<List<RecordTagAssociation>> getAllRecordTagAssociations();
  Future<void> addRecordTagAssociationsInBatch(
      List<RecordTagAssociation>? associations);
  Future<void> renameTag(String old, String newTag);
  Future<void> deleteTag(String tagToDelete);

  // Recurrent Records Patterns CRUD
  Future<List<RecurrentRecordPattern>> getRecurrentRecordPatterns();
  Future<RecurrentRecordPattern?> getRecurrentRecordPattern(
      String? recurrentPatternId);
  Future<void> addRecurrentRecordPattern(RecurrentRecordPattern recordPattern);
  Future<void> deleteRecurrentRecordPatternById(String? recurrentPatternId);
  Future<void> updateRecordPatternById(
      String? recurrentPatternId, RecurrentRecordPattern pattern);

  // Utils
  Future<void> deleteDatabase();
}
