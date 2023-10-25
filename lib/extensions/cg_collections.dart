import 'package:untitled/extensions/cg_optional.dart';

extension FirstWhereOrNullExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) predicate) {
    try {
      return firstWhere(predicate);
    } catch (e) {
      return null;
    }
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
