import '../../../../core/error/failures.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/either_x.dart';

/// Clean-arch contract for Communities. Current backing is still the
/// mock datasource (no backend endpoint yet). The real datasource will
/// slot in behind this same interface once the API ships.
abstract class CommunityRepository {
  Future<Either<Failure, List<Community>>> getCommunities();
}
