import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/models/user_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  try {
    return FirebaseAuth.instance.authStateChanges();
  } catch (e) {
    debugPrint('Firebase auth stream error: $e');
    return Stream.value(null);
  }
});

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserModel?>>((ref) {
  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref ref;
  static const _storage = FlutterSecureStorage();

  UserNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.getIdToken();
      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });

      await _saveTokens(response.data['data']);
      state = AsyncValue.data(UserModel.fromJson(response.data['data']['user']));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> registerWithEmail(String name, String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiConstants.register, data: {
        'name': name,
        'email': email,
        'password': password,
      });

      // Also sign in with Firebase
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _saveTokens(response.data['data']);
      state = AsyncValue.data(UserModel.fromJson(response.data['data']['user']));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user!.getIdToken();

      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiConstants.googleAuth, data: {
        'idToken': idToken,
      });

      await _saveTokens(response.data['data']);
      state = AsyncValue.data(UserModel.fromJson(response.data['data']['user']));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> continueAsGuest() async {
    state = const AsyncValue.loading();
    try {
      final credential = await FirebaseAuth.instance.signInAnonymously();
      await credential.user!.getIdToken();

      final dio = ref.read(dioProvider);
      final response = await dio.post(ApiConstants.guestAuth);

      await _saveTokens(response.data['data']);
      state = AsyncValue.data(UserModel.fromJson(response.data['data']['user']));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> fetchProfile() async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiConstants.profile);
      state = AsyncValue.data(UserModel.fromJson(response.data['data']));
    } catch (e) {
      // Silent fail for profile fetch
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
    await _storage.deleteAll();
    state = const AsyncValue.data(null);
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    await _storage.write(key: 'access_token', value: data['accessToken']);
    await _storage.write(key: 'refresh_token', value: data['refreshToken']);
  }
}
