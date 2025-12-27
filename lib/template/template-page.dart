import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:pocket_guard/categories/categories-tab-page-view.dart';
import 'package:pocket_guard/components/category_icon_circle.dart';
import 'package:pocket_guard/models/category-type.dart';
import 'package:pocket_guard/models/category.dart';
import 'package:pocket_guard/models/template.dart';
import 'package:pocket_guard/services/database/database-interface.dart';
import 'package:pocket_guard/services/service-config.dart';

import '../helpers/records-utility-functions.dart';
import '../i18n.dart';

class TemplatePage extends StatefulWidget {
  final Category? passedCategory;

  const TemplatePage({super.key, this.passedCategory});

  @override
  State<TemplatePage> createState() => _TemplatePageState(this.passedCategory);
}

class _TemplatePageState extends State<TemplatePage> {
  DatabaseInterface database = ServiceConfig.database;
  final TextEditingController titleEditingController = TextEditingController();
  final TextEditingController amountEditingController = TextEditingController();
  Category? passedCategory;
  late Template? template;
  DateTime? lastCharInsertedMillisecond;
  final _formKey = GlobalKey<FormState>();

  _TemplatePageState(this.passedCategory);

  @override
  void initState() {
    super.initState();

    bool overwriteDotValue = getOverwriteDotValue();
    bool overwriteCommaValue = getOverwriteCommaValue();

    template = Template(null, null, passedCategory);

    amountEditingController.addListener(() {
      lastCharInsertedMillisecond = DateTime.now();
      var text = amountEditingController.text.toLowerCase();
      final exp = new RegExp(r'[^\d.,\\+\-\*=/%x]');
      text = text.replaceAll("x", "*");
      text = text.replaceAll(exp, "");

      if (overwriteDotValue) {
        text = text.replaceAll(".", ",");
      }

      if (overwriteCommaValue) {
        text = text.replaceAll(",", ".");
      }
      TextSelection previousSelection = amountEditingController.selection;
      amountEditingController.value = amountEditingController.value.copyWith(
        text: text,
        selection: previousSelection,
        composing: TextRange.empty,
      );
    });
  }

  @override
  void dispose() {
    amountEditingController.dispose();
    titleEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Template')),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(child: _getForm()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            await addOrUpdateRecord();
          }
        },
        tooltip: 'Save'.i18n,
        child: Semantics(
            identifier: 'save-button', child: const Icon(Icons.save)),
      ),
    );
  }

  Widget _getForm() {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 10, 10, 80),
      child: Column(
        children: [
          Form(
            key: _formKey,
            child: Container(
              child: Column(
                children: [
                  _createAmountCard(),
                  _createTitleCard(),
                  _createCategoryCard(),
                  _createAddNoteCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createTitleCard() {
    return Card(
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: TextFormField(
          controller: titleEditingController,
          onChanged: (text) {
            setState(() {
              template!.title = text;
            });
          },
          style: TextStyle(
            fontSize: 22.0,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: EdgeInsets.all(10),
            border: InputBorder.none,
            hintText: template!.category?.name,
            labelText: "Template name".i18n,
          ),
        ),
      ),
    );
  }

  Widget _createCategoryCard() {
    return Card(
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                var selectedCategory = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryTabPageView(),
                  ),
                );
                if (selectedCategory != null) {
                  setState(() {
                    template!.category = selectedCategory;
                    changeRecordValue(
                      amountEditingController.text.toLowerCase(),
                    );
                  });
                }
              },
              child: Semantics(
                identifier: 'category-field',
                child: Row(
                  children: [
                    CategoryIconCircle(
                      iconEmoji: template!.category!.iconEmoji,
                      iconDataFromDefaultIconSet: template!.category!.icon,
                      backgroundColor: template!.category!.color,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(20, 10, 10, 10),
                      child: Text(
                        template!.category!.name!,
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createAddNoteCard() {
    return Card(
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.only(
          bottom: 40.0,
          top: 10,
          right: 10,
          left: 10,
        ),
        child: Semantics(
          identifier: 'note-field',
          child: TextFormField(
            onChanged: (text) {
              setState(() {
                template!.description = text;
              });
            },
            style: TextStyle(
              fontSize: 22.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: "Add a note".i18n,
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(10),
              label: Text("Note"),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createAmountCard() {
    String categorySign =
        template!.category?.categoryType == CategoryType.expense ? "-" : "+";
    return Card(
      elevation: 1,
      child: Container(
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(left: 10, top: 25),
                  child: Text(
                    categorySign,
                    style: TextStyle(fontSize: 32),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Semantics(
                    identifier: 'amount-field',
                    child: TextFormField(
                      controller: amountEditingController,
                      // autofocus: record!.value == null,
                      onChanged: (text) {
                        changeRecordValue(text);
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a value".i18n;
                        }
                        var numericValue = tryParseCurrencyString(value);
                        if (numericValue == null) {
                          return "Not a valid format (use for example: %s)".i18n
                              .fill([
                                getCurrencyValueString(
                                  1234.20,
                                  turnOffGrouping: true,
                                ),
                              ]);
                        }
                        return null;
                      },
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 32.0,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: "0",
                        labelText: "Amount".i18n,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  addOrUpdateRecord() async {
    if (template!.id == null) {
      await database.addTemplate(template);
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void changeRecordValue(String text) {
    var numericValue = tryParseCurrencyString(text);
    if (numericValue != null) {
      numericValue = numericValue.abs();
      if (template!.category!.categoryType == CategoryType.expense) {
        numericValue = numericValue * -1;
      }
      template!.value = numericValue;
    }
  }
}

@Preview(name: 'Template Page')
Widget mySampleText() {
  return TemplatePage();
}
