import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pocket_guard/categories/edit-category-page.dart';
import 'package:pocket_guard/categories/notifiers/category_provider.dart';
import 'package:pocket_guard/models/category-type.dart';
import 'package:pocket_guard/services/database/database-interface.dart';
import 'package:pocket_guard/services/service-config.dart';

import '../i18n.dart';
import 'categories-list.dart';

class TabCategories extends StatefulWidget {
  /// The category page that you can select from the bottom navigation bar.
  /// It contains two tab, showing the categories for expenses and categories
  /// for incomes. It has a single Floating Button that, dependending from which
  /// tab you clicked, it open the EditCategory page passing the selected Category type.

  TabCategories({Key? key}) : super(key: key);

  @override
  TabCategoriesState createState() => TabCategoriesState();
}

class TabCategoriesState extends State<TabCategories>
    with SingleTickerProviderStateMixin {
  DatabaseInterface database = ServiceConfig.database;
  TabController? _tabController;
  late CategoryProvider _categoryProvider;

  @override
  void initState() {
    super.initState();
    _categoryProvider = CategoryProvider(database: database);
    _categoryProvider.loadAllCategories();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  dispose() {
    _tabController!.dispose();
    _categoryProvider.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TabCategories oldWidget) {
    super.didUpdateWidget(oldWidget);
    _categoryProvider.loadAllCategories();
  }

  refreshCategories() async {
    _categoryProvider.loadAllCategories();
  }

  refreshCategoriesAndHighlightsTab(int destionationTabIndex) async {
    _categoryProvider.loadAllCategories();
    await Future.delayed(Duration(milliseconds: 50));
    if (_tabController!.index != destionationTabIndex) {
      _tabController!.animateTo(destionationTabIndex);
    }
  }

  onTabChange() async {
    await refreshCategories();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "Expenses".i18n.toUpperCase()),
              Tab(text: "Income".i18n.toUpperCase()),
            ],
          ),
          title: ListenableBuilder(
            listenable: _categoryProvider,
            builder: (context, child) {
              return Text(_categoryProvider.title.i18n);
            },
          ),
          actions: [
            ListenableBuilder(
              listenable: _categoryProvider,
              builder: (context, child) {
                var archivedOptionStr = _categoryProvider.showArchived
                    ? "Show active categories".i18n
                    : "Show archived categories".i18n;
                return PopupMenuButton<int>(
                  icon: Icon(Icons.more_vert),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  onSelected: (index) {
                    if (index == 1) {
                      _categoryProvider.toggleShowArchive();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return {archivedOptionStr: 1}.entries.map((entry) {
                      return PopupMenuItem<int>(
                        padding: EdgeInsets.all(20),
                        value: entry.value,
                        child: Text(entry.key, style: TextStyle(fontSize: 16)),
                      );
                    }).toList();
                  },
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ListenableBuilder(
              listenable: _categoryProvider,
              builder: (context, child) {
                if (_categoryProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return CategoriesList(
                  _categoryProvider.expenseCategories,
                  callback: refreshCategories,
                );
              },
            ),

            ListenableBuilder(
              listenable: _categoryProvider,
              builder: (context, child) {
                if (_categoryProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return CategoriesList(
                  _categoryProvider.incomeCategories,
                  callback: refreshCategories,
                );
              },
            ),
          ],
        ),
        floatingActionButton: SpeedDial(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          spacing: 20,
          childrenButtonSize: const Size(65, 65),
          animatedIcon: AnimatedIcons.menu_close,
          childPadding: EdgeInsets.fromLTRB(8, 8, 8, 8),
          children: [
            SpeedDialChild(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Icon(FontAwesomeIcons.moneyBillWave),
              label: "Add a new 'Expense' category".i18n,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditCategoryPage(categoryType: CategoryType.expense),
                  ),
                );
                await refreshCategoriesAndHighlightsTab(0);
              },
            ),
            SpeedDialChild(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Icon(FontAwesomeIcons.handHoldingDollar),
              label: "Add a new 'Income' category".i18n,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditCategoryPage(categoryType: CategoryType.income),
                  ),
                );
                await refreshCategoriesAndHighlightsTab(1);
              },
            ),
          ],
        ),
      ),
    );
  }
}
