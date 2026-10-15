import '../../../../backend/models/auth_models.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/either_x.dart';

/// Clean-arch contract for the Auth feature. Wraps the token-lifecycle
/// behaviours that today live in `backend/services/AuthService`. The
/// infrastructure concerns (secure storage, HttpClient wiring, the
/// ValueNotifier<AuthState> broadcast, analytics identify side-effects)
/// stay inside AuthService; this interface only exposes the user-facing
/// verbs the sign-in flow calls.
///
/// ApiUser + OtpRequestResult are still physically under
/// `backend/models/`. A later PR moves them under
/// `features/auth/domain/entities/`.
abstract class AuthRepository {
  /// Send an OTP to the given E.164 phone number.
  Future<Either<Failure, OtpRequestResult>> requestOtp(String phone);

  /// Verify the OTP. On success the implementation persists tokens and
  /// flips the auth-state broadcast to signedIn as a side-effect.
  Future<Either<Failure, void>> verifyOtp(String phone, String otp);

  /// MSG91 widget sign-in: exchange the short-lived widget token for our
  /// JWT pair.
  Future<Either<Failure, void>> signInWithMsg91Token(
    String accessToken, {
    String? phone,
  });

  /// Local + remote sign-out. Always succeeds locally; the server call
  /// is best-effort.
  Future<Either<Failure, void>> signOut();

  /// Replace the cached ApiUser after a profile PATCH.
  Future<Either<Failure, void>> updateCachedUser(ApiUser user);

  /// The last known user, or null before sign-in. Reads from AuthService's
  /// in-memory cache so is cheap and sync-ish.
  ApiUser? get currentUser;

  /// True when a valid access token is present.
  bool get isSignedIn;
}
