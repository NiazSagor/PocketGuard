import 'package:flutter/material.dart';
import 'package:pocket_guard/components/category_icon_circle.dart';
import 'package:pocket_guard/models/category.dart';

import '../i18n.dart';
import 'edit-category-page.dart';

class CategoriesList extends StatelessWidget {
  /// CategoriesList fetches the categories of a given categoryType (input parameter)
  /// and renders them using a vertical ListView.

  final _biggerFont = const TextStyle(fontSize: 18.0);
  final List<Category?> categories;
  final void Function()? callback;

  const CategoriesList(this.categories, {super.key, this.callback});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      child: categories.isEmpty
          ? Column(
              children: <Widget>[
                Image.asset('assets/images/no_entry_2.png', width: 200),
                Text(
                  "No categories yet.".i18n,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22.0),
                ),
              ],
            )
          : _buildCategories(context),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(thickness: 0.5),
      itemCount: categories.length,
      padding: const EdgeInsets.all(6.0),
      itemBuilder: /*1*/ (context, i) {
        return _buildCategory(categories[i]!, context);
      },
    );
  }

  Widget _buildCategory(Category category, BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCategoryPage(passedCategory: category),
          ),
        );
        if (callback != null) callback!();
      },
      child: Opacity(
        opacity: category.isArchived ? 0.8 : 1.0, // Dim the tile
        child: ListTile(
          leading: CategoryIconCircle(
            iconEmoji: category.iconEmoji,
            iconDataFromDefaultIconSet: category.icon,
            backgroundColor: category.color,
            overlayIcon: category.isArchived ? Icons.archive : null,
          ),
          title: Text(category.name!, style: _biggerFont),
        ),
      ),
    );
  }
}
