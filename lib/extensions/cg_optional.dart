class Optional<T> {
  final T? _value;

  // const Optional._internal(this._value);

  const Optional.empty() : _value = null;

  const Optional.of(T value) : _value = value;

  bool get isPresent => _value != null;

  bool get isAbsent => !isPresent;

  T get value {
    if (_value == null) {
      throw StateError('Value is absent');
    }
    return _value!;
  }

  T orElse(T defaultValue) => _value ?? defaultValue;

  bool condition(bool Function(Optional<T>) predicate) {
    if (isPresent && predicate(Optional.of(_value as T))) {
      return true;
    }
    return false;
  }

  Optional<U> map<U>(U Function(Optional<T>) mapper) {
    if (!isPresent) {
      return Optional<U>.empty();
    }
    return Optional<U>.of(mapper(Optional.of(_value as T)));
  }

  void ifPresent(void Function(T) consumer) {
    if (isPresent) {
      consumer(_value as T);
    }
  }
}
