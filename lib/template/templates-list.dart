import 'package:flutter/material.dart';
import 'package:pocket_guard/categories/categories-tab-page-view.dart';
import 'package:pocket_guard/components/category_icon_circle.dart';
import 'package:pocket_guard/helpers/alert-dialog-builder.dart';
import 'package:pocket_guard/models/category-type.dart';
import 'package:pocket_guard/models/template.dart';
import 'package:pocket_guard/services/database/database-interface.dart';
import 'package:pocket_guard/services/service-config.dart';

import '../i18n.dart';

class TemplatesList extends StatefulWidget {
  final void Function()? callback;

  final bool? returnResult;

  final CategoryType? passedCategoryType;

  const TemplatesList({
    super.key,
    this.callback,
    this.returnResult,
    this.passedCategoryType,
  });

  @override
  State<TemplatesList> createState() => _TemplatesListState();
}

class _TemplatesListState extends State<TemplatesList> {
  DatabaseInterface database = ServiceConfig.database;
  final _biggerFont = const TextStyle(fontSize: 18.0);
  List<Template?>? _templates = [];

  void _deleteTemplate(int? templateId) async {
    await database.deleteTemplateById(templateId!);
    setState(() {
      _templates?.removeWhere((template) => template!.id == templateId);
    });
  }

  @override
  void initState() {
    super.initState();
    database
        .getTemplates(widget.passedCategoryType)
        .then(
          (templates) => {
            setState(() {
              _templates = templates;
            }),
          },
          onError: (error) => _templates = [],
        );
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = widget.passedCategoryType == CategoryType.expense;
    final title = isExpense ? "Expense Templates" : "Income Templates";
    return Scaffold(
      appBar: AppBar(title: Text(title.i18n)),
      body: Container(
        margin: EdgeInsets.all(15),
        child: _templates!.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/images/no_entry_2.png', width: 200),
                    Text(
                      "No templates yet.".i18n,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22.0),
                    ),
                  ],
                ),
              )
            : _buildTemplates(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CategoryTabPageView(goToTemplateMovementPage: true),
            ),
          );
        },
        tooltip: 'New Template'.i18n,
        child: Semantics(
          identifier: 'new-template-button',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTemplates() {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(thickness: 0.5),
      itemCount: _templates!.length,
      padding: const EdgeInsets.all(6.0),
      itemBuilder: /*1*/ (context, i) {
        return _buildTemplate(_templates![i]!);
      },
    );
  }

  Widget _buildTemplate(Template template) {
    return InkWell(
      onTap: () async {
        if (widget.returnResult != null && widget.returnResult == true) {
          Navigator.pop(context, template);
        }
        if (widget.callback != null) widget.callback!();
      },
      onLongPress: () async {
        final dialog = AlertDialogBuilder("Delete Template".i18n)
            .addSubtitle("Are you sure you want to delete this template?".i18n)
            .addTrueButtonName("Yes".i18n)
            .addFalseButtonName("No".i18n);
        final ok = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return dialog.build(context);
          },
        );

        if (ok) {
          _deleteTemplate(template.id);
        }
      },
      child: ListTile(
        leading: CategoryIconCircle(
          iconEmoji: template.category?.iconEmoji,
          iconDataFromDefaultIconSet: template.category?.icon,
          backgroundColor: template.category?.color,
        ),
        title: Text(template.title!, style: _biggerFont),
      ),
    );
  }
}
