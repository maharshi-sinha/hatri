import '../../../../core/error/failures.dart';
import '../../../../core/models/models.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/creator_repository.dart';

class GetCreators extends UseCase<List<CreatorProfile>, NoParams> {
  final CreatorRepository repo;
  const GetCreators(this.repo);
  @override
  Future<Either<Failure, List<CreatorProfile>>> call(NoParams _) =>
      repo.getCreators();
}

class GetCreatorById extends UseCase<CreatorProfile?, String> {
  final CreatorRepository repo;
  const GetCreatorById(this.repo);
  @override
  Future<Either<Failure, CreatorProfile?>> call(String id) =>
      repo.getById(id);
}
