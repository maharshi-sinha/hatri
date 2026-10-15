import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hatri/core/error/failures.dart';
import 'package:hatri/core/models/models.dart';
import 'package:hatri/core/repositories/event_feed_page.dart';
import 'package:hatri/features/events/domain/repositories/event_repository.dart';
import 'package:hatri/features/events/domain/usecases/get_events.dart';
import 'package:mocktail/mocktail.dart';

/// Use-case-level test: GetEvents just forwards to the repository. The
/// test exists to lock the forwarding contract so a refactor can't
/// silently drop params.

class _MockRepo extends Mock implements EventRepository {}

void main() {
  late _MockRepo repo;
  late GetEvents usecase;

  setUp(() {
    repo = _MockRepo();
    usecase = GetEvents(repo);
  });

  test('forwards params to repository.getEvents', () async {
    when(() => repo.getEvents(
          cursor: any(named: 'cursor'),
          citySlug: any(named: 'citySlug'),
          category: any(named: 'category'),
          limit: any(named: 'limit'),
        )).thenAnswer((_) async => const Right<Failure, EventFeedPage>(
          EventFeedPage(events: <Event>[], nextCursor: null),
        ));

    const params = GetEventsParams(
      cursor: 'abc',
      citySlug: 'raipur',
      category: 'music',
      limit: 50,
    );
    await usecase(params);

    verify(() => repo.getEvents(
          cursor: 'abc',
          citySlug: 'raipur',
          category: 'music',
          limit: 50,
        )).called(1);
  });
}
