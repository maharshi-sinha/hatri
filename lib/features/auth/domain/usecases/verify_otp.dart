import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp extends UseCase<void, VerifyOtpParams> {
  final AuthRepository repo;
  const VerifyOtp(this.repo);

  @override
  Future<Either<Failure, void>> call(VerifyOtpParams p) =>
      repo.verifyOtp(p.phone, p.otp);
}

class VerifyOtpParams extends Equatable {
  final String phone;
  final String otp;
  const VerifyOtpParams({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}
