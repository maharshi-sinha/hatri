import '../../../../core/error/failures.dart';
import '../../../../core/models/models.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/community_repository.dart';

class GetCommunities extends UseCase<List<Community>, NoParams> {
  final CommunityRepository repo;
  const GetCommunities(this.repo);

  @override
  Future<Either<Failure, List<Community>>> call(NoParams _) =>
      repo.getCommunities();
}
