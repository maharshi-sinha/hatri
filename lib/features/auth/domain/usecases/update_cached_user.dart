import '../../../../backend/models/auth_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/auth_repository.dart';

class UpdateCachedUser extends UseCase<void, ApiUser> {
  final AuthRepository repo;
  const UpdateCachedUser(this.repo);

  @override
  Future<Either<Failure, void>> call(ApiUser user) =>
      repo.updateCachedUser(user);
}
