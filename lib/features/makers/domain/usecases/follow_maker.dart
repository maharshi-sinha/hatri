import '../../../../backend/models/maker_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/maker_repository.dart';

class FollowMaker extends UseCase<FollowResult, String> {
  final MakerRepository repo;
  const FollowMaker(this.repo);

  @override
  Future<Either<Failure, FollowResult>> call(String id) => repo.follow(id);
}

class UnfollowMaker extends UseCase<FollowResult, String> {
  final MakerRepository repo;
  const UnfollowMaker(this.repo);

  @override
  Future<Either<Failure, FollowResult>> call(String id) => repo.unfollow(id);
}
