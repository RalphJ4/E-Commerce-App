import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopease/features/auth/domain/entities/user.dart';
import 'package:shopease/core/constants/app_constants.dart';

abstract class AuthRemoteDataSource {
  Future<User> signIn({
    required String email,
    required String password,
  });

  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<User> signInWithGoogle();

  Future<void> signOut();

  Future<User?> getCurrentUser();

  Future<bool> isSignedIn();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final String? googleSignInClientId;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    this.googleSignInClientId,
  }) : _googleSignIn = null;

  // GoogleSignIn is NOT eagerly created to avoid web assertion errors.
  // It is created on-demand inside signInWithGoogle() and caught there.
  GoogleSignIn? _googleSignIn;

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _getUserFromFirestore(credential.user!);
  }

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user!.updateDisplayName(displayName);
    await credential.user!.reload();

    final user = User(
      uid: credential.user!.uid,
      displayName: displayName,
      email: email,
      avatarUrl: null,
      xp: 0,
      level: 1,
      streak: 0,
      coins: 0,
      badges: ['Welcome'],
      totalOrders: 0,
      totalSpent: 0.0,
    );

    await firestore
        .collection(AppConstants.usersCollection)
        .doc(credential.user!.uid)
        .set(user.toMap());

    return user;
  }

  @override
  Future<User> signInWithGoogle() async {
    // Lazy init GoogleSignIn to avoid web assertion errors at startup.
    try {
      _googleSignIn ??= GoogleSignIn(
        scopes: ['email'],
        clientId: googleSignInClientId,
      );
    } catch (e) {
      throw firebase.FirebaseAuthException(
        code: 'configuration-error',
        message: 'Google Sign-In is not configured for web.\n'
            'Option 1: Uncomment the <meta> tag in web/index.html\n'
            'Option 2: Pass clientId to GoogleSignIn in the code',
      );
    }

    try {
      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        throw firebase.FirebaseAuthException(
          code: 'canceled',
          message: 'Google sign-in was canceled',
        );
      }

      final authentication = await googleUser.authentication;
      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );

      final result = await firebaseAuth.signInWithCredential(credential);
      final firebaseUser = result.user!;
      final existingDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (existingDoc.exists) {
        final data = existingDoc.data()!;
        data['uid'] = firebaseUser.uid;
        data['displayName'] = firebaseUser.displayName ?? googleUser.displayName ?? 'User';
        data['email'] = firebaseUser.email ?? googleUser.email;
        data['avatarUrl'] = firebaseUser.photoURL;
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .update({'displayName': data['displayName'], 'avatarUrl': data['avatarUrl']});
        return User.fromMap(data);
      }

      final newUser = User(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? googleUser.displayName ?? 'User',
        email: firebaseUser.email ?? googleUser.email,
        avatarUrl: firebaseUser.photoURL,
        xp: 0,
        level: 1,
        streak: 0,
        coins: 0,
        badges: ['Welcome'],
        totalOrders: 0,
        totalSpent: 0.0,
      );

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .set(newUser.toMap());

      return newUser;
    } on firebase.FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw firebase.FirebaseAuthException(
        code: 'web-error',
        message: 'Google Sign-In failed: $e',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
    } catch (_) {}
    await firebaseAuth.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return _getUserFromFirestore(firebaseUser);
  }

  @override
  Future<bool> isSignedIn() async {
    return firebaseAuth.currentUser != null;
  }

  Future<User> _getUserFromFirestore(firebase.User firebaseUser) async {
    final doc = await firestore
        .collection(AppConstants.usersCollection)
        .doc(firebaseUser.uid)
        .get();

    if (!doc.exists) {
      final fallback = User(
        uid: firebaseUser.uid,
        displayName: firebaseUser.displayName ?? 'User',
        email: firebaseUser.email ?? '',
        avatarUrl: firebaseUser.photoURL,
      );
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .set(fallback.toMap());
      return fallback;
    }

    final data = doc.data()!;
    data['uid'] = firebaseUser.uid;
    data['displayName'] ??= firebaseUser.displayName ?? 'User';
    data['email'] ??= firebaseUser.email ?? '';
    data['avatarUrl'] ??= firebaseUser.photoURL;
    return User.fromMap(data);
  }
}
