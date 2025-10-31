import 'package:floatit/src/shared/errors/failures.dart';

/// Either type for handling success and failure cases
/// Left represents failure, Right represents success
abstract class Either<L, R> {
  const Either();

  /// Create a Left (failure) instance
  factory Either.left(L value) => Left<L, R>(value);

  /// Create a Right (success) instance
  factory Either.right(R value) => Right<L, R>(value);

  /// Check if this is a Left (failure)
  bool get isLeft;

  /// Check if this is a Right (success)
  bool get isRight;

  /// Get the Left value, throws if Right
  L get left;

  /// Get the Right value, throws if Left
  R get right;

  /// Fold the Either into a single value
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn);

  /// Map the Right value to a new type
  Either<L, T> map<T>(T Function(R right) fn);

  /// Map the Left value to a new type
  Either<T, R> mapLeft<T>(T Function(L left) fn);

  /// Flat map for chaining operations
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) fn);

  /// Get the Right value or a default
  R getOrElse(R Function() defaultFn);

  /// Convert to nullable Right value
  R? toOption();
}

/// Left implementation (failure case)
class Left<L, R> extends Either<L, R> {
  final L _value;

  const Left(this._value);

  @override
  bool get isLeft => true;

  @override
  bool get isRight => false;

  @override
  L get left => _value;

  @override
  R get right => throw StateError('Cannot get right value from Left');

  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) {
    return leftFn(_value);
  }

  @override
  Either<L, T> map<T>(T Function(R right) fn) {
    return Left<L, T>(_value);
  }

  @override
  Either<T, R> mapLeft<T>(T Function(L left) fn) {
    return Left<T, R>(fn(_value));
  }

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) fn) {
    return Left<L, T>(_value);
  }

  @override
  R getOrElse(R Function() defaultFn) {
    return defaultFn();
  }

  @override
  R? toOption() => null;
}

/// Right implementation (success case)
class Right<L, R> extends Either<L, R> {
  final R _value;

  const Right(this._value);

  @override
  bool get isLeft => false;

  @override
  bool get isRight => true;

  @override
  L get left => throw StateError('Cannot get left value from Right');

  @override
  R get right => _value;

  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) {
    return rightFn(_value);
  }

  @override
  Either<L, T> map<T>(T Function(R right) fn) {
    return Right<L, T>(fn(_value));
  }

  @override
  Either<T, R> mapLeft<T>(T Function(L left) fn) {
    return Right<T, R>(_value);
  }

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) fn) {
    return fn(_value);
  }

  @override
  R getOrElse(R Function() defaultFn) {
    return _value;
  }

  @override
  R? toOption() => _value;
}

/// Type alias for common Either usage with Failure
typedef Result<T> = Either<Failure, T>;
