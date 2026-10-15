import '../../../../core/error/failures.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/either_x.dart';

/// Clean-arch contract. No backend endpoint yet; today the datasource is
/// the hardcoded mock list in core/repositories/mock_repository.dart.
abstract class CreatorRepository {
  Future<Either<Failure, List<CreatorProfile>>> getCreators();
  Future<Either<Failure, CreatorProfile?>> getById(String id);
}
