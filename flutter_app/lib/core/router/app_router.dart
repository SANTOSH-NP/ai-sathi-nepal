import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/main_shell.dart';
import '../../features/cv/screens/cv_builder_screen.dart';
import '../../features/cv/screens/cv_preview_screen.dart';
import '../../features/qr/screens/qr_scanner_screen.dart';
import '../../features/pdf/screens/image_to_pdf_screen.dart';
import '../../features/ai_tools/screens/ai_tools_screen.dart';
import '../../features/ai_tools/screens/grammar_screen.dart';
import '../../features/ai_tools/screens/translate_screen.dart';
import '../../features/ai_tools/screens/summarize_screen.dart';
import '../../features/ai_tools/screens/rewrite_screen.dart';
import '../../features/daily_tools/screens/daily_tools_screen.dart';
import '../../features/daily_tools/screens/email_generator_screen.dart';
import '../../features/daily_tools/screens/caption_generator_screen.dart';
import '../../features/daily_tools/screens/job_message_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/subscription/screens/subscription_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute && state.matchedLocation != '/splash') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/tools',
            builder: (context, state) => const AiToolsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Feature screens
      GoRoute(
        path: '/cv-builder',
        builder: (context, state) => const CvBuilderScreen(),
      ),
      GoRoute(
        path: '/cv-preview',
        builder: (context, state) {
          final cvData = state.extra as Map<String, dynamic>?;
          return CvPreviewScreen(cvData: cvData ?? {});
        },
      ),
      GoRoute(
        path: '/qr-scanner',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/image-to-pdf',
        builder: (context, state) => const ImageToPdfScreen(),
      ),
      GoRoute(
        path: '/grammar',
        builder: (context, state) => const GrammarScreen(),
      ),
      GoRoute(
        path: '/translate',
        builder: (context, state) => const TranslateScreen(),
      ),
      GoRoute(
        path: '/summarize',
        builder: (context, state) => const SummarizeScreen(),
      ),
      GoRoute(
        path: '/rewrite',
        builder: (context, state) => const RewriteScreen(),
      ),
      GoRoute(
        path: '/daily-tools',
        builder: (context, state) => const DailyToolsScreen(),
      ),
      GoRoute(
        path: '/email-generator',
        builder: (context, state) => const EmailGeneratorScreen(),
      ),
      GoRoute(
        path: '/caption-generator',
        builder: (context, state) => const CaptionGeneratorScreen(),
      ),
      GoRoute(
        path: '/job-message',
        builder: (context, state) => const JobMessageScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
    ],
  );
});
