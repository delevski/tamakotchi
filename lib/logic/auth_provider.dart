import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsign;

// Toggle this to false when Firebase is actually configured
const bool useMockAuth = true;

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>((ref) {
  return AuthNotifier();
});

class AuthState {
  final User? user;
  final bool isMockLoggedIn;

  AuthState({this.user, this.isMockLoggedIn = false});
}

class AuthNotifier extends StateNotifier<AsyncValue<AuthState>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    if (useMockAuth) {
      await Future.delayed(const Duration(seconds: 1));
      state = AsyncValue.data(AuthState());
      return;
    }
    
    final user = FirebaseAuth.instance.currentUser;
    state = AsyncValue.data(AuthState(user: user));
    
    FirebaseAuth.instance.authStateChanges().listen((user) {
      state = AsyncValue.data(AuthState(user: user));
    });
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      if (useMockAuth) {
        await Future.delayed(const Duration(seconds: 1));
        // We can't return a real User object easily without Firebase, 
        // so we'll just pretend we are logged in for now if we need to.
        // But for type safety, let's keep it null or handle "mock user".
        // In a real app we'd mock the User class too, but it's complex.
        // For now, let's just log "Signed in" and stay in null state 
        // or we need to change the state type to something custom.
        print("Mock Sign In Successful");
        state = AsyncValue.data(AuthState(isMockLoggedIn: true));
        return;
      }

      /*
      final gsign.GoogleSignInAccount? googleUser = await gsign.GoogleSignIn().signIn();
      if (googleUser == null) return;

      final gsign.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: null, // accessToken no longer directly on googleAuth in 7.x
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      */
      print("Google Sign In (Mock Mode)");
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    if (useMockAuth) {
      state = AsyncValue.data(AuthState());
      return;
    }
    await FirebaseAuth.instance.signOut();
  }
}
