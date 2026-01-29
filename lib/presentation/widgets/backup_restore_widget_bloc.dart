import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/backup_bloc.dart';

/// Full-text search enhancement (DB-005)
class FullTextSearchService {
  /// Initialize FTS5 virtual table
  static Future<void> initializeFTS5() async {
    // Create FTS5 virtual table for notes
    // CREATE VIRTUAL TABLE notes_fts USING fts5(
    //   title,
    //   content,
    //   content=notes,
    //   content_rowid=id
    // );
  }

  /// Search using FTS5
  static Future<List<Map<String, dynamic>>> fullTextSearch(String query) async {
    // SELECT * FROM notes_fts WHERE notes_fts MATCH ?
    return [];
  }

  /// Rebuild FTS5 index
  static Future<void> rebuildFTSIndex() async {
    // INSERT INTO notes_fts(notes_fts, rank) VALUES('rebuild', -1);
  }
}

/// Backup/Restore UI widget
class BackupRestoreWidget extends StatelessWidget {
  final VoidCallback? onBackupComplete;
  final VoidCallback? onRestoreComplete;

  const BackupRestoreWidget({
    Key? key,
    this.onBackupComplete,
    this.onRestoreComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackupBloc, BackupState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backup & Restore',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                if (state is BackupCompleted)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Last Backup',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                Text(
                                  _formatDate(state.lastBackupDate),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (state is BackupInProgress)
                  Column(
                    children: [
                      LinearProgressIndicator(value: state.progress),
                      SizedBox(height: 8),
                      Text(
                        '${(state.progress * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.backup),
                          label: Text('Create Backup'),
                          onPressed: () {
                            context.read<BackupBloc>().add(CreateBackupEvent());
                            onBackupComplete?.call();
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: Icon(Icons.restore),
                        label: Text('Restore'),
                        onPressed: () {
                          context.read<BackupBloc>().add(
                            RestoreBackupEvent('path/to/backup'),
                          );
                          onRestoreComplete?.call();
                        },
                      ),
                    ],
                  ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 18),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Backups include all notes, tasks, and settings',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (state is BackupError)
                  Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 18,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.message,
                              style: TextStyle(fontSize: 12, color: Colors.red),
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
      },
    );
  }

  static String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoString;
    }
  }
}

/// Cache management widget
class CacheManagementWidget extends StatelessWidget {
  const CacheManagementWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BackupBloc, BackupState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cache Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cache Size',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (state is CacheSizeCalculated)
                      Text(
                        state.formattedSize,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                SizedBox(height: 16),
                if (state is CacheClearInProgress)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: null,
                      child: Text('Clearing...'),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.delete_sweep),
                      label: Text('Clear Cache'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Clear Cache?'),
                            content: Text(
                              'This will delete cached images and temporary files.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.read<BackupBloc>().add(
                                    ClearCacheEvent(),
                                  );
                                  Navigator.pop(context);
                                },
                                child: Text('Clear'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
