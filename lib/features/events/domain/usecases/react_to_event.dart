import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/event_repository.dart';

class ReactToEvent extends UseCase<bool, ReactToEventParams> {
  final EventRepository repo;
  const ReactToEvent(this.repo);

  @override
  Future<Either<Failure, bool>> call(ReactToEventParams p) =>
      repo.react(p.eventId, p.reaction);
}

class ReactToEventParams extends Equatable {
  final String eventId;
  final String reaction;
  const ReactToEventParams({required this.eventId, required this.reaction});

  @override
  List<Object?> get props => [eventId, reaction];
}
