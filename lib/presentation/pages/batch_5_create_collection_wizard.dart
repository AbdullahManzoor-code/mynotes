import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/presentation/bloc/smart_collections_bloc.dart';

/// Create Smart Collection Wizard - Batch 5, Screen 1
class CreateSmartCollectionWizard extends StatefulWidget {
  const CreateSmartCollectionWizard({Key? key}) : super(key: key);

  @override
  State<CreateSmartCollectionWizard> createState() =>
      _CreateSmartCollectionWizardState();
}

class _CreateSmartCollectionWizardState
    extends State<CreateSmartCollectionWizard> {
  late PageController _pageController;
  int _currentStep = 0;

  // Step 1: Basic Info
  final _collectionNameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Step 2: Rules
  List<Map<String, dynamic>> _rules = [];

  // Step 3: Logic
  String _logic = 'AND';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _collectionNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Smart Collection'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step Indicator
          _buildStepIndicator(),
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildStep1BasicInfo(),
                _buildStep2AddRules(),
                _buildStep3ReviewLogic(),
              ],
            ),
          ),
          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStepCircle(0, 'Basic Info'),
          _buildConnector(),
          _buildStepCircle(1, 'Add Rules'),
          _buildConnector(),
          _buildStepCircle(2, 'Review'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isCompleted = _currentStep > step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted || isCurrent ? Colors.blue : Colors.grey,
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? Icon(Icons.check, color: Colors.white)
              : Text(
                  '${step + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }

  Widget _buildConnector() {
    return Expanded(
      child: Container(
        height: 2,
        color: _currentStep > 0 ? Colors.blue : Colors.grey,
        margin: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildStep1BasicInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Collection Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _collectionNameController,
            decoration: InputDecoration(
              labelText: 'Collection Name',
              hintText: 'e.g., Important Documents',
              prefixIcon: Icon(Icons.folder),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Optional description',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2AddRules() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Filtering Rules',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Add Rule'),
                onPressed: _showAddRuleDialog,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_rules.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.rule, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No rules added yet'),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _rules.length,
              itemBuilder: (context, index) {
                final rule = _rules[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      '${rule['field']} ${rule['operator']} ${rule['value']}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _rules.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStep3ReviewLogic() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Confirm',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Collection Name',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(_collectionNameController.text),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(_descriptionController.text),
                  const SizedBox(height: 16),
                  Text(
                    'Number of Rules',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text('${_rules.length} rule(s)'),
                  const SizedBox(height: 16),
                  Text('Logic', style: Theme.of(context).textTheme.labelSmall),
                  Text(_logic),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Logic Type',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text('AND'),
                  subtitle: Text('All rules must match'),
                  value: 'AND',
                  groupValue: _logic,
                  onChanged: (value) {
                    setState(() {
                      _logic = value ?? 'AND';
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text('OR'),
                  subtitle: Text('Any rule can match'),
                  value: 'OR',
                  groupValue: _logic,
                  onChanged: (value) {
                    setState(() {
                      _logic = value ?? 'OR';
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_currentStep > 0)
            ElevatedButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text('Previous'),
            ),
          if (_currentStep < 2)
            ElevatedButton(
              onPressed: _canProceedToNext()
                  ? () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              child: Text('Next'),
            ),
          if (_currentStep == 2)
            ElevatedButton(
              onPressed: _createCollection,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Create Collection'),
            ),
        ],
      ),
    );
  }

  bool _canProceedToNext() {
    if (_currentStep == 0) {
      return _collectionNameController.text.isNotEmpty;
    } else if (_currentStep == 1) {
      return _rules.isNotEmpty;
    }
    return true;
  }

  void _showAddRuleDialog() {
    final fieldController = TextEditingController();
    final valueController = TextEditingController();
    String selectedOperator = '=';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Rule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: fieldController,
              decoration: InputDecoration(
                labelText: 'Field',
                hintText: 'e.g., type, size, createdAt',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedOperator,
              items: ['=', '~', '>', '<', '^', "\$", '∈']
                  .map((op) => DropdownMenuItem(value: op, child: Text(op)))
                  .toList(),
              onChanged: (value) {
                selectedOperator = value ?? '=';
              },
              decoration: InputDecoration(labelText: 'Operator'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valueController,
              decoration: InputDecoration(labelText: 'Value'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _rules.add({
                  'field': fieldController.text,
                  'operator': selectedOperator,
                  'value': valueController.text,
                });
              });
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _createCollection() {
    if (_collectionNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a collection name')));
      return;
    }

    // Create collection via BLoC
    context.read<SmartCollectionsBloc>().add(
      CreateCollectionEvent(
        name: _collectionNameController.text,
        description: _descriptionController.text,
        rules: _rules,
        logic: _logic,
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Collection created successfully!')));

    Navigator.pop(context);
  }
}

// Add this event to SmartCollectionsBloc
class CreateCollectionEvent extends SmartCollectionsEvent {
  final String name;
  final String description;
  final List<Map<String, dynamic>> rules;
  final String logic;

  CreateCollectionEvent({
    required this.name,
    required this.description,
    required this.rules,
    required this.logic,
  });
}
