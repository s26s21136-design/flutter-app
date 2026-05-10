import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

class SupabaseService {

  static final SupabaseClient client =
      Supabase.instance.client;

  // LOGIN
  Future<void> signIn(
    String email,
    String password,
  ) async {

    await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // SIGNUP
  Future<void> signUp(
    String email,
    String password,
  ) async {

    await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> createUserProfile(String email) async {
  final user = client.auth.currentUser;

  if (user == null) return;

  await client.from('profiles').insert({
    'id': user.id,
    'email': email,
  });
}

  // LOGOUT
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // CURRENT USER
  User? get currentUser =>
      client.auth.currentUser;
}