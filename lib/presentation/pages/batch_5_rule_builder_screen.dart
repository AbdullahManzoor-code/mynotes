import 'package:flutter/material.dart';
import 'package:mynotes/domain/services/rule_evaluation_engine.dart';

/// Rule Builder Screen - Batch 5, Screen 2
class RuleBuilderScreen extends StatefulWidget {
  final Map<String, dynamic>? existingRule;

  const RuleBuilderScreen({Key? key, this.existingRule}) : super(key: key);

  @override
  State<RuleBuilderScreen> createState() => _RuleBuilderScreenState();
}

class _RuleBuilderScreenState extends State<RuleBuilderScreen> {
  final _ruleEngine = RuleEvaluationEngine();
  final _fieldController = TextEditingController();
  final _valueController = TextEditingController();
  String _selectedOperator = '=';
  List<Map<String, dynamic>> _builtRules = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingRule != null) {
      _fieldController.text = widget.existingRule!['field'] ?? '';
      _selectedOperator = widget.existingRule!['operator'] ?? '=';
      _valueController.text = widget.existingRule!['value']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _fieldController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rule Builder'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rules Guide
            _buildRulesGuide(),
            const SizedBox(height: 24),

            // Rule Input
            _buildRuleInput(),
            const SizedBox(height: 24),

            // Built Rules Preview
            _buildRulesPreview(),
            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rule Components',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGuideItem(
                  'Field',
                  'The property to check (e.g., type, size)',
                ),
                _buildGuideItem(
                  'Operator',
                  'How to compare (=, >, <, ~, ^, \$, ∈)',
                ),
                _buildGuideItem('Value', 'The value to compare against'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuideItem(String label, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(description, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildRuleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Build Your Rule',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Field Input
        TextField(
          controller: _fieldController,
          decoration: InputDecoration(
            labelText: 'Field Name',
            hintText: 'e.g., type, size, name',
            prefixIcon: Icon(Icons.category),
            border: OutlineInputBorder(),
            suffixIcon: PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text('type'),
                  onTap: () => _fieldController.text = 'type',
                ),
                PopupMenuItem(
                  child: Text('size'),
                  onTap: () => _fieldController.text = 'size',
                ),
                PopupMenuItem(
                  child: Text('name'),
                  onTap: () => _fieldController.text = 'name',
                ),
                PopupMenuItem(
                  child: Text('createdAt'),
                  onTap: () => _fieldController.text = 'createdAt',
                ),
                PopupMenuItem(
                  child: Text('tags'),
                  onTap: () => _fieldController.text = 'tags',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Operator Selection
        DropdownButtonFormField<String>(
          value: _selectedOperator,
          items: _ruleEngine.getSupportedOperators().map((op) {
            return DropdownMenuItem(
              value: op,
              child: Text(_getOperatorLabel(op)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedOperator = value ?? '=';
            });
          },
          decoration: InputDecoration(
            labelText: 'Operator',
            prefixIcon: Icon(Icons.compare),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _getOperatorDescription(_selectedOperator),
          style: Theme.of(context).textTheme.labelSmall,
        ),
        const SizedBox(height: 16),

        // Value Input
        TextField(
          controller: _valueController,
          decoration: InputDecoration(
            labelText: 'Value',
            hintText: 'The value to compare',
            prefixIcon: Icon(Icons.edit),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Add Rule Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(Icons.add),
            label: Text('Add This Rule'),
            onPressed: _addRule,
          ),
        ),
      ],
    );
  }

  Widget _buildRulesPreview() {
    if (_builtRules.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.rule, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text('No rules added yet'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rules (${_builtRules.length})',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _builtRules.length,
          itemBuilder: (context, index) {
            final rule = _builtRules[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(
                  '${rule['field']} ${_getOperatorLabel(rule['operator'])} ${rule['value']}',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _builtRules.removeAt(index);
                    });
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.clear),
          label: Text('Clear All'),
          onPressed: () {
            setState(() {
              _builtRules.clear();
            });
          },
        ),
        ElevatedButton.icon(
          icon: Icon(Icons.check),
          label: Text('Save Rules'),
          onPressed: () {
            Navigator.pop(context, _builtRules);
          },
        ),
      ],
    );
  }

  void _addRule() async {
    final field = _fieldController.text.trim();
    final value = _valueController.text.trim();

    if (field.isEmpty || value.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    final rule = {
      'field': field,
      'operator': _selectedOperator,
      'value': value,
    };

    // Validate rule
    final isValid = await _ruleEngine.validateRule(rule);

    if (isValid) {
      setState(() {
        _builtRules.add(rule);
        _fieldController.clear();
        _valueController.clear();
        _selectedOperator = '=';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Rule added successfully!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid rule. Please check your input.')),
      );
    }
  }

  String _getOperatorLabel(String operator) {
    switch (operator) {
      case 'equals':
        return 'Equals (=)';
      case 'contains':
        return 'Contains (~)';
      case 'greaterThan':
        return 'Greater Than (>)';
      case 'lessThan':
        return 'Less Than (<)';
      case 'startsWith':
        return 'Starts With (^)';
      case 'endsWith':
        return 'Ends With (\$)';
      case 'inList':
        return 'In List (∈)';
      default:
        return operator;
    }
  }

  String _getOperatorDescription(String operator) {
    switch (operator) {
      case 'equals':
        return 'The field must equal the value exactly';
      case 'contains':
        return 'The field must contain the value';
      case 'greaterThan':
        return 'The field must be greater than the value';
      case 'lessThan':
        return 'The field must be less than the value';
      case 'startsWith':
        return 'The field must start with the value';
      case 'endsWith':
        return 'The field must end with the value';
      case 'inList':
        return 'The field must be in the list (comma-separated)';
      default:
        return '';
    }
  }
}

