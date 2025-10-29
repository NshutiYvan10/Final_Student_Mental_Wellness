import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../services/auth_service.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final authUserProvider = StreamProvider<fb.User?>((ref) {
  return AuthService.authStateChanges();
});

final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(authUserProvider).valueOrNull;
  return user != null;
});

