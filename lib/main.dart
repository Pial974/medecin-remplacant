import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/remplacement_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'utils/liquid_theme.dart';
import 'services/database_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await DatabaseService.initialize();
  await SupabaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RemplacementProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Médecin Remplaçant',
            debugShowCheckedModeBanner: false,
            theme: LiquidTheme.light(),
            darkTheme: LiquidTheme.dark(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const LiquidBackground(child: AppRouter()),
          );
        },
      ),
    );
  }
}

class AppRouter extends StatefulWidget {
  const AppRouter({super.key});

  @override
  State<AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<AppRouter> {
  bool? _onboardingComplete;
  bool? _authComplete;

  @override
  void initState() {
    super.initState();
    _checkState();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    SupabaseService().authStateChanges.listen((AuthState data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        setState(() {
          _authComplete = true;
        });
      } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        setState(() {
          _authComplete = true;
        });
      } else if (event == AuthChangeEvent.signedOut) {
        // Ne pas changer _authComplete si l'utilisateur a skip l'auth
        // (on ne veut pas le renvoyer sur l'écran de connexion)
      }
    });
  }

  Future<void> _checkState() async {
    final prefs = await SharedPreferences.getInstance();
    final onboarding = prefs.getBool('onboarding_complete') ?? false;
    final authSkipped = prefs.getBool('auth_skipped') ?? false;
    final isLoggedIn = SupabaseService().isLoggedIn;

    setState(() {
      _onboardingComplete = onboarding;
      _authComplete = isLoggedIn || authSkipped;
    });
  }

  void _completeOnboarding() {
    setState(() {
      _onboardingComplete = true;
    });
  }

  Future<void> _completeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_skipped', true);
    setState(() {
      _authComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Écran de chargement
    if (_onboardingComplete == null || _authComplete == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Onboarding
    if (!_onboardingComplete!) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    // Authentification
    if (!_authComplete!) {
      return AuthScreen(onAuthSuccess: _completeAuth);
    }

    // Écran principal
    return const HomeScreen();
  }
}

class LiquidBackground extends StatelessWidget {
  final Widget child;

  const LiquidBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: isDark
          ? LiquidTheme.darkBackgroundGradient
          : LiquidTheme.backgroundGradient,
      child: child,
    );
  }
}
