import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/event_repository.dart';

class ShareEvent extends UseCase<int, String> {
  final EventRepository repo;
  const ShareEvent(this.repo);

  @override
  Future<Either<Failure, int>> call(String id) => repo.share(id);
}
