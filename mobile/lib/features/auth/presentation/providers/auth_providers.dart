import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/datasources/auth_remote_datasource.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final datasource = AuthRemoteDatasource(supabase);
  return AuthRepositoryImpl(datasource);
});

/// Auth state provider (stream of auth changes)
final authStateProvider = StreamProvider<User?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange.map((event) => event.session?.user);
});

/// Current user provider
final currentUserProvider = FutureProvider<UserEntity?>((ref) async {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;

      final repository = ref.read(authRepositoryProvider);
      final result = await repository.getCurrentUser();

      return result.fold(
        (failure) => null,
        (user) => user,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Loading state provider
final authLoadingProvider = StateProvider<bool>((ref) => false);

/// Error state provider
final authErrorProvider = StateProvider<String?>((ref) => null);
