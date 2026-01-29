import 'package:mynotes/domain/repositories/smart_collection_repository.dart';

/// Rule evaluation engine for smart collections
class RuleEvaluationEngine {
  static final RuleEvaluationEngine _instance =
      RuleEvaluationEngine._internal();

  factory RuleEvaluationEngine() {
    return _instance;
  }

  RuleEvaluationEngine._internal();

  /// Rule operator types
  static const String opEquals = 'equals';
  static const String opContains = 'contains';
  static const String opGreaterThan = 'greaterThan';
  static const String opLessThan = 'lessThan';
  static const String opStartsWith = 'startsWith';
  static const String opEndsWith = 'endsWith';
  static const String opInList = 'inList';

  /// Logical operators
  static const String logicAnd = 'AND';
  static const String logicOr = 'OR';

  /// Evaluate a single rule against an item
  Future<bool> evaluateRule({
    required dynamic item,
    required Map<String, dynamic> rule,
  }) async {
    try {
      final field = rule['field'] as String;
      final operator = rule['operator'] as String;
      final value = rule['value'];

      final itemValue = _getItemField(item, field);

      return _compareValues(itemValue, operator, value);
    } catch (e) {
      throw Exception('Rule evaluation failed: ${e.toString()}');
    }
  }

  /// Evaluate multiple rules with logical operators
  Future<bool> evaluateRuleSet({
    required dynamic item,
    required List<Map<String, dynamic>> rules,
    String logic = logicAnd,
  }) async {
    try {
      if (rules.isEmpty) return true;

      final results = <bool>[];

      for (final rule in rules) {
        final result = await evaluateRule(item: item, rule: rule);
        results.add(result);
      }

      if (logic == logicAnd) {
        return results.every((r) => r);
      } else if (logic == logicOr) {
        return results.any((r) => r);
      }

      return false;
    } catch (e) {
      throw Exception('Rule set evaluation failed: ${e.toString()}');
    }
  }

  /// Evaluate nested rule groups (complex conditions)
  Future<bool> evaluateComplexRules({
    required dynamic item,
    required Map<String, dynamic> ruleGroup,
  }) async {
    try {
      final logic = ruleGroup['logic'] as String? ?? logicAnd;
      final rules = ruleGroup['rules'] as List<dynamic>? ?? [];
      final nestedGroups = ruleGroup['groups'] as List<dynamic>? ?? [];

      final results = <bool>[];

      // Evaluate direct rules
      for (final rule in rules) {
        final result = await evaluateRule(
          item: item,
          rule: rule as Map<String, dynamic>,
        );
        results.add(result);
      }

      // Evaluate nested groups
      for (final group in nestedGroups) {
        final result = await evaluateComplexRules(
          item: item,
          ruleGroup: group as Map<String, dynamic>,
        );
        results.add(result);
      }

      if (results.isEmpty) return true;

      if (logic == logicAnd) {
        return results.every((r) => r);
      } else {
        return results.any((r) => r);
      }
    } catch (e) {
      throw Exception('Complex rule evaluation failed: ${e.toString()}');
    }
  }

  /// Filter items by rule set
  Future<List<dynamic>> filterByRules({
    required List<dynamic> items,
    required List<Map<String, dynamic>> rules,
    String logic = logicAnd,
  }) async {
    try {
      final filtered = <dynamic>[];

      for (final item in items) {
        final matches = await evaluateRuleSet(
          item: item,
          rules: rules,
          logic: logic,
        );

        if (matches) {
          filtered.add(item);
        }
      }

      return filtered;
    } catch (e) {
      throw Exception('Rule filtering failed: ${e.toString()}');
    }
  }

  /// Validate rule syntax
  Future<bool> validateRule(Map<String, dynamic> rule) async {
    try {
      final field = rule['field'];
      final operator = rule['operator'];
      final value = rule['value'];

      if (field == null || field.toString().isEmpty) return false;
      if (operator == null || !_isValidOperator(operator as String)) {
        return false;
      }
      if (value == null) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get list of supported operators
  List<String> getSupportedOperators() {
    return [
      opEquals,
      opContains,
      opGreaterThan,
      opLessThan,
      opStartsWith,
      opEndsWith,
      opInList,
    ];
  }

  /// Get field value from item
  dynamic _getItemField(dynamic item, String field) {
    try {
      final fields = field.split('.');
      dynamic value = item;

      for (final f in fields) {
        if (value is Map) {
          value = value[f];
        } else if (value is dynamic) {
          try {
            value = (value as dynamic).toMap()[f] ?? value;
          } catch (_) {
            return null;
          }
        }
      }

      return value;
    } catch (e) {
      return null;
    }
  }

  /// Compare values using operator
  bool _compareValues(dynamic itemValue, String operator, dynamic ruleValue) {
    try {
      if (itemValue == null) {
        return operator == opEquals && ruleValue == null;
      }

      switch (operator) {
        case opEquals:
          return itemValue == ruleValue;

        case opContains:
          return itemValue.toString().contains(ruleValue.toString());

        case opGreaterThan:
          final numItem = num.tryParse(itemValue.toString());
          final numRule = num.tryParse(ruleValue.toString());
          return numItem != null && numRule != null && numItem > numRule;

        case opLessThan:
          final numItem = num.tryParse(itemValue.toString());
          final numRule = num.tryParse(ruleValue.toString());
          return numItem != null && numRule != null && numItem < numRule;

        case opStartsWith:
          return itemValue.toString().startsWith(ruleValue.toString());

        case opEndsWith:
          return itemValue.toString().endsWith(ruleValue.toString());

        case opInList:
          if (ruleValue is List) {
            return ruleValue.contains(itemValue);
          }
          return false;

        default:
          return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Check if operator is valid
  bool _isValidOperator(String operator) {
    return getSupportedOperators().contains(operator);
  }

  /// Generate rule summary for display
  Future<String> generateRuleSummary(Map<String, dynamic> rule) async {
    try {
      final field = rule['field'] as String? ?? 'field';
      final operator = rule['operator'] as String? ?? 'unknown';
      final value = rule['value'].toString();

      final operatorLabel = _operatorToLabel(operator);

      return '$field $operatorLabel $value';
    } catch (e) {
      return 'Invalid rule';
    }
  }

  /// Convert operator to human-readable label
  String _operatorToLabel(String operator) {
    switch (operator) {
      case opEquals:
        return 'equals';
      case opContains:
        return 'contains';
      case opGreaterThan:
        return 'is greater than';
      case opLessThan:
        return 'is less than';
      case opStartsWith:
        return 'starts with';
      case opEndsWith:
        return 'ends with';
      case opInList:
        return 'is in';
      default:
        return operator;
    }
  }
}
