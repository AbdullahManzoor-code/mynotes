/// Extension methods on List for convenient manipulation and searching
extension ListExtensions<T> on List<T> {
  /// Check if list is empty
  bool get isEmpty => length == 0;

  /// Check if list is not empty
  bool get isNotEmpty => length > 0;

  /// Get first element or null
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }

  /// Get last element or null
  T? get lastOrNull {
    if (isEmpty) return null;
    return last;
  }

  /// Get element at index or null
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Safely get sublist
  List<T> getRange(int start, int end) {
    if (start < 0) start = 0;
    if (end > length) end = length;
    if (start >= end) return [];
    return sublist(start, end);
  }

  /// Remove all null values (for List<T?>)
  List<T> removeNulls() {
    return whereType<T>().toList();
  }

  /// Duplicate list with all elements
  List<T> duplicate() => List<T>.from(this);

  /// Reverse list without modifying original
  List<T> reversed2() => [...this].reversed.toList();

  /// Shuffle list without modifying original
  List<T> shuffled() {
    final list = List<T>.from(this);
    list.shuffle();
    return list;
  }

  /// Sort list without modifying original
  List<T> sorted(Comparable Function(T a, T b) compare) {
    final list = List<T>.from(this);
    list.sort((a, b) => compare(a, b).compareTo(0));
    return list;
  }

  /// Get unique elements
  List<T> getUnique() {
    return toSet().toList();
  }

  /// Combine two lists
  List<T> combine(List<T> other) => [...this, ...other];

  /// Flatten nested list (one level)
  List<T> flatten() {
    final result = <T>[];
    for (final item in this) {
      if (item is List) {
        result.addAll(item as List<T>);
      } else {
        result.add(item);
      }
    }
    return result;
  }

  /// Group list elements by key
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final key = keySelector(item);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  /// Chunk list into smaller lists
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }

  /// Get elements at specified indices
  List<T> getAt(List<int> indices) {
    return indices.map((i) => this[i]).toList();
  }

  /// Separate elements by predicate
  (List<T> matches, List<T> nonMatches) partition(bool Function(T) test) {
    final matches = <T>[];
    final nonMatches = <T>[];
    for (final item in this) {
      if (test(item)) {
        matches.add(item);
      } else {
        nonMatches.add(item);
      }
    }
    return (matches, nonMatches);
  }

  /// Check if all elements match predicate
  bool allMatch(bool Function(T) test) => every(test);

  /// Check if any element matches predicate
  bool anyMatch(bool Function(T) test) => any(test);

  /// Count elements matching predicate
  int countWhere(bool Function(T) test) => where(test).length;

  /// Find element matching predicate or return null
  T? findOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (_) {
      return null;
    }
  }

  /// Insert element at position
  List<T> insertAt(int index, T element) {
    final list = List<T>.from(this);
    list.insert(index, element);
    return list;
  }

  /// Remove element at position
  List<T> removeAt2(int index) {
    final list = List<T>.from(this);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
    }
    return list;
  }

  /// Replace element at position
  List<T> replaceAt(int index, T element) {
    final list = List<T>.from(this);
    if (index >= 0 && index < list.length) {
      list[index] = element;
    }
    return list;
  }

  /// Slice list (start inclusive, end exclusive)
  List<T> slice(int start, [int? end]) {
    end ??= length;
    if (start < 0) start = 0;
    if (end > length) end = length;
    if (start >= end) return [];
    return sublist(start, end);
  }

  /// Intersperse separator between elements
  List<T> intersperse(T separator) {
    if (isEmpty) return [];
    final result = <T>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }

  /// Find index of element
  int indexOfElement(T element) => indexOf(element);

  /// Find last index of element
  int lastIndexOfElement(T element) => lastIndexOf(element);

  /// Check if list contains all elements from other list
  bool containsAll(List<T> other) => other.every((e) => contains(e));

  /// Check if list contains any element from other list
  bool containsAny(List<T> other) => other.any((e) => contains(e));

  /// Get sum of numeric list (for List<num>)
  num sum() {
    num total = 0;
    for (final item in this) {
      if (item is num) total += item;
    }
    return total;
  }

  /// Get average of numeric list (for List<num>)
  num average() {
    if (isEmpty) return 0;
    return sum() / length;
  }

  /// Zip two lists together
  List<(T, U)> zip<U>(List<U> other) {
    final result = <(T, U)>[];
    for (var i = 0; i < length && i < other.length; i++) {
      result.add((this[i], other[i]));
    }
    return result;
  }
}
