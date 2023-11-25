import 'package:untitled/extensions/cg_optional.dart';

extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) predicate) {
    try {
      return firstWhere(predicate);
    } catch (e) {
      return null;
    }
  }

  Iterable<T> doOnItem(void Function(T) action) {
    for (var item in this) {
      action(item);
    }
    return this;
  }

  Optional<T> firstWhereOrAbsent(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) {
        return Optional.of(element);
      }
    }
    return Optional<T>.empty();
  }
}

extension ListExtensions<T> on List<T> {
  List<T> addItem(T value) {
    add(value);
    return this;
  }
}
