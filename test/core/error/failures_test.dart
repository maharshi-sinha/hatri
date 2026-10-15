import 'package:flutter_test/flutter_test.dart';
import 'package:hatri/core/error/failures.dart';

/// Smoke tests for the sealed Failure hierarchy. Confirms the subtypes
/// still extend Failure (sealed-exhaustive matching in blocs relies on
/// this) and that equatable equality holds within a type.
void main() {
  group('Failure', () {
    test('all variants are subtypes of Failure', () {
      final failures = <Failure>[
        const NetworkFailure(),
        const ServerFailure('x', statusCode: 500),
        const NotFoundFailure(),
        const AuthFailure(),
        const ValidationFailure('invalid'),
        const CacheFailure(),
        const UnknownFailure(),
      ];
      for (final f in failures) {
        expect(f, isA<Failure>());
      }
    });

    test('equatable: same type + same message is equal', () {
      expect(
        const NetworkFailure('offline'),
        equals(const NetworkFailure('offline')),
      );
      expect(
        const ServerFailure('oops', statusCode: 500),
        equals(const ServerFailure('oops', statusCode: 500)),
      );
    });

    test('equatable: different status codes are not equal', () {
      expect(
        const ServerFailure('oops', statusCode: 500),
        isNot(equals(const ServerFailure('oops', statusCode: 503))),
      );
    });
  });
}
