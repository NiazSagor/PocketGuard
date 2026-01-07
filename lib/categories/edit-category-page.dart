import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emojipicker;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:pocket_guard/categories/notifiers/edit_category_provider.dart';
import 'package:pocket_guard/helpers/alert-dialog-builder.dart';
import 'package:pocket_guard/models/category-type.dart';
import 'package:pocket_guard/models/category.dart';
import 'package:pocket_guard/premium/splash-screen.dart';
import 'package:pocket_guard/premium/util-widgets.dart';
import 'package:pocket_guard/services/database/database-interface.dart';
import 'package:pocket_guard/services/service-config.dart';

import '../i18n.dart';
import '../style.dart';

class EditCategoryPage extends StatefulWidget {
  /// EditCategoryPage is a page containing forms for the editing of a Category object.
  /// EditCategoryPage can take the category object to edit as a constructor parameters
  /// or can create a new Category otherwise.

  final Category? passedCategory;
  final CategoryType? categoryType;

  EditCategoryPage({Key? key, this.passedCategory, this.categoryType})
    : super(key: key);

  @override
  EditCategoryPageState createState() => EditCategoryPageState();
}

class EditCategoryPageState extends State<EditCategoryPage> {
  late EditCategoryProvider _stateProvider;
  late TextEditingController _nameController;
  TextEditingController _controller = TextEditingController();
  late List<IconData?> icons;

  EditCategoryPageState();

  DatabaseInterface database = ServiceConfig.database;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _stateProvider = EditCategoryProvider(
      isPremium: ServiceConfig.isPremium,
      categoryType: widget.categoryType,
      passedCategory: widget.passedCategory,
      database: database,
    );
    icons = _stateProvider.availableIcons;
    _nameController = TextEditingController(text: _stateProvider.category.name);
  }

  @override
  dispose() {
    _nameController.dispose();
    _stateProvider.dispose();
    _controller.dispose();
    super.dispose();
  }

  Widget _getPageSeparatorLabel(String labelText) {
    TextStyle textStyle = TextStyle(
      fontFamily: FontNameDefault,
      fontWeight: FontWeight.w300,
      fontSize: 26.0,
      color: MaterialThemeInstance.currentTheme?.colorScheme.onSurface,
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.fromLTRB(15, 15, 0, 5),
        child: Text(labelText, style: textStyle, textAlign: TextAlign.left),
      ),
    );
  }

  Widget _getIconsGrid() {
    var surfaceContainer = Theme.of(context).colorScheme.surfaceContainer;
    var bottonActionColor = Theme.of(context).colorScheme.surfaceContainerLow;
    var buttonColors = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);
    return Column(
      children: [
        ListenableBuilder(
          listenable: _stateProvider,
          builder: (context, child) {
            return Offstage(
              offstage: !_stateProvider.isEmojiMode,
              child: emojipicker.EmojiPicker(
                textEditingController: _controller,
                config: emojipicker.Config(
                  locale: I18n.locale,
                  height: 256,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: emojipicker.EmojiViewConfig(
                    emojiSizeMax: 28,
                    backgroundColor: surfaceContainer,
                  ),
                  categoryViewConfig: emojipicker.CategoryViewConfig(
                    backgroundColor: bottonActionColor,
                    iconColorSelected: buttonColors,
                  ),
                  bottomActionBarConfig: emojipicker.BottomActionBarConfig(
                    backgroundColor: bottonActionColor,
                    buttonColor: buttonColors,
                    showBackspaceButton: false,
                  ),
                  searchViewConfig: emojipicker.SearchViewConfig(
                    backgroundColor: Colors.white,
                  ),
                ),
                onEmojiSelected: (c, emoji) {
                  _controller.text = emoji.emoji;
                  _stateProvider.selectEmoji(emoji.emoji);
                },
              ),
            );
          },
        ),
        _buildIconGrid(),
      ],
    );
  }

  Widget _buildIconGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            alignment: Alignment.center,
            child: ListenableBuilder(
              listenable: _stateProvider,
              builder: (context, child) {
                return IconButton(
                  icon: ServiceConfig.isPremium
                      ? Text(
                          _stateProvider
                              .currentEmoji, // Display an emoji as text
                          style: TextStyle(
                            fontSize: 24, // Set the emoji size
                          ),
                        )
                      : Stack(
                          children: [
                            Text(
                              _stateProvider.currentEmoji,
                              // Display an emoji as text
                              style: TextStyle(
                                fontSize: 24, // Set the emoji size
                              ),
                            ),
                            !ServiceConfig.isPremium
                                ? Container(
                                    margin: EdgeInsets.fromLTRB(20, 20, 0, 0),
                                    child: getProLabel(labelFontSize: 10.0),
                                  )
                                : Container(),
                          ],
                        ),
                  onPressed: ServiceConfig.isPremium
                      ? () {
                          _stateProvider.toggleEmojiShowing();
                        }
                      : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PremiumSplashScreen(),
                            ),
                          );
                        },
                );
              },
            ),
          );
        }

        return _IconTile(
          index: index,
          iconData: icons[index],
          stateProvider: _stateProvider,
        );
      },
    );
  }

  Widget _buildColorList() {
    return SizedBox(
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: Category.colors.length,
        itemBuilder: (context, index) {
          return _ColorCircle(
            index: index,
            color: Category.colors[index],
            stateProvider: _stateProvider,
          );
        },
      ),
    );
  }

  Widget _createColorsList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 90,
        child: Row(
          children: [
            _createNoColorCircle(),
            _createColorPickerCircle(),
            _buildColorList(),
          ],
        ),
      ),
    );
  }

  Widget _createNoColorCircle() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Stack(
        children: [
          ClipOval(
            child: Material(
              color: Colors
                  .transparent, // Ensure no background color for the Material
              child: InkWell(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Ensure the shape is a circle
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                        alpha: 0.8,
                      ), // Light grey border
                      width: 2.0, // Border width
                    ),
                  ),
                  child: Icon(
                    Icons.not_interested,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 30,
                  ),
                ),
                onTap: () async {
                  _stateProvider.resetColorCircle();
                },
              ),
            ),
          ),
          ServiceConfig.isPremium ? Container() : getProLabel(),
        ],
      ),
    );
  }

  Widget _createCategoryCirclePreview() {
    return Container(
      margin: EdgeInsets.all(10),
      child: ClipOval(
        child: ListenableBuilder(
          listenable: _stateProvider,
          builder: (context, child) {
            return Material(
              color: _stateProvider.category.color, // Button color
              child: InkWell(
                splashColor: _stateProvider.category.color, // InkWell color
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: _stateProvider.category.iconEmoji != null
                      ? Center(
                          // Center the content
                          child: Text(
                            _stateProvider
                                .category
                                .iconEmoji!, // Display the emoji
                            style: TextStyle(
                              fontSize:
                                  30, // Adjust the font size for the emoji
                            ),
                          ),
                        )
                      : Icon(
                          _stateProvider.category.icon, // Fallback to the icon
                          color: _stateProvider.category.color != null
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          size: 30,
                        ),
                ),
                onTap: () {},
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _createColorPickerCircle() {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Stack(
        children: [
          ListenableBuilder(
            listenable: _stateProvider,
            child: const SizedBox(
              width: 70,
              height: 70,
              child: Icon(Icons.colorize, color: Colors.white, size: 30),
            ),
            builder: (context, staticIcon) {
              return ClipOval(
                child: Material(
                  child: InkWell(
                    splashColor: _stateProvider.category.color,
                    onTap: ServiceConfig.isPremium
                        ? openColorPicker
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PremiumSplashScreen(),
                            ),
                          ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: _stateProvider.pickedColor == null
                              ? [
                                  Colors.yellow,
                                  Colors.red,
                                  Colors.indigo,
                                  Colors.teal,
                                ]
                              : [
                                  _stateProvider.pickedColor!,
                                  _stateProvider.pickedColor!,
                                ],
                        ),
                      ),
                      child: staticIcon,
                    ),
                  ),
                ),
              );
            },
          ),
          if (!ServiceConfig.isPremium) getProLabel(),
        ],
      ),
    );
  }

  openColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            padding: EdgeInsets.all(15),
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Choose a color".i18n,
                  style: TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop('dialog');
                  },
                ),
              ],
            ),
          ),
          titlePadding: const EdgeInsets.all(0.0),
          contentPadding: const EdgeInsets.all(0.0),
          content: SingleChildScrollView(
            child: MaterialPicker(
              pickerColor: Category.colors[0]!,
              onColorChanged: (newColor) {
                _stateProvider.setCustomColor(newColor);
              },
              enableLabel: false,
            ),
          ),
        );
      },
    );
  }

  Widget _getTextField() {
    return Expanded(
      child: Form(
        key: _formKey,
        child: Container(
          margin: EdgeInsets.all(10),
          child: TextFormField(
            controller: _nameController,
            onChanged: (text) {
              _stateProvider.updateCategoryName(text);
            },
            validator: (value) {
              if (value!.isEmpty) {
                return "Please enter the category name".i18n;
              }
              return null;
            },
            style: TextStyle(
              fontSize: 22.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: "Category name".i18n,
              errorStyle: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getAppBar() {
    return AppBar(
      title: Text("Edit category".i18n),
      actions: <Widget>[
        Visibility(
          visible: widget.passedCategory != null,
          child: IconButton(
            icon: widget.passedCategory == null
                ? const Icon(Icons.archive)
                : !(widget.passedCategory!.isArchived)
                ? const Icon(Icons.archive)
                : const Icon(Icons.unarchive),
            tooltip: widget.passedCategory == null
                ? ""
                : !(widget.passedCategory!.isArchived)
                ? "Archive".i18n
                : "Unarchive".i18n,
            onPressed: () async {
              bool isCurrentlyArchived = widget.passedCategory!.isArchived;

              String dialogMessage = !isCurrentlyArchived
                  ? "Do you really want to archive the category?".i18n
                  : "Do you really want to unarchive the category?".i18n;

              // Prompt confirmation
              AlertDialogBuilder archiveDialog = AlertDialogBuilder(
                dialogMessage,
              ).addTrueButtonName("Yes".i18n).addFalseButtonName("No".i18n);

              if (!isCurrentlyArchived) {
                archiveDialog.addSubtitle(
                  "Archiving the category you will NOT remove the associated records"
                      .i18n,
                );
              }

              var continueArchivingAction = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return archiveDialog.build(context);
                },
              );

              if (continueArchivingAction) {
                await database.archiveCategory(
                  widget.passedCategory!.name!,
                  widget.passedCategory!.categoryType!,
                  !isCurrentlyArchived,
                );
                Navigator.pop(context);
              }
            },
          ),
        ),
        Visibility(
          visible: widget.passedCategory != null,
          child: PopupMenuButton<int>(
            icon: Icon(Icons.more_vert),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            onSelected: (index) async {
              if (index == 1) {
                // Prompt confirmation
                AlertDialogBuilder deleteDialog =
                    AlertDialogBuilder(
                          "Do you really want to delete the category?".i18n,
                        )
                        .addSubtitle(
                          "Deleting the category you will remove all the associated records"
                              .i18n,
                        )
                        .addTrueButtonName("Yes".i18n)
                        .addFalseButtonName("No".i18n);

                var continueDelete = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return deleteDialog.build(context);
                  },
                );

                if (continueDelete) {
                  database.deleteCategory(
                    widget.passedCategory!.name,
                    widget.passedCategory!.categoryType,
                  );
                  Navigator.pop(context);
                }
              }
            },
            itemBuilder: (BuildContext context) {
              var deleteStr = "Delete".i18n;
              return {deleteStr: 1}.entries.map((entry) {
                return PopupMenuItem<int>(
                  padding: EdgeInsets.all(20),
                  value: entry.value,
                  child: Text(entry.key, style: TextStyle(fontSize: 16)),
                );
              }).toList();
            },
          ),
        ),
      ],
    );
  }

  Widget _getPickColorCard() {
    return Container(
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            _getPageSeparatorLabel("Color".i18n),
            Divider(thickness: 0.5),
            _createColorsList(),
          ],
        ),
      ),
    );
  }

  Widget _getIconPickerCard() {
    return Container(
      child: Container(
        child: Column(
          children: [
            _getPageSeparatorLabel("Icon".i18n),
            Divider(thickness: 0.5),
            _getIconsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _getPreviewAndTitleCard() {
    return Container(
      child: Column(
        children: [
          _getPageSeparatorLabel("Name".i18n),
          Divider(thickness: 0.5),
          Container(
            child: Row(
              children: <Widget>[
                Container(child: _createCategoryCirclePreview()),
                Container(child: _getTextField()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  saveCategory() async {
    if (_formKey.currentState!.validate()) {
      final success = await _stateProvider.saveCategory();
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter a valid name".i18n)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppBar() as PreferredSizeWidget?,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _getPreviewAndTitleCard(),
            _getPickColorCard(),
            _getIconPickerCard(),
            SizedBox(height: 75),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveCategory,
        tooltip: 'Add a new category'.i18n,
        child: const Icon(Icons.save),
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final int index;
  final Color? color;
  final EditCategoryProvider stateProvider;

  const _ColorCircle({
    required this.index,
    required this.color,
    required this.stateProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: ClipOval(
        child: Material(
          color: color,
          child: InkWell(
            onTap: () => stateProvider.selectColor(index),
            child: SizedBox(
              width: 70,
              height: 70,
              child: ListenableBuilder(
                listenable: stateProvider,
                builder: (context, _) {
                  return stateProvider.chosenColorIndex == index
                      ? const Icon(Icons.check, color: Colors.white, size: 24)
                      : const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  final int index;
  final IconData? iconData;
  final EditCategoryProvider stateProvider;

  const _IconTile({
    required this.index,
    required this.iconData,
    required this.stateProvider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: stateProvider,
      builder: (context, _) {
        final bool isSelected = stateProvider.chosenIconIndex == index;
        return IconButton(
          icon: FaIcon(iconData),
          color: isSelected
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          onPressed: () => stateProvider.selectIcon(index),
        );
      },
    );
  }
}
