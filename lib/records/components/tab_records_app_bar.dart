import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pocket_guard/records/components/styled_action_buttons.dart';
import 'package:pocket_guard/records/components/styled_popup_menu_button.dart';

import '../../helpers/records-utility-functions.dart';
import '../controllers/tab_records_controller.dart';

class TabRecordsAppBar extends StatelessWidget {
  final TabRecordsController controller;
  final bool isAppBarExpanded;
  final VoidCallback onDatePickerPressed;
  final VoidCallback onStatisticsPressed;
  final VoidCallback onSearchPressed;
  final Function(int) onMenuItemSelected;

  const TabRecordsAppBar({
    Key? key,
    required this.controller,
    required this.isAppBarExpanded,
    required this.onDatePickerPressed,
    required this.onStatisticsPressed,
    required this.onSearchPressed,
    required this.onMenuItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final headerFontSize = controller.getHeaderFontSize();
    // final headerPaddingBottom = controller.getHeaderPaddingBottom();
    final canShiftBack = controller.canShiftBack();
    final canShiftForward = controller.canShiftForward();

    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 2,
      backgroundColor: Theme.of(context).primaryColor,
      actions: _buildActions(),
      pinned: true,
      titleSpacing: 0,
      expandedHeight: null,
      title: _buildCompactNavigation(canShiftBack, canShiftForward),
    );
  }

  Widget _buildCompactNavigation(bool canShiftBack, bool canShiftForward) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canShiftBack) _buildShiftButton(Icons.chevron_left, -1),

        GestureDetector(
          onTap: onDatePickerPressed,
          child: Text(
            controller.header,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              letterSpacing: -0.5,
            ),
          ),
        ),

        if (canShiftForward) _buildShiftButton(Icons.chevron_right, 1),
      ],
    );
  }

  Widget _buildShiftButton(IconData icon, int offset) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(), // Removes default 48px padding
      icon: Icon(icon, color: Colors.white),
      onPressed: () => controller.shiftMonthOrYear(offset),
    );
  }

  List<Widget> _buildActions() {
    const double actionButtonScale = 1.0;

    return <Widget>[
      StyledActionButton(
        icon: Icons.donut_small,
        onPressed: onStatisticsPressed,
        semanticsId: 'statistics',
        scaleFactor: actionButtonScale,
      ),
      StyledActionButton(
        icon: Icons.search,
        onPressed: onSearchPressed,
        semanticsId: 'search-button',
        scaleFactor: actionButtonScale,
      ),
      StyledPopupMenuButton(
        onSelected: onMenuItemSelected,
        scaleFactor: actionButtonScale,
      ),
    ];
  }

  Widget _buildTitle(
    double headerFontSize,
    bool canShiftBack,
    bool canShiftForward,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (isAppBarExpanded && canShiftBack)
          _buildShiftButton(Icons.arrow_left, -1),
        Expanded(
          child: Semantics(
            identifier: 'date-text',
            child: Text(
              controller.header,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: TextStyle(color: Colors.white, fontSize: headerFontSize),
            ),
          ),
        ),
        if (isAppBarExpanded && canShiftForward)
          _buildShiftButton(Icons.arrow_right, 1),
      ],
    );
  }

  // Widget _buildShiftButton(IconData icon, int direction) {
  //   return SizedBox(
  //     height: 30,
  //     width: 30,
  //     child: IconButton(
  //       icon: Icon(icon, color: Colors.white, size: 24),
  //       onPressed: () => controller.shiftMonthOrYear(direction),
  //       padding: EdgeInsets.zero,
  //       constraints: const BoxConstraints(),
  //     ),
  //   );
  // }

  Widget _buildBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // The Seasonal Image
        Image(image: getBackgroundImage(), fit: BoxFit.cover),
        // The Gradient Scrim (Darkens top and bottom for readability)
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black54, // Darker at the top for Action buttons
                Colors.transparent,
                Colors.transparent,
                Colors.black87, // Darkest at the bottom for the Month Name
              ],
              stops: [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        ),
      ],
    );
  }

  EdgeInsets _getTitlePadding(
    double headerPaddingBottom,
    bool canShiftBack,
    bool canShiftForward,
  ) {
    return !isAppBarExpanded
        ? EdgeInsets.fromLTRB(15, 15, 15, headerPaddingBottom)
        : EdgeInsets.fromLTRB(
            canShiftBack ? 0 : 15,
            15,
            canShiftForward ? 0 : 15,
            headerPaddingBottom,
          );
  }
}
