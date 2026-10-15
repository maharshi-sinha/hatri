import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/event_repository.dart';

class SaveEvent extends UseCase<int, String> {
  final EventRepository repo;
  const SaveEvent(this.repo);

  @override
  Future<Either<Failure, int>> call(String id) => repo.save(id);
}

class UnsaveEvent extends UseCase<int, String> {
  final EventRepository repo;
  const UnsaveEvent(this.repo);

  @override
  Future<Either<Failure, int>> call(String id) => repo.unsave(id);
}
