import '../../../../backend/models/auth_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/auth_repository.dart';

class RequestOtp extends UseCase<OtpRequestResult, String> {
  final AuthRepository repo;
  const RequestOtp(this.repo);

  @override
  Future<Either<Failure, OtpRequestResult>> call(String phone) =>
      repo.requestOtp(phone);
}
