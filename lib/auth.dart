import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneymanager/queries.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  User? get currentUser => _firebaseAuth.currentUser;
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future signInWithGoogle() async {
    final googleUser = await googleSignIn.signIn();

    if (googleUser == null) return;
    _user = googleUser;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _firebaseAuth.signInWithCredential(credential);
    await saveUser(
        googleUser.email, googleUser.displayName!, googleUser.photoUrl!);
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    await saveUser(email, password, "");
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
