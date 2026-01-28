import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../design_system/design_system.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_state.dart';
import '../bloc/note_event.dart';
import '../../domain/entities/note.dart';
import '../../core/routes/app_routes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotesBloc>().add(const LoadNotesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 100.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildStatsSection(),
              _buildReflectionPrompt(),
              _buildYourDaySection(),
              _buildContinueWriting(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return PageContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning, Alex',
                  style: AppTypography.heading1(context),
                ),
                Text(
                  'Here’s your focus for today.',
                  style: AppTypography.bodySmall(
                    context,
                  ).copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
            CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              child: Icon(Icons.person_outline, color: AppColors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return PageContainer(
      child: Row(
        children: [
          Expanded(
            child: CardContainer(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REFLECTION STREAK',
                    style: AppTypography.captionSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text('7 Days', style: AppTypography.heading2(context)),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        '+2%',
                        style: AppTypography.captionSmall(context).copyWith(
                          color: AppColors.successColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: CardContainer(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TODOS DONE',
                    style: AppTypography.captionSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Text('4/10', style: AppTypography.heading2(context)),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        '40%',
                        style: AppTypography.captionSmall(context).copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionPrompt() {
    return PageContainer(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.self_improvement,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Daily Reflection',
                  style: AppTypography.heading3(context),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'What is one thing you want to achieve today that will make you feel proud?',
              style: AppTypography.bodyMedium(context),
            ),
            SizedBox(height: AppSpacing.md),
            PrimaryButton(
              text: 'Answer',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.reflectionEditor);
              },
              isFullWidth: true,
              height: 40.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYourDaySection() {
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Day', style: AppTypography.heading2(context)),
          SizedBox(height: AppSpacing.md),
          _buildCollapsibleSection(
            title: 'Next Reminders',
            actionText: 'See all',
            onAction: () =>
                Navigator.pushNamed(context, AppRoutes.remindersList),
            children: [
              _buildReminderItem('Pick up groceries', '5:00 PM'),
              _buildReminderItem('Call Mom', '6:30 PM'),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          _buildCollapsibleSection(
            title: "Today's Todos",
            actionText: '+ Add',
            onAction: () => Navigator.pushNamed(context, AppRoutes.todosList),
            children: [
              _buildTodoItem('Draft project proposal', false),
              _buildTodoItem('Morning workout', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required String actionText,
    required VoidCallback onAction,
    required List<Widget> children,
  }) {
    return CardContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    actionText,
                    style: AppTypography.captionSmall(context).copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.dividerColor(context)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildReminderItem(String title, String time) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.dividerColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(
              Icons.schedule,
              color: AppColors.primaryColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodySmall(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  time,
                  style: AppTypography.captionSmall(
                    context,
                  ).copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          Icon(
            Icons.notifications_paused_outlined,
            size: 20.sp,
            color: AppColors.textTertiary(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoItem(String title, bool isCompleted) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.dividerColor(context),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: isCompleted
                ? AppColors.successColor
                : AppColors.primaryColor.withOpacity(0.4),
            size: 24.sp,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodySmall(context).copyWith(
                fontWeight: FontWeight.w500,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? AppColors.textTertiary(context) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueWriting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'CONTINUE WRITING',
            style: AppTypography.captionSmall(context).copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        SizedBox(
          height: 120.h,
          child: BlocBuilder<NotesBloc, NoteState>(
            builder: (context, state) {
              if (state is NotesLoaded) {
                final recentNotes = state.notes.take(5).toList();
                if (recentNotes.isEmpty) return const SizedBox();
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  itemCount: recentNotes.length,
                  itemBuilder: (context, index) {
                    final note = recentNotes[index];
                    return Container(
                      width: 160.w,
                      margin: EdgeInsets.only(right: AppSpacing.md),
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground(context),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                        border: Border.all(
                          color: AppColors.dividerColor(context),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 14.sp,
                                color: AppColors.primaryColor,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'RECENT',
                                style: AppTypography.captionSmall(context)
                                    .copyWith(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            note.title,
                            style: AppTypography.bodySmall(
                              context,
                            ).copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            note.content,
                            style: AppTypography.captionSmall(context),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}
