import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hatri/backend/api/api_exception.dart' as api;
import 'package:hatri/core/error/failures.dart';
import 'package:hatri/core/models/models.dart';
import 'package:hatri/core/repositories/event_feed_page.dart';
import 'package:hatri/features/events/data/datasources/events_remote_data_source.dart';
import 'package:hatri/features/events/data/repositories/event_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

/// Repository-level test: wires EventRepositoryImpl against a mock
/// datasource and asserts the ApiException -> Failure mapping produces
/// the right Failure subtype for each case.

class _MockRemote extends Mock implements EventsRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late EventRepositoryImpl repo;

  setUp(() {
    remote = _MockRemote();
    repo = EventRepositoryImpl(remote);
  });

  test('getEvents happy path returns Right(EventFeedPage)', () async {
    when(() => remote.getFeedPage(
          citySlug: any(named: 'citySlug'),
          category: any(named: 'category'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async =>
        const EventFeedPage(events: <Event>[], nextCursor: null));

    final result = await repo.getEvents();

    expect(result.isRight(), isTrue);
    result.fold(
      (f) => fail('expected Right, got $f'),
      (page) => expect(page.events, isEmpty),
    );
  });

  test('getEvents maps NetworkException to NetworkFailure', () async {
    when(() => remote.getFeedPage(
          citySlug: any(named: 'citySlug'),
          category: any(named: 'category'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        )).thenThrow(const api.NetworkException('offline'));

    final result = await repo.getEvents();

    expect(result, isA<Left<Failure, EventFeedPage>>());
    result.fold(
      (f) => expect(f, isA<NetworkFailure>()),
      (_) => fail('expected Left'),
    );
  });

  test('getEvents maps UnauthorizedException to AuthFailure', () async {
    when(() => remote.getFeedPage(
          citySlug: any(named: 'citySlug'),
          category: any(named: 'category'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        )).thenThrow(const api.UnauthorizedException('expired'));

    final result = await repo.getEvents();

    result.fold(
      (f) => expect(f, isA<AuthFailure>()),
      (_) => fail('expected Left'),
    );
  });

  test('getEvents maps 422 ClientException to ValidationFailure', () async {
    when(() => remote.getFeedPage(
          citySlug: any(named: 'citySlug'),
          category: any(named: 'category'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        )).thenThrow(const api.ClientException(422, 'bad body'));

    final result = await repo.getEvents();

    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('expected Left'),
    );
  });

  test('getEvents maps ServerException to ServerFailure', () async {
    when(() => remote.getFeedPage(
          citySlug: any(named: 'citySlug'),
          category: any(named: 'category'),
          cursor: any(named: 'cursor'),
          limit: any(named: 'limit'),
        )).thenThrow(const api.ServerException(500, 'boom'));

    final result = await repo.getEvents();

    result.fold(
      (f) {
        expect(f, isA<ServerFailure>());
        expect((f as ServerFailure).statusCode, 500);
      },
      (_) => fail('expected Left'),
    );
  });
}
