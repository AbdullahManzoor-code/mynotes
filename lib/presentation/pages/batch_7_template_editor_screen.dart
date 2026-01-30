import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/template_management_bloc.dart';
import 'package:mynotes/domain/services/template_conversion_service.dart';

/// Template Editor - Batch 7, Screen 2
class TemplateEditorScreen extends StatefulWidget {
  final dynamic existingTemplate;

  const TemplateEditorScreen({Key? key, this.existingTemplate})
    : super(key: key);

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String _selectedCategory = 'Personal';
  List<Map<String, String>> _fields = [];
  final _templateService = TemplateConversionService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingTemplate?.name ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingTemplate?.description ?? '',
    );
    if (widget.existingTemplate != null) {
      _selectedCategory = widget.existingTemplate!.category;
      _fields = List.from(widget.existingTemplate!.fields ?? []);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingTemplate != null ? 'Edit Template' : 'Create Template',
        ),
        centerTitle: true,
        actions: [
          if (widget.existingTemplate != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template Name
            _buildSection(
              'Template Name',
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter template name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Description
            _buildSection(
              'Description',
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter template description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Category
            _buildSection('Category', _buildCategorySelector()),
            const SizedBox(height: 20),

            // Fields
            _buildSection(
              'Fields',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldsList(),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showAddFieldDialog,
                      icon: Icon(Icons.add),
                      label: Text('Add Field'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTemplate,
                    child: Text('Save Template'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['Work', 'Personal', 'Health', 'Learning'];

    return Wrap(
      spacing: 8,
      children: categories.map((category) {
        final isSelected = _selectedCategory == category;
        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedCategory = category);
          },
        );
      }).toList(),
    );
  }

  Widget _buildFieldsList() {
    if (_fields.isEmpty) {
      return Card(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: Text('No fields yet. Add one to get started.')),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _fields.length,
      itemBuilder: (context, index) {
        final field = _fields[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(Icons.drag_handle),
            title: Text(field['name'] ?? 'Field'),
            subtitle: Text(field['type'] ?? 'text'),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() => _fields.removeAt(index));
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddFieldDialog() {
    final fieldNameController = TextEditingController();
    final defaultValueController = TextEditingController();
    String selectedType = 'text';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Field'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fieldNameController,
                decoration: InputDecoration(
                  labelText: 'Field Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'Field Type',
                  border: OutlineInputBorder(),
                ),
                items: ['text', 'number', 'date', 'checkbox']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) => selectedType = value ?? 'text',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: defaultValueController,
                decoration: InputDecoration(
                  labelText: 'Default Value (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (fieldNameController.text.isNotEmpty) {
                setState(() {
                  _fields.add({
                    'name': fieldNameController.text,
                    'type': selectedType,
                    'defaultValue': defaultValueController.text,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Template?'),
        content: Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TemplateManagementBloc>().add(
                DeleteTemplateEvent(templateId: widget.existingTemplate!.id),
              );
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveTemplate() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a template name')));
      return;
    }

    context.read<TemplateManagementBloc>().add(
      CreateTemplateEvent(
        name: _nameController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        fields: _fields,
      ),
    );

    Navigator.pop(context);
  }
}

