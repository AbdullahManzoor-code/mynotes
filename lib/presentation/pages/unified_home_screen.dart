import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';
import '../widgets/universal_item_card.dart';
import '../../data/repositories/unified_repository.dart';
import 'fixed_universal_quick_add_screen.dart';
import 'enhanced_global_search_screen.dart';
import 'focus_session_screen.dart';

/// Unified Home Screen
/// Single dashboard showcasing the integrated Note/Todo/Reminder system
/// Demonstrates the "Universal Item" concept in action
class UnifiedHomeScreen extends StatefulWidget {
  const UnifiedHomeScreen({Key? key}) : super(key: key);

  @override
  State<UnifiedHomeScreen> createState() => _UnifiedHomeScreenState();
}

class _UnifiedHomeScreenState extends State<UnifiedHomeScreen>
    with TickerProviderStateMixin {
  final _repository = UnifiedRepository.instance;
  late TabController _tabController;

  List<UniversalItem> _allItems = [];
  List<UniversalItem> _notes = [];
  List<UniversalItem> _todos = [];
  List<UniversalItem> _reminders = [];

  bool _isLoading = true;
  Map<String, int> _itemCounts = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      await _repository.initialize();
      await _loadData();
    } catch (error) {
      debugPrint('Error initializing data: $error');
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final futures = await Future.wait([
        _repository.getAllItems(),
        _repository.getNotes(),
        _repository.getTodos(),
        _repository.getReminders(),
        _repository.getItemCounts(),
      ]);

      setState(() {
        _allItems = futures[0] as List<UniversalItem>;
        _notes = futures[1] as List<UniversalItem>;
        _todos = futures[2] as List<UniversalItem>;
        _reminders = futures[3] as List<UniversalItem>;
        _itemCounts = futures[4] as Map<String, int>;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Failed to load data: $error');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _toggleTodoCompletion(String id) async {
    await _repository.toggleTodoCompletion(id);
    await _loadData(); // Refresh
    HapticFeedback.lightImpact();
  }

  Future<void> _addReminderToItem(String id) async {
    final reminderTime = await _showReminderTimePicker();
    if (reminderTime != null) {
      await _repository.addReminderToItem(id, reminderTime);
      await _loadData(); // Refresh
    }
  }

  Future<DateTime?> _showReminderTimePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
      );

      if (pickedTime != null) {
        return DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(child: _isLoading ? _buildLoadingState() : _buildTabView()),
        ],
      ),
      floatingActionButton: _buildQuickAddButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MyNotes',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Universal Productivity Hub',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Action buttons
              Row(
                children: [
                  _buildActionButton(
                    icon: Icons.search,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EnhancedGlobalSearchScreen(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  _buildActionButton(
                    icon: Icons.psychology,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FocusSessionScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Stats overview
          _buildStatsOverview(),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          _buildStatItem(
            'Notes',
            _itemCounts['notes'] ?? 0,
            AppColors.primary,
            Icons.note,
          ),
          _buildStatDivider(),
          _buildStatItem(
            'Todos',
            _itemCounts['todos'] ?? 0,
            AppColors.accentBlue,
            Icons.task_alt,
          ),
          _buildStatDivider(),
          _buildStatItem(
            'Reminders',
            _itemCounts['reminders'] ?? 0,
            AppColors.accentPurple,
            Icons.alarm,
          ),
          _buildStatDivider(),
          _buildStatItem(
            'Done',
            _itemCounts['completed_todos'] ?? 0,
            AppColors.accentGreen,
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1.w,
      height: 40.h,
      color: Colors.white.withOpacity(0.1),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.darkCardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: AppColors.darkCardBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelColor: AppColors.primary,
        unselectedLabelColor: Colors.grey.shade500,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Notes'),
          Tab(text: 'Todos'),
          Tab(text: 'Reminders'),
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildItemsList(_allItems, showMixed: true),
        _buildItemsList(_notes),
        _buildItemsList(_todos),
        _buildItemsList(_reminders),
      ],
    );
  }

  Widget _buildItemsList(List<UniversalItem> items, {bool showMixed = false}) {
    if (items.isEmpty) {
      return _buildEmptyState(showMixed);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return UniversalItemCard(
            item: item,
            onTap: () => _handleItemTap(item),
            onTodoToggle: item.isTodo
                ? (completed) => _toggleTodoCompletion(item.id)
                : null,
            onReminderTap: () => _addReminderToItem(item.id),
            showActions: true,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool showMixed) {
    String title, subtitle;
    IconData icon;

    if (showMixed) {
      title = 'No items yet';
      subtitle = 'Create your first note, todo, or reminder';
      icon = Icons.lightbulb_outline;
    } else if (_tabController.index == 1) {
      title = 'No notes yet';
      subtitle = 'Start writing your thoughts';
      icon = Icons.note_add;
    } else if (_tabController.index == 2) {
      title = 'No todos yet';
      subtitle = 'Add tasks to stay organized';
      icon = Icons.task_alt;
    } else {
      title = 'No reminders yet';
      subtitle = 'Set reminders to never forget';
      icon = Icons.alarm_add;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 48.sp),
          ),
          SizedBox(height: 24.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildQuickAddButton() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const FixedUniversalQuickAddScreen(),
          fullscreenDialog: true,
        ),
      ).then((_) => _loadData()), // Refresh after adding
      backgroundColor: AppColors.primary,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            'Quick Add',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _handleItemTap(UniversalItem item) {
    // TODO: Navigate to appropriate editor based on item type
    HapticFeedback.selectionClick();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCardBackground,
      builder: (_) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (item.content.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Text(
                item.content,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade300),
              ),
            ],
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text('Edit', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
