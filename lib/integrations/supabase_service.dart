import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tvplus/globals/app_constants.dart';
import 'package:tvplus/models/lista_de_canales.dart';
import 'package:tvplus/main.dart';
import 'package:flutter/material.dart';

@NowaGenerated()
class SupabaseService {
  SupabaseService._();

  factory SupabaseService() {
    return _instance;
  }

  static final SupabaseService _instance = SupabaseService._();

  Future<AuthResponse> signIn(String email, String password) async {
    return Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password) async {
    return Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  Future initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  Future<List<listaDeCanales>> getAllCanales() async {
    final response = await Supabase.instance.client.from('canales').select('*');
    return response.map((json) => listaDeCanales.fromJson(json)).toList();
  }

  Future<AuthResponse> signUpWithProfile(
    String email,
    String password,
    String nombre,
  ) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user != null) {
      await Supabase.instance.client.from('profiles').insert({
        'id': response.user?.id,
        'nombre': nombre,
        'preferencia_canal': null,
      });
    }
    return response;
  }

  Future<void> updateLastChannel(int channelId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client
          .from('profiles')
          .update({'preferencia_canal': channelId})
          .eq('id', user.id);
    }
  }

  Future<bool> signInWithCode(String code) async {
    try {
      final response = await Supabase.instance.client
          .from('codigos_acceso')
          .select()
          .eq('codigo', code)
          .maybeSingle();
      if (response != null) {
        await sharedPrefs.setBool('bypass_auth', true);
        return true;
      }
    } catch (e) {
      debugPrint('Error validando código: ${e}');
    }
    return false;
  }
}
