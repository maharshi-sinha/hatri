import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/either_x.dart';
import '../repositories/auth_repository.dart';

class SignInWithMsg91 extends UseCase<void, SignInWithMsg91Params> {
  final AuthRepository repo;
  const SignInWithMsg91(this.repo);

  @override
  Future<Either<Failure, void>> call(SignInWithMsg91Params p) =>
      repo.signInWithMsg91Token(p.accessToken, phone: p.phone);
}

class SignInWithMsg91Params extends Equatable {
  final String accessToken;
  final String? phone;
  const SignInWithMsg91Params({required this.accessToken, this.phone});

  @override
  List<Object?> get props => [accessToken, phone];
}
