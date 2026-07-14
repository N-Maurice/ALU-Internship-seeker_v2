import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Wraps Firebase Auth. Callers (Riverpod notifiers) are responsible for
/// catching exceptions and translating them via `core/errors`.
abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;

  Future<UserCredential> signUp({required String email, required String password});
  Future<UserCredential> signIn({required String email, required String password});
  Future<UserCredential> signInWithGoogle();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> reloadCurrentUser();
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInReady = false;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  @override
  Future<UserCredential> signInWithGoogle() async {
    if (!_googleSignInReady) {
      await _googleSignIn.initialize();
      _googleSignInReady = true;
    }
    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _auth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    if (_googleSignInReady) {
      await _googleSignIn.signOut();
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<void> reloadCurrentUser() async {
    await _auth.currentUser?.reload();
  }
}
