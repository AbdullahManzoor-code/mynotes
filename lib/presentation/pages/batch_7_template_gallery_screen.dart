import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/template_management_bloc.dart';
import 'package:mynotes/domain/services/template_conversion_service.dart';

/// Template Gallery - Batch 7, Screen 1
class TemplateGalleryScreen extends StatefulWidget {
  const TemplateGalleryScreen({Key? key}) : super(key: key);

  @override
  State<TemplateGalleryScreen> createState() => _TemplateGalleryScreenState();
}

class _TemplateGalleryScreenState extends State<TemplateGalleryScreen> {
  final _templateService = TemplateConversionService();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Template Gallery'), centerTitle: true),
      body: BlocBuilder<TemplateManagementBloc, TemplateManagementState>(
        builder: (context, state) {
          if (state is! TemplatesLoaded) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Search and Filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search templates...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryFilter(),
                  ],
                ),
              ),

              // Templates Grid
              Expanded(child: _buildTemplatesGrid(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', 'Work', 'Personal', 'Health', 'Learning'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTemplatesGrid(TemplatesLoaded state) {
    final templates = state.templates.where((template) {
      final matchesSearch = template.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesCategory =
          _selectedCategory == 'All' || template.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (templates.isEmpty) {
      return Center(child: Text('No templates found'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  Widget _buildTemplateCard(dynamic template) {
    return Card(
      child: InkWell(
        onTap: () => _showTemplatePreview(template),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTemplateIcon(template.category),
                  size: 40,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                template.name,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Chip(
                label: Text(template.category, style: TextStyle(fontSize: 12)),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _useTemplate(template),
                  child: Text('Use'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTemplatePreview(dynamic template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(template.description ?? 'No description'),
              const SizedBox(height: 16),
              Text('Category:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(template.category),
              const SizedBox(height: 16),
              Text('Fields:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...((template.fields ?? []) as List).map((field) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text('• ${field['name'] ?? 'Field'}'),
                );
              }),
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
              _useTemplate(template);
              Navigator.pop(context);
            },
            child: Text('Use Template'),
          ),
        ],
      ),
    );
  }

  void _useTemplate(dynamic template) {
    context.read<TemplateManagementBloc>().add(
      CreateTemplateEvent(
        name: template.name,
        description: template.description ?? '',
        fields: template.fields ?? [],
        category: template.category,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Template "${template.name}" loaded')),
    );
  }

  IconData _getTemplateIcon(String category) {
    switch (category) {
      case 'Work':
        return Icons.work;
      case 'Personal':
        return Icons.person;
      case 'Health':
        return Icons.health_and_safety;
      case 'Learning':
        return Icons.school;
      default:
        return Icons.note;
    }
  }
}

