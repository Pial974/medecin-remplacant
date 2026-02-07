import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/remplacement.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  static const String _supabaseUrl = 'https://qjchhvxxrccahhtbmvcc.supabase.co';
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqY2hodnh4cmNjYWhodGJtdmNjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA0NjA5MDYsImV4cCI6MjA4NjAzNjkwNn0.lz-WfKqG2M08N5Uj5_uFhzpEmT_JSK6pfqDMFI_yy7k';

  SupabaseClient get client => Supabase.instance.client;

  // Initialisation
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  // ==================== AUTHENTIFICATION ====================

  User? get currentUser => client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // Inscription
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Connexion
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Déconnexion
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Réinitialisation mot de passe
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  // ==================== SYNCHRONISATION ====================

  // Envoyer tous les remplacements locaux vers Supabase
  Future<int> syncToCloud(List<Remplacement> localRemplacements) async {
    if (!isLoggedIn) return 0;

    final userId = currentUser!.id;
    int synced = 0;

    for (final r in localRemplacements) {
      try {
        await client.from('remplacements').upsert({
          'id': r.id,
          'user_id': userId,
          'date_debut': r.dateDebut.toIso8601String().split('T')[0],
          'date_fin': r.dateFin.toIso8601String().split('T')[0],
          'medecin_remplace': r.medecinRemplace,
          'nombre_jours': r.nombreJours,
          'taux_retrocession': r.tauxRetrocession,
          'montant_avant_retrocession': r.montantAvantRetrocession,
          'mode_paiement': r.modePaiement,
          'date_paiement': r.datePaiement?.toIso8601String().split('T')[0],
          'statut_paiement': r.statutPaiement,
          'notes': r.notes,
          'created_at': r.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
          'updated_at': r.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        });
        synced++;
      } catch (e) {
        // Continuer avec les autres
      }
    }
    return synced;
  }

  // Récupérer tous les remplacements depuis Supabase
  Future<List<Remplacement>> fetchFromCloud() async {
    if (!isLoggedIn) return [];

    try {
      final response = await client
          .from('remplacements')
          .select()
          .order('date_debut', ascending: false);

      return (response as List).map((map) {
        return Remplacement(
          id: map['id'] as String,
          dateDebut: DateTime.parse(map['date_debut'] as String),
          dateFin: DateTime.parse(map['date_fin'] as String),
          medecinRemplace: map['medecin_remplace'] as String,
          nombreJours: (map['nombre_jours'] as num).toDouble(),
          tauxRetrocession: map['taux_retrocession'] as int,
          montantAvantRetrocession:
              (map['montant_avant_retrocession'] as num).toDouble(),
          modePaiement: map['mode_paiement'] as String?,
          datePaiement: map['date_paiement'] != null
              ? DateTime.parse(map['date_paiement'] as String)
              : null,
          statutPaiement: map['statut_paiement'] as String? ?? 'En attente',
          notes: map['notes'] as String?,
          createdAt: map['created_at'] != null
              ? DateTime.parse(map['created_at'] as String)
              : null,
          updatedAt: map['updated_at'] != null
              ? DateTime.parse(map['updated_at'] as String)
              : null,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Supprimer un remplacement du cloud
  Future<void> deleteFromCloud(String id) async {
    if (!isLoggedIn) return;
    try {
      await client.from('remplacements').delete().eq('id', id);
    } catch (e) {
      // Silencieux
    }
  }

  // Synchronisation complète : cloud → local
  // Retourne les remplacements du cloud pour les fusionner
  Future<List<Remplacement>> fullSync(List<Remplacement> localData) async {
    if (!isLoggedIn) return localData;

    // 1. Envoyer les données locales vers le cloud
    await syncToCloud(localData);

    // 2. Récupérer toutes les données du cloud (qui contient maintenant tout)
    final cloudData = await fetchFromCloud();

    return cloudData.isNotEmpty ? cloudData : localData;
  }
}
