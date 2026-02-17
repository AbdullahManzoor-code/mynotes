// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:mynotes/core/services/app_logger.dart';
// import 'package:mynotes/domain/entities/todo_item.dart';
// import 'package:mynotes/presentation/bloc/note/note_bloc.dart';
// import 'package:mynotes/presentation/bloc/note/note_state.dart';
// import 'package:mynotes/presentation/bloc/focus/focus_bloc.dart';
// import 'package:mynotes/presentation/design_system/design_system.dart';
// import 'package:mynotes/core/routes/app_routes.dart';
// import 'package:mynotes/presentation/widgets/lottie_animation_widget.dart';

// /// Premium Daily Focus Highlight Screen - Phase 3
// /// Modern, gradient-based UI with smooth animations
// class DailyFocusHighlightScreen extends StatelessWidget {
//   const DailyFocusHighlightScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       extendBodyBehindAppBar: true,
//       appBar: _buildPremiumAppBar(context),
//       body: BlocBuilder<NotesBloc, NoteState>(
//         builder: (context, noteState) {
//           if (noteState is NotesLoaded) {
//             final highlightTask = _findHighlightTask(
//               noteState.notes.whereType<TodoItem>().toList(),
//             );
//             if (highlightTask == null) {
//               return _buildPremiumEmptyState(context);
//             }
//             return _buildPremiumHighlightContent(context, highlightTask);
//           }
//           return const Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }

//   PreferredSizeWidget _buildPremiumAppBar(BuildContext context) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       title: Text(
//         'Daily Highlight',
//         style: AppTypography.heading3(
//           context,
//           AppColors.textPrimary(context),
//         ).copyWith(fontWeight: FontWeight.w600),
//       ),
//       centerTitle: false,
//       leading: Container(
//         margin: EdgeInsets.all(8.w),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: AppColors.primary.withOpacity(0.1),
//         ),
//         child: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: AppColors.textPrimary(context),
//             size: 20.sp,
//           ),
//           onPressed: () {
//             AppLogger.i('DailyFocusHighlightScreenV2: Back pressed');
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       actions: [
//         Container(
//           margin: EdgeInsets.only(right: 16.w),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: AppColors.primary.withOpacity(0.1),
//           ),
//           child: IconButton(
//             icon: Icon(
//               Icons.info_outline,
//               color: AppColors.textPrimary(context),
//               size: 20.sp,
//             ),
//             onPressed: () {
//               AppLogger.i('DailyFocusHighlightScreenV2: Info pressed');
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                     'Mark tasks as Urgent or add #highlight to set your focus',
//                     style: AppTypography.bodySmall(context),
//                   ),
//                   behavior: SnackBarBehavior.floating,
//                   margin: EdgeInsets.all(16.w),
//                   backgroundColor: AppColors.primary,
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   TodoItem? _findHighlightTask(List<TodoItem> todos) {
//     try {
//       return todos.firstWhere(
//         (t) => t.text.toLowerCase().contains('#highlight') && !t.isCompleted,
//       );
//     } catch (_) {}
//     try {
//       return todos.firstWhere(
//         (t) => t.priority == TodoPriority.urgent && !t.isCompleted,
//       );
//     } catch (_) {
//       return null;
//     }
//   }

//   Widget _buildPremiumEmptyState(BuildContext context) {
//     return Center(
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(24.w),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               SizedBox(height: 80.h),
//               // Animation
//               SizedBox(
//                 height: 180.h,
//                 child: LottieAnimationWidget(
//                   'empty_state',
//                   width: 160.w,
//                   height: 160.h,
//                 ),
//               ),
//               SizedBox(height: 32.h),

//               Text(
//                 'No Daily Highlight',
//                 style: AppTypography.heading2(
//                   context,
//                 ).copyWith(fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 12.h),

//               Text(
//                 'Create inspiration by marking an important task',
//                 style: AppTypography.bodyMedium(
//                   context,
//                   AppColors.secondaryText,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 32.h),

//               // Tips card
//               Container(
//                 padding: EdgeInsets.all(20.w),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(20.r),
//                   border: Border.all(
//                     color: AppColors.primary.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.lightbulb,
//                           color: AppColors.primary,
//                           size: 20.sp,
//                         ),
//                         SizedBox(width: 8.w),
//                         Text(
//                           'Quick tips',
//                           style: AppTypography.bodyMedium(
//                             context,
//                           ).copyWith(fontWeight: FontWeight.w600),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 12.h),
//                     ...[
//                       '• Mark as "Urgent" priority',
//                       '• Add #highlight in title',
//                       '• Set as focus goal',
//                     ].map((tip) {
//                       return Padding(
//                         padding: EdgeInsets.only(bottom: 8.h),
//                         child: Text(
//                           tip,
//                           style: AppTypography.bodySmall(
//                             context,
//                             AppColors.secondaryText,
//                           ),
//                         ),
//                       );
//                     }),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPremiumHighlightContent(BuildContext context, TodoItem task) {
//     return BlocBuilder<FocusBloc, FocusState>(
//       builder: (context, focusState) {
//         final completion = task.completionPercentage;

//         return SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 80.h),

//               // Premium card with gradient
//               _buildHighlightCard(context, task, completion),

//               SizedBox(height: 32.h),

//               // Stats
//               _buildStatsRow(context, task),

//               SizedBox(height: 32.h),

//               // Subtasks
//               if (task.subtasks.isNotEmpty)
//                 _buildSubtasksSection(context, task),

//               SizedBox(height: 24.h),

//               // Action buttons
//               _buildActionButtons(context, task),

//               SizedBox(height: 32.h),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildHighlightCard(
//     BuildContext context,
//     TodoItem task,
//     double completion,
//   ) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w),
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               AppColors.primary.withOpacity(0.15),
//               AppColors.primary.withOpacity(0.05),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(28.r),
//           border: Border.all(
//             color: AppColors.primary.withOpacity(0.4),
//             width: 1.5,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: AppColors.primary.withOpacity(0.15),
//               blurRadius: 25,
//               offset: const Offset(0, 8),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: EdgeInsets.all(32.w),
//           child: Column(
//             children: [
//               // Badge
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20.r),
//                   border: Border.all(color: AppColors.primary.withOpacity(0.5)),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.star, size: 16.sp, color: AppColors.primary),
//                     SizedBox(width: 6.w),
//                     Text(
//                       'TODAY\'S FOCUS',
//                       style: AppTypography.caption(context, AppColors.primary)
//                           .copyWith(
//                             fontWeight: FontWeight.w700,
//                             letterSpacing: 1.5,
//                           ),
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: 24.h),

//               // Title
//               Text(
//                 task.text.replaceAll('#highlight', '').trim(),
//                 textAlign: TextAlign.center,
//                 style: AppTypography.heading1(
//                   context,
//                 ).copyWith(fontWeight: FontWeight.w700, height: 1.3),
//               ),

//               SizedBox(height: 28.h),

//               // Progress circle
//               SizedBox(
//                 width: 140.w,
//                 height: 140.w,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     CircularProgressIndicator(
//                       value: completion,
//                       strokeWidth: 10.w,
//                       valueColor: AlwaysStoppedAnimation(AppColors.primary),
//                       backgroundColor: AppColors.primary.withOpacity(0.2),
//                     ),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           '${(completion * 100).toInt()}%',
//                           style: AppTypography.heading2(context).copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: AppColors.primary,
//                           ),
//                         ),
//                         SizedBox(height: 4.h),
//                         Text(
//                           'Complete',
//                           style: AppTypography.caption(
//                             context,
//                           ).copyWith(color: AppColors.secondaryText),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsRow(BuildContext context, TodoItem task) {
//     final stats = [
//       {
//         'label': 'Priority',
//         'value': task.priority.toString().split('.').last.toUpperCase(),
//         'icon': Icons.flag,
//       },
//       {
//         'label': 'Created',
//         'value': '${task.createdAt.day}/${task.createdAt.month}',
//         'icon': Icons.calendar_today,
//       },
//       {
//         'label': 'Status',
//         'value': task.isCompleted ? 'Done' : 'In Progress',
//         'icon': task.isCompleted ? Icons.check_circle : Icons.pending,
//       },
//     ];

//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w),
//       child: Row(
//         children: stats.map((stat) {
//           return Expanded(
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 8.w),
//               padding: EdgeInsets.all(16.w),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).cardColor,
//                 borderRadius: BorderRadius.circular(16.r),
//                 border: Border.all(
//                   color: AppColors.primary.withOpacity(0.2),
//                   width: 1,
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         stat['icon'] as IconData,
//                         size: 16.sp,
//                         color: AppColors.primary,
//                       ),
//                       SizedBox(width: 6.w),
//                       Text(
//                         stat['label'] as String,
//                         style: AppTypography.caption(
//                           context,
//                           AppColors.secondaryText,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 8.h),
//                   Text(
//                     stat['value'] as String,
//                     style: AppTypography.bodySmall(
//                       context,
//                     ).copyWith(fontWeight: FontWeight.w600),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildSubtasksSection(BuildContext context, TodoItem task) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20.w),
//           child: Text(
//             'Subtasks',
//             style: AppTypography.heading3(
//               context,
//             ).copyWith(fontWeight: FontWeight.w600),
//           ),
//         ),
//         SizedBox(height: 16.h),
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 20.w),
//           child: Column(
//             children: task.subtasks.map((sub) {
//               return Padding(
//                 padding: EdgeInsets.only(bottom: 12.h),
//                 child: Container(
//                   padding: EdgeInsets.all(16.w),
//                   decoration: BoxDecoration(
//                     color: sub.isCompleted
//                         ? AppColors.primary.withOpacity(0.08)
//                         : Theme.of(context).cardColor,
//                     borderRadius: BorderRadius.circular(14.r),
//                     border: Border.all(
//                       color: sub.isCompleted
//                           ? AppColors.primary.withOpacity(0.3)
//                           : AppColors.primary.withOpacity(0.1),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 24.w,
//                         height: 24.w,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: sub.isCompleted ? AppColors.primary : null,
//                           border: sub.isCompleted
//                               ? null
//                               : Border.all(
//                                   color: AppColors.primary.withOpacity(0.3),
//                                   width: 2,
//                                 ),
//                         ),
//                         child: sub.isCompleted
//                             ? Icon(
//                                 Icons.check,
//                                 size: 14.sp,
//                                 color: Colors.white,
//                               )
//                             : null,
//                       ),
//                       SizedBox(width: 12.w),
//                       Expanded(
//                         child: Text(
//                           sub.text,
//                           style: AppTypography.bodyMedium(context).copyWith(
//                             decoration: sub.isCompleted
//                                 ? TextDecoration.lineThrough
//                                 : null,
//                             color: sub.isCompleted
//                                 ? AppColors.secondaryText
//                                 : null,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons(BuildContext context, TodoItem task) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20.w),
//       child: Column(
//         children: [
//           // Focus button
//           Container(
//             width: double.infinity,
//             height: 56.h,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
//               ),
//               borderRadius: BorderRadius.circular(16.r),
//               boxShadow: [
//                 BoxShadow(
//                   color: AppColors.primary.withOpacity(0.3),
//                   blurRadius: 15,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: () {
//                   AppLogger.i(
//                     'DailyFocusHighlightScreenV2: Start Focus Session pressed',
//                   );
//                   HapticFeedback.mediumImpact();
//                   Navigator.pushNamed(
//                     context,
//                     AppRoutes.focusSession,
//                     arguments: {'todoTitle': task.text, 'todoId': task.id},
//                   );
//                 },
//                 borderRadius: BorderRadius.circular(16.r),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.timer_outlined,
//                       size: 20.sp,
//                       color: Colors.white,
//                     ),
//                     SizedBox(width: 12.w),
//                     Text(
//                       'Start Focus Session',
//                       style: AppTypography.bodyLarge(context).copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(height: 12.h),

//           // Share button
//           Container(
//             width: double.infinity,
//             height: 48.h,
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(14.r),
//               border: Border.all(
//                 color: AppColors.primary.withOpacity(0.3),
//                 width: 1.5,
//               ),
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: () {
//                   AppLogger.i(
//                     'DailyFocusHighlightScreenV2: Share Highlight pressed',
//                   );
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                         'Highlight copied to clipboard',
//                         style: AppTypography.bodySmall(context),
//                       ),
//                       behavior: SnackBarBehavior.floating,
//                       margin: EdgeInsets.all(16.w),
//                       backgroundColor: AppColors.primary,
//                       duration: const Duration(seconds: 2),
//                     ),
//                   );
//                 },
//                 borderRadius: BorderRadius.circular(14.r),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.share_outlined,
//                       size: 18.sp,
//                       color: AppColors.primary,
//                     ),
//                     SizedBox(width: 8.w),
//                     Text(
//                       'Share Highlight',
//                       style: AppTypography.bodyMedium(context).copyWith(
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
