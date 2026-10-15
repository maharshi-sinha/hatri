import 'package:flutter/foundation.dart';

import '../../../../backend/api/api_exception.dart' as api;
import '../../../../backend/models/auth_models.dart';
import '../../../../backend/services/auth_service.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either_x.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementation wraps the existing [AuthService] so the complex JWT
/// lifecycle (refresh coalescing, HttpClient wiring, secure storage,
/// ValueNotifier broadcasts) stays intact. The repository is a thin
/// Either-returning facade that catches ApiException and surfaces
/// typed Failures.
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _auth;
  const AuthRepositoryImpl(this._auth);

  @override
  Future<Either<Failure, OtpRequestResult>> requestOtp(String phone) =>
      _guard(() => _auth.requestOtp(phone));

  @override
  Future<Either<Failure, void>> verifyOtp(String phone, String otp) =>
      _guard(() => _auth.verifyOtp(phone, otp));

  @override
  Future<Either<Failure, void>> signInWithMsg91Token(
    String accessToken, {
    String? phone,
  }) =>
      _guard(() => _auth.signInWithMsg91Token(accessToken, phone: phone));

  @override
  Future<Either<Failure, void>> signOut() => _guard(() => _auth.signOut());

  @override
  Future<Either<Failure, void>> updateCachedUser(ApiUser user) =>
      _guard(() => _auth.updateCachedUser(user));

  @override
  ApiUser? get currentUser => _auth.user;

  @override
  bool get isSignedIn => _auth.isSignedIn;

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() op) async {
    try {
      final value = await op();
      return Right(value);
    } on api.UnauthorizedException catch (e) {
      return Left(AuthFailure(e.message));
    } on api.NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on api.ClientException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 422) {
        return Left(ValidationFailure(e.message));
      }
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on api.ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on api.NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e, s) {
      debugPrint('AuthRepositoryImpl: unexpected $e\n$s');
      return Left(UnknownFailure(e.toString()));
    }
  }
}
