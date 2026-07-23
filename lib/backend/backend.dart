import 'package:supabase_flutter/supabase_flutter.dart';

import 'backend_config.dart';

/// Plain data object returned by the backend layer. Intentionally free of any
/// dependency on the UI models in `main.dart` (no circular imports); the UI
/// maps this into its own `AppUser` / `UserSettings`.
class BackendProfile {
  const BackendProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.settings,
  });

  final String id;
  final String email;
  final String name;

  /// One of: resident, tourist, merchant, organization, supervisor, mayor, admin.
  final String role;
  final Map<String, dynamic> settings;

  factory BackendProfile.fromRow(Map<String, dynamic> row) {
    final rawSettings = row['settings'];
    return BackendProfile(
      id: row['id'] as String,
      email: (row['email'] as String?) ?? '',
      name: (row['name'] as String?) ?? 'Utente',
      role: (row['role'] as String?) ?? 'resident',
      settings: rawSettings is Map
          ? Map<String, dynamic>.from(rawSettings)
          : <String, dynamic>{},
    );
  }
}

/// Thin wrapper around Supabase for Slice 1 (auth + profiles).
///
/// Everything is guarded by [BackendConfig.isConfigured]; when the backend is
/// not configured the app never touches Supabase and stays in demo mode.
class Backend {
  const Backend._();

  static bool get isEnabled => BackendConfig.isConfigured;

  static SupabaseClient get _client => Supabase.instance.client;

  /// Initialize Supabase. Safe to call once at startup; no-op when unconfigured.
  static Future<void> init() async {
    if (!isEnabled) return;
    await Supabase.initialize(
      url: BackendConfig.supabaseUrl,
      anonKey: BackendConfig.supabaseAnonKey,
    );
  }

  /// Restore an already authenticated session (e.g. after app restart).
  static Future<BackendProfile?> currentProfile() async {
    if (!isEnabled) return null;
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return _fetchProfile(user.id);
  }

  /// Sign in with email/password; if the account does not exist yet, create it
  /// (using [fallbackRole] and [fallbackName] for the new profile). Returns the
  /// resolved profile.
  static Future<BackendProfile> signInOrSignUp({
    required String email,
    required String password,
    required String fallbackRole,
    required String fallbackName,
  }) async {
    if (!isEnabled) {
      throw StateError('Backend non configurato');
    }
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final id = res.user!.id;
      return await _fetchProfile(id) ??
          await _ensureProfile(id, email, fallbackName, fallbackRole);
    } on AuthException {
      // No such user (or wrong password): try to register a fresh account.
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': fallbackName, 'role': fallbackRole},
      );
      final id = res.user!.id;
      // The DB trigger creates the profile, but ensure it exists for the case
      // where email confirmation is enabled and the row isn't visible yet.
      return await _fetchProfile(id) ??
          BackendProfile(
            id: id,
            email: email,
            name: fallbackName,
            role: fallbackRole,
            settings: const {},
          );
    }
  }

  /// Sign in an existing account.
  static Future<BackendProfile> signIn({
    required String email,
    required String password,
  }) async {
    if (!isEnabled) throw StateError('Backend non configurato');
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final id = res.user!.id;
    return await _fetchProfile(id) ??
        BackendProfile(
          id: id,
          email: email,
          name: email.split('@').first,
          role: 'resident',
          settings: const {},
        );
  }

  /// Register a new account with the given role/name.
  static Future<BackendProfile> signUp({
    required String email,
    required String password,
    required String role,
    required String name,
  }) async {
    if (!isEnabled) throw StateError('Backend non configurato');
    final res = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role},
    );
    final user = res.user;
    if (user == null) {
      throw StateError('Registrazione non riuscita');
    }
    return await _fetchProfile(user.id) ??
        BackendProfile(
          id: user.id,
          email: email,
          name: name,
          role: role,
          settings: const {},
        );
  }

  static Future<void> signOut() async {
    if (!isEnabled) return;
    await _client.auth.signOut();
  }

  /// The id of the currently authenticated user, or null.
  static String? get currentUserId =>
      isEnabled ? _client.auth.currentUser?.id : null;

  // -------------------------------------------------------------------------
  // Slice 2 · gamification persistence (raw maps; UI maps to its own models)
  // -------------------------------------------------------------------------

  static Future<Map<String, dynamic>?> loadGamification(String userId) async {
    if (!isEnabled) return null;
    return _client
        .from('gamification_state')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  static Future<void> saveGamification(
    String userId, {
    required int xp,
    required int tokens,
  }) async {
    if (!isEnabled) return;
    await _client.from('gamification_state').upsert({
      'user_id': userId,
      'xp': xp,
      'tokens': tokens,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> loadLedger(String userId) async {
    if (!isEnabled) return const [];
    final rows = await _client
        .from('reward_ledger')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<void> insertLedger(
    String userId, {
    required String reason,
    required int deltaXp,
    required int deltaTokens,
  }) async {
    if (!isEnabled) return;
    await _client.from('reward_ledger').insert({
      'user_id': userId,
      'reason': reason,
      'delta_xp': deltaXp,
      'delta_tokens': deltaTokens,
    });
  }

  static Future<List<Map<String, dynamic>>> loadVouchers(String userId) async {
    if (!isEnabled) return const [];
    final rows = await _client
        .from('vouchers')
        .select()
        .eq('user_id', userId)
        .order('issued_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<void> insertVoucher(
    String userId, {
    required String code,
    required String label,
    required int discountPct,
    required String status,
  }) async {
    if (!isEnabled) return;
    await _client.from('vouchers').insert({
      'user_id': userId,
      'code': code,
      'label': label,
      'discount_pct': discountPct,
      'status': status,
    });
  }

  static Future<void> markVoucherRedeemed(
    String userId, {
    required String code,
    required String merchantName,
  }) async {
    if (!isEnabled) return;
    await _client
        .from('vouchers')
        .update({
          'status': 'usato',
          'merchant_name': merchantName,
          'redeemed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('user_id', userId)
        .eq('code', code);
  }

  // -------------------------------------------------------------------------
  // Slice 3 · event participations & sport reservations
  // -------------------------------------------------------------------------

  static Future<Set<String>> loadJoinedEventIds(String userId) async {
    if (!isEnabled) return <String>{};
    final rows = await _client
        .from('event_participations')
        .select('event_id')
        .eq('user_id', userId);
    return {for (final row in rows) row['event_id'] as String};
  }

  static Future<void> setEventParticipation(
    String userId, {
    required String eventId,
    required bool joined,
  }) async {
    if (!isEnabled) return;
    if (joined) {
      await _client.from('event_participations').upsert({
        'user_id': userId,
        'event_id': eventId,
        'status': 'joined',
      });
    } else {
      await _client
          .from('event_participations')
          .delete()
          .eq('user_id', userId)
          .eq('event_id', eventId);
    }
  }

  static Future<Set<String>> loadReservedSlotIds(String userId) async {
    if (!isEnabled) return <String>{};
    final rows = await _client
        .from('sport_reservations')
        .select('slot_id')
        .eq('user_id', userId);
    return {for (final row in rows) row['slot_id'] as String};
  }

  static Future<void> addReservation(
    String userId, {
    required String slotId,
  }) async {
    if (!isEnabled) return;
    await _client.from('sport_reservations').insert({
      'user_id': userId,
      'slot_id': slotId,
      'status': 'reserved',
    });
  }

  // -------------------------------------------------------------------------
  // Realtime subscriptions (per-user rows). Channels are tracked by name so
  // callers (main.dart) never touch Supabase types directly.
  // -------------------------------------------------------------------------

  static final Map<String, RealtimeChannel> _channels = {};

  static void subscribeUserTable(
    String name, {
    required String table,
    required String userId,
    required void Function() onChange,
  }) {
    if (!isEnabled) return;
    unsubscribe(name);
    final channel = _client.channel('rt:$name');
    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => onChange(),
        )
        .subscribe();
    _channels[name] = channel;
  }

  static void unsubscribe(String name) {
    final channel = _channels.remove(name);
    if (channel != null) {
      _client.removeChannel(channel);
    }
  }

  static Future<BackendProfile?> _fetchProfile(String id) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return BackendProfile.fromRow(row);
  }

  static Future<BackendProfile> _ensureProfile(
    String id,
    String email,
    String name,
    String role,
  ) async {
    final row = await _client
        .from('profiles')
        .upsert({'id': id, 'email': email, 'name': name, 'role': role})
        .select()
        .single();
    return BackendProfile.fromRow(row);
  }
}
