import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient client;
  AuthRepository(this.client);

  Future<AuthResponse> signUp({required String email, required String password, required String role, required String name}) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {
        'role': role, // 'user' or 'org'
        'name': name,
      },
    );
    return response;
  }

  Future<AuthResponse> signIn({required String email, required String password}) async {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }
}


