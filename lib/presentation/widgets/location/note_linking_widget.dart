import 'package:flutter/material.dart';
import 'package:mynotes/domain/entities/note.dart';

class NoteLinkingDialog extends StatefulWidget {
  final List<Note>? availableNotes;
  final String? linkedNoteId;
  final Function(String?) onLinkChanged;

  const NoteLinkingDialog({
    super.key,
    this.availableNotes,
    this.linkedNoteId,
    required this.onLinkChanged,
  });

  @override
  State<NoteLinkingDialog> createState() => _NoteLinkingDialogState();
}

class _NoteLinkingDialogState extends State<NoteLinkingDialog> {
  late TextEditingController _searchController;
  String? _selectedNoteId;
  late List<Note> _filteredNotes;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedNoteId = widget.linkedNoteId;
    _filteredNotes = widget.availableNotes ?? [];
  }

  void _filterNotes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredNotes = widget.availableNotes ?? [];
      } else {
        _filteredNotes = (widget.availableNotes ?? [])
            .where(
              (note) =>
                  note.title.toLowerCase().contains(query.toLowerCase()) ||
                  note.content.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Link Note'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterNotes,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            _filterNotes('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            // Notes list
            Expanded(
              child: _filteredNotes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.note_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No notes found',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredNotes.length + 1,
                      itemBuilder: (context, index) {
                        // "None" option at the top
                        if (index == 0) {
                          return ListTile(
                            leading: Radio<String?>(
                              value: null,
                              groupValue: _selectedNoteId,
                              onChanged: (_) {
                                setState(() => _selectedNoteId = null);
                              },
                            ),
                            title: const Text('No linked note'),
                            onTap: () {
                              setState(() => _selectedNoteId = null);
                            },
                          );
                        }

                        final note = _filteredNotes[index - 1];
                        final isSelected = _selectedNoteId == note.id;

                        return ListTile(
                          leading: Radio<String?>(
                            value: note.id,
                            groupValue: _selectedNoteId,
                            onChanged: (_) {
                              setState(() => _selectedNoteId = note.id);
                            },
                          ),
                          title: Text(note.title),
                          subtitle: note.content.isNotEmpty
                              ? Text(
                                  note.content,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          selected: isSelected,
                          onTap: () {
                            setState(() => _selectedNoteId = note.id);
                          },
                        );
                      },
                    ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onLinkChanged(_selectedNoteId);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Link Note'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class NoteLinkingWidget extends StatelessWidget {
  final String? linkedNoteId;
  final String? linkedNoteTitle;
  final VoidCallback onShowLinkDialog;
  final VoidCallback? onRemoveLink;

  const NoteLinkingWidget({
    super.key,
    this.linkedNoteId,
    this.linkedNoteTitle,
    required this.onShowLinkDialog,
    this.onRemoveLink,
  });

  @override
  Widget build(BuildContext context) {
    if (linkedNoteId == null) {
      return ListTile(
        leading: const Icon(Icons.note_outlined),
        title: const Text('Link to Note'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onShowLinkDialog,
      );
    }

    return Card(
      child: ListTile(
        leading: const Icon(Icons.note),
        title: const Text('Linked Note'),
        subtitle: Text(
          linkedNoteTitle ??
              (linkedNoteId != null && linkedNoteId!.length >= 8
                  ? 'Note #${linkedNoteId!.substring(0, 8)}'
                  : 'Note #$linkedNoteId'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onRemoveLink,
        ),
        onTap: onShowLinkDialog,
      ),
    );
  }
}
