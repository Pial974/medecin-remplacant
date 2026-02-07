import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../widgets/glass_card.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthSuccess;

  const AuthScreen({super.key, required this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = SupabaseService();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isLogin) {
        await _supabase.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        final response = await _supabase.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (response.user != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compte créé ! Vérifiez votre email pour confirmer.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (_supabase.isLoggedIn && mounted) {
        widget.onAuthSuccess();
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect';
    }
    if (error.contains('Email not confirmed')) {
      return 'Veuillez confirmer votre email avant de vous connecter';
    }
    if (error.contains('User already registered')) {
      return 'Un compte existe déjà avec cet email';
    }
    if (error.contains('Password should be at least')) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    if (error.contains('Unable to validate email')) {
      return 'Adresse email invalide';
    }
    return 'Une erreur est survenue. Vérifiez votre connexion internet.';
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Entrez votre email pour réinitialiser');
      return;
    }

    try {
      await _supabase.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de réinitialisation envoyé !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Erreur lors de l\'envoi');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Icon(
                  Icons.local_hospital_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Médecin Remplaçant',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? 'Connectez-vous pour synchroniser vos données' : 'Créez votre compte',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Formulaire
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isLogin ? 'Connexion' : 'Inscription',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Entrez votre email';
                              }
                              if (!value.contains('@')) {
                                return 'Email invalide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Mot de passe
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Mot de passe',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.white.withValues(alpha: 0.5),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Entrez votre mot de passe';
                              }
                              if (!_isLogin && value.length < 6) {
                                return 'Minimum 6 caractères';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Mot de passe oublié
                          if (_isLogin)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _resetPassword,
                                child: const Text('Mot de passe oublié ?'),
                              ),
                            ),
                          const SizedBox(height: 8),

                          // Erreur
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (_errorMessage != null) const SizedBox(height: 16),

                          // Bouton principal
                          FilledButton(
                            onPressed: _isLoading ? null : _submit,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isLogin ? 'Se connecter' : 'Créer un compte',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                          ),
                          const SizedBox(height: 16),

                          // Basculer login/register
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLogin
                                    ? 'Pas encore de compte ?'
                                    : 'Déjà un compte ?',
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                    _errorMessage = null;
                                  });
                                },
                                child: Text(
                                  _isLogin ? 'S\'inscrire' : 'Se connecter',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Utiliser sans compte
                TextButton.icon(
                  onPressed: widget.onAuthSuccess,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continuer sans compte'),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? Colors.white60 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
