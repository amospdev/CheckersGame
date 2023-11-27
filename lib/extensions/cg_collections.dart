import 'package:untitled/extensions/cg_optional.dart';

extension IterableExtensions<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) predicate) {
    try {
      return firstWhere(predicate);
    } catch (e) {
      return null;
    }
  }

  Iterable<E> doOnItem(void Function(E) action) {
    for (var item in this) {
      action(item);
    }
    return this;
  }

  Optional<E> firstWhereOrAbsent(bool Function(E) test) {
    for (var element in this) {
      if (test(element)) {
        return Optional.of(element);
      }
    }
    return Optional<E>.empty();
  }

  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}

extension ListExtensions<T> on List<T> {
  List<T> addItem(T value) {
    add(value);
    return this;
  }
}
