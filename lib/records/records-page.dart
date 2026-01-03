import 'dart:core';

import 'package:flutter/material.dart';
import 'package:pocket_guard/records/components/days-summary-box-card.dart';
import 'package:pocket_guard/records/components/records-day-list.dart';
import 'package:pocket_guard/records/components/tab_records_search_app_bar.dart';
import 'package:pocket_guard/records/components/top_spending_carousel.dart';
import 'package:pocket_guard/records/controllers/tab_records_controller.dart';

import '../i18n.dart';
import 'components/tab_records_app_bar.dart';
import 'components/tab_records_date_picker.dart';

class TabRecords extends StatefulWidget {
  /// MovementsPage is the page showing the list of movements grouped per day.
  /// It contains also buttons for filtering the list of movements and add a new movement.

  TabRecords({Key? key}) : super(key: key);

  @override
  TabRecordsState createState() => TabRecordsState();
}

class TabRecordsState extends State<TabRecords> {
  late final TabRecordsController _controller;
  late final AppLifecycleListener _listener;
  final ValueNotifier<bool> _isExpandedNotifier = ValueNotifier<bool>(true);

  void _onScroll(ScrollNotification scrollInfo) {
    final bool isExpanded = scrollInfo.metrics.pixels < 100;
    if (_isExpandedNotifier.value != isExpanded) {
      _isExpandedNotifier.value = isExpanded;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = TabRecordsController(onStateChanged: () => setState(() {}));
    _listener = AppLifecycleListener(onStateChange: _handleOnResume);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize();
    });
  }

  void _handleOnResume(AppLifecycleState value) {
    if (value == AppLifecycleState.resumed) {
      _controller.onResume();
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    _controller.dispose();
    _isExpandedNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.runAutomaticBackup(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        _onScroll(scrollInfo);
        return false;
      },
      child: CustomScrollView(slivers: _buildSlivers()),
    );
  }

  List<Widget> _buildSlivers() {
    return <Widget>[
      if (!_controller.isSearchingEnabled) _buildMainSliverAppBar(),
      _buildSummarySection(),

      if (_controller.filteredRecords.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              "Top Spending".i18n,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),

      SliverToBoxAdapter(
        child: TopSpendingCarousel(
          passedRecords:
              _controller.overviewRecords ?? _controller.filteredRecords,
        ),
      ),

      if (_controller.filteredRecords.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              "Daily Breakdown".i18n,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),

      if (_controller.filteredRecords.isEmpty) _buildEmptyState(),
      RecordsDayList(
        _controller.filteredRecords,
        onListBackCallback: _controller.updateRecurrentRecordsAndFetchRecords,
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 75)),
    ];
  }

  Widget _buildMainSliverAppBar() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isExpandedNotifier,
      builder: (context, isExpanded, child) {
        return TabRecordsAppBar(
          controller: _controller,
          isAppBarExpanded: isExpanded,
          onDatePickerPressed: () => _showDatePicker(),
          onStatisticsPressed: () =>
              _controller.navigateToStatisticsPage(context),
          onSearchPressed: () => _controller.startSearch(),
          onMenuItemSelected: (index) =>
              _controller.handleMenuAction(context, index),
        );
      },
    );
  }

  TabRecordsSearchAppBar? _buildAppBar() {
    if (!_controller.isSearchingEnabled) return null;

    return TabRecordsSearchAppBar(
      controller: _controller,
      onBackPressed: () => _controller.stopSearch(),
      onDatePickerPressed: () => _showDatePicker(),
      onStatisticsPressed: () => _controller.navigateToStatisticsPage(context),
      onMenuItemSelected: (index) =>
          _controller.handleMenuAction(context, index),
      onFilterPressed: () => _controller.showFilterModal(context),
      hasActiveFilters: _controller.hasActiveFilters,
    );
  }

  Widget _buildSummarySection() {
    return SliverToBoxAdapter(
      child: Padding(
        // Use Padding instead of Container with fixed height
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 5),
        child: DaysSummaryBox(
          _controller.overviewRecords ?? _controller.filteredRecords,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Image.asset('assets/images/no_entry.png', width: 200),
          const SizedBox(height: 10),
          Text(
            "No entries yet.".i18n,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _controller.navigateToAddNewRecord(context),
      tooltip: 'Add a new record'.i18n,
      child: Semantics(identifier: 'add-record', child: const Icon(Icons.add)),
    );
  }

  Future<void> _showDatePicker() async {
    await showDialog(
      context: context,
      builder: (context) => TabRecordsDatePicker(
        controller: _controller,
        onDateSelected: () => setState(() {}),
      ),
    );
  }

  // Public method for external navigation callbacks
  onTabChange() async {
    await _controller.onTabChange();
  }
}
