import 'package:pocket_guard/models/category.dart';
import 'package:pocket_guard/models/model.dart';

class Template extends Model {
  int? id;
  double? value;
  String? title;
  String? description;
  Category? category;

  Template(
    this.value,
    this.title,
    this.category, {
    this.id,
    this.description,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'category_name': category?.name,
      'category_type': category?.categoryType?.index,
      'description': description,
    };
  }

  static Template fromMap(Map<String, dynamic> map) {
    return Template(
      map['value'],
      map['title'],
      map['category'],
      id: map['id'],
      description: map['description'],
    );
  }
}
