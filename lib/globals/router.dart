import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tvplus/main.dart';
import 'package:tvplus/pages/tv_plus.dart';
import 'package:tvplus/pages/auth_page.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final bool loggedIn = Supabase.instance.client.auth.currentSession != null;
    final bool hasBypass = sharedPrefs.getBool('bypass_auth') ?? false;
    final bool isAuthorized = loggedIn || hasBypass;
    final bool loggingIn = state.matchedLocation == '/login';
    if (!isAuthorized && !loggingIn) {
      return '/login';
    }
    if (isAuthorized && loggingIn) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const TvPlus()),
    GoRoute(path: '/login', builder: (context, state) => const AuthPage()),
  ],
);
