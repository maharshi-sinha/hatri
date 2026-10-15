import '../../../../backend/models/maker_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either_x.dart';

/// Clean-arch contract for the Makers feature. Mirrors MakersApi 1:1
/// but returns Either<Failure, T>. Entity location: ApiMakerFeed +
/// ApiMakerDetail + FollowResult still live under `backend/models/`;
/// a later PR moves them to `features/makers/domain/entities/`.
abstract class MakerRepository {
  Future<Either<Failure, ApiMakerFeed>> list({
    String? citySlug,
    String? category,
    String? cursor,
    String? q,
    int limit,
  });

  Future<Either<Failure, ApiMakerDetail>> getById(String id);

  Future<Either<Failure, FollowResult>> follow(String id);
  Future<Either<Failure, FollowResult>> unfollow(String id);
}
