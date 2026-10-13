import '../../backend/services/auth_service.dart';
import '../di/injection_container.dart';
import '../models/models.dart' show currentUser;

/// Keeps the legacy mock-era [currentUser] global in sync with the real
/// [ApiUser] held by [AuthService]. The onboarding screens and the profile
/// screen still read from [currentUser], so without this the profile would
/// show the "AAROHI SHARMA" placeholder on every launch where the user is
/// restored from secure storage (name/bio/avatar fields on currentUser start
/// empty and the UI falls back to the mock copy).
///
/// Long-term we should delete [currentUser] and read from AuthService
/// directly. Until then, call [installUserSync] once at app boot.
void installUserSync() {
  final auth = sl<AuthService>();
  _hydrate(auth);
  auth.state.addListener(() => _hydrate(auth));
}

void _hydrate(AuthService auth) {
  final u = auth.user;
  if (u == null) {
    currentUser.name = '';
    currentUser.bio = '';
    currentUser.profileImage = '';
    currentUser.birthday = '';
    currentUser.gender = '';
    currentUser.energy = '';
    currentUser.interests = const [];
    return;
  }
  currentUser.name = u.displayName ?? '';
  currentUser.bio = u.bio ?? '';
  currentUser.profileImage = u.avatarUrl ?? '';
  currentUser.birthday = u.dob ?? '';
  currentUser.gender = u.gender ?? '';
  currentUser.energy = u.energy ?? '';
  currentUser.interests = List<String>.from(u.interests);
}
