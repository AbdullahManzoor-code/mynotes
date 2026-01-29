import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/media_gallery_bloc.dart';
import 'package:mynotes/domain/services/media_filtering_service.dart';

/// Advanced Media Filter Screen - Batch 4, Screen 1
class AdvancedMediaFilterScreen extends StatefulWidget {
  const AdvancedMediaFilterScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedMediaFilterScreen> createState() =>
      _AdvancedMediaFilterScreenState();
}

class _AdvancedMediaFilterScreenState extends State<AdvancedMediaFilterScreen> {
  final _filtering = MediaFilteringService();
  
  String? _selectedType;
  DateTime? _fromDate;
  DateTime? _toDate;
  int? _minSize;
  int? _maxSize;
  List<String> _selectedTags = [];
  
  bool _excludeArchived = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Media Filter'),
        centerTitle: true,
      ),
      body: BlocListener<MediaGalleryBloc, MediaGalleryState>(
        listener: (context, state) {
          if (state is MediaGalleryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Type Filter
              _buildSectionTitle('Media Type'),
              _buildMediaTypeSelector(),
              const SizedBox(height: 24),

              // Date Range Filter
              _buildSectionTitle('Date Range'),
              _buildDateRangeSelector(),
              const SizedBox(height: 24),

              // File Size Filter
              _buildSectionTitle('File Size'),
              _buildSizeRangeSelector(),
              const SizedBox(height: 24),

              // Tags Filter
              _buildSectionTitle('Tags'),
              _buildTagsInput(),
              const SizedBox(height: 24),

              // Options
              _buildSectionTitle('Options'),
              _buildOptionsCheckbox(),
              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildMediaTypeSelector() {
    final types = ['image', 'video', 'audio', 'document'];
    
    return Wrap(
      spacing: 8,
      children: types.map((type) {
        return ChoiceChip(
          label: Text(type.toUpperCase()),
          selected: _selectedType == type,
          onSelected: (selected) {
            setState(() {
              _selectedType = selected ? type : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildDateRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text('From: ${_fromDate?.toString().split(' ')[0] ?? 'Not set'}'),
          trailing: Icon(Icons.calendar_today),
          onTap: () => _selectDate(true),
        ),
        ListTile(
          title: Text('To: ${_toDate?.toString().split(' ')[0] ?? 'Not set'}'),
          trailing: Icon(Icons.calendar_today),
          onTap: () => _selectDate(false),
        ),
        if (_fromDate != null || _toDate != null)
          TextButton(
            onPressed: () {
              setState(() {
                _fromDate = null;
                _toDate = null;
              });
            },
            child: const Text('Clear'),
          ),
      ],
    );
  }

  Widget _buildSizeRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Min Size (MB)',
            prefixIcon: Icon(Icons.storage),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _minSize = int.tryParse(value) != null
                  ? int.parse(value) * 1024 * 1024
                  : null;
            });
          },
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'Max Size (MB)',
            prefixIcon: Icon(Icons.storage),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _maxSize = int.tryParse(value) != null
                  ? int.parse(value) * 1024 * 1024
                  : null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTagsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Enter tags (comma-separated)',
            hintText: 'e.g., vacation, important, work',
            prefixIcon: Icon(Icons.label),
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Show tag suggestions in dialog
                _showTagSuggestions();
              },
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                _selectedTags = value.split(',').map((t) => t.trim()).toList();
              });
            }
          },
        ),
        if (_selectedTags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _selectedTags.map((tag) {
              return Chip(
                label: Text(tag),
                onDeleted: () {
                  setState(() {
                    _selectedTags.remove(tag);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildOptionsCheckbox() {
    return CheckboxListTile(
      title: const Text('Exclude Archived Items'),
      value: _excludeArchived,
      onChanged: (value) {
        setState(() {
          _excludeArchived = value ?? true;
        });
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.clear),
          label: Text('Reset'),
          onPressed: _resetFilters,
        ),
        BlocBuilder<MediaGalleryBloc, MediaGalleryState>(
          builder: (context, state) {
            return ElevatedButton.icon(
              icon: state is MediaGalleryLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.search),
              label: Text('Apply Filter'),
              onPressed: state is MediaGalleryLoading
                  ? null
                  : () => _applyFilter(context),
            );
          },
        ),
      ],
    );
  }

  void _selectDate(bool isFromDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _showTagSuggestions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Popular Tags'),
        content: Wrap(
          spacing: 8,
          children: ['vacation', 'work', 'important', 'family', 'project']
              .map((tag) => ActionChip(
                    label: Text(tag),
                    onPressed: () {
                      setState(() {
                        if (!_selectedTags.contains(tag)) {
                          _selectedTags.add(tag);
                        }
                      });
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedType = null;
      _fromDate = null;
      _toDate = null;
      _minSize = null;
      _maxSize = null;
      _selectedTags = [];
      _excludeArchived = true;
    });
  }

  void _applyFilter(BuildContext context) {
    // Create filter event for BLoC
    context.read<MediaGalleryBloc>().add(
          FilterMediaEvent(
            typeFilter: _selectedType,
            fromDate: _fromDate,
            toDate: _toDate,
            minSizeBytes: _minSize,
            maxSizeBytes: _maxSize,
            tags: _selectedTags.isNotEmpty ? _selectedTags : null,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Filter applied!')),
    );
  }
}

/// Filter event to add to MediaGalleryBloc
class FilterMediaEvent extends MediaGalleryEvent {
  final String? typeFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? minSizeBytes;
  final int? maxSizeBytes;
  final List<String>? tags;

  FilterMediaEvent({
    this.typeFilter,
    this.fromDate,
    this.toDate,
    this.minSizeBytes,
    this.maxSizeBytes,
    this.tags,
  });
}

