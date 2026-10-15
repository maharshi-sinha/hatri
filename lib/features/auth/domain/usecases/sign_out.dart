import '../../../../core/error/failures.dart';
import '../../../../core/usecases/no_params.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/auth_repository.dart';

class SignOut extends UseCase<void, NoParams> {
  final AuthRepository repo;
  const SignOut(this.repo);

  @override
  Future<Either<Failure, void>> call(NoParams _) => repo.signOut();
}
