import "dart:math" as math;
import "dart:ui";

import "package:flutter/material.dart";
import "package:flutter/services.dart" show NetworkAssetBundle;
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart" show LatLng;
import "package:xml/xml.dart";

void main() {
  runApp(const AppEcchioApp());
}

class AppEcchioApp extends StatelessWidget {
  const AppEcchioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "APPecchio Mockup",
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3A7A57),
          brightness: Brightness.light,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

enum UserProfile {
  resident,
  tourist,
  merchant,
  organization,
  supervisor,
  mayor,
  admin,
}

class AppUser {
  const AppUser({
    required this.name,
    required this.profile,
    required this.email,
    required this.settings,
  });

  final String name;
  final UserProfile profile;
  final String email;
  final UserSettings settings;

  String get profileLabel {
    switch (profile) {
      case UserProfile.resident:
        return "Cittadino residente";
      case UserProfile.tourist:
        return "Turista";
      case UserProfile.merchant:
        return "Esercente";
      case UserProfile.organization:
        return "Organizzazione";
      case UserProfile.supervisor:
        return "Supervisore";
      case UserProfile.mayor:
        return "Sindaco";
      case UserProfile.admin:
        return "Amministratore";
    }
  }

  bool get isBackoffice => switch (profile) {
        UserProfile.resident || UserProfile.tourist => false,
        _ => true,
      };
}

class UserSettings {
  const UserSettings({
    required this.language,
    required this.notificationsEnabled,
    required this.locationEnabled,
    required this.analyticsEnabled,
    required this.marketingEnabled,
  });

  final String language;
  final bool notificationsEnabled;
  final bool locationEnabled;
  final bool analyticsEnabled;
  final bool marketingEnabled;
}

final GamificationController appGamification = GamificationController.demo();
final EventParticipationController appEventParticipation =
    EventParticipationController();
final SportReservationController appSportReservations =
    SportReservationController();
final NoticeController appNotices = NoticeController.demo();

class SportReservationController extends ChangeNotifier {
  final Set<String> _reservedSlotIds = {};

  Set<String> get reservedSlotIds => Set.unmodifiable(_reservedSlotIds);

  bool isReserved(SportBookingSlot slot) => _reservedSlotIds.contains(slot.id);

  bool reserve(SportBookingSlot slot) {
    final changed = _reservedSlotIds.add(slot.id);
    if (changed) {
      notifyListeners();
    }
    return changed;
  }
}

class EventParticipationController extends ChangeNotifier {
  final Set<String> _joinedEventIds = {};

  Set<String> get joinedEventIds => Set.unmodifiable(_joinedEventIds);

  bool isJoined(AppEvent event) => _joinedEventIds.contains(event.id);

  void setJoined(AppEvent event, bool joined) {
    final changed = joined
        ? _joinedEventIds.add(event.id)
        : _joinedEventIds.remove(event.id);
    if (changed) {
      notifyListeners();
    }
  }

  void toggle(AppEvent event) {
    setJoined(event, !isJoined(event));
  }
}

class RewardTier {
  const RewardTier({
    required this.threshold,
    required this.label,
    required this.discountPercentage,
  });

  final int threshold;
  final String label;
  final int discountPercentage;
}

class RewardLevel {
  const RewardLevel({
    required this.name,
    required this.minPoints,
    required this.icon,
  });

  final String name;
  final int minPoints;
  final IconData icon;
}

class RewardMedal {
  const RewardMedal({
    required this.label,
    required this.threshold,
    required this.icon,
  });

  final String label;
  final int threshold;
  final IconData icon;
}

class RewardVoucher {
  const RewardVoucher({
    required this.code,
    required this.label,
    required this.discountPercentage,
    required this.threshold,
    required this.status,
    required this.issuedAt,
    this.redeemedAt,
    this.merchantName,
  });

  final String code;
  final String label;
  final int discountPercentage;
  final int threshold;
  final String status;
  final DateTime issuedAt;
  final DateTime? redeemedAt;
  final String? merchantName;

  bool get isActive => status == "attivo";

  RewardVoucher redeem(String merchantName) {
    return RewardVoucher(
      code: code,
      label: label,
      discountPercentage: discountPercentage,
      threshold: threshold,
      status: "usato",
      issuedAt: issuedAt,
      redeemedAt: DateTime.now(),
      merchantName: merchantName,
    );
  }
}

class RewardLedgerEntry {
  const RewardLedgerEntry({
    required this.label,
    required this.points,
    required this.status,
    required this.createdAt,
  });

  final String label;
  final int points;
  final String status;
  final DateTime createdAt;
}

class GamificationController extends ChangeNotifier {
  GamificationController.demo()
      : rewardTiers = const [
          RewardTier(threshold: 500, label: "Sconto 5%", discountPercentage: 5),
          RewardTier(
            threshold: 1000,
            label: "Sconto 10%",
            discountPercentage: 10,
          ),
        ];

  static const List<RewardLevel> levels = [
    RewardLevel(name: "Esploratore", minPoints: 0, icon: Icons.explore_rounded),
    RewardLevel(
      name: "Amico del borgo",
      minPoints: 300,
      icon: Icons.volunteer_activism_rounded,
    ),
    RewardLevel(
      name: "Custode locale",
      minPoints: 700,
      icon: Icons.workspace_premium_rounded,
    ),
    RewardLevel(
      name: "Ambasciatore",
      minPoints: 1200,
      icon: Icons.military_tech_rounded,
    ),
  ];

  static const List<RewardMedal> medals = [
    RewardMedal(
      label: "Primo check-in",
      threshold: 120,
      icon: Icons.qr_code_scanner_rounded,
    ),
    RewardMedal(
      label: "Vita in paese",
      threshold: 500,
      icon: Icons.emoji_events_rounded,
    ),
    RewardMedal(
      label: "Patron locale",
      threshold: 1000,
      icon: Icons.local_activity_rounded,
    ),
  ];

  final List<RewardTier> rewardTiers;
  final List<RewardLedgerEntry> _ledger = [];
  final List<RewardVoucher> _vouchers = [];
  final Set<String> _idempotencyKeys = {};
  final Set<int> _issuedThresholds = {};
  int _balance = 360;
  int _voucherCounter = 1;

  int get balance => _balance;
  List<RewardLedgerEntry> get ledger => List.unmodifiable(_ledger);
  List<RewardVoucher> get vouchers => List.unmodifiable(_vouchers);
  List<RewardVoucher> get activeVouchers =>
      _vouchers.where((voucher) => voucher.isActive).toList(growable: false);

  RewardLevel get currentLevel {
    return levels.lastWhere((level) => _balance >= level.minPoints);
  }

  RewardLevel? get nextLevel {
    for (final level in levels) {
      if (level.minPoints > _balance) {
        return level;
      }
    }
    return null;
  }

  double get progressToNextLevel {
    final next = nextLevel;
    if (next == null) {
      return 1;
    }
    final current = currentLevel;
    final span = math.max(next.minPoints - current.minPoints, 1);
    return ((_balance - current.minPoints) / span).clamp(0, 1).toDouble();
  }

  int get unlockedMedalCount {
    return medals.where((medal) => _balance >= medal.threshold).length;
  }

  RewardTier? get nextTier {
    for (final tier in rewardTiers) {
      if (tier.threshold > _balance) {
        return tier;
      }
    }
    return null;
  }

  double get progressToNextTier {
    final tier = nextTier;
    if (tier == null) {
      return 1;
    }
    return (_balance / tier.threshold).clamp(0, 1).toDouble();
  }

  int get missingPoints {
    final tier = nextTier;
    if (tier == null) {
      return 0;
    }
    return math.max(tier.threshold - _balance, 0);
  }

  bool awardPoints({
    required int points,
    required String label,
    required String idempotencyKey,
  }) {
    if (_idempotencyKeys.contains(idempotencyKey)) {
      return false;
    }
    _idempotencyKeys.add(idempotencyKey);
    _balance += points;
    _ledger.insert(
      0,
      RewardLedgerEntry(
        label: label,
        points: points,
        status: "confirmed",
        createdAt: DateTime.now(),
      ),
    );
    _issueVouchersIfNeeded();
    notifyListeners();
    return true;
  }

  bool recordEventCheckin(AppEvent event) {
    return awardPoints(
      points: 120,
      label: "Check-in evento: ${event.title}",
      idempotencyKey: "event:${event.id}",
    );
  }

  bool recordBooking({
    required String sourceId,
    required String label,
    int points = 40,
  }) {
    return awardPoints(
      points: points,
      label: label,
      idempotencyKey: "booking:$sourceId",
    );
  }

  bool redeemVoucher({required String code, required String merchantName}) {
    final index = _vouchers.indexWhere(
      (voucher) => voucher.code == code && voucher.isActive,
    );
    if (index == -1) {
      return false;
    }
    _vouchers[index] = _vouchers[index].redeem(merchantName);
    _ledger.insert(
      0,
      RewardLedgerEntry(
        label: "Voucher ${_vouchers[index].label} usato da $merchantName",
        points: 0,
        status: "redeemed",
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return true;
  }

  void _issueVouchersIfNeeded() {
    for (final tier in rewardTiers) {
      if (_balance < tier.threshold ||
          _issuedThresholds.contains(tier.threshold)) {
        continue;
      }
      _issuedThresholds.add(tier.threshold);
      final code = "APE-${_voucherCounter.toString().padLeft(4, "0")}";
      _voucherCounter += 1;
      _vouchers.insert(
        0,
        RewardVoucher(
          code: code,
          label: tier.label,
          discountPercentage: tier.discountPercentage,
          threshold: tier.threshold,
          status: "attivo",
          issuedAt: DateTime.now(),
        ),
      );
      _ledger.insert(
        0,
        RewardLedgerEntry(
          label: "Voucher ${tier.label} sbloccato",
          points: 0,
          status: "issued",
          createdAt: DateTime.now(),
        ),
      );
    }
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(
    text: "utente@apppecchio.it",
  );
  final TextEditingController _passwordController = TextEditingController(
    text: "demo",
  );
  UserProfile _selectedProfile = UserProfile.resident;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const _LivingMapLayer(),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.30),
                    Colors.black.withValues(alpha: 0.58),
                    Colors.black.withValues(alpha: 0.76),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "APPecchio",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Accedi al mockup con credenziali dimostrative. Nessun dato viene verificato o salvato.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.84),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 26),
                      _LoginFormCard(
                        selectedProfile: _selectedProfile,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        onProfileChanged: (profile) =>
                            setState(() => _selectedProfile = profile),
                        onTogglePassword: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        onSubmit: () => _openHome(context),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _selectedProfile == UserProfile.resident
                            ? "Profilo residente: include myApecchio, pratiche, preferenze e permessi comunali."
                            : _selectedProfile == UserProfile.tourist
                                ? "Profilo turista: mostra esperienze, luoghi, eventi e servizi pubblici essenziali."
                                : "Profilo backoffice: apre cruscotto, pagina organizzazione, eventi, voucher e strumenti operativi.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openHome(BuildContext context) {
    final user = AppUser(
      name: _demoNameForProfile(_selectedProfile),
      profile: _selectedProfile,
      email: _emailController.text.trim().isEmpty
          ? "utente@apppecchio.it"
          : _emailController.text.trim(),
      settings: UserSettings(
        language: "Italiano",
        notificationsEnabled: true,
        locationEnabled: _selectedProfile == UserProfile.tourist,
        analyticsEnabled: false,
        marketingEnabled: false,
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => user.isBackoffice
            ? BackofficeScreen(initialProfile: user.profile)
            : HomeScreen(user: user),
      ),
    );
  }

  String _demoNameForProfile(UserProfile profile) {
    return switch (profile) {
      UserProfile.resident => "Giulia",
      UserProfile.tourist => "Luca",
      UserProfile.merchant => "Osteria Monte Nerone",
      UserProfile.organization => "Pro Loco Apecchio",
      UserProfile.supervisor => "Supervisore",
      UserProfile.mayor => "Sindaco",
      UserProfile.admin => "Admin APPecchio",
    };
  }
}

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({
    required this.selectedProfile,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onProfileChanged,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final UserProfile selectedProfile;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final ValueChanged<UserProfile> onProfileChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<UserProfile>(
              initialValue: selectedProfile,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Ruolo di accesso",
                helperText:
                    "Scegli il profilo con cui vuoi entrare nel mockup.",
                prefixIcon: Icon(Icons.badge_rounded),
                border: OutlineInputBorder(),
              ),
              items: [
                for (final option in _loginProfileOptions)
                  DropdownMenuItem<UserProfile>(
                    value: option.profile,
                    child: Row(
                      children: [
                        Icon(option.icon, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            option.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onProfileChanged(value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email o codice utente",
                prefixIcon: Icon(Icons.alternate_email_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  tooltip:
                      obscurePassword ? "Mostra password" : "Nascondi password",
                  onPressed: onTogglePassword,
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.login_rounded),
              label: const Text("Accedi"),
            ),
            const SizedBox(height: 10),
            Text(
              "Login dimostrativa: qualsiasi valore consente di proseguire.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF1B2E21).withValues(alpha: 0.62),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginProfileOption {
  const _LoginProfileOption(this.profile, this.label, this.icon);

  final UserProfile profile;
  final String label;
  final IconData icon;
}

const List<_LoginProfileOption> _loginProfileOptions = [
  _LoginProfileOption(
    UserProfile.resident,
    "Residenti",
    Icons.home_work_rounded,
  ),
  _LoginProfileOption(UserProfile.tourist, "Turisti", Icons.hiking_rounded),
  _LoginProfileOption(
    UserProfile.merchant,
    "Esercente",
    Icons.storefront_rounded,
  ),
  _LoginProfileOption(
    UserProfile.organization,
    "Organizzazione",
    Icons.groups_rounded,
  ),
  _LoginProfileOption(
    UserProfile.supervisor,
    "Supervisore",
    Icons.dashboard_rounded,
  ),
  _LoginProfileOption(
    UserProfile.mayor,
    "Sindaco",
    Icons.account_balance_rounded,
  ),
  _LoginProfileOption(
    UserProfile.admin,
    "Amministratore",
    Icons.admin_panel_settings_rounded,
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class MenuNode {
  const MenuNode({
    required this.id,
    required this.label,
    required this.icon,
    this.highlighted = false,
    this.children = const <MenuNode>[],
  });

  final String id;
  final String label;
  final IconData icon;
  final bool highlighted;
  final List<MenuNode> children;

  bool get isLeaf => children.isEmpty;
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showRadialMenu = false;
  String _activeQuickFilter = "oggi";

  static const List<HomeQuickAction> _quickActions = [
    HomeQuickAction(id: "oggi", label: "Oggi", icon: Icons.today_rounded),
    HomeQuickAction(
      id: "avvisi",
      label: "Avvisi",
      icon: Icons.campaign_rounded,
    ),
    HomeQuickAction(
      id: "aperti",
      label: "Aperti ora",
      icon: Icons.schedule_rounded,
    ),
    HomeQuickAction(
      id: "vicino",
      label: "Vicino a me",
      icon: Icons.near_me_rounded,
    ),
    HomeQuickAction(
      id: "notifiche",
      label: "Notifiche",
      icon: Icons.notifications_rounded,
    ),
  ];

  static const MenuNode _menuRoot = MenuNode(
    id: "root",
    label: "Esplora",
    icon: Icons.explore_rounded,
    children: <MenuNode>[
      MenuNode(
        id: "avvisi",
        label: "Avvisi",
        icon: Icons.campaign_rounded,
        highlighted: true,
      ),
      MenuNode(
        id: "eventi",
        label: "Eventi",
        icon: Icons.celebration_rounded,
        children: <MenuNode>[
          MenuNode(
            id: "calendario",
            label: "Calendario",
            icon: Icons.calendar_month_rounded,
          ),
          MenuNode(
            id: "feste_tradizioni",
            label: "Feste e tradizioni",
            icon: Icons.celebration_rounded,
          ),
          MenuNode(
            id: "eventi_gastronomici",
            label: "Eventi gastronomici",
            icon: Icons.restaurant_menu_rounded,
          ),
          MenuNode(
            id: "cultura_spettacoli",
            label: "Cultura e spettacoli",
            icon: Icons.theater_comedy_rounded,
          ),
          MenuNode(id: "mostre", label: "Mostre", icon: Icons.museum_rounded),
          MenuNode(
            id: "sport_outdoor",
            label: "Sport e outdoor",
            icon: Icons.terrain_rounded,
          ),
          MenuNode(
            id: "comunita_spiritualita",
            label: "Comunita e spiritualita",
            icon: Icons.groups_rounded,
          ),
        ],
      ),
      MenuNode(
        id: "food",
        label: "Cibo e Drink",
        icon: Icons.restaurant_menu_rounded,
        children: <MenuNode>[
          MenuNode(
            id: "ristoranti",
            label: "Ristoranti",
            icon: Icons.restaurant_rounded,
          ),
          MenuNode(
            id: "agriturismi",
            label: "Agriturismi",
            icon: Icons.park_rounded,
          ),
          MenuNode(id: "bar", label: "Bar", icon: Icons.local_cafe_rounded),
          MenuNode(
            id: "locali",
            label: "Locali",
            icon: Icons.storefront_rounded,
          ),
          MenuNode(
            id: "prodotti_locali",
            label: "Prodotti locali",
            icon: Icons.shopping_basket_rounded,
            children: <MenuNode>[
              MenuNode(
                id: "prodotto_tartufo",
                label: "Tartufo",
                icon: Icons.spa_rounded,
              ),
              MenuNode(
                id: "prodotto_birra",
                label: "Birra artigianale",
                icon: Icons.sports_bar_rounded,
              ),
              MenuNode(
                id: "tartufo_birra",
                label: "Alogastronomia",
                icon: Icons.local_bar_rounded,
              ),
              MenuNode(
                id: "tipicita_deco",
                label: "Tipicita De.C.O.",
                icon: Icons.verified_rounded,
              ),
            ],
          ),
        ],
      ),
      MenuNode(
        id: "dove_dormire",
        label: "Dove dormire",
        icon: Icons.bed_rounded,
        children: <MenuNode>[
          MenuNode(id: "bnb", label: "B&B", icon: Icons.home_work_rounded),
          MenuNode(id: "hotel", label: "Hotel", icon: Icons.hotel_rounded),
          MenuNode(
            id: "agriturismi_dormire",
            label: "Agriturismi",
            icon: Icons.park_rounded,
          ),
        ],
      ),
      MenuNode(
        id: "cultura",
        label: "Cultura",
        icon: Icons.account_balance_rounded,
        children: <MenuNode>[
          MenuNode(
            id: "musei",
            label: "Musei e mostre",
            icon: Icons.museum_rounded,
          ),
          MenuNode(
            id: "arte_storia",
            label: "Arte e storia",
            icon: Icons.history_edu_rounded,
            children: <MenuNode>[
              MenuNode(id: "arte", label: "Arte", icon: Icons.palette_rounded),
              MenuNode(
                id: "storia",
                label: "Percorsi storici",
                icon: Icons.history_edu_rounded,
              ),
              MenuNode(
                id: "vicolo_ebrei",
                label: "Vicolo degli Ebrei",
                icon: Icons.signpost_rounded,
              ),
            ],
          ),
          MenuNode(
            id: "borgo_simboli",
            label: "Borgo e simboli",
            icon: Icons.location_city_rounded,
            children: <MenuNode>[
              MenuNode(
                id: "borghi",
                label: "Borghi",
                icon: Icons.location_city_rounded,
              ),
              MenuNode(
                id: "teatro_perugini",
                label: "Teatro G. Perugini",
                icon: Icons.theaters_rounded,
              ),
              MenuNode(
                id: "globo_pace",
                label: "Globo della Pace",
                icon: Icons.public_rounded,
              ),
            ],
          ),
          MenuNode(
            id: "territorio",
            label: "Territorio",
            icon: Icons.map_rounded,
            children: <MenuNode>[
              MenuNode(
                id: "dove_siamo",
                label: "Dove siamo",
                icon: Icons.location_on_rounded,
              ),
              MenuNode(
                id: "monte_nerone",
                label: "Monte Nerone",
                icon: Icons.landscape_rounded,
              ),
              MenuNode(
                id: "citta_birra",
                label: "Citta della Birra",
                icon: Icons.sports_bar_rounded,
              ),
              MenuNode(
                id: "mappa_turistica",
                label: "Mappa turistica",
                icon: Icons.map_outlined,
              ),
              MenuNode(
                id: "webcam_meteo",
                label: "Webcam e meteo",
                icon: Icons.wb_cloudy_rounded,
              ),
            ],
          ),
          MenuNode(
            id: "spiritualita",
            label: "Spiritualita",
            icon: Icons.church_rounded,
            children: <MenuNode>[
              MenuNode(
                id: "ss_crocifisso",
                label: "Santuario SS. Crocifisso",
                icon: Icons.church_rounded,
              ),
              MenuNode(
                id: "madonna_vita",
                label: "Madonna della Vita",
                icon: Icons.volunteer_activism_rounded,
              ),
              MenuNode(
                id: "san_martino",
                label: "San Martino",
                icon: Icons.account_balance_rounded,
              ),
              MenuNode(
                id: "parrocchia",
                label: "Parrocchia",
                icon: Icons.diversity_3_rounded,
              ),
              MenuNode(
                id: "oratorio",
                label: "Oratorio San Martino",
                icon: Icons.child_care_rounded,
              ),
              MenuNode(
                id: "avvisi_parrocchiali",
                label: "Avvisi parrocchiali",
                icon: Icons.campaign_rounded,
              ),
            ],
          ),
          MenuNode(
            id: "comunita",
            label: "Comunita",
            icon: Icons.people_alt_rounded,
            children: <MenuNode>[
              MenuNode(
                id: "notizie_paese",
                label: "Notizie del paese",
                icon: Icons.newspaper_rounded,
              ),
              MenuNode(
                id: "pro_loco",
                label: "Pro Loco",
                icon: Icons.groups_2_rounded,
              ),
              MenuNode(
                id: "associazioni",
                label: "Associazioni",
                icon: Icons.handshake_rounded,
              ),
              MenuNode(
                id: "avis",
                label: "AVIS",
                icon: Icons.bloodtype_rounded,
              ),
              MenuNode(
                id: "biblioteca",
                label: "Biblioteca comunale",
                icon: Icons.local_library_rounded,
              ),
              MenuNode(
                id: "mediateca",
                label: "Mediateca",
                icon: Icons.photo_library_rounded,
              ),
              MenuNode(
                id: "foto_giorno",
                label: "Foto del giorno",
                icon: Icons.camera_alt_rounded,
              ),
            ],
          ),
        ],
      ),
      MenuNode(
        id: "servizi",
        label: "Servizi",
        icon: Icons.miscellaneous_services_rounded,
        children: <MenuNode>[
          MenuNode(
            id: "farmacia",
            label: "Farmacie",
            icon: Icons.local_hospital_rounded,
          ),
          MenuNode(
            id: "trasporti",
            label: "Trasporti",
            icon: Icons.directions_bus_rounded,
          ),
          MenuNode(id: "bancomat", label: "Bancomat", icon: Icons.atm_rounded),
          MenuNode(
            id: "salute",
            label: "Salute",
            icon: Icons.health_and_safety_rounded,
          ),
        ],
      ),
      MenuNode(
        id: "myapecchio",
        label: "myApecchio",
        icon: Icons.account_balance_rounded,
        children: <MenuNode>[
          MenuNode(
            id: "amministrazione",
            label: "Amministrazione comunale",
            icon: Icons.apartment_rounded,
            children: <MenuNode>[
              MenuNode(
                id: "sindaco_giunta",
                label: "Sindaco e Giunta",
                icon: Icons.groups_rounded,
              ),
              MenuNode(
                id: "uffici_orari",
                label: "Uffici e orari",
                icon: Icons.schedule_rounded,
              ),
              MenuNode(
                id: "rubrica",
                label: "Contatti rapidi",
                icon: Icons.contact_phone_rounded,
              ),
            ],
          ),
          MenuNode(
            id: "consiglio_comunale",
            label: "Consiglio comunale",
            icon: Icons.how_to_vote_rounded,
            children: <MenuNode>[
              MenuNode(
                id: "diretta",
                label: "Diretta sedute",
                icon: Icons.live_tv_rounded,
              ),
              MenuNode(
                id: "registrazioni",
                label: "Sedute registrate",
                icon: Icons.video_library_rounded,
              ),
              MenuNode(
                id: "ordine_giorno",
                label: "Ordine del giorno",
                icon: Icons.list_alt_rounded,
              ),
            ],
          ),
          MenuNode(
            id: "atti_trasparenza",
            label: "Atti e Trasparenza",
            icon: Icons.gavel_rounded,
            children: <MenuNode>[
              MenuNode(
                id: "albo_pretorio",
                label: "Albo pretorio",
                icon: Icons.folder_shared_rounded,
              ),
              MenuNode(
                id: "delibere",
                label: "Delibere e determine",
                icon: Icons.description_rounded,
              ),
              MenuNode(
                id: "bandi",
                label: "Bandi e concorsi",
                icon: Icons.campaign_rounded,
              ),
            ],
          ),
          MenuNode(
            id: "servizi_cittadino",
            label: "Servizi al cittadino",
            icon: Icons.volunteer_activism_rounded,
            children: <MenuNode>[
              MenuNode(
                id: "pagamenti",
                label: "Pagamenti e tributi",
                icon: Icons.payments_rounded,
              ),
              MenuNode(
                id: "appuntamenti",
                label: "Prenota appuntamento",
                icon: Icons.event_available_rounded,
              ),
              MenuNode(
                id: "certificati",
                label: "Certificati anagrafici",
                icon: Icons.badge_rounded,
              ),
              MenuNode(
                id: "segnalazioni",
                label: "Segnalazioni al Comune",
                icon: Icons.report_problem_rounded,
              ),
            ],
          ),
          MenuNode(
            id: "vita_pubblica",
            label: "Scuola, mobilita e ambiente",
            icon: Icons.public_rounded,
            children: <MenuNode>[
              MenuNode(
                id: "scuola",
                label: "Servizi scolastici",
                icon: Icons.school_rounded,
              ),
              MenuNode(
                id: "mobilita",
                label: "Viabilita e trasporto locale",
                icon: Icons.traffic_rounded,
              ),
              MenuNode(
                id: "rifiuti",
                label: "Raccolta rifiuti",
                icon: Icons.recycling_rounded,
              ),
            ],
          ),
        ],
      ),
      MenuNode(
        id: "sport_prenotazioni",
        label: "Sport",
        icon: Icons.sports_tennis_rounded,
        children: <MenuNode>[
          MenuNode(
            id: "prenotazioni_sport",
            label: "Prenota impianti",
            icon: Icons.event_available_rounded,
            children: <MenuNode>[
              MenuNode(
                id: "campetto_del_prete",
                label: "Campetto del prete",
                icon: Icons.grass_rounded,
              ),
              MenuNode(
                id: "palazzetto",
                label: "Palazzetto",
                icon: Icons.sports_handball_rounded,
                children: <MenuNode>[
                  MenuNode(
                    id: "palazzetto_calcetto",
                    label: "Calcetto",
                    icon: Icons.sports_soccer_rounded,
                  ),
                  MenuNode(
                    id: "palazzetto_city_tennis",
                    label: "City tennis",
                    icon: Icons.sports_handball_rounded,
                  ),
                  MenuNode(
                    id: "palazzetto_pallavolo",
                    label: "Pallavolo",
                    icon: Icons.sports_volleyball_rounded,
                  ),
                ],
              ),
              MenuNode(
                id: "campo_tennis",
                label: "Campo da tennis",
                icon: Icons.sports_tennis_rounded,
              ),
              MenuNode(
                id: "regole_prenotazione",
                label: "Regolamenti e tariffe",
                icon: Icons.rule_rounded,
                children: <MenuNode>[
                  MenuNode(
                    id: "fasce_orarie",
                    label: "Fasce orarie",
                    icon: Icons.schedule_rounded,
                  ),
                  MenuNode(
                    id: "tariffe",
                    label: "Tariffe",
                    icon: Icons.euro_rounded,
                  ),
                  MenuNode(
                    id: "annulla_sposta",
                    label: "Annulla o sposta prenotazione",
                    icon: Icons.swap_horiz_rounded,
                  ),
                ],
              ),
            ],
          ),
          MenuNode(
            id: "sentieri",
            label: "Sentieri e percorsi naturalistici",
            icon: Icons.terrain_rounded,
            children: <MenuNode>[
              MenuNode(
                id: "mappa_sentieri",
                label: "Mappa sentieri",
                icon: Icons.map_rounded,
              ),
              MenuNode(
                id: "difficolta_tempo",
                label: "Difficolta e tempi",
                icon: Icons.hiking_rounded,
              ),
              MenuNode(
                id: "guide_noleggi",
                label: "Guide e noleggi",
                icon: Icons.support_agent_rounded,
                children: <MenuNode>[
                  MenuNode(
                    id: "prenota_guida",
                    label: "Prenota guida ambientale",
                    icon: Icons.support_agent_rounded,
                  ),
                  MenuNode(
                    id: "prenota_istruttore",
                    label: "Prenota istruttore outdoor",
                    icon: Icons.fitness_center_rounded,
                  ),
                  MenuNode(
                    id: "noleggio_ebike",
                    label: "Noleggio bici elettriche",
                    icon: Icons.electric_bike_rounded,
                  ),
                ],
              ),
              MenuNode(
                id: "tour_natura",
                label: "Tour e natura",
                icon: Icons.family_restroom_rounded,
                children: <MenuNode>[
                  MenuNode(
                    id: "tour_famiglie",
                    label: "Tour famiglie e scuole",
                    icon: Icons.family_restroom_rounded,
                  ),
                  MenuNode(
                    id: "canoa_trekking",
                    label: "Canoa e trekking guidato",
                    icon: Icons.kayaking_rounded,
                  ),
                  MenuNode(
                    id: "birdwatching",
                    label: "Birdwatching",
                    icon: Icons.visibility_rounded,
                  ),
                ],
              ),
              MenuNode(
                id: "parchi_avventura",
                label: "Parchi e avventura",
                icon: Icons.forest_rounded,
                children: <MenuNode>[
                  MenuNode(
                    id: "parco_avventura",
                    label: "Parco Avventura Furlo",
                    icon: Icons.forest_rounded,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  late List<MenuNode> _menuPath;

  MenuNode get _profileMenuRoot {
    if (widget.user.profile == UserProfile.resident) {
      return _menuRoot;
    }
    return MenuNode(
      id: _menuRoot.id,
      label: _menuRoot.label,
      icon: _menuRoot.icon,
      highlighted: _menuRoot.highlighted,
      children: _menuRoot.children
          .where((node) => node.id != "myapecchio")
          .toList(growable: false),
    );
  }

  MenuNode get _currentNode => _menuPath.last;
  MenuNode? get _parentNode =>
      _menuPath.length > 1 ? _menuPath[_menuPath.length - 2] : null;

  @override
  void initState() {
    super.initState();
    _menuPath = <MenuNode>[_profileMenuRoot];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const _LivingMapLayer(),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: _showRadialMenu ? 0.16 : 1,
            child: IgnorePointer(
              ignoring: _showRadialMenu,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _WelcomePanel(
                        user: widget.user,
                        onSettings: _openSettings,
                        onLogout: _logout,
                      ),
                      const SizedBox(height: 12),
                      _RewardCenterPanel(onTap: _openRewards),
                      const SizedBox(height: 12),
                      _QuickActionRow(
                        selected: _activeQuickFilter,
                        actions: _quickActions,
                        onChanged: (value) =>
                            setState(() => _activeQuickFilter = value),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _HomeInsightPanel(
                          selectedAction: _activeQuickFilter,
                          user: widget.user,
                          onOpenNotices: _openNotices,
                          onOpenNoticeDetail: _openNoticeDetail,
                          onOpenEvents: () => _openEvents(),
                          onOpenDining: () => _openDining(nodeId: "ristoranti"),
                          onOpenTrails: _openTrails,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _showRadialMenu ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            child: IgnorePointer(
              ignoring: !_showRadialMenu,
              child: _RadialMenuOverlay(
                currentNode: _currentNode,
                parentNode: _parentNode,
                onNodeTap: _onNodeTap,
                onBackTap: _onBackTap,
              ),
            ),
          ),
          _ExploreOrbButton(
            isOpen: _showRadialMenu,
            onTap: _toggleExplore,
            label: _showRadialMenu ? _currentNode.label : "Esplora",
          ),
        ],
      ),
    );
  }

  void _toggleExplore() {
    setState(() {
      if (!_showRadialMenu) {
        _menuPath = <MenuNode>[_profileMenuRoot];
      }
      _showRadialMenu = !_showRadialMenu;
    });
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  void _openSettings() {
    setState(() => _showRadialMenu = false);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(user: widget.user),
      ),
    );
  }

  void _openRewards() {
    setState(() => _showRadialMenu = false);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RewardsScreen(controller: appGamification),
      ),
    );
  }

  void _openNotices() {
    setState(() => _showRadialMenu = false);
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: const NoticesArchiveScreen(),
            ),
          );
        },
      ),
    );
  }

  void _openNoticeDetail(AppNotice notice) {
    setState(() => _showRadialMenu = false);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NoticeDetailScreen(notice: notice),
      ),
    );
  }

  void _onNodeTap(MenuNode node) {
    if (node.isLeaf) {
      setState(() => _showRadialMenu = false);
      Future<void>.delayed(const Duration(milliseconds: 560), () {
        if (!mounted) {
          return;
        }
        if (_isEventNode(node)) {
          _openEvents(initialFilter: node.id == "calendario" ? null : node.id);
          return;
        }
        if (_isNoticeNode(node)) {
          _openNotices();
          return;
        }
        if (_isLocalProductNode(node)) {
          _openLocalProducts(initialProductId: node.id);
          return;
        }
        if (_isDiningNode(node)) {
          _openDining(nodeId: node.id);
          return;
        }
        if (_isTrailNode(node)) {
          _openTrails();
          return;
        }
        if (_isSportBookingNode(node)) {
          _openSportBooking(node.id);
          return;
        }
        if (_isSportRulesNode(node)) {
          _openSportRules(node.id);
          return;
        }
        if (_isOutdoorServiceNode(node)) {
          _openOutdoorServices(node.id);
          return;
        }
        if (_isCultureNode(node)) {
          _openCulture(node.id);
          return;
        }
        if (_isFinalInfoNode(node)) {
          _openFinalInfo(node.id);
          return;
        }
        _openDetail(
          title: node.label,
          type: "Foglia di menu",
          ctaLabel: "Apri",
        );
      });
      return;
    }
    setState(() {
      _menuPath = <MenuNode>[..._menuPath, node];
    });
  }

  bool _isEventNode(MenuNode node) {
    return const {
      "calendario",
      "feste_tradizioni",
      "eventi_gastronomici",
      "cultura_spettacoli",
      "mostre",
      "sport_outdoor",
      "comunita_spiritualita",
    }.contains(node.id);
  }

  bool _isNoticeNode(MenuNode node) {
    return node.id == "avvisi";
  }

  bool _isDiningNode(MenuNode node) {
    return const {
      "ristoranti",
      "agriturismi",
      "bar",
      "bnb",
      "agriturismi_dormire",
      "hotel",
      "locali",
    }.contains(node.id);
  }

  bool _isLocalProductNode(MenuNode node) {
    return const {
      "prodotto_tartufo",
      "prodotto_birra",
      "tartufo_birra",
      "tipicita_deco",
    }.contains(node.id);
  }

  bool _isTrailNode(MenuNode node) {
    return const {"mappa_sentieri", "difficolta_tempo"}.contains(node.id);
  }

  bool _isSportBookingNode(MenuNode node) {
    return const {
      "campetto_del_prete",
      "palazzetto_calcetto",
      "palazzetto_city_tennis",
      "palazzetto_pallavolo",
      "campo_tennis",
    }.contains(node.id);
  }

  bool _isSportRulesNode(MenuNode node) {
    return const {
      "fasce_orarie",
      "tariffe",
      "annulla_sposta",
    }.contains(node.id);
  }

  bool _isOutdoorServiceNode(MenuNode node) {
    return const {
      "prenota_guida",
      "prenota_istruttore",
      "noleggio_ebike",
      "tour_famiglie",
      "canoa_trekking",
      "parco_avventura",
      "birdwatching",
    }.contains(node.id);
  }

  bool _isCultureNode(MenuNode node) {
    return const {
      "musei",
      "borghi",
      "arte",
      "storia",
      "vicolo_ebrei",
      "teatro_perugini",
      "globo_pace",
    }.contains(node.id);
  }

  bool _isFinalInfoNode(MenuNode node) {
    return _finalInfoPagesById.containsKey(node.id);
  }

  void _onBackTap() {
    if (_menuPath.length <= 1) {
      return;
    }
    setState(() {
      _menuPath = _menuPath.sublist(0, _menuPath.length - 1);
    });
  }

  void _openDetail({
    required String title,
    required String type,
    required String ctaLabel,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: DetailScreen(title: title, type: type, ctaLabel: ctaLabel),
            ),
          );
        },
      ),
    );
  }

  void _openEvents({String? initialFilter}) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: EventsScreen(initialFilter: initialFilter),
            ),
          );
        },
      ),
    );
  }

  void _openDining({required String nodeId}) {
    final initialKind = switch (nodeId) {
      "agriturismi" || "agriturismi_dormire" => DiningKind.agriturismo,
      "bar" => DiningKind.bar,
      "bnb" || "hotel" => DiningKind.bnb,
      "locali" => DiningKind.locale,
      "musei" => DiningKind.mostra,
      _ => DiningKind.restaurant,
    };
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: DiningScreen(initialKind: initialKind),
            ),
          );
        },
      ),
    );
  }

  void _openLocalProducts({required String initialProductId}) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: LocalProductsScreen(initialProductId: initialProductId),
            ),
          );
        },
      ),
    );
  }

  void _openTrails() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: curved, child: const TrailsScreen()),
          );
        },
      ),
    );
  }

  void _openSportBooking(String nodeId) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: SportBookingScreen(initialFacilityId: nodeId),
            ),
          );
        },
      ),
    );
  }

  void _openSportRules(String nodeId) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: SportRulesScreen(initialSectionId: nodeId),
            ),
          );
        },
      ),
    );
  }

  void _openOutdoorServices(String nodeId) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: OutdoorServicesScreen(initialServiceId: nodeId),
            ),
          );
        },
      ),
    );
  }

  void _openCulture(String nodeId) {
    final page = _culturePagesById[nodeId]!;
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: CulturePageScreen(page: page),
            ),
          );
        },
      ),
    );
  }

  void _openFinalInfo(String nodeId) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: FinalInfoPageScreen(initialPageId: nodeId),
            ),
          );
        },
      ),
    );
  }
}

class _LivingMapLayer extends StatelessWidget {
  const _LivingMapLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            "assets/images/appecchio_bg.png",
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF4F7F62),
                      Color(0xFF769F80),
                      Color(0xFFB1C8AF),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: _MapPathPainter())),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.10),
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.25),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(20, size.height * 0.24)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.22,
        size.width - 30,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.54,
        40,
        size.height * 0.68,
      )
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.76,
        size.width - 40,
        size.height * 0.9,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MapPathPainter oldDelegate) => false;
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({
    required this.user,
    required this.onSettings,
    required this.onLogout,
  });

  final AppUser user;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 74,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          color: Colors.black.withValues(alpha: 0.32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                tooltip: "Impostazioni",
                onPressed: onSettings,
                icon: const Icon(Icons.settings_rounded, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ciao, ${user.name}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.profileLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: "Cambia ruolo",
                onPressed: onLogout,
                icon: const Icon(
                  Icons.switch_account_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardCenterPanel extends StatelessWidget {
  const _RewardCenterPanel({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appGamification,
      builder: (context, _) {
        final nextLevel = appGamification.nextLevel;
        final level = appGamification.currentLevel;
        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Material(
              color: Colors.white.withValues(alpha: 0.92),
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFFFE8A8),
                            child: Icon(
                              level.icon,
                              color: const Color(0xFF8A6400),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Token totali",
                                  style: TextStyle(
                                    color: Color(0xFF526055),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  "${appGamification.balance}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF17251D),
                                    fontSize: 34,
                                    height: 1,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                level.name,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Color(0xFF2E7D57),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.workspace_premium_rounded,
                                    size: 16,
                                    color: Color(0xFF8A6400),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${appGamification.unlockedMedalCount}/${GamificationController.medals.length}",
                                    style: const TextStyle(
                                      color: Color(0xFF526055),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: appGamification.progressToNextLevel,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE1E8DD),
                          color: const Color(0xFF2E7D57),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              nextLevel == null
                                  ? "Livello massimo raggiunto"
                                  : "Prossimo livello: ${nextLevel.name} a ${nextLevel.minPoints} token",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF526055),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Color(0xFF2E7D57),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class HomeQuickAction {
  const HomeQuickAction({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}

class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow({
    required this.selected,
    required this.actions,
    required this.onChanged,
  });

  final String selected;
  final List<HomeQuickAction> actions;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final action in actions) ...[
          Expanded(
            child: _QuickActionButton(
              action: action,
              selected: action.id == selected,
              onTap: () => onChanged(action.id),
            ),
          ),
          if (action != actions.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.action,
    required this.selected,
    required this.onTap,
  });

  final HomeQuickAction action;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: action.label,
      child: Material(
        color: selected
            ? const Color(0xFF2E7D57)
            : Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            height: 62,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action.icon, color: Colors.white, size: 22),
                const SizedBox(height: 5),
                Text(
                  action.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
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

class _HomeInsightPanel extends StatelessWidget {
  const _HomeInsightPanel({
    required this.selectedAction,
    required this.user,
    required this.onOpenNotices,
    required this.onOpenNoticeDetail,
    required this.onOpenEvents,
    required this.onOpenDining,
    required this.onOpenTrails,
  });

  final String selectedAction;
  final AppUser user;
  final VoidCallback onOpenNotices;
  final ValueChanged<AppNotice> onOpenNoticeDetail;
  final VoidCallback onOpenEvents;
  final VoidCallback onOpenDining;
  final VoidCallback onOpenTrails;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      child: _HomeInsightContent(
        key: ValueKey<String>(selectedAction),
        selectedAction: selectedAction,
        user: user,
        onOpenNotices: onOpenNotices,
        onOpenNoticeDetail: onOpenNoticeDetail,
        onOpenEvents: onOpenEvents,
        onOpenDining: onOpenDining,
        onOpenTrails: onOpenTrails,
      ),
    );
  }
}

class _HomeInsightContent extends StatelessWidget {
  const _HomeInsightContent({
    super.key,
    required this.selectedAction,
    required this.user,
    required this.onOpenNotices,
    required this.onOpenNoticeDetail,
    required this.onOpenEvents,
    required this.onOpenDining,
    required this.onOpenTrails,
  });

  final String selectedAction;
  final AppUser user;
  final VoidCallback onOpenNotices;
  final ValueChanged<AppNotice> onOpenNoticeDetail;
  final VoidCallback onOpenEvents;
  final VoidCallback onOpenDining;
  final VoidCallback onOpenTrails;

  @override
  Widget build(BuildContext context) {
    final raining =
        selectedAction == "oggi" || user.profile == UserProfile.tourist;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.white.withValues(alpha: 0.18),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WeatherSuggestionBubble(
                  raining: raining,
                  touristMode: user.profile == UserProfile.tourist,
                ),
                const SizedBox(height: 14),
                if (selectedAction == "oggi")
                  _TodayOverview(
                    raining: raining,
                    onOpenNotices: onOpenNotices,
                    onOpenNoticeDetail: onOpenNoticeDetail,
                    onOpenEvents: onOpenEvents,
                    onOpenDining: onOpenDining,
                    onOpenTrails: onOpenTrails,
                  )
                else if (selectedAction == "avvisi")
                  _NoticesOverview(
                    onOpenNotices: onOpenNotices,
                    onOpenNoticeDetail: onOpenNoticeDetail,
                  )
                else if (selectedAction == "aperti")
                  _OpenNowOverview(onOpenDining: onOpenDining)
                else if (selectedAction == "vicino")
                  _NearbyOverview(raining: raining, onOpenTrails: onOpenTrails)
                else
                  _NotificationsOverview(
                    onOpenNotices: onOpenNotices,
                    onOpenNoticeDetail: onOpenNoticeDetail,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeatherSuggestionBubble extends StatelessWidget {
  const _WeatherSuggestionBubble({
    required this.raining,
    required this.touristMode,
  });

  final bool raining;
  final bool touristMode;

  @override
  Widget build(BuildContext context) {
    final icon = raining ? Icons.water_drop_rounded : Icons.wb_sunny_rounded;
    final title = raining ? "Pioggia leggera" : "Sole pieno";
    final message = raining
        ? touristMode
            ? "Meglio stare al coperto: questa settimana ci sono mostra fotografica e teatro nel borgo."
            : "Campi outdoor delicati: oggi meglio palazzetto o appuntamenti al coperto."
        : "Giornata buona per percorsi, sport all'aperto e tavoli con vista.";
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                raining ? const Color(0xFFDCEBFF) : const Color(0xFFFFE8A8),
            child: Icon(
              icon,
              color:
                  raining ? const Color(0xFF2A6F97) : const Color(0xFF9A6B00),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(message, style: const TextStyle(height: 1.25)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayOverview extends StatelessWidget {
  const _TodayOverview({
    required this.raining,
    required this.onOpenNotices,
    required this.onOpenNoticeDetail,
    required this.onOpenEvents,
    required this.onOpenDining,
    required this.onOpenTrails,
  });

  final bool raining;
  final VoidCallback onOpenNotices;
  final ValueChanged<AppNotice> onOpenNoticeDetail;
  final VoidCallback onOpenEvents;
  final VoidCallback onOpenDining;
  final VoidCallback onOpenTrails;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PanelTitle(title: "Oggi in paese"),
        AnimatedBuilder(
          animation: appNotices,
          builder: (context, _) {
            final notice = appNotices.todayNotices.isNotEmpty
                ? appNotices.todayNotices.first
                : appNotices.leadingNotice;
            if (notice == null) {
              return _InsightTile(
                icon: Icons.campaign_rounded,
                title: "Nessun avviso urgente",
                subtitle: "L'archivio resta pronto per nuove segnalazioni.",
                onTap: onOpenNotices,
              );
            }
            return _NoticeInsightTile(
              notice: notice,
              compactDate: true,
              onTap: () => onOpenNoticeDetail(notice),
            );
          },
        ),
        _InsightTile(
          icon: raining ? Icons.museum_rounded : Icons.hiking_rounded,
          title: raining
              ? "Mostra fotografica in sala civica"
              : "Percorso panoramico del pomeriggio",
          subtitle: raining
              ? "Evento consigliato al coperto, aperto fino alle 19:00."
              : "Ideale con il sole: partenza morbida dal centro.",
          onTap: raining ? onOpenEvents : onOpenTrails,
        ),
        _InsightTile(
          icon: Icons.restaurant_rounded,
          title: "Cena consigliata",
          subtitle: "Civico 14+5 e Monte Nerone hanno slot liberi stasera.",
          onTap: onOpenDining,
        ),
        _InsightTile(
          icon: raining
              ? Icons.sports_handball_rounded
              : Icons.sports_tennis_rounded,
          title: raining
              ? "Palazzetto disponibile"
              : "Campo da tennis disponibile",
          subtitle: raining
              ? "Meglio una partita indoor: calcetto e pallavolo hanno spazi liberi."
              : "Tempo buono per giocare all'aperto nel tardo pomeriggio.",
        ),
        _InsightTile(
          icon: Icons.event_rounded,
          title: "Prossimo evento",
          subtitle: "Jazz tra le pietre, sabato sera nel centro storico.",
          onTap: onOpenEvents,
        ),
      ],
    );
  }
}

class _OpenNowOverview extends StatelessWidget {
  const _OpenNowOverview({required this.onOpenDining});

  final VoidCallback onOpenDining;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PanelTitle(title: "Aperti adesso"),
        const _InsightTile(
          icon: Icons.local_cafe_rounded,
          title: "Bar in centro",
          subtitle: "Pausa rapida e punto di incontro vicino alla piazza.",
        ),
        _InsightTile(
          icon: Icons.restaurant_menu_rounded,
          title: "Cucine con disponibilita",
          subtitle: "Il Greco, SP257 e Le Ciocche accettano prenotazioni.",
          onTap: onOpenDining,
        ),
        const _InsightTile(
          icon: Icons.local_hospital_rounded,
          title: "Servizi essenziali",
          subtitle:
              "Farmacia e informazioni comunali disponibili negli orari diurni.",
        ),
      ],
    );
  }
}

class _NearbyOverview extends StatelessWidget {
  const _NearbyOverview({required this.raining, required this.onOpenTrails});

  final bool raining;
  final VoidCallback onOpenTrails;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PanelTitle(title: "Vicino a te"),
        const _InsightTile(
          icon: Icons.place_rounded,
          title: "Centro storico",
          subtitle: "Luoghi, mostre e ristoranti raggiungibili a piedi.",
        ),
        _InsightTile(
          icon: raining ? Icons.account_balance_rounded : Icons.terrain_rounded,
          title: raining ? "Riparo culturale" : "Aria aperta",
          subtitle: raining
              ? "Museo e sala civica sono le scelte migliori con il meteo incerto."
              : "Sentieri del Nerone, Gorgaccia e Fondarca mappati dall'alto.",
          onTap: raining ? null : onOpenTrails,
        ),
      ],
    );
  }
}

class _NoticesOverview extends StatelessWidget {
  const _NoticesOverview({
    required this.onOpenNotices,
    required this.onOpenNoticeDetail,
  });

  final VoidCallback onOpenNotices;
  final ValueChanged<AppNotice> onOpenNoticeDetail;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appNotices,
      builder: (context, _) {
        final notices = appNotices.notices.take(4).toList(growable: false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PanelTitle(title: "Avvisi e segnalazioni"),
            for (final notice in notices)
              _NoticeInsightTile(
                notice: notice,
                onTap: () => onOpenNoticeDetail(notice),
              ),
            _InsightTile(
              icon: Icons.archive_rounded,
              title: "Archivio completo",
              subtitle:
                  "Apri tutti gli avvisi e consulta il calendario dedicato.",
              onTap: onOpenNotices,
            ),
          ],
        );
      },
    );
  }
}

class _NotificationsOverview extends StatelessWidget {
  const _NotificationsOverview({
    required this.onOpenNotices,
    required this.onOpenNoticeDetail,
  });

  final VoidCallback onOpenNotices;
  final ValueChanged<AppNotice> onOpenNoticeDetail;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appNotices,
      builder: (context, _) {
        final notices = appNotices.notices.take(2).toList(growable: false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PanelTitle(title: "Notifiche"),
            for (final notice in notices)
              _NoticeInsightTile(
                notice: notice,
                onTap: () => onOpenNoticeDetail(notice),
              ),
            const _InsightTile(
              icon: Icons.notifications_active_rounded,
              title: "Meteo aggiornato",
              subtitle:
                  "Pioggia possibile nel pomeriggio: consigliati eventi al coperto.",
            ),
            const _InsightTile(
              icon: Icons.event_available_rounded,
              title: "Prenotazioni",
              subtitle: "Palazzetto libero dalle 18:30 per attivita indoor.",
            ),
            _InsightTile(
              icon: Icons.archive_rounded,
              title: "Tutti gli avvisi",
              subtitle: "Consulta archivio e calendario delle segnalazioni.",
              onTap: onOpenNotices,
            ),
          ],
        );
      },
    );
  }
}

class _NoticeInsightTile extends StatelessWidget {
  const _NoticeInsightTile({
    required this.notice,
    required this.onTap,
    this.compactDate = false,
  });

  final AppNotice notice;
  final VoidCallback onTap;
  final bool compactDate;

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        compactDate ? _formatNoticeShortDate(notice.date) : notice.dateLabel;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: notice.highlighted
            ? const Color(0xFFFFF1C7)
            : Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: notice.accentColor.withValues(alpha: 0.16),
                  child: Icon(notice.icon, color: notice.accentColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              notice.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (notice.highlighted) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.priority_high_rounded,
                              color: Color(0xFF9A5A00),
                              size: 17,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "$dateLabel · ${notice.kindLabel}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notice.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(height: 1.2),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF2E7D57),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  const _PanelTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE4EFE8),
                  child: Icon(icon, color: const Color(0xFF2E7D57)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(height: 1.2),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF2E7D57),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadialMenuOverlay extends StatelessWidget {
  const _RadialMenuOverlay({
    required this.currentNode,
    required this.parentNode,
    required this.onNodeTap,
    required this.onBackTap,
  });

  final MenuNode currentNode;
  final MenuNode? parentNode;
  final ValueChanged<MenuNode> onNodeTap;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return _RadialMenuStage(
      key: ValueKey<String>(currentNode.id),
      currentNode: currentNode,
      parentNode: parentNode,
      onNodeTap: onNodeTap,
      onBackTap: onBackTap,
    );
  }
}

class _MenuLayoutSpec {
  const _MenuLayoutSpec({
    required this.useCompactMenu,
    required this.edgePadding,
    required this.bottomPadding,
    required this.titleTop,
    required this.titleClearance,
    required this.centerYFactor,
    required this.nodeWidthFactor,
    required this.nodeHeightFactor,
    required this.minNodeWidth,
    required this.maxNodeWidth,
    required this.minNodeHeight,
    required this.maxNodeHeight,
    required this.rootRadiusFactor,
    required this.childRadiusFactor,
    required this.backRadiusFactor,
    required this.minRadius,
    required this.maxRadius,
    required this.minBackRadius,
    required this.maxBackRadius,
    required this.ringGapFactor,
    required this.minRingGap,
    required this.maxRingGap,
    required this.nodeGap,
    required this.radiusStep,
    required this.minFallbackRadius,
  });

  final bool useCompactMenu;
  final double edgePadding;
  final double bottomPadding;
  final double titleTop;
  final double titleClearance;
  final double centerYFactor;
  final double nodeWidthFactor;
  final double nodeHeightFactor;
  final double minNodeWidth;
  final double maxNodeWidth;
  final double minNodeHeight;
  final double maxNodeHeight;
  final double rootRadiusFactor;
  final double childRadiusFactor;
  final double backRadiusFactor;
  final double minRadius;
  final double maxRadius;
  final double minBackRadius;
  final double maxBackRadius;
  final double ringGapFactor;
  final double minRingGap;
  final double maxRingGap;
  final double nodeGap;
  final double radiusStep;
  final double minFallbackRadius;

  factory _MenuLayoutSpec.from(Size size) {
    final shortest = math.min(size.width, size.height);
    final isLandscape = size.width > size.height;
    final tablet = shortest >= 600;

    return _MenuLayoutSpec(
      useCompactMenu: false,
      edgePadding: shortest < 390 ? 10 : 16,
      bottomPadding: shortest < 390 ? 82 : 96,
      titleTop: isLandscape ? 24 : (shortest < 390 ? 54 : 70),
      titleClearance: shortest < 390 ? 62 : 74,
      centerYFactor: isLandscape ? 0.54 : 0.52,
      nodeWidthFactor: tablet ? 0.20 : 0.27,
      nodeHeightFactor: tablet ? 0.16 : 0.21,
      minNodeWidth: shortest <= 430 ? 62 : 86,
      maxNodeWidth: tablet ? 148 : 122,
      minNodeHeight: shortest <= 430 ? 50 : 74,
      maxNodeHeight: tablet ? 116 : 100,
      rootRadiusFactor: tablet ? 0.33 : 0.38,
      childRadiusFactor: tablet ? 0.30 : 0.34,
      backRadiusFactor: tablet ? 0.23 : 0.27,
      minRadius: shortest < 390 ? 92 : 112,
      maxRadius: tablet ? 260 : 192,
      minBackRadius: shortest < 390 ? 82 : 102,
      maxBackRadius: tablet ? 180 : 148,
      ringGapFactor: tablet ? 1.04 : 0.96,
      minRingGap: shortest < 390 ? 52 : 60,
      maxRingGap: tablet ? 92 : 80,
      nodeGap: shortest < 390 ? 8 : 12,
      radiusStep: shortest < 390 ? 4 : 6,
      minFallbackRadius: shortest < 390 ? 68 : 82,
    );
  }
}

class _CompactMenuStage extends StatelessWidget {
  const _CompactMenuStage({
    required this.currentNode,
    required this.parentNode,
    required this.onNodeTap,
    required this.onBackTap,
  });

  final MenuNode currentNode;
  final MenuNode? parentNode;
  final ValueChanged<MenuNode> onNodeTap;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.78),
            Colors.black.withValues(alpha: 0.70),
            Colors.black.withValues(alpha: 0.82),
          ],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final crossAxisCount =
                isLandscape ? 4 : (constraints.maxWidth < 380 ? 2 : 3);
            final aspectRatio = isLandscape ? 1.55 : 1.08;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                isLandscape ? 20 : 16,
                isLandscape ? 12 : 18,
                isLandscape ? 20 : 16,
                104,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (parentNode != null)
                        _CompactBackButton(
                          label: parentNode!.label,
                          onTap: onBackTap,
                        ),
                      if (parentNode != null) const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          currentNode.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: currentNode.children.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: aspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final node = currentNode.children[index];
                        return _CompactMenuCard(
                          node: node,
                          onTap: () => onNodeTap(node),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CompactBackButton extends StatelessWidget {
  const _CompactBackButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 116),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactMenuCard extends StatelessWidget {
  const _CompactMenuCard({required this.node, required this.onTap});

  final MenuNode node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final highlighted = node.highlighted;
    return Material(
      color: highlighted
          ? const Color(0xFFFFF1C7)
          : Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 82;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    node.icon,
                    color: highlighted
                        ? const Color(0xFF9A5A00)
                        : const Color(0xFF1B2E21),
                    size: compact ? 20 : 26,
                  ),
                  SizedBox(height: compact ? 4 : 8),
                  Flexible(
                    child: Text(
                      node.label,
                      textAlign: TextAlign.center,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: highlighted
                            ? const Color(0xFF5F3C00)
                            : const Color(0xFF1B2E21),
                        fontWeight: FontWeight.w800,
                        height: 1.06,
                        fontSize: compact ? 11 : 12,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RadialMenuStage extends StatelessWidget {
  const _RadialMenuStage({
    super.key,
    required this.currentNode,
    required this.parentNode,
    required this.onNodeTap,
    required this.onBackTap,
  });

  final MenuNode currentNode;
  final MenuNode? parentNode;
  final ValueChanged<MenuNode> onNodeTap;
  final VoidCallback onBackTap;

  static const double _goldenRatio = 1.618033988749895;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spec = _MenuLayoutSpec.from(constraints.biggest);
        final shortest = math.min(constraints.maxWidth, constraints.maxHeight);
        if (spec.useCompactMenu) {
          return _CompactMenuStage(
            currentNode: currentNode,
            parentNode: parentNode,
            onNodeTap: onNodeTap,
            onBackTap: onBackTap,
          );
        }

        final countFactor = currentNode.children.length > 5
            ? 0.68
            : (currentNode.children.length > 3 ? 0.70 : 1.0);
        final nodeWidth = ((shortest * spec.nodeWidthFactor) * countFactor)
            .clamp(spec.minNodeWidth, spec.maxNodeWidth)
            .toDouble();
        final nodeHeight = ((shortest * spec.nodeHeightFactor) * countFactor)
            .clamp(spec.minNodeHeight, spec.maxNodeHeight)
            .toDouble();
        final center = Offset(constraints.maxWidth / 2,
            constraints.maxHeight * spec.centerYFactor);
        final backRadius = (shortest * spec.backRadiusFactor)
            .clamp(spec.minBackRadius, spec.maxBackRadius)
            .toDouble();
        final backTarget = parentNode != null
            ? Offset(center.dx - backRadius, center.dy)
            : null;
        final targets = _computeTargets(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          center: center,
          total: currentNode.children.length,
          hasParent: parentNode != null,
          nodeWidth: nodeWidth,
          nodeHeight: nodeHeight,
          backTarget: backTarget,
          spec: spec,
        );
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.72),
                Colors.black.withValues(alpha: 0.66),
                Colors.black.withValues(alpha: 0.74),
              ],
            ),
          ),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 620),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0.0, end: 1.0),
            builder: (context, progress, child) {
              return Stack(
                children: [
                  Positioned(
                    top: spec.titleTop,
                    left: spec.edgePadding,
                    right: spec.edgePadding,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: progress,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Text(
                            currentNode.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _TreeBranchPainter(
                        center: center,
                        targets: targets,
                        backTarget: backTarget,
                        progress: progress,
                        hasParent: parentNode != null,
                      ),
                    ),
                  ),
                  if (parentNode != null)
                    _RadialNode(
                      center: center,
                      fixedAngle: math.pi,
                      radius: backRadius,
                      nodeId: "back-${parentNode!.id}",
                      label: parentNode!.label,
                      icon: Icons.undo_rounded,
                      selected: false,
                      highlighted: false,
                      progress: progress,
                      width: nodeWidth,
                      height: nodeHeight,
                      onTap: onBackTap,
                    ),
                  for (var i = 0; i < currentNode.children.length; i++)
                    _RadialNode(
                      center: center,
                      fixedOffset: targets[i],
                      radius: 0,
                      nodeId: currentNode.children[i].id,
                      label: currentNode.children[i].label,
                      icon: currentNode.children[i].icon,
                      selected: false,
                      highlighted: currentNode.children[i].highlighted,
                      progress: progress,
                      width: nodeWidth,
                      height: nodeHeight,
                      onTap: () => onNodeTap(currentNode.children[i]),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  List<Offset> _computeTargets({
    required Size size,
    required Offset center,
    required int total,
    required bool hasParent,
    required double nodeWidth,
    required double nodeHeight,
    required Offset? backTarget,
    required _MenuLayoutSpec spec,
  }) {
    if (total == 0) {
      return const <Offset>[];
    }
    final useWideChildArc = hasParent && size.height < 520;
    final start = hasParent
        ? (useWideChildArc ? -math.pi * 0.78 : -math.pi / 2.65)
        : -math.pi * 0.86;
    final end = hasParent
        ? (useWideChildArc ? math.pi * 0.78 : math.pi / 2.65)
        : math.pi * 0.86;
    final shortest = math.min(size.width, size.height);
    var baseRadius = (hasParent
            ? shortest * spec.childRadiusFactor
            : shortest * spec.rootRadiusFactor)
        .clamp(spec.minRadius, spec.maxRadius)
        .toDouble();

    final horizontalPadding = spec.edgePadding;
    final bottomPadding = spec.bottomPadding;
    final topPadding = spec.titleTop + spec.titleClearance;

    final minX = horizontalPadding + nodeWidth / 2;
    final maxX = size.width - horizontalPadding - nodeWidth / 2;
    final minY = topPadding + nodeHeight / 2;
    final maxY = size.height - bottomPadding - nodeHeight / 2;
    final openOrbSize = (shortest * 0.22).clamp(76.0, 86.0).toDouble();
    final centerClearance = openOrbSize / 2 + nodeWidth / 2 + spec.nodeGap;
    final childMinX =
        hasParent && !useWideChildArc ? center.dx + centerClearance : minX;

    Offset clampToViewport(Offset point) {
      return Offset(
        point.dx.clamp(math.min(childMinX, maxX), maxX).toDouble(),
        point.dy.clamp(minY, maxY).toDouble(),
      );
    }

    bool fits(List<Offset> positions) {
      for (final p in positions) {
        if (p.dx - (nodeWidth / 2) < horizontalPadding) {
          return false;
        }
        if (p.dx + (nodeWidth / 2) > size.width - horizontalPadding) {
          return false;
        }
        if (p.dy - (nodeHeight / 2) < topPadding) {
          return false;
        }
        if (p.dy + (nodeHeight / 2) > size.height - bottomPadding) {
          return false;
        }
      }
      for (var i = 0; i < positions.length; i++) {
        for (var j = i + 1; j < positions.length; j++) {
          final minDist = math.max(nodeWidth, nodeHeight) * 0.92;
          if ((positions[i] - positions[j]).distance < minDist) {
            return false;
          }
        }
      }
      return true;
    }

    List<Offset> buildPositions(double radius) {
      final arc = (end - start).abs();
      const goldenGapFactor =
          1 / _goldenRatio + 1 / (_goldenRatio * _goldenRatio);
      final ringGap =
          (nodeHeight * ((spec.ringGapFactor + goldenGapFactor) / 2))
              .clamp(spec.minRingGap, spec.maxRingGap)
              .toDouble();
      final rings = <double>[radius];
      if (total > 4) {
        rings.add((radius - ringGap).clamp(74.0, radius).toDouble());
      }
      if (total > 8) {
        rings.add((radius - (ringGap * 2)).clamp(62.0, radius).toDouble());
      }

      var remaining = total;
      final points = <Offset>[];

      for (var ringIndex = 0; ringIndex < rings.length; ringIndex++) {
        final ringRadius = rings[ringIndex];
        final ringArcLength = arc * ringRadius;
        final capacity =
            math.max(1, (ringArcLength / (nodeWidth + spec.nodeGap)).floor());
        final take = ringIndex == rings.length - 1
            ? remaining
            : math.min(remaining, capacity);
        if (take <= 0) {
          continue;
        }

        final ringInset = ringIndex / (_goldenRatio * 5);
        final ringStart = start + (end - start) * ringInset;
        final ringEnd = end - (end - start) * ringInset;
        final offsetStep =
            ringIndex.isOdd && take > 1 ? 1 / (_goldenRatio * take) : 0.0;

        for (var i = 0; i < take; i++) {
          final t = take == 1 ? 0.5 : (i + offsetStep) / (take - 1);
          final angle = ringStart +
              (ringEnd - ringStart) *
                  _goldenArcProgress(t.clamp(0.0, 1.0).toDouble());
          final dx = center.dx + math.cos(angle) * ringRadius;
          final dy = center.dy + math.sin(angle) * ringRadius;
          points.add(clampToViewport(Offset(dx, dy)));
        }
        remaining -= take;
        if (remaining <= 0) {
          break;
        }
      }

      if (remaining > 0) {
        final extraRadius = (radius - 10).clamp(58.0, radius).toDouble();
        for (var i = 0; i < remaining; i++) {
          final t = remaining == 1 ? 0.5 : i / (remaining - 1);
          final angle = start + (end - start) * t;
          final dx = center.dx + math.cos(angle) * extraRadius;
          final dy = center.dy + math.sin(angle) * extraRadius;
          points.add(clampToViewport(Offset(dx, dy)));
        }
      }
      return points;
    }

    List<Offset> settlePositions(List<Offset> initial) {
      final ideals = List<Offset>.of(initial);
      var positions = List<Offset>.of(initial);
      final minDistance = math.max(nodeWidth, nodeHeight) + spec.nodeGap;
      final backPoint = backTarget ?? Offset.zero;

      for (var iteration = 0; iteration < 96; iteration++) {
        var moved = false;
        final deltas = List<Offset>.filled(total, Offset.zero);

        for (var i = 0; i < total; i++) {
          deltas[i] += (ideals[i] - positions[i]) * 0.12;

          if (hasParent) {
            final fromBack = positions[i] - backPoint;
            final distance = math.max(fromBack.distance, 0.01);
            final safeDistance = minDistance * 1.15;
            if (distance < safeDistance) {
              deltas[i] +=
                  Offset(fromBack.dx / distance, fromBack.dy / distance) *
                      ((safeDistance - distance) * 0.14);
            }
          }

          for (var j = i + 1; j < total; j++) {
            final vector = positions[i] - positions[j];
            final distance = math.max(vector.distance, 0.01);
            if (distance >= minDistance) {
              continue;
            }
            final push = Offset(vector.dx / distance, vector.dy / distance) *
                ((minDistance - distance) * 0.28);
            deltas[i] += push;
            deltas[j] -= push;
          }
        }

        positions = [
          for (var i = 0; i < total; i++)
            (() {
              final next = clampToViewport(positions[i] + deltas[i]);
              if ((next - positions[i]).distance > 0.08) {
                moved = true;
              }
              return next;
            })(),
        ];

        if (!moved || fits(positions)) {
          break;
        }
      }

      return positions;
    }

    var points = buildPositions(baseRadius);
    points = settlePositions(points);
    while (baseRadius > spec.minFallbackRadius && !fits(points)) {
      baseRadius -= spec.radiusStep;
      points = buildPositions(baseRadius);
      points = settlePositions(points);
    }

    if (!fits(points)) {
      points = settlePositions(buildPositions(spec.minFallbackRadius));
    }

    return points;
  }

  double _goldenArcProgress(double t) {
    if (t <= 0) {
      return 0;
    }
    if (t >= 1) {
      return 1;
    }
    final mirrored = t <= 0.5 ? t * 2 : (1 - t) * 2;
    final grown =
        (math.pow(_goldenRatio, mirrored).toDouble() - 1) / (_goldenRatio - 1);
    final eased = grown.clamp(0.0, 1.0).toDouble() / 2;
    return t <= 0.5 ? eased : 1 - eased;
  }
}

class _TreeBranchPainter extends CustomPainter {
  _TreeBranchPainter({
    required this.center,
    required this.targets,
    required this.backTarget,
    required this.progress,
    required this.hasParent,
  });

  static const double _goldenRatio = 1.618033988749895;

  final Offset center;
  final List<Offset> targets;
  final Offset? backTarget;
  final double progress;
  final bool hasParent;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFBFE8C7).withValues(alpha: 0.58 * progress);

    for (var i = 0; i < targets.length; i++) {
      final target = Offset.lerp(center, targets[i], progress) ?? targets[i];
      canvas.drawPath(_goldenBranchPath(center, target, i), paint);
    }

    if (hasParent && backTarget != null) {
      final back = Offset.lerp(center, backTarget!, progress) ?? backTarget!;
      canvas.drawPath(
        _goldenBranchPath(center, back, targets.length),
        paint
          ..color = const Color(0xFFE4EFE8).withValues(alpha: 0.35 * progress),
      );
    }
  }

  Path _goldenBranchPath(Offset from, Offset to, int index) {
    final vector = to - from;
    final distance = vector.distance;
    final path = Path()..moveTo(from.dx, from.dy);
    if (distance < 0.1) {
      return path..lineTo(to.dx, to.dy);
    }

    final baseAngle = math.atan2(vector.dy, vector.dx);
    final turnSign =
        baseAngle.abs() < 0.08 ? (index.isEven ? -1.0 : 1.0) : baseAngle.sign;
    final turn = turnSign *
        (math.pi / (5.5 * _goldenRatio)) *
        (distance / 180).clamp(0.55, 1.0).toDouble();

    for (var step = 1; step <= 18; step++) {
      final t = step / 18;
      final radius = distance *
          ((math.pow(_goldenRatio, t).toDouble() - 1) / (_goldenRatio - 1));
      final angle = baseAngle + math.sin(math.pi * t) * turn;
      path.lineTo(
        from.dx + math.cos(angle) * radius,
        from.dy + math.sin(angle) * radius,
      );
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _TreeBranchPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.targets != targets ||
        oldDelegate.backTarget != backTarget ||
        oldDelegate.center != center ||
        oldDelegate.hasParent != hasParent;
  }
}

class _ExploreOrbButton extends StatelessWidget {
  const _ExploreOrbButton({
    required this.isOpen,
    required this.onTap,
    required this.label,
  });

  final bool isOpen;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final spec = _MenuLayoutSpec.from(size);
    final shortest = size.shortestSide;
    final openSize = (shortest * 0.22).clamp(76.0, 86.0).toDouble();
    final closedSize = (shortest * 0.24).clamp(80.0, 92.0).toDouble();
    final openFont = (shortest * 0.026).clamp(9.0, 10.5).toDouble();
    final closedFont = (shortest * 0.038).clamp(12.0, 14.0).toDouble();
    final openAlignment =
        spec.useCompactMenu ? const Alignment(0, 0.92) : Alignment.center;
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
          alignment: isOpen ? openAlignment : const Alignment(0, 0.92),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeInOutCubic,
              width: isOpen ? openSize : closedSize,
              height: isOpen ? openSize : closedSize,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D57),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(
                      0xFF1F5D3E,
                    ).withValues(alpha: isOpen ? 0.45 : 0.60),
                    blurRadius: isOpen ? 22 : 34,
                    spreadRadius: isOpen ? 1 : 3,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOpen ? Icons.close_rounded : Icons.explore_rounded,
                    color: Colors.white,
                    size: isOpen ? 24 : 32,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOpen ? label : "Esplora",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isOpen ? openFont : closedFont,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadialNode extends StatelessWidget {
  const _RadialNode({
    required this.center,
    required this.radius,
    required this.width,
    required this.height,
    required this.nodeId,
    required this.label,
    required this.icon,
    required this.selected,
    required this.highlighted,
    required this.progress,
    required this.onTap,
    this.fixedAngle,
    this.fixedOffset,
  });

  final Offset center;
  final double radius;
  final double width;
  final double height;
  final String nodeId;
  final String label;
  final IconData icon;
  final bool selected;
  final bool highlighted;
  final double progress;
  final VoidCallback onTap;
  final double? fixedAngle;
  final Offset? fixedOffset;

  @override
  Widget build(BuildContext context) {
    final iconSize = (width * 0.18).clamp(18.0, 22.0).toDouble();
    final textSize = (width * 0.095).clamp(10.0, 11.5).toDouble();
    final targetDx =
        fixedOffset?.dx ?? (center.dx + math.cos(fixedAngle ?? 0) * radius);
    final targetDy =
        fixedOffset?.dy ?? (center.dy + math.sin(fixedAngle ?? 0) * radius);
    final dx = targetDx;
    final dy = targetDy;
    return Positioned(
      left: dx - (width / 2),
      top: dy - (height / 2),
      child: GestureDetector(
        key: ValueKey("menu-node-$nodeId"),
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 280),
          scale: 0.98 + (progress * 0.02),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF2E7D57)
                  : highlighted
                      ? const Color(0xFFFFF1C7)
                      : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: highlighted
                    ? const Color(0xFFFFD46A)
                    : Colors.white.withValues(alpha: 0.7),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 14,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact =
                        constraints.maxHeight < 66 || constraints.maxWidth < 86;
                    final adaptiveIconSize =
                        compact ? (iconSize - 3).clamp(14.0, 18.0) : iconSize;
                    final adaptiveTextSize =
                        compact ? (textSize - 1.4).clamp(8.8, 10.6) : textSize;
                    final maxTextLines = compact ? 2 : 3;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: adaptiveIconSize,
                          color: selected
                              ? Colors.white
                              : highlighted
                                  ? const Color(0xFF9A5A00)
                                  : const Color(0xFF1B2E21),
                        ),
                        SizedBox(height: compact ? 2 : 5),
                        Expanded(
                          child: Center(
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              maxLines: maxTextLines,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                height: 1.08,
                                fontWeight: FontWeight.w700,
                                fontSize: adaptiveTextSize,
                                color: selected
                                    ? Colors.white
                                    : highlighted
                                        ? const Color(0xFF5F3C00)
                                        : const Color(0xFF1B2E21),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        title: const Text("Impostazioni"),
        backgroundColor: const Color(0xFFF4F7F1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _SettingsIdentityHeader(user: user),
          const SizedBox(height: 16),
          _SettingsSectionCard(
            title: "Profilo",
            subtitle: "Dati utente, tipo account e contatti principali.",
            icon: Icons.account_circle_rounded,
            onTap: () => _openDetail(context, _SettingsPageKind.profile),
          ),
          _SettingsSectionCard(
            title: "Preferenze",
            subtitle: "Lingua, notifiche, tema e contenuti prioritari.",
            icon: Icons.tune_rounded,
            onTap: () => _openDetail(context, _SettingsPageKind.preferences),
          ),
          _SettingsSectionCard(
            title: "Permessi app",
            subtitle: "Consensi per posizione, notifiche, dati e privacy.",
            icon: Icons.privacy_tip_rounded,
            onTap: () => _openDetail(context, _SettingsPageKind.permissions),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, _SettingsPageKind kind) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _SettingsDetailScreen(user: user, kind: kind),
      ),
    );
  }
}

enum _SettingsPageKind { profile, preferences, permissions }

class _SettingsIdentityHeader extends StatelessWidget {
  const _SettingsIdentityHeader({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D57),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Colors.white,
            child: Text(
              user.name.characters.first.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF2E7D57),
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "${user.profileLabel} · ${user.email}",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE4EFE8),
          child: Icon(icon, color: const Color(0xFF2E7D57)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _SettingsDetailScreen extends StatefulWidget {
  const _SettingsDetailScreen({required this.user, required this.kind});

  final AppUser user;
  final _SettingsPageKind kind;

  @override
  State<_SettingsDetailScreen> createState() => _SettingsDetailScreenState();
}

class _SettingsDetailScreenState extends State<_SettingsDetailScreen> {
  late bool _notificationsEnabled;
  late bool _locationEnabled;
  late bool _analyticsEnabled;
  late bool _marketingEnabled;
  late String _language;
  bool _darkMode = false;
  bool _priorityEvents = true;

  @override
  void initState() {
    super.initState();
    final settings = widget.user.settings;
    _notificationsEnabled = settings.notificationsEnabled;
    _locationEnabled = settings.locationEnabled;
    _analyticsEnabled = settings.analyticsEnabled;
    _marketingEnabled = settings.marketingEnabled;
    _language = settings.language;
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (widget.kind) {
      _SettingsPageKind.profile => "Profilo",
      _SettingsPageKind.preferences => "Preferenze",
      _SettingsPageKind.permissions => "Permessi app",
    };
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFF4F7F1),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (widget.kind == _SettingsPageKind.profile) ..._profileRows(),
          if (widget.kind == _SettingsPageKind.preferences)
            ..._preferenceRows(),
          if (widget.kind == _SettingsPageKind.permissions)
            ..._permissionRows(),
        ],
      ),
    );
  }

  List<Widget> _profileRows() {
    return [
      _ReadonlySettingsTile(
        icon: Icons.badge_rounded,
        title: "Nome visualizzato",
        value: widget.user.name,
      ),
      _ReadonlySettingsTile(
        icon: Icons.alternate_email_rounded,
        title: "Email mock",
        value: widget.user.email,
      ),
      _ReadonlySettingsTile(
        icon: Icons.verified_user_rounded,
        title: "Tipo profilo",
        value: widget.user.profileLabel,
      ),
      const _ReadonlySettingsTile(
        icon: Icons.key_rounded,
        title: "Metodo accesso",
        value: "Login dimostrativa locale",
      ),
      Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: ListTile(
          leading: const Icon(
            Icons.switch_account_rounded,
            color: Color(0xFF2E7D57),
          ),
          title: const Text("Cambia ruolo"),
          subtitle: const Text("Torna alla schermata di scelta profilo."),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
            (_) => false,
          ),
        ),
      ),
    ];
  }

  List<Widget> _preferenceRows() {
    return [
      _DropdownSettingsTile(
        icon: Icons.language_rounded,
        title: "Lingua",
        value: _language,
        values: const ["Italiano", "English", "Deutsch"],
        onChanged: (value) => setState(() => _language = value),
      ),
      SwitchListTile(
        value: _notificationsEnabled,
        onChanged: (value) => setState(() => _notificationsEnabled = value),
        title: const Text("Notifiche importanti"),
        subtitle: const Text("Avvisi comunali, eventi e aggiornamenti utili."),
        secondary: const Icon(Icons.notifications_active_rounded),
      ),
      SwitchListTile(
        value: _priorityEvents,
        onChanged: (value) => setState(() => _priorityEvents = value),
        title: const Text("Mostra eventi in evidenza"),
        subtitle: const Text("Dai priorita a eventi e suggerimenti locali."),
        secondary: const Icon(Icons.star_rounded),
      ),
      SwitchListTile(
        value: _darkMode,
        onChanged: (value) => setState(() => _darkMode = value),
        title: const Text("Tema scuro"),
        subtitle: const Text("Preferenza fittizia per il tema applicazione."),
        secondary: const Icon(Icons.dark_mode_rounded),
      ),
    ].map(_settingsSurface).toList();
  }

  List<Widget> _permissionRows() {
    return [
      SwitchListTile(
        value: _locationEnabled,
        onChanged: (value) => setState(() => _locationEnabled = value),
        title: const Text("Posizione"),
        subtitle: const Text("Usata per luoghi vicini, percorsi e servizi."),
        secondary: const Icon(Icons.location_on_rounded),
      ),
      SwitchListTile(
        value: _analyticsEnabled,
        onChanged: (value) => setState(() => _analyticsEnabled = value),
        title: const Text("Statistiche anonime"),
        subtitle: const Text("Aiuta a migliorare il mockup senza dati reali."),
        secondary: const Icon(Icons.analytics_rounded),
      ),
      SwitchListTile(
        value: _marketingEnabled,
        onChanged: (value) => setState(() => _marketingEnabled = value),
        title: const Text("Comunicazioni promozionali"),
        subtitle: const Text("Eventi turistici, iniziative e campagne locali."),
        secondary: const Icon(Icons.campaign_rounded),
      ),
      const _ReadonlySettingsTile(
        icon: Icons.shield_rounded,
        title: "Stato privacy",
        value: "Consensi gestiti solo nel mockup",
      ),
    ].map(_settingsSurface).toList();
  }

  Widget _settingsSurface(Widget child) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: child,
    );
  }
}

class _ReadonlySettingsTile extends StatelessWidget {
  const _ReadonlySettingsTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E7D57)),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key, required this.controller});

  final GamificationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final nextTier = controller.nextTier;
        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F1),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF4F7F1),
            title: const Text("Premi APPecchio"),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF203B2C),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Wallet token",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${controller.balance}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      nextTier == null
                          ? "Hai sbloccato tutte le soglie disponibili nel mockup."
                          : "Mancano ${controller.missingPoints} token per ${nextTier.label}.",
                      style: const TextStyle(
                        color: Color(0xFFDCE9DD),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: controller.progressToNextTier,
                        minHeight: 10,
                        backgroundColor: Colors.white24,
                        color: const Color(0xFFFFD166),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _TrailDetailCard(
                title: "Livelli",
                child: Column(
                  children: [
                    for (final level in GamificationController.levels)
                      _RewardLevelRow(
                        level: level,
                        unlocked: controller.balance >= level.minPoints,
                        current: level == controller.currentLevel,
                      ),
                  ],
                ),
              ),
              _TrailDetailCard(
                title: "Medaglie",
                child: Column(
                  children: [
                    for (final medal in GamificationController.medals)
                      _RewardMedalRow(
                        medal: medal,
                        unlocked: controller.balance >= medal.threshold,
                      ),
                  ],
                ),
              ),
              _TrailDetailCard(
                title: "Soglie ricompensa",
                child: Column(
                  children: [
                    for (final tier in controller.rewardTiers)
                      _RewardTierRow(
                        tier: tier,
                        unlocked: controller.balance >= tier.threshold,
                      ),
                  ],
                ),
              ),
              _TrailDetailCard(
                title: "Voucher",
                child: controller.vouchers.isEmpty
                    ? const Text("Nessun voucher ancora sbloccato.")
                    : Column(
                        children: [
                          for (final voucher in controller.vouchers)
                            _VoucherTile(voucher: voucher),
                        ],
                      ),
              ),
              _TrailDetailCard(
                title: "Movimenti",
                child: controller.ledger.isEmpty
                    ? const Text("Nessun movimento registrato.")
                    : Column(
                        children: [
                          for (final entry in controller.ledger)
                            _LedgerTile(entry: entry),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RewardTierRow extends StatelessWidget {
  const _RewardTierRow({required this.tier, required this.unlocked});

  final RewardTier tier;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor:
            unlocked ? const Color(0xFFDCF1E5) : const Color(0xFFE8ECE4),
        child: Icon(
          unlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
          color: unlocked ? const Color(0xFF2E7D57) : const Color(0xFF7A847B),
        ),
      ),
      title: Text(
        tier.label,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text("${tier.threshold} token"),
      trailing: Text(
        "${tier.discountPercentage}%",
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _RewardLevelRow extends StatelessWidget {
  const _RewardLevelRow({
    required this.level,
    required this.unlocked,
    required this.current,
  });

  final RewardLevel level;
  final bool unlocked;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor:
            unlocked ? const Color(0xFFDCF1E5) : const Color(0xFFE8ECE4),
        child: Icon(
          level.icon,
          color: unlocked ? const Color(0xFF2E7D57) : const Color(0xFF7A847B),
        ),
      ),
      title: Text(
        level.name,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text("Da ${level.minPoints} token"),
      trailing: current
          ? const Text(
              "attuale",
              style: TextStyle(
                color: Color(0xFF2E7D57),
                fontWeight: FontWeight.w900,
              ),
            )
          : Icon(
              unlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
              color:
                  unlocked ? const Color(0xFF2E7D57) : const Color(0xFF7A847B),
            ),
    );
  }
}

class _RewardMedalRow extends StatelessWidget {
  const _RewardMedalRow({required this.medal, required this.unlocked});

  final RewardMedal medal;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor:
            unlocked ? const Color(0xFFFFE8A8) : const Color(0xFFE8ECE4),
        child: Icon(
          medal.icon,
          color: unlocked ? const Color(0xFF8A6400) : const Color(0xFF7A847B),
        ),
      ),
      title: Text(
        medal.label,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text("${medal.threshold} token"),
      trailing: Icon(
        unlocked ? Icons.verified_rounded : Icons.radio_button_unchecked,
        color: unlocked ? const Color(0xFF2E7D57) : const Color(0xFF7A847B),
      ),
    );
  }
}

class _VoucherTile extends StatelessWidget {
  const _VoucherTile({required this.voucher});

  final RewardVoucher voucher;

  @override
  Widget build(BuildContext context) {
    final active = voucher.isActive;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor:
            active ? const Color(0xFFFFE8A8) : const Color(0xFFE8ECE4),
        child: Icon(
          active
              ? Icons.confirmation_number_rounded
              : Icons.check_circle_rounded,
          color: active ? const Color(0xFF8A6400) : const Color(0xFF526055),
        ),
      ),
      title: Text(
        "${voucher.label} · ${voucher.code}",
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      subtitle: Text(
        active
            ? "Attivo nei locali aderenti"
            : "Usato da ${voucher.merchantName ?? "locale aderente"}",
      ),
      trailing: Text(
        voucher.status,
        style: TextStyle(
          color: active ? const Color(0xFF2E7D57) : const Color(0xFF526055),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LedgerTile extends StatelessWidget {
  const _LedgerTile({required this.entry});

  final RewardLedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final positive = entry.points > 0;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        positive ? Icons.add_circle_rounded : Icons.receipt_long_rounded,
        color: positive ? const Color(0xFF2E7D57) : const Color(0xFF526055),
      ),
      title: Text(
        entry.label,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(entry.status),
      trailing: Text(
        entry.points == 0 ? "0" : "+${entry.points}",
        style: TextStyle(
          color: positive ? const Color(0xFF2E7D57) : const Color(0xFF526055),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DropdownSettingsTile extends StatelessWidget {
  const _DropdownSettingsTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E7D57)),
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        items: [
          for (final item in values)
            DropdownMenuItem<String>(value: item, child: Text(item)),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}

class TrailRoute {
  const TrailRoute({
    required this.id,
    required this.name,
    required this.caiNumber,
    required this.newNumber,
    required this.start,
    required this.end,
    required this.lengthKm,
    required this.elevationGainM,
    required this.elevationLossM,
    required this.startAltitudeM,
    required this.endAltitudeM,
    required this.maxAltitudeM,
    required this.timeLabel,
    required this.difficulty,
    required this.summary,
    required this.safetyNote,
    required this.highlights,
    required this.sourceLabel,
    required this.sourceUrl,
    required this.gpxUrl,
    required this.geoPoints,
    required this.color,
    required this.tags,
  });

  final String id;
  final String name;
  final String caiNumber;
  final String newNumber;
  final String start;
  final String end;
  final double lengthKm;
  final int elevationGainM;
  final int elevationLossM;
  final int startAltitudeM;
  final int endAltitudeM;
  final int maxAltitudeM;
  final String timeLabel;
  final String difficulty;
  final String summary;
  final String safetyNote;
  final List<String> highlights;
  final String sourceLabel;
  final String sourceUrl;
  final String gpxUrl;
  final List<LatLng> geoPoints;
  final Color color;
  final Set<String> tags;

  String get distanceLabel =>
      "${lengthKm.toStringAsFixed(1).replaceAll(".", ",")} km";
  String get elevationLabel => "+$elevationGainM m";
  bool get hasGpx => gpxUrl.isNotEmpty;
}

const List<LatLng> _apecchioBoundary = [
  LatLng(43.544200, 12.312759),
  LatLng(43.539687, 12.318197),
  LatLng(43.532742, 12.324767),
  LatLng(43.525839, 12.330716),
  LatLng(43.522623, 12.338894),
  LatLng(43.521804, 12.348587),
  LatLng(43.528154, 12.356083),
  LatLng(43.534103, 12.366728),
  LatLng(43.527322, 12.376457),
  LatLng(43.521541, 12.387044),
  LatLng(43.513980, 12.384799),
  LatLng(43.509133, 12.396100),
  LatLng(43.517571, 12.402468),
  LatLng(43.527149, 12.409268),
  LatLng(43.533944, 12.416780),
  LatLng(43.534393, 12.427439),
  LatLng(43.537604, 12.437909),
  LatLng(43.529330, 12.447338),
  LatLng(43.519549, 12.455338),
  LatLng(43.518583, 12.464040),
  LatLng(43.516751, 12.474991),
  LatLng(43.525750, 12.477958),
  LatLng(43.524337, 12.489895),
  LatLng(43.521296, 12.499066),
  LatLng(43.522012, 12.507575),
  LatLng(43.527602, 12.517145),
  LatLng(43.529461, 12.521807),
  LatLng(43.537599, 12.514382),
  LatLng(43.546257, 12.513766),
  LatLng(43.551497, 12.520347),
  LatLng(43.557779, 12.518005),
  LatLng(43.556138, 12.507306),
  LatLng(43.562858, 12.499711),
  LatLng(43.567056, 12.489804),
  LatLng(43.573963, 12.491661),
  LatLng(43.580661, 12.490343),
  LatLng(43.584058, 12.486709),
  LatLng(43.578454, 12.482134),
  LatLng(43.578292, 12.477980),
  LatLng(43.579364, 12.470282),
  LatLng(43.577769, 12.462163),
  LatLng(43.580112, 12.456888),
  LatLng(43.584930, 12.451498),
  LatLng(43.590376, 12.443916),
  LatLng(43.599655, 12.447902),
  LatLng(43.610001, 12.449953),
  LatLng(43.615190, 12.445823),
  LatLng(43.609127, 12.439690),
  LatLng(43.605878, 12.430810),
  LatLng(43.598420, 12.434529),
  LatLng(43.591364, 12.431213),
  LatLng(43.596611, 12.420664),
  LatLng(43.600313, 12.411286),
  LatLng(43.601093, 12.405555),
  LatLng(43.607161, 12.399824),
  LatLng(43.614796, 12.394365),
  LatLng(43.612558, 12.386197),
  LatLng(43.612054, 12.373118),
  LatLng(43.606131, 12.365934),
  LatLng(43.598810, 12.361997),
  LatLng(43.593425, 12.364876),
  LatLng(43.588000, 12.367918),
  LatLng(43.581800, 12.371592),
  LatLng(43.574309, 12.361500),
  LatLng(43.564095, 12.354270),
  LatLng(43.555258, 12.345956),
  LatLng(43.553968, 12.334050),
  LatLng(43.552184, 12.323602),
  LatLng(43.546950, 12.314041),
  LatLng(43.544200, 12.312759),
];

const List<TrailRoute> _trailRoutes = [
  TrailRoute(
    id: "sentiero_39",
    name: "Apecchio - Bivio Sentiero Italia",
    caiNumber: "39",
    newNumber: "239",
    start: "Apecchio",
    end: "Bivio Sentiero Italia",
    lengthKm: 8.2,
    elevationGainM: 280,
    elevationLossM: 40,
    startAltitudeM: 493,
    endAltitudeM: 755,
    maxAltitudeM: 780,
    timeLabel: "3:15 - 4:00",
    difficulty: "E",
    summary:
        "Il percorso sale dal paese verso il sistema della Gorgaccia e del Fosso dei Tacconi, creando un collegamento naturale tra centro abitato e dorsale del Nerone.",
    safetyNote:
        "Verificare sempre fondo e segnaletica dopo piogge intense: alcuni tratti di fosso possono cambiare rapidamente.",
    highlights: [
      "Apecchio",
      "Gorgaccia",
      "Fosso dei Tacconi",
      "Sentiero Italia",
    ],
    sourceLabel: "Pesaro Trekking - Sentiero 39 Monte Nerone",
    sourceUrl: "https://www.pesarotrekking.it/monte-nerone/sentiero-39.html",
    gpxUrl: "https://www.pesarotrekking.it/images/tracce/Sentiero39.gpx",
    geoPoints: [
      LatLng(43.556816, 12.417131),
      LatLng(43.553386, 12.406115),
      LatLng(43.547758, 12.403106),
      LatLng(43.541278, 12.406712),
      LatLng(43.535027, 12.404131),
      LatLng(43.529801, 12.398012),
      LatLng(43.524223, 12.390209),
      LatLng(43.515078, 12.369435),
    ],
    color: Color(0xFF1D8A6A),
    tags: {"apecchio", "e", "panoramici"},
  ),
  TrailRoute(
    id: "sentiero_20",
    name: "Pianello - Pieia",
    caiNumber: "20",
    newNumber: "220",
    start: "Pianello",
    end: "Pieia",
    lengthKm: 5.3,
    elevationGainM: 350,
    elevationLossM: 85,
    startAltitudeM: 385,
    endAltitudeM: 650,
    maxAltitudeM: 705,
    timeLabel: "2:00 - 2:30",
    difficulty: "E",
    summary:
        "Dalla valle di Pianello il tracciato risale verso Pieia e apre la lettura del paesaggio su Fondarca e sulle connessioni del Sentiero Italia.",
    safetyNote:
        "Percorso escursionistico: portare acqua e scarpe adatte, soprattutto nei mesi caldi.",
    highlights: ["Pianello", "Pieia", "Fondarca", "Sentiero Italia"],
    sourceLabel: "Pesaro Trekking - Sentiero 20 Monte Nerone",
    sourceUrl: "https://www.pesarotrekking.it/monte-nerone/sentiero-20.html",
    gpxUrl: "https://www.pesarotrekking.it/images/tracce/Sentiero20.gpx",
    geoPoints: [
      LatLng(43.515252, 12.555896),
      LatLng(43.519101, 12.554781),
      LatLng(43.522628, 12.555207),
      LatLng(43.525851, 12.553039),
      LatLng(43.529206, 12.547878),
      LatLng(43.534691, 12.548692),
      LatLng(43.537877, 12.541163),
      LatLng(43.535546, 12.534354),
    ],
    color: Color(0xFFD6802B),
    tags: {"e", "famiglie", "nerone", "panoramici"},
  ),
  TrailRoute(
    id: "sentiero_13",
    name: "San Lorenzo - Valcellone",
    caiNumber: "13",
    newNumber: "213",
    start: "San Lorenzo",
    end: "Valcellone",
    lengthKm: 2.1,
    elevationGainM: 330,
    elevationLossM: 20,
    startAltitudeM: 560,
    endAltitudeM: 870,
    maxAltitudeM: 890,
    timeLabel: "1:15 - 1:45",
    difficulty: "E",
    summary:
        "Un collegamento breve ma intenso tra San Lorenzo e Valcellone, utile per leggere da vicino il paesaggio della Forra del Presale.",
    safetyNote:
        "Tratto ripido: evitare in caso di terreno bagnato e controllare gli aggiornamenti locali prima di partire.",
    highlights: ["San Lorenzo", "Forra del Presale", "Valcellone"],
    sourceLabel: "Pesaro Trekking - Sentiero 13 Monte Nerone",
    sourceUrl: "https://www.pesarotrekking.it/monte-nerone/sentiero-13.html",
    gpxUrl: "https://www.pesarotrekking.it/images/tracce/Sentiero13.gpx",
    geoPoints: [
      LatLng(43.577647, 12.538453),
      LatLng(43.575280, 12.540569),
      LatLng(43.572910, 12.540327),
      LatLng(43.571429, 12.538035),
      LatLng(43.569502, 12.538635),
      LatLng(43.567690, 12.537159),
      LatLng(43.567517, 12.538937),
      LatLng(43.565961, 12.540487),
    ],
    color: Color(0xFF6B5BA8),
    tags: {"e", "nerone"},
  ),
  TrailRoute(
    id: "sentiero_1",
    name: "Piobbico - Monte Nerone",
    caiNumber: "1",
    newNumber: "201",
    start: "Piobbico",
    end: "Monte Nerone",
    lengthKm: 9.8,
    elevationGainM: 980,
    elevationLossM: 120,
    startAltitudeM: 339,
    endAltitudeM: 1525,
    maxAltitudeM: 1525,
    timeLabel: "4:00 - 5:00",
    difficulty: "EE",
    summary:
        "La salita piu impegnativa del comprensorio porta fino alla vetta del Nerone, pensata per escursionisti esperti e giornate stabili.",
    safetyNote:
        "Itinerario per esperti: meteo, orientamento e dotazione sono parte dell'esperienza, non dettagli opzionali.",
    highlights: ["Piobbico", "Balza Forata", "Vetta Monte Nerone"],
    sourceLabel: "Pesaro Trekking - Sentiero 1 Monte Nerone",
    sourceUrl: "https://www.pesarotrekking.it/monte-nerone/sentiero-1.html",
    gpxUrl: "https://www.pesarotrekking.it/images/tracce/Sentiero1.gpx",
    geoPoints: [
      LatLng(43.584948, 12.516473),
      LatLng(43.579493, 12.516894),
      LatLng(43.574388, 12.512858),
      LatLng(43.572437, 12.514571),
      LatLng(43.569556, 12.516685),
      LatLng(43.563579, 12.514894),
      LatLng(43.560736, 12.513891),
      LatLng(43.557734, 12.517663),
    ],
    color: Color(0xFFC83E4D),
    tags: {"apecchio", "ee", "nerone", "panoramici"},
  ),
  TrailRoute(
    id: "sentiero_30",
    name: "Le Porte - Colluccio",
    caiNumber: "30",
    newNumber: "230",
    start: "Le Porte",
    end: "Colluccio",
    lengthKm: 5.3,
    elevationGainM: 727,
    elevationLossM: 339,
    startAltitudeM: 362,
    endAltitudeM: 749,
    maxAltitudeM: 788,
    timeLabel: "2:45 - 3:30",
    difficulty: "E",
    summary:
        "Tracciato sul versante di Apecchio che collega l'area de Le Porte con Colluccio, utile per leggere la valle e i raccordi verso il Nerone.",
    safetyNote:
        "Percorso con dislivello sensibile: pianificare il rientro e verificare fondo e segnaletica.",
    highlights: ["Le Porte", "Colluccio", "Apecchio", "Monte Nerone"],
    sourceLabel: "Pesaro Trekking - Sentiero 30 Monte Nerone",
    sourceUrl: "https://www.pesarotrekking.it/monte-nerone/sentiero-30.html",
    gpxUrl: "https://www.pesarotrekking.it/images/tracce/Sentiero30.gpx",
    geoPoints: [
      LatLng(43.582891, 12.491079),
      LatLng(43.578574, 12.489989),
      LatLng(43.573009, 12.494194),
      LatLng(43.567667, 12.493610),
      LatLng(43.564575, 12.496820),
      LatLng(43.560539, 12.489830),
      LatLng(43.555166, 12.487645),
      LatLng(43.550504, 12.486048),
    ],
    color: Color(0xFF3B8EA5),
    tags: {"apecchio", "e", "nerone", "panoramici"},
  ),
  TrailRoute(
    id: "sentiero_25",
    name: "Serravalle di Carda - Pieia",
    caiNumber: "25",
    newNumber: "225",
    start: "Serravalle di Carda",
    end: "Pieia",
    lengthKm: 4.2,
    elevationGainM: 396,
    elevationLossM: 323,
    startAltitudeM: 687,
    endAltitudeM: 760,
    maxAltitudeM: 849,
    timeLabel: "2:00 - 2:40",
    difficulty: "E",
    summary:
        "Connessione tra Serravalle di Carda e Pieia, al margine del territorio comunale e della rete naturalistica del Nerone.",
    safetyNote:
        "Sentiero di collegamento: controllare i raccordi con gli itinerari limitrofi prima della partenza.",
    highlights: ["Serravalle di Carda", "Pieia", "Monte Nerone"],
    sourceLabel: "Pesaro Trekking - Sentiero 25 Monte Nerone",
    sourceUrl: "https://www.pesarotrekking.it/monte-nerone/sentiero-25.html",
    gpxUrl: "https://www.pesarotrekking.it/images/tracce/Sentiero25.gpx",
    geoPoints: [
      LatLng(43.535539, 12.534359),
      LatLng(43.531633, 12.529705),
      LatLng(43.534718, 12.527794),
      LatLng(43.535228, 12.524404),
      LatLng(43.534699, 12.518810),
      LatLng(43.535053, 12.512774),
      LatLng(43.537467, 12.507423),
      LatLng(43.539848, 12.501404),
    ],
    color: Color(0xFF9B5DE5),
    tags: {"e", "nerone"},
  ),
  TrailRoute(
    id: "sentiero_8",
    name: "Fosso dell'Eremo",
    caiNumber: "8",
    newNumber: "208",
    start: "Fosso dell'Eremo",
    end: "Bacciardi",
    lengthKm: 3.3,
    elevationGainM: 391,
    elevationLossM: 185,
    startAltitudeM: 320,
    endAltitudeM: 526,
    maxAltitudeM: 526,
    timeLabel: "1:45 - 2:20",
    difficulty: "E",
    summary:
        "Percorso breve e ripido nel sistema del Fosso dell'Eremo, utile come collegamento di versante nel comprensorio del Nerone.",
    safetyNote:
        "Prestare attenzione nei tratti umidi e nei passaggi incassati del fosso.",
    highlights: ["Fosso dell'Eremo", "Bacciardi", "Monte Nerone"],
    sourceLabel: "Pesaro Trekking - Sentiero 8 Monte Nerone",
    sourceUrl: "https://www.pesarotrekking.it/monte-nerone/sentiero-8.html",
    gpxUrl: "https://www.pesarotrekking.it/images/tracce/Sentiero8.gpx",
    geoPoints: [
      LatLng(43.588065, 12.531353),
      LatLng(43.587553, 12.534811),
      LatLng(43.584206, 12.536684),
      LatLng(43.582350, 12.541280),
      LatLng(43.579948, 12.546201),
      LatLng(43.577565, 12.548650),
      LatLng(43.574999, 12.547485),
      LatLng(43.572444, 12.549249),
    ],
    color: Color(0xFF0077B6),
    tags: {"e", "nerone"},
  ),
  TrailRoute(
    id: "sentiero_12",
    name: "Bacciardi - La Montagnola",
    caiNumber: "12",
    newNumber: "212",
    start: "Bacciardi",
    end: "La Montagnola",
    lengthKm: 4.1,
    elevationGainM: 938,
    elevationLossM: 105,
    startAltitudeM: 526,
    endAltitudeM: 1358,
    maxAltitudeM: 1395,
    timeLabel: "3:15 - 4:00",
    difficulty: "EE",
    summary:
        "Salita decisa verso le quote alte del Nerone, pensata per chi cerca un percorso fisico e panoramico.",
    safetyNote:
        "Percorso impegnativo: partire con meteo stabile e dotazione da escursionismo.",
    highlights: ["Bacciardi", "La Montagnola", "Monte Nerone"],
    sourceLabel: "Pesaro Trekking - Sentiero 12 Monte Nerone",
    sourceUrl: "https://www.pesarotrekking.it/monte-nerone/sentiero-12.html",
    gpxUrl: "https://www.pesarotrekking.it/images/tracce/Sentiero12.gpx",
    geoPoints: [
      LatLng(43.572444, 12.549249),
      LatLng(43.568866, 12.550264),
      LatLng(43.568559, 12.546937),
      LatLng(43.566159, 12.545581),
      LatLng(43.563497, 12.542957),
      LatLng(43.558792, 12.540300),
      LatLng(43.554433, 12.537074),
      LatLng(43.553954, 12.530912),
    ],
    color: Color(0xFFB5179E),
    tags: {"ee", "nerone", "panoramici"},
  ),
  TrailRoute(
    id: "sentiero_21",
    name: "Pieia - Monte del Pantano",
    caiNumber: "21",
    newNumber: "221",
    start: "Pieia",
    end: "Monte del Pantano",
    lengthKm: 4.0,
    elevationGainM: 894,
    elevationLossM: 193,
    startAltitudeM: 657,
    endAltitudeM: 1358,
    maxAltitudeM: 1480,
    timeLabel: "3:00 - 3:45",
    difficulty: "EE",
    summary:
        "Da Pieia il sentiero sale verso il Monte del Pantano e le quote piu alte del comprensorio.",
    safetyNote:
        "Dislivello importante: evitare con nebbia, vento forte o temporali in quota.",
    highlights: ["Pieia", "Monte del Pantano", "Monte Nerone"],
    sourceLabel: "Pesaro Trekking - Sentiero 21 Monte Nerone",
    sourceUrl: "https://www.pesarotrekking.it/monte-nerone/sentiero-21.html",
    gpxUrl: "https://www.pesarotrekking.it/images/tracce/Sentiero21.gpx",
    geoPoints: [
      LatLng(43.535546, 12.534354),
      LatLng(43.540176, 12.536477),
      LatLng(43.541270, 12.542609),
      LatLng(43.545144, 12.540211),
      LatLng(43.546037, 12.535778),
      LatLng(43.549959, 12.538551),
      LatLng(43.552701, 12.536632),
      LatLng(43.553954, 12.530912),
    ],
    color: Color(0xFFE85D04),
    tags: {"ee", "nerone", "panoramici"},
  ),
  TrailRoute(
    id: "sentiero_22",
    name: "Fonte dei Ranchetti - Pian del Sasso",
    caiNumber: "22",
    newNumber: "222",
    start: "Fonte dei Ranchetti",
    end: "Pian del Sasso",
    lengthKm: 1.1,
    elevationGainM: 212,
    elevationLossM: 20,
    startAltitudeM: 1126,
    endAltitudeM: 1318,
    maxAltitudeM: 1318,
    timeLabel: "0:45 - 1:10",
    difficulty: "E",
    summary:
        "Breve raccordo in quota tra Fonte dei Ranchetti e Pian del Sasso, utile per comporre anelli piu lunghi.",
    safetyNote:
        "Anche se breve, resta un tratto di quota: controllare visibilita e vento.",
    highlights: ["Fonte dei Ranchetti", "Pian del Sasso"],
    sourceLabel: "Pesaro Trekking - Sentiero 22 Monte Nerone",
    sourceUrl: "https://www.pesarotrekking.it/monte-nerone/sentiero-22.html",
    gpxUrl: "https://www.pesarotrekking.it/images/tracce/Sentiero22.gpx",
    geoPoints: [
      LatLng(43.547258, 12.531435),
      LatLng(43.547694, 12.531681),
      LatLng(43.549389, 12.531315),
      LatLng(43.548846, 12.532266),
      LatLng(43.547349, 12.533476),
      LatLng(43.545601, 12.532481),
      LatLng(43.545122, 12.533427),
      LatLng(43.545928, 12.535406),
    ],
    color: Color(0xFF588157),
    tags: {"e", "famiglie", "nerone"},
  ),
  TrailRoute(
    id: "sentiero_24",
    name: "Cerreto - Casciaia Mochi",
    caiNumber: "24",
    newNumber: "224",
    start: "Cerreto",
    end: "Casciaia Mochi",
    lengthKm: 2.2,
    elevationGainM: 526,
    elevationLossM: 3,
    startAltitudeM: 672,
    endAltitudeM: 1195,
    maxAltitudeM: 1195,
    timeLabel: "1:45 - 2:20",
    difficulty: "E",
    summary:
        "Salita compatta dal Cerreto verso Casciaia Mochi, con forte lettura del versante orientale del Nerone.",
    safetyNote:
        "Tratto breve ma ripido: gestire bene ritmo, acqua e calzature.",
    highlights: ["Cerreto", "Casciaia Mochi", "Monte Nerone"],
    sourceLabel: "Pesaro Trekking - Sentiero 24 Monte Nerone",
    sourceUrl: "https://www.pesarotrekking.it/monte-nerone/sentiero-24.html",
    gpxUrl: "https://www.pesarotrekking.it/images/tracce/Sentiero24.gpx",
    geoPoints: [
      LatLng(43.529590, 12.547163),
      LatLng(43.530580, 12.549486),
      LatLng(43.532601, 12.551443),
      LatLng(43.534214, 12.553429),
      LatLng(43.536013, 12.553794),
      LatLng(43.538151, 12.553622),
      LatLng(43.540114, 12.553807),
      LatLng(43.546098, 12.554111),
    ],
    color: Color(0xFFBC6C25),
    tags: {"e", "nerone"},
  ),
];

class TrailsScreen extends StatefulWidget {
  const TrailsScreen({super.key});

  @override
  State<TrailsScreen> createState() => _TrailsScreenState();
}

class _TrailsScreenState extends State<TrailsScreen> {
  String _selectedFilter = "tutti";
  TrailRoute _selectedTrail = _trailRoutes.first;
  bool _reliefMode = false;

  static const Map<String, String> _filters = {
    "tutti": "Tutti",
    "e": "E",
    "ee": "EE",
    "apecchio": "Apecchio",
    "facili": "Facili",
    "famiglie": "Famiglie",
    "panoramici": "Panoramici",
  };

  @override
  Widget build(BuildContext context) {
    final trails = _filteredTrails;
    final visibleSelected = trails.any((trail) => trail.id == _selectedTrail.id)
        ? _selectedTrail
        : trails.first;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F6EC),
        title: const Text("Sentieri e percorsi naturalistici"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
        children: [
          _TrailsHero(
            trails: trails,
            selectedTrail: visibleSelected,
            onTrailSelected: _selectTrailOnMap,
            reliefMode: _reliefMode,
          ),
          const SizedBox(height: 16),
          _TrailFilterBar(
            filters: _filters,
            selectedFilter: _selectedFilter,
            onChanged: (value) => setState(() {
              _selectedFilter = value;
              final nextTrails = _filteredTrails;
              if (!nextTrails.any((trail) => trail.id == _selectedTrail.id)) {
                _selectedTrail = nextTrails.first;
              }
            }),
          ),
          const SizedBox(height: 10),
          _TrailMapModeSwitch(
            reliefMode: _reliefMode,
            onChanged: (value) => setState(() => _reliefMode = value),
          ),
          const SizedBox(height: 12),
          _TrailQuickOpenRow(
            trails: _trailRoutes
                .where((trail) => trail.tags.contains("apecchio"))
                .toList(growable: false),
            onTrailSelected: _selectTrailOnMap,
          ),
          const SizedBox(height: 14),
          _TrailSelectedPanel(
            trail: visibleSelected,
            onOpenDetail: () => _openTrailDetail(visibleSelected),
          ),
          const SizedBox(height: 18),
          const Text(
            "Percorsi nel territorio",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (final trail in trails)
            _TrailListCard(
              trail: trail,
              selected: trail.id == visibleSelected.id,
              onTap: () => _selectTrailOnMap(trail),
              onOpenDetail: () => _openTrailDetail(trail),
            ),
        ],
      ),
    );
  }

  List<TrailRoute> get _filteredTrails {
    if (_selectedFilter == "tutti") {
      return _trailRoutes;
    }
    if (_selectedFilter == "facili") {
      return _trailRoutes
          .where((trail) => trail.difficulty == "E" && trail.lengthKm <= 5.5)
          .toList(growable: false);
    }
    return _trailRoutes
        .where((trail) => trail.tags.contains(_selectedFilter))
        .toList(growable: false);
  }

  void _openTrailDetail(TrailRoute trail) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => TrailDetailScreen(trail: trail)),
    );
  }

  void _selectTrailOnMap(TrailRoute trail) {
    setState(() => _selectedTrail = trail);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TrailMapScreen(trail: trail, reliefMode: _reliefMode),
      ),
    );
  }
}

class _TrailsHero extends StatelessWidget {
  const _TrailsHero({
    required this.trails,
    required this.selectedTrail,
    required this.onTrailSelected,
    required this.reliefMode,
  });

  final List<TrailRoute> trails;
  final TrailRoute selectedTrail;
  final ValueChanged<TrailRoute> onTrailSelected;
  final bool reliefMode;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 330,
        child: Stack(
          children: [
            Positioned.fill(
              child: _TrailOnlineMap(
                trails: trails,
                selectedTrail: selectedTrail,
                showOnlySelected: false,
                onTrailSelected: onTrailSelected,
                fitPadding: const EdgeInsets.fromLTRB(34, 52, 34, 100),
                reliefMode: reliefMode,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.28),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: _TrailMapLegend(selectedTrail: selectedTrail),
            ),
            const Positioned(left: 16, top: 16, child: _TrailMapBadge()),
          ],
        ),
      ),
    );
  }
}

class _TrailMapBadge extends StatelessWidget {
  const _TrailMapBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_rounded, color: Color(0xFF2E7D57), size: 18),
          SizedBox(width: 7),
          Text(
            "Mappa reale online",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _TrailMapLegend extends StatelessWidget {
  const _TrailMapLegend({required this.selectedTrail});

  final TrailRoute selectedTrail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: selectedTrail.color,
            child: Text(
              selectedTrail.caiNumber,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedTrail.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  "${selectedTrail.distanceLabel} · ${selectedTrail.elevationLabel} · ${selectedTrail.difficulty}",
                  style: const TextStyle(
                    color: Color(0xFF526055),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrailMapGeometry {
  const TrailMapGeometry({
    required this.trail,
    required this.points,
    required this.loadedFromGpx,
  });

  final TrailRoute trail;
  final List<LatLng> points;
  final bool loadedFromGpx;

  LatLng get midPoint => points[points.length ~/ 2];
}

class TrailGeometryRepository {
  static final Map<String, Future<TrailMapGeometry>> _cache = {};

  static TrailMapGeometry fallback(TrailRoute trail) {
    return TrailMapGeometry(
      trail: trail,
      points: trail.geoPoints,
      loadedFromGpx: false,
    );
  }

  static Future<List<TrailMapGeometry>> loadAll(List<TrailRoute> trails) {
    return Future.wait(trails.map(load));
  }

  static Future<TrailMapGeometry> load(TrailRoute trail) {
    return _cache.putIfAbsent(trail.id, () async {
      if (!trail.hasGpx) {
        return fallback(trail);
      }
      try {
        final source = await NetworkAssetBundle(
          Uri.parse(trail.gpxUrl),
        ).loadString("");
        final points = _parseGpxTrack(source);
        if (points.length >= 2) {
          return TrailMapGeometry(
            trail: trail,
            points: points,
            loadedFromGpx: true,
          );
        }
      } catch (_) {
        // The map must stay usable when a GPX host is offline or blocked.
      }
      return fallback(trail);
    });
  }

  static List<LatLng> _parseGpxTrack(String source) {
    final document = XmlDocument.parse(source);
    final points = <LatLng>[];
    for (final element in document.descendants.whereType<XmlElement>()) {
      final name = element.name.local;
      if (name != "trkpt" && name != "rtept") {
        continue;
      }
      final lat = double.tryParse(element.getAttribute("lat") ?? "");
      final lon = double.tryParse(element.getAttribute("lon") ?? "");
      if (lat != null && lon != null) {
        points.add(LatLng(lat, lon));
      }
    }
    return points;
  }
}

class _TrailMapButton extends StatelessWidget {
  const _TrailMapButton({
    super.key,
    required this.trail,
    required this.selected,
    required this.onTap,
  });

  final TrailRoute trail;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = selected ? 46.0 : 38.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: trail.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: trail.color.withValues(alpha: 0.38),
                blurRadius: selected ? 20 : 12,
                spreadRadius: selected ? 3 : 0,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            trail.caiNumber,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrailOnlineMap extends StatelessWidget {
  const _TrailOnlineMap({
    required this.trails,
    required this.selectedTrail,
    required this.showOnlySelected,
    required this.fitPadding,
    required this.reliefMode,
    this.onTrailSelected,
  });

  final List<TrailRoute> trails;
  final TrailRoute selectedTrail;
  final bool showOnlySelected;
  final EdgeInsets fitPadding;
  final bool reliefMode;
  final ValueChanged<TrailRoute>? onTrailSelected;

  @override
  Widget build(BuildContext context) {
    final visibleTrails = showOnlySelected ? [selectedTrail] : trails;
    final fallbackGeometries =
        visibleTrails.map(TrailGeometryRepository.fallback).toList();
    return FutureBuilder<List<TrailMapGeometry>>(
      future: TrailGeometryRepository.loadAll(visibleTrails),
      builder: (context, snapshot) {
        final geometries = snapshot.data ?? fallbackGeometries;
        final loaded = snapshot.connectionState == ConnectionState.done;
        final anyRemote =
            geometries.any((geometry) => geometry.loadedFromGpx) || !loaded;
        final bounds = _boundsFor(geometries);
        final mapKey = ValueKey(
          "${showOnlySelected ? "single" : "all"}-"
          "${visibleTrails.map((trail) => trail.id).join("-")}-"
          "${snapshot.hasData ? "gpx" : "fallback"}-"
          "${reliefMode ? "relief" : "map"}",
        );
        return Stack(
          children: [
            FlutterMap(
              key: mapKey,
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: bounds,
                  padding: fitPadding,
                  maxZoom: showOnlySelected ? 15 : 13,
                ),
                minZoom: 9,
                maxZoom: 17,
                backgroundColor: const Color(0xFFDCE7D9),
              ),
              children: [
                TileLayer(
                  urlTemplate: reliefMode
                      ? "https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}"
                      : "https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png",
                  fallbackUrl: reliefMode
                      ? "https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png"
                      : "https://a.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png",
                  userAgentPackageName: "appecchio_mockup",
                ),
                if (reliefMode) const _TrailReliefOverlay(),
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _apecchioBoundary,
                      color: const Color(0xFF2E7D57).withValues(alpha: 0.08),
                      borderStrokeWidth: 3.2,
                      borderColor: const Color(
                        0xFF0F5C43,
                      ).withValues(alpha: 0.92),
                      label: "Comune di Apecchio",
                      labelStyle: const TextStyle(
                        color: Color(0xFF173B2B),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                PolylineLayer(polylines: _buildPolylines(geometries)),
                MarkerLayer(markers: _buildMarkers(geometries)),
                RichAttributionWidget(
                  attributions: [
                    const TextSourceAttribution("OpenStreetMap contributors"),
                    if (reliefMode)
                      const TextSourceAttribution("Esri World Topographic Map")
                    else
                      const TextSourceAttribution("CARTO"),
                  ],
                  showFlutterMapAttribution: false,
                ),
              ],
            ),
            Positioned(
              right: 12,
              top: 12,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: loaded
                    ? _TrailSourcePill(
                        key: const ValueKey("loaded"),
                        label: anyRemote ? "GPX online" : "Traccia reale",
                        icon: anyRemote
                            ? Icons.cloud_done_rounded
                            : Icons.route_rounded,
                      )
                    : const _TrailSourcePill(
                        key: ValueKey("loading"),
                        label: "Carico GPX",
                        icon: Icons.cloud_download_rounded,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Polyline> _buildPolylines(List<TrailMapGeometry> geometries) {
    final ordered = [
      ...geometries.where((geometry) => geometry.trail.id != selectedTrail.id),
      ...geometries.where((geometry) => geometry.trail.id == selectedTrail.id),
    ];
    return [
      for (final geometry in ordered)
        if (geometry.points.length >= 2)
          Polyline(
            points: geometry.points,
            strokeWidth: geometry.trail.id == selectedTrail.id ? 5.8 : 3.8,
            color: geometry.trail.color.withValues(
              alpha: geometry.trail.id == selectedTrail.id ? 1 : 0.62,
            ),
            borderStrokeWidth:
                geometry.trail.id == selectedTrail.id ? 5.5 : 4.2,
            borderColor: Colors.white.withValues(
              alpha: geometry.trail.id == selectedTrail.id ? 0.88 : 0.58,
            ),
          ),
    ];
  }

  List<Marker> _buildMarkers(List<TrailMapGeometry> geometries) {
    return [
      for (final geometry in geometries)
        Marker(
          point: geometry.midPoint,
          width: geometry.trail.id == selectedTrail.id ? 58 : 50,
          height: geometry.trail.id == selectedTrail.id ? 58 : 50,
          child: _TrailMapButton(
            key: ValueKey("trail-map-button-${geometry.trail.id}"),
            trail: geometry.trail,
            selected: geometry.trail.id == selectedTrail.id,
            onTap: onTrailSelected == null
                ? null
                : () => onTrailSelected!(geometry.trail),
          ),
        ),
    ];
  }

  LatLngBounds _boundsFor(List<TrailMapGeometry> geometries) {
    final points = [
      if (!showOnlySelected) ..._apecchioBoundary,
      for (final geometry in geometries) ...geometry.points,
    ];
    if (points.isEmpty) {
      return LatLngBounds(
        const LatLng(43.50, 12.35),
        const LatLng(43.60, 12.57),
      );
    }
    return LatLngBounds.fromPoints(points);
  }
}

class _TrailReliefOverlay extends StatelessWidget {
  const _TrailReliefOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.18),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.16),
            ],
            stops: const [0, 0.48, 1],
          ),
        ),
        child: CustomPaint(painter: _ReliefLinePainter()),
      ),
    );
  }
}

class _ReliefLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (var y = -size.height * 0.15; y < size.height; y += 36) {
      final path = Path()..moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 32) {
        final wave = math.sin((x / size.width * math.pi * 3) + y / 52) * 9;
        path.lineTo(x, y + wave + x * 0.10);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ReliefLinePainter oldDelegate) => false;
}

class _TrailSourcePill extends StatelessWidget {
  const _TrailSourcePill({super.key, required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF2E7D57)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _TrailFilterBar extends StatelessWidget {
  const _TrailFilterBar({
    required this.filters,
    required this.selectedFilter,
    required this.onChanged,
  });

  final Map<String, String> filters;
  final String selectedFilter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final entry in filters.entries) ...[
            ChoiceChip(
              label: Text(entry.value),
              selected: selectedFilter == entry.key,
              selectedColor: const Color(0xFF2E7D57),
              labelStyle: TextStyle(
                color: selectedFilter == entry.key
                    ? Colors.white
                    : const Color(0xFF1B2E21),
                fontWeight: FontWeight.w800,
              ),
              onSelected: (_) => onChanged(entry.key),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _TrailMapModeSwitch extends StatelessWidget {
  const _TrailMapModeSwitch({
    required this.reliefMode,
    required this.onChanged,
  });

  final bool reliefMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment<bool>(
          value: false,
          icon: Icon(Icons.map_rounded),
          label: Text("Mappa"),
        ),
        ButtonSegment<bool>(
          value: true,
          icon: Icon(Icons.terrain_rounded),
          label: Text("Rilievo 3D"),
        ),
      ],
      selected: {reliefMode},
      onSelectionChanged: (values) => onChanged(values.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        textStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _TrailMapModeChip extends StatelessWidget {
  const _TrailMapModeChip({required this.reliefMode, required this.onTap});

  final bool reliefMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                reliefMode ? Icons.terrain_rounded : Icons.map_rounded,
                size: 18,
                color: const Color(0xFF2E7D57),
              ),
              const SizedBox(width: 7),
              Text(
                reliefMode ? "Rilievo 3D" : "Mappa",
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrailQuickOpenRow extends StatelessWidget {
  const _TrailQuickOpenRow({
    required this.trails,
    required this.onTrailSelected,
  });

  final List<TrailRoute> trails;
  final ValueChanged<TrailRoute> onTrailSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final trail in trails) ...[
            ActionChip(
              key: ValueKey("trail-card-${trail.id}"),
              avatar: CircleAvatar(
                backgroundColor: trail.color,
                child: Text(
                  trail.caiNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              label: Text(trail.name),
              onPressed: () => onTrailSelected(trail),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _TrailSelectedPanel extends StatelessWidget {
  const _TrailSelectedPanel({required this.trail, required this.onOpenDetail});

  final TrailRoute trail;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE8D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: trail.color,
                child: Text(
                  trail.caiNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trail.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${trail.start} -> ${trail.end}",
                      style: const TextStyle(
                        color: Color(0xFF526055),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TrailStatChip(
                icon: Icons.straighten_rounded,
                label: trail.distanceLabel,
              ),
              _TrailStatChip(
                icon: Icons.trending_up_rounded,
                label: trail.elevationLabel,
              ),
              _TrailStatChip(
                icon: Icons.schedule_rounded,
                label: trail.timeLabel,
              ),
              _TrailStatChip(
                icon: Icons.hiking_rounded,
                label: trail.difficulty,
              ),
              _TrailStatChip(
                icon: Icons.filter_hdr_rounded,
                label: "${trail.maxAltitudeM} m max",
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(trail.summary, style: const TextStyle(height: 1.28)),
          const SizedBox(height: 10),
          Text(
            trail.safetyNote,
            style: const TextStyle(
              color: Color(0xFF7A4B00),
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpenDetail,
              icon: const Icon(Icons.map_rounded),
              label: const Text("Apri scheda sentiero"),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D57),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrailStatChip extends StatelessWidget {
  const _TrailStatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2E6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E7D57)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _TrailListCard extends StatelessWidget {
  const _TrailListCard({
    required this.trail,
    required this.selected,
    required this.onTap,
    required this.onOpenDetail,
  });

  final TrailRoute trail;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: selected ? const Color(0xFFE3F1E8) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? trail.color : const Color(0xFFE1E8DD),
          width: selected ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: trail.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  trail.caiNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trail.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${trail.distanceLabel} · ${trail.elevationLabel} · ${trail.timeLabel} · ${trail.difficulty}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF526055),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: "Dettaglio sentiero",
                onPressed: onOpenDetail,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrailMapScreen extends StatefulWidget {
  const TrailMapScreen({
    super.key,
    required this.trail,
    required this.reliefMode,
  });

  final TrailRoute trail;
  final bool reliefMode;

  @override
  State<TrailMapScreen> createState() => _TrailMapScreenState();
}

class _TrailMapScreenState extends State<TrailMapScreen> {
  late bool _reliefMode;

  @override
  void initState() {
    super.initState();
    _reliefMode = widget.reliefMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1B2E21),
        elevation: 0,
        title: Text("Sentiero ${widget.trail.caiNumber}"),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _TrailOnlineMap(
              trails: [widget.trail],
              selectedTrail: widget.trail,
              showOnlySelected: true,
              fitPadding: const EdgeInsets.fromLTRB(44, 100, 44, 210),
              reliefMode: _reliefMode,
            ),
          ),
          Positioned(
            top: 94,
            left: 16,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.centerRight,
                child: _TrailMapModeChip(
                  reliefMode: _reliefMode,
                  onTap: () => setState(() => _reliefMode = !_reliefMode),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: widget.trail.color,
                          child: Text(
                            widget.trail.caiNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.trail.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "${widget.trail.start} -> ${widget.trail.end}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF526055),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TrailStatChip(
                          icon: Icons.straighten_rounded,
                          label: widget.trail.distanceLabel,
                        ),
                        _TrailStatChip(
                          icon: Icons.trending_up_rounded,
                          label: widget.trail.elevationLabel,
                        ),
                        _TrailStatChip(
                          icon: Icons.schedule_rounded,
                          label: widget.trail.timeLabel,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  TrailDetailScreen(trail: widget.trail),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline_rounded),
                        label: const Text("Apri scheda sentiero"),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D57),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrailDetailScreen extends StatelessWidget {
  const TrailDetailScreen({super.key, required this.trail});

  final TrailRoute trail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F6EC),
        title: Text("Sentiero ${trail.caiNumber}"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 300,
              child: _TrailOnlineMap(
                trails: [trail],
                selectedTrail: trail,
                showOnlySelected: true,
                fitPadding: const EdgeInsets.all(48),
                reliefMode: true,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            trail.name,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            "CAI ${trail.caiNumber} · nuova numerazione ${trail.newNumber}",
            style: const TextStyle(
              color: Color(0xFF526055),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TrailStatChip(
                icon: Icons.straighten_rounded,
                label: trail.distanceLabel,
              ),
              _TrailStatChip(
                icon: Icons.trending_up_rounded,
                label: "+${trail.elevationGainM} m",
              ),
              _TrailStatChip(
                icon: Icons.trending_down_rounded,
                label: "-${trail.elevationLossM} m",
              ),
              _TrailStatChip(
                icon: Icons.schedule_rounded,
                label: trail.timeLabel,
              ),
              _TrailStatChip(
                icon: Icons.hiking_rounded,
                label: "Difficolta ${trail.difficulty}",
              ),
            ],
          ),
          const SizedBox(height: 18),
          _TrailDetailCard(
            title: "Partenza e arrivo",
            child: Column(
              children: [
                _TrailInfoRow(
                  icon: Icons.flag_rounded,
                  label: "Partenza",
                  value: "${trail.start} · ${trail.startAltitudeM} m",
                ),
                _TrailInfoRow(
                  icon: Icons.place_rounded,
                  label: "Arrivo",
                  value: "${trail.end} · ${trail.endAltitudeM} m",
                ),
                _TrailInfoRow(
                  icon: Icons.filter_hdr_rounded,
                  label: "Quota massima",
                  value: "${trail.maxAltitudeM} m",
                ),
              ],
            ),
          ),
          _TrailDetailCard(
            title: "Perche valorizzarlo",
            child: Text(trail.summary, style: const TextStyle(height: 1.32)),
          ),
          _TrailDetailCard(
            title: "Punti notevoli",
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final highlight in trail.highlights)
                  Chip(
                    label: Text(highlight),
                    avatar: const Icon(Icons.place_rounded, size: 18),
                  ),
              ],
            ),
          ),
          _TrailDetailCard(
            title: "Sicurezza",
            child: Text(
              trail.safetyNote,
              style: const TextStyle(
                color: Color(0xFF7A4B00),
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          _TrailDetailCard(
            title: "Fonte dati",
            child: Text(
              "${trail.sourceLabel}\n${trail.sourceUrl}",
              style: const TextStyle(height: 1.35),
            ),
          ),
          const SizedBox(height: 4),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    trail.hasGpx
                        ? "Mockup: GPX pronto da ${trail.gpxUrl}"
                        : "Mockup: traccia GPX non disponibile nella scheda caricata.",
                  ),
                ),
              );
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text("Scarica GPX"),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D57),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrailDetailCard extends StatelessWidget {
  const _TrailDetailCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TrailInfoRow extends StatelessWidget {
  const _TrailInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2E7D57), size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF526055)),
            ),
          ),
        ],
      ),
    );
  }
}

class SportFacility {
  const SportFacility({
    required this.id,
    required this.name,
    required this.activity,
    required this.place,
    required this.surface,
    required this.capacity,
    required this.priceLabel,
    required this.nextSlots,
    required this.rules,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;
  final String activity;
  final String place;
  final String surface;
  final String capacity;
  final String priceLabel;
  final List<String> nextSlots;
  final List<String> rules;
  final Color color;
  final IconData icon;
}

class SportBookingSlot {
  const SportBookingSlot({
    required this.facility,
    required this.date,
    required this.timeLabel,
  });

  final SportFacility facility;
  final DateTime date;
  final String timeLabel;

  String get id => "${facility.id}:${_formatSportSlotDate(date)}:$timeLabel";

  String get dayLabel => _formatSportSlotDay(date);
}

const List<SportFacility> _sportFacilities = [
  SportFacility(
    id: "campetto_del_prete",
    name: "Campetto del prete",
    activity: "Calcetto outdoor",
    place: "Area sportiva comunale",
    surface: "Sintetico outdoor",
    capacity: "5 vs 5",
    priceLabel: "Da 12 euro/ora",
    nextSlots: ["Oggi 18:00", "Oggi 19:30", "Domani 17:00"],
    rules: [
      "Prenotazione minima 60 minuti.",
      "Luci incluse nelle fasce serali.",
      "Accesso consentito 10 minuti prima dello slot.",
    ],
    color: Color(0xFF2E7D57),
    icon: Icons.grass_rounded,
  ),
  SportFacility(
    id: "palazzetto_calcetto",
    name: "Palazzetto",
    activity: "Calcetto indoor",
    place: "Palazzetto comunale",
    surface: "Parquet indoor",
    capacity: "5 vs 5",
    priceLabel: "Da 18 euro/ora",
    nextSlots: ["Oggi 20:00", "Domani 18:30", "Sab 16:00"],
    rules: [
      "Obbligatorie scarpe pulite da indoor.",
      "Spogliatoi disponibili su richiesta.",
      "In caso di evento scolastico lo slot viene riprogrammato.",
    ],
    color: Color(0xFF1D5D8F),
    icon: Icons.sports_soccer_rounded,
  ),
  SportFacility(
    id: "palazzetto_city_tennis",
    name: "Palazzetto",
    activity: "City tennis",
    place: "Palazzetto comunale",
    surface: "Campo indoor multisport",
    capacity: "Singolo o doppio",
    priceLabel: "Da 14 euro/ora",
    nextSlots: ["Domani 09:00", "Domani 12:00", "Ven 18:00"],
    rules: [
      "Rete e linee configurate dal custode.",
      "Racchette non incluse nel servizio comunale.",
      "Priorita alle prenotazioni associative gia calendarizzate.",
    ],
    color: Color(0xFFD6802B),
    icon: Icons.sports_handball_rounded,
  ),
  SportFacility(
    id: "palazzetto_pallavolo",
    name: "Palazzetto",
    activity: "Pallavolo",
    place: "Palazzetto comunale",
    surface: "Parquet indoor",
    capacity: "6 vs 6",
    priceLabel: "Da 20 euro/ora",
    nextSlots: ["Oggi 21:00", "Ven 19:30", "Dom 10:00"],
    rules: [
      "Prenotazione consigliata per gruppi da almeno 8 persone.",
      "Montaggio rete incluso.",
      "Palloni disponibili se richiesti in prenotazione.",
    ],
    color: Color(0xFF7A5AA6),
    icon: Icons.sports_volleyball_rounded,
  ),
  SportFacility(
    id: "campo_tennis",
    name: "Campo da tennis",
    activity: "Tennis outdoor",
    place: "Campo tennis comunale",
    surface: "Outdoor illuminato",
    capacity: "Singolo o doppio",
    priceLabel: "Da 10 euro/ora",
    nextSlots: ["Oggi 17:00", "Oggi 18:00", "Sab 09:30"],
    rules: [
      "Luci serali attivabili dalla prenotazione.",
      "Accesso con codice temporaneo nell'app.",
      "Annullamento gratuito fino a 6 ore prima.",
    ],
    color: Color(0xFFB5475B),
    icon: Icons.sports_tennis_rounded,
  ),
];

class SportBookingScreen extends StatefulWidget {
  const SportBookingScreen({super.key, required this.initialFacilityId});

  final String initialFacilityId;

  @override
  State<SportBookingScreen> createState() => _SportBookingScreenState();
}

class _SportBookingScreenState extends State<SportBookingScreen> {
  late SportFacility _selectedFacility;
  late DateTime _focusedMonth;
  late DateTime _selectedDay;
  SportBookingSlot? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _selectedFacility = _sportFacilities.firstWhere(
      (facility) => facility.id == widget.initialFacilityId,
      orElse: () => _sportFacilities.first,
    );
    final slots = _sportBookingSlotsForFacility(_selectedFacility);
    _selectedSlot = slots.first;
    _selectedDay = _selectedSlot!.date;
    _focusedMonth = DateTime(_selectedDay.year, _selectedDay.month);
  }

  @override
  Widget build(BuildContext context) {
    final allSlots = _sportBookingSlots();
    final selectedDaySlots = _sportSlotsForDay(_selectedDay, allSlots);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F6F0),
        title: const Text("Prenota impianti"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
        children: [
          _SportHeroCard(facility: _selectedFacility),
          const SizedBox(height: 16),
          _SportFacilitySelector(
            selectedFacility: _selectedFacility,
            onChanged: (facility) => setState(() {
              _selectedFacility = facility;
              final facilitySlots = _sportBookingSlotsForFacility(facility);
              final daySlots = _sportSlotsForDay(_selectedDay, facilitySlots);
              _selectedSlot =
                  daySlots.isNotEmpty ? daySlots.first : facilitySlots.first;
              _selectedDay = _selectedSlot!.date;
              _focusedMonth = DateTime(_selectedDay.year, _selectedDay.month);
            }),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: appSportReservations,
            builder: (context, _) {
              return _SportBookingCalendar(
                focusedMonth: _focusedMonth,
                selectedDay: _selectedDay,
                slots: allSlots,
                reservations: appSportReservations,
                onPreviousMonth: () => setState(
                  () => _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month - 1,
                  ),
                ),
                onNextMonth: () => setState(
                  () => _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month + 1,
                  ),
                ),
                onDaySelected: (day) => setState(() {
                  _selectedDay = day;
                  _focusedMonth = DateTime(day.year, day.month);
                  final daySlots = _sportSlotsForDay(day, allSlots);
                  final preferred = daySlots
                      .where((slot) => slot.facility.id == _selectedFacility.id)
                      .toList(growable: false);
                  _selectedSlot = preferred.isNotEmpty
                      ? preferred.first
                      : daySlots.isNotEmpty
                          ? daySlots.first
                          : null;
                  if (_selectedSlot != null) {
                    _selectedFacility = _selectedSlot!.facility;
                  }
                }),
              );
            },
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: appSportReservations,
            builder: (context, _) {
              return _SportDaySlotsPanel(
                day: _selectedDay,
                slots: selectedDaySlots,
                selectedSlot: _selectedSlot,
                reservations: appSportReservations,
                onSlotSelected: (slot) => setState(() {
                  _selectedSlot = slot;
                  _selectedFacility = slot.facility;
                  _selectedDay = slot.date;
                }),
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _selectedSlot == null
                ? null
                : () {
                    final slot = _selectedSlot!;
                    final reserved = appSportReservations.reserve(slot);
                    final awarded = reserved
                        ? appGamification.recordBooking(
                            sourceId: slot.id,
                            label:
                                "Prenotazione sport: ${slot.facility.activity} · ${slot.dayLabel} ${slot.timeLabel}",
                          )
                        : false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          reserved
                              ? awarded
                                  ? "Prenotazione inviata: +40 token accreditati."
                                  : "Prenotazione inviata: slot gia premiato in precedenza."
                              : "Prenotazione gia presente nel calendario.",
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.event_available_rounded),
            label: const Text("Conferma prenotazione"),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D57),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
          const SizedBox(height: 16),
          _TrailDetailCard(
            title: "Dettagli impianto",
            child: Column(
              children: [
                _TrailInfoRow(
                  icon: Icons.place_rounded,
                  label: "Luogo",
                  value: _selectedFacility.place,
                ),
                _TrailInfoRow(
                  icon: Icons.layers_rounded,
                  label: "Fondo",
                  value: _selectedFacility.surface,
                ),
                _TrailInfoRow(
                  icon: Icons.groups_rounded,
                  label: "Formato",
                  value: _selectedFacility.capacity,
                ),
                _TrailInfoRow(
                  icon: Icons.euro_rounded,
                  label: "Tariffa",
                  value: _selectedFacility.priceLabel,
                ),
              ],
            ),
          ),
          _TrailDetailCard(
            title: "Regole principali",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final rule in _selectedFacility.rules)
                  _SportBullet(text: rule),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<SportBookingSlot> _sportBookingSlots() {
  return [
    for (final facility in _sportFacilities)
      ..._sportBookingSlotsForFacility(facility),
  ]..sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return a.timeLabel.compareTo(b.timeLabel);
    });
}

List<SportBookingSlot> _sportBookingSlotsForFacility(SportFacility facility) {
  return [
    for (final rawSlot in facility.nextSlots)
      SportBookingSlot(
        facility: facility,
        date: _sportDateFromSlotLabel(rawSlot),
        timeLabel: _sportTimeFromSlotLabel(rawSlot),
      ),
  ];
}

List<SportBookingSlot> _sportSlotsForDay(
  DateTime day,
  List<SportBookingSlot> slots,
) {
  return slots.where((slot) => _sameDay(slot.date, day)).toList();
}

DateTime _sportDateFromSlotLabel(String label) {
  final now = _dateOnly(DateTime.now());
  final pieces = label.split(" ");
  final dayToken = pieces.first.toLowerCase();
  if (dayToken == "oggi") {
    return now;
  }
  if (dayToken == "domani") {
    return now.add(const Duration(days: 1));
  }
  const weekdays = {
    "lun": DateTime.monday,
    "mar": DateTime.tuesday,
    "mer": DateTime.wednesday,
    "gio": DateTime.thursday,
    "ven": DateTime.friday,
    "sab": DateTime.saturday,
    "dom": DateTime.sunday,
  };
  final targetWeekday =
      weekdays[dayToken.substring(0, math.min(3, dayToken.length))];
  if (targetWeekday == null) {
    return now;
  }
  var daysUntil = targetWeekday - now.weekday;
  if (daysUntil < 0) {
    daysUntil += 7;
  }
  return now.add(Duration(days: daysUntil));
}

String _sportTimeFromSlotLabel(String label) {
  final pieces = label.split(" ");
  return pieces.isEmpty ? label : pieces.last;
}

String _formatSportSlotDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}";
}

String _formatSportSlotDay(DateTime date) {
  return "${date.day} ${_monthName(date.month)}";
}

class _SportBookingCalendar extends StatelessWidget {
  const _SportBookingCalendar({
    required this.focusedMonth,
    required this.selectedDay,
    required this.slots,
    required this.reservations,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDaySelected,
  });

  final DateTime focusedMonth;
  final DateTime selectedDay;
  final List<SportBookingSlot> slots;
  final SportReservationController reservations;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final days = _calendarDays(focusedMonth);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDCE8DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: "Mese precedente",
              ),
              Expanded(
                child: Text(
                  _formatMonthYear(focusedMonth),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: "Mese successivo",
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final label in [
                "Lun",
                "Mar",
                "Mer",
                "Gio",
                "Ven",
                "Sab",
                "Dom",
              ])
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final daySlots = _sportSlotsForDay(day, slots);
              return _SportCalendarDayCell(
                day: day,
                inMonth: _sameMonth(day, focusedMonth),
                selected: _sameDay(day, selectedDay),
                reserved: daySlots.any((slot) => reservations.isReserved(slot)),
                slots: daySlots,
                onTap: () => onDaySelected(day),
              );
            },
          ),
          const SizedBox(height: 12),
          const _SportCalendarLegend(),
        ],
      ),
    );
  }
}

class _SportCalendarDayCell extends StatelessWidget {
  const _SportCalendarDayCell({
    required this.day,
    required this.inMonth,
    required this.selected,
    required this.reserved,
    required this.slots,
    required this.onTap,
  });

  final DateTime day;
  final bool inMonth;
  final bool selected;
  final bool reserved;
  final List<SportBookingSlot> slots;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final slotCount = slots.length;
    final bgColor = selected
        ? const Color(0xFFE4F2E8)
        : reserved
            ? const Color(0xFFEAF5EA)
            : inMonth
                ? const Color(0xFFFAFCF7)
                : const Color(0xFFF1F2EE);
    final borderColor = selected
        ? const Color(0xFF2E7D57)
        : reserved
            ? const Color(0xFF78A65D)
            : slotCount > 0
                ? const Color(0xFFCAD8C7)
                : const Color(0xFFE7ECE2);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "${day.day}",
                  style: TextStyle(
                    color: inMonth ? Colors.black87 : Colors.black38,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (slotCount > 1)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 19,
                    constraints: const BoxConstraints(minWidth: 19),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF263E2B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$slotCount",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              if (reserved)
                const Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF2E7D57),
                    size: 18,
                  ),
                ),
              Align(
                alignment: Alignment.bottomLeft,
                child: _SportSlotMarks(slots: slots),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportSlotMarks extends StatelessWidget {
  const _SportSlotMarks({required this.slots});

  final List<SportBookingSlot> slots;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const SizedBox.shrink();
    }
    final visible = slots.take(4).toList(growable: false);
    return SizedBox(
      width: 42,
      height: 16,
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * 8,
              bottom: 0,
              child: Container(
                width: 22,
                height: 6,
                decoration: BoxDecoration(
                  color: visible[i].facility.color,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SportCalendarLegend extends StatelessWidget {
  const _SportCalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final facility in _sportFacilities)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: facility.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: facility.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  facility.activity,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SportDaySlotsPanel extends StatelessWidget {
  const _SportDaySlotsPanel({
    required this.day,
    required this.slots,
    required this.selectedSlot,
    required this.reservations,
    required this.onSlotSelected,
  });

  final DateTime day;
  final List<SportBookingSlot> slots;
  final SportBookingSlot? selectedSlot;
  final SportReservationController reservations;
  final ValueChanged<SportBookingSlot> onSlotSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE8DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Slot del ${_formatDayLong(day)}",
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (slots.isEmpty)
            const Text(
              "Nessuno slot disponibile in questa giornata.",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final slot in slots)
                  ChoiceChip(
                    avatar: Icon(
                      reservations.isReserved(slot)
                          ? Icons.check_circle_rounded
                          : slot.facility.icon,
                      size: 18,
                      color: selectedSlot?.id == slot.id
                          ? Colors.white
                          : slot.facility.color,
                    ),
                    label: Text(
                      "${slot.timeLabel} · ${slot.facility.activity}",
                    ),
                    selected: selectedSlot?.id == slot.id,
                    selectedColor: slot.facility.color,
                    labelStyle: TextStyle(
                      color: selectedSlot?.id == slot.id
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                    onSelected: (_) => onSlotSelected(slot),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SportHeroCard extends StatelessWidget {
  const _SportHeroCard({required this.facility});

  final SportFacility facility;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 188,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [facility.color, const Color(0xFF263D32)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              facility.icon,
              color: Colors.white.withValues(alpha: 0.38),
              size: 82,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Sport comunale",
                style: TextStyle(
                  color: Color(0xFFE8F2E8),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                facility.activity,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "${facility.name} · ${facility.place}",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.84),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SportFacilitySelector extends StatelessWidget {
  const _SportFacilitySelector({
    required this.selectedFacility,
    required this.onChanged,
  });

  final SportFacility selectedFacility;
  final ValueChanged<SportFacility> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _sportFacilities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final facility = _sportFacilities[index];
          final selected = facility.id == selectedFacility.id;
          return SizedBox(
            width: 156,
            child: Material(
              color: selected ? facility.color : Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onChanged(facility),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        facility.icon,
                        color: selected ? Colors.white : facility.color,
                      ),
                      const Spacer(),
                      Text(
                        facility.activity,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        facility.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.78)
                              : const Color(0xFF526055),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SportRulesScreen extends StatefulWidget {
  const SportRulesScreen({super.key, required this.initialSectionId});

  final String initialSectionId;

  @override
  State<SportRulesScreen> createState() => _SportRulesScreenState();
}

class _SportRulesScreenState extends State<SportRulesScreen> {
  late String _selectedSection;

  static const Map<String, String> _sections = {
    "fasce_orarie": "Fasce orarie",
    "tariffe": "Tariffe",
    "annulla_sposta": "Annulla o sposta",
  };

  @override
  void initState() {
    super.initState();
    _selectedSection = _sections.containsKey(widget.initialSectionId)
        ? widget.initialSectionId
        : "fasce_orarie";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F6F0),
        title: const Text("Regolamenti e tariffe"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF203B2C),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sport senza telefonate infinite",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Fasce, costi, regole di annullamento e istruzioni operative in una pagina sola.",
                  style: TextStyle(
                    color: Color(0xFFDCE9DD),
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _TrailFilterBar(
            filters: _sections,
            selectedFilter: _selectedSection,
            onChanged: (value) => setState(() => _selectedSection = value),
          ),
          const SizedBox(height: 16),
          if (_selectedSection == "fasce_orarie")
            const _SportTimeRules()
          else if (_selectedSection == "tariffe")
            const _SportPricingRules()
          else
            const _SportChangeRules(),
        ],
      ),
    );
  }
}

class _SportTimeRules extends StatelessWidget {
  const _SportTimeRules();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SportRuleBlock(
          title: "Mattina",
          icon: Icons.wb_sunny_rounded,
          lines: ["08:00 - 12:30", "Ideale per tennis, scuole e gruppi."],
        ),
        _SportRuleBlock(
          title: "Pomeriggio",
          icon: Icons.schedule_rounded,
          lines: ["14:30 - 19:30", "Fascia principale per campi outdoor."],
        ),
        _SportRuleBlock(
          title: "Sera",
          icon: Icons.nights_stay_rounded,
          lines: ["19:30 - 22:30", "Luci e palazzetto su disponibilita."],
        ),
      ],
    );
  }
}

class _SportPricingRules extends StatelessWidget {
  const _SportPricingRules();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SportRuleBlock(
          title: "Campi outdoor",
          icon: Icons.grass_rounded,
          lines: ["Tennis da 10 euro/ora", "Calcetto outdoor da 12 euro/ora"],
        ),
        _SportRuleBlock(
          title: "Palazzetto",
          icon: Icons.sports_handball_rounded,
          lines: [
            "City tennis da 14 euro/ora",
            "Calcetto e volley da 18 euro/ora",
          ],
        ),
        _SportRuleBlock(
          title: "Agevolazioni",
          icon: Icons.volunteer_activism_rounded,
          lines: [
            "Scuole e associazioni: tariffa convenzionata",
            "Residenti: priorita sugli slot feriali",
          ],
        ),
      ],
    );
  }
}

class _SportChangeRules extends StatelessWidget {
  const _SportChangeRules();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _SportRuleBlock(
          title: "Annullamento",
          icon: Icons.event_busy_rounded,
          lines: [
            "Gratuito fino a 6 ore prima",
            "Dopo la scadenza resta visibile allo sportello",
          ],
        ),
        _SportRuleBlock(
          title: "Sposta prenotazione",
          icon: Icons.swap_horiz_rounded,
          lines: [
            "Una modifica rapida per prenotazione",
            "Conferma immediata se lo slot e libero",
          ],
        ),
        _SportRuleBlock(
          title: "Maltempo",
          icon: Icons.water_drop_rounded,
          lines: [
            "Campi outdoor riprogrammabili",
            "Palazzetto suggerito come alternativa",
          ],
        ),
      ],
    );
  }
}

class _SportRuleBlock extends StatelessWidget {
  const _SportRuleBlock({
    required this.title,
    required this.icon,
    required this.lines,
  });

  final String title;
  final IconData icon;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E8DD)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE4EFE8),
            child: Icon(icon, color: const Color(0xFF2E7D57)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                for (final line in lines)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(line, style: const TextStyle(height: 1.22)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OutdoorService {
  const OutdoorService({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.priceLabel,
    required this.bestFor,
    required this.includes,
    required this.color,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final String duration;
  final String priceLabel;
  final String bestFor;
  final List<String> includes;
  final Color color;
  final IconData icon;
}

const List<OutdoorService> _outdoorServices = [
  OutdoorService(
    id: "prenota_guida",
    title: "Guida ambientale",
    subtitle: "Accompagnamento sui sentieri del Nerone",
    duration: "Mezza giornata",
    priceLabel: "Da concordare",
    bestFor: "Visitatori, gruppi piccoli, fotografia naturalistica",
    includes: [
      "Scelta sentiero in base a meteo e livello",
      "Racconto del territorio e punti panoramici",
      "Piano sicurezza prima della partenza",
    ],
    color: Color(0xFF1D8A6A),
    icon: Icons.support_agent_rounded,
  ),
  OutdoorService(
    id: "prenota_istruttore",
    title: "Istruttore outdoor",
    subtitle: "Tecnica base, preparazione e movimento in sicurezza",
    duration: "90 min o 3 ore",
    priceLabel: "Pacchetto singolo o gruppo",
    bestFor: "Principianti, scuole, sportivi in ripresa",
    includes: [
      "Valutazione livello di partenza",
      "Esercizi su salita, discesa e passo",
      "Consigli su scarpe, zaino e ritmo",
    ],
    color: Color(0xFFD6802B),
    icon: Icons.fitness_center_rounded,
  ),
  OutdoorService(
    id: "noleggio_ebike",
    title: "Noleggio bici elettriche",
    subtitle: "E-bike per collegare borgo, valle e punti panoramici",
    duration: "2 ore, mezza giornata, giornata",
    priceLabel: "Da 18 euro",
    bestFor: "Coppie, famiglie, itinerari morbidi",
    includes: [
      "Casco e lucchetto",
      "Briefing su autonomia e percorso",
      "Suggerimenti per soste e rientro",
    ],
    color: Color(0xFF1D5D8F),
    icon: Icons.electric_bike_rounded,
  ),
  OutdoorService(
    id: "tour_famiglie",
    title: "Tour famiglie e scuole",
    subtitle: "Percorsi brevi con lettura del paesaggio",
    duration: "2 - 3 ore",
    priceLabel: "Formula gruppo",
    bestFor: "Bambini, classi, prime esperienze",
    includes: [
      "Tappe brevi e pause frequenti",
      "Materiale didattico semplificato",
      "Percorso alternativo in caso di meteo incerto",
    ],
    color: Color(0xFF7A5AA6),
    icon: Icons.family_restroom_rounded,
  ),
  OutdoorService(
    id: "canoa_trekking",
    title: "Canoa e trekking guidato",
    subtitle: "Uscite combinate tra acqua, bosco e sentieri",
    duration: "Mezza giornata",
    priceLabel: "Su disponibilita",
    bestFor: "Gruppi attivi, weekend outdoor, team piccoli",
    includes: [
      "Verifica meteo e livello del gruppo",
      "Abbinamento con guida locale o accompagnatore",
      "Punto di ritrovo e rientro coordinati",
    ],
    color: Color(0xFF2A7F9E),
    icon: Icons.kayaking_rounded,
  ),
  OutdoorService(
    id: "parco_avventura",
    title: "Parco Avventura Furlo",
    subtitle: "Giornata outdoor collegata agli itinerari dell'entroterra",
    duration: "Giornata",
    priceLabel: "Biglietto/parco",
    bestFor: "Famiglie, ragazzi, gruppi scuola",
    includes: [
      "Scheda logistica per raggiungere il parco",
      "Suggerimenti per abbinare pranzo e rientro",
      "Controllo stagionalita e aperture prima della partenza",
    ],
    color: Color(0xFF426B3F),
    icon: Icons.forest_rounded,
  ),
  OutdoorService(
    id: "birdwatching",
    title: "Birdwatching",
    subtitle: "Osservazione naturalistica nei punti panoramici",
    duration: "2 ore",
    priceLabel: "Formula libera o guidata",
    bestFor: "Fotografia, natura lenta, piccoli gruppi",
    includes: [
      "Suggerimenti su orari con luce migliore",
      "Punti panoramici e comportamento rispettoso",
      "Alternativa breve in caso di vento o pioggia",
    ],
    color: Color(0xFF8A6B24),
    icon: Icons.visibility_rounded,
  ),
];

class OutdoorServicesScreen extends StatefulWidget {
  const OutdoorServicesScreen({super.key, required this.initialServiceId});

  final String initialServiceId;

  @override
  State<OutdoorServicesScreen> createState() => _OutdoorServicesScreenState();
}

class _OutdoorServicesScreenState extends State<OutdoorServicesScreen> {
  late OutdoorService _selectedService;

  @override
  void initState() {
    super.initState();
    _selectedService = _outdoorServices.firstWhere(
      (service) => service.id == widget.initialServiceId,
      orElse: () => _outdoorServices.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F6EC),
        title: const Text("Servizi outdoor"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
        children: [
          _OutdoorServiceHero(service: _selectedService),
          const SizedBox(height: 16),
          _OutdoorServiceSelector(
            selectedService: _selectedService,
            onChanged: (service) => setState(() => _selectedService = service),
          ),
          const SizedBox(height: 16),
          _TrailDetailCard(
            title: "Esperienza",
            child: Text(
              _selectedService.subtitle,
              style: const TextStyle(height: 1.32),
            ),
          ),
          _TrailDetailCard(
            title: "Dettagli",
            child: Column(
              children: [
                _TrailInfoRow(
                  icon: Icons.schedule_rounded,
                  label: "Durata",
                  value: _selectedService.duration,
                ),
                _TrailInfoRow(
                  icon: Icons.euro_rounded,
                  label: "Costo",
                  value: _selectedService.priceLabel,
                ),
                _TrailInfoRow(
                  icon: Icons.groups_rounded,
                  label: "Ideale per",
                  value: _selectedService.bestFor,
                ),
              ],
            ),
          ),
          _TrailDetailCard(
            title: "Include",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in _selectedService.includes)
                  _SportBullet(text: item),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Mockup: richiesta inviata per ${_selectedService.title}.",
                  ),
                ),
              );
            },
            icon: const Icon(Icons.send_rounded),
            label: const Text("Richiedi disponibilita"),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D57),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutdoorServiceHero extends StatelessWidget {
  const _OutdoorServiceHero({required this.service});

  final OutdoorService service;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/appecchio_bg.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      service.color.withValues(alpha: 0.78),
                      Colors.black.withValues(alpha: 0.48),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(service.icon, color: Colors.white, size: 42),
                  const SizedBox(height: 12),
                  Text(
                    service.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutdoorServiceSelector extends StatelessWidget {
  const _OutdoorServiceSelector({
    required this.selectedService,
    required this.onChanged,
  });

  final OutdoorService selectedService;
  final ValueChanged<OutdoorService> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _outdoorServices.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final service = _outdoorServices[index];
          final selected = service.id == selectedService.id;
          return SizedBox(
            width: 154,
            child: Material(
              color: selected ? service.color : Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onChanged(service),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        service.icon,
                        color: selected ? Colors.white : service.color,
                      ),
                      const Spacer(),
                      Text(
                        service.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black,
                          height: 1.05,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SportBullet extends StatelessWidget {
  const _SportBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: Color(0xFF2E7D57),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(height: 1.25))),
        ],
      ),
    );
  }
}

class AppEvent {
  const AppEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.dateLabel,
    required this.timeLabel,
    required this.place,
    required this.description,
    required this.contacts,
    required this.website,
    required this.posterTitle,
    required this.posterSubtitle,
    required this.posterColors,
    required this.icon,
    this.bookingRewardPoints = 0,
    this.bookingActionLabel = "Prenota posto",
  });

  final String id;
  final String title;
  final String category;
  final String dateLabel;
  final String timeLabel;
  final String place;
  final String description;
  final String contacts;
  final String website;
  final String posterTitle;
  final String posterSubtitle;
  final List<Color> posterColors;
  final IconData icon;
  final int bookingRewardPoints;
  final String bookingActionLabel;
}

const List<AppEvent> _mockEvents = [
  AppEvent(
    id: "tartufo_birra_osterie",
    title: "Tartufo e Birra - Andar per osterie",
    category: "eventi_gastronomici",
    dateLabel: "3-5 ottobre",
    timeLabel: "Centro storico diffuso",
    place: "Apecchio, centro storico",
    description:
        "Mostra mercato dedicata a tartufo, birre artigianali e prodotti del bosco. L'esperienza riprende il format diffuso delle osterie nel borgo.",
    contacts: "Ufficio Turistico - +39 0722 99279",
    website: "www.vivereapecchio.it/eventi",
    posterTitle: "Tartufo e Birra",
    posterSubtitle: "Andar per osterie",
    posterColors: [Color(0xFF2E3A24), Color(0xFFD0A441)],
    icon: Icons.celebration_rounded,
    bookingRewardPoints: 25,
    bookingActionLabel: "Prenota osteria",
  ),
  AppEvent(
    id: "rembrandt_barocci",
    title: "Rembrandt e Barocci, incidere la luce",
    category: "mostre",
    dateLabel: "8 giugno - 7 settembre 2025",
    timeLabel: "Sale espositive",
    place: "Palazzo Ubaldini, piazza S. Martino",
    description:
        "Mostra d'arte grafica con oltre quaranta incisioni originali, in dialogo tra Rembrandt e Federico Barocci. Scheda mantenuta come archivio mostra e modello di prenotazione visita.",
    contacts: "Ufficio IAT - +39 0722 99279 - WhatsApecchio +39 366 1377489",
    website: "www.vivereapecchio.it/rembrandt-e-barocci",
    posterTitle: "Incidere la luce",
    posterSubtitle: "Rembrandt e Barocci",
    posterColors: [Color(0xFF493548), Color(0xFFE6C17A)],
    icon: Icons.image_rounded,
    bookingRewardPoints: 45,
    bookingActionLabel: "Prenota visita",
  ),
  AppEvent(
    id: "museo_fossili_minerali",
    title: "Museo dei Fossili e Minerali del Monte Nerone",
    category: "mostre",
    dateLabel: "Tutto l'anno",
    timeLabel: "Prenotazione visite",
    place: "Sotterranei di Palazzo Ubaldini",
    description:
        "Percorso museale interattivo con fossili, minerali, ammoniti e reperti legati al Monte Nerone, ospitato nei sotterranei di Palazzo Ubaldini.",
    contacts: "Ufficio Turistico - +39 0722 99249 - prenotazioni@lamacina.it",
    website: "www.vivereapecchio.it/cultura",
    posterTitle: "Museo Fossili",
    posterSubtitle: "Monte Nerone",
    posterColors: [Color(0xFF1B4332), Color(0xFF74C69D)],
    icon: Icons.museum_rounded,
    bookingRewardPoints: 30,
    bookingActionLabel: "Prenota visita",
  ),
  AppEvent(
    id: "torneo_tennis_birra",
    title: "Torneo di tennis Apecchio Citta della Birra",
    category: "sport_outdoor",
    dateLabel: "Dal 1 giugno",
    timeLabel: "Calendario ATAD",
    place: "Campo da tennis",
    description:
        "Torneo estivo al campo da tennis, collegato alla vocazione sportiva e alla narrazione di Apecchio come Citta della Birra.",
    contacts: "Ass. ATAD - Ufficio Turistico",
    website: "www.vivereapecchio.it/eventi",
    posterTitle: "Tennis",
    posterSubtitle: "Citta della Birra",
    posterColors: [Color(0xFF1D3557), Color(0xFFA8DADC)],
    icon: Icons.sports_tennis_rounded,
  ),
  AppEvent(
    id: "estate_musicale",
    title: "Estate Musicale Apecchiese",
    category: "cultura_spettacoli",
    dateLabel: "16, 23, 30 luglio",
    timeLabel: "Sera",
    place: "Apecchio",
    description:
        "Rassegna musicale estiva curata dal Comune di Apecchio e dall'Associazione Asilo Teatrale degli Appennini.",
    contacts: "Comune di Apecchio - Asilo Teatrale degli Appennini",
    website: "www.vivereapecchio.it/eventi",
    posterTitle: "Estate musicale",
    posterSubtitle: "Apecchiese",
    posterColors: [Color(0xFF31455E), Color(0xFFE9C46A)],
    icon: Icons.theater_comedy_rounded,
  ),
  AppEvent(
    id: "passio",
    title: "Passio - rappresentazione storico religiosa",
    category: "comunita_spiritualita",
    dateLabel: "Venerdi Santo",
    timeLabel: "Programma parrocchiale",
    place: "Apecchio",
    description:
        "Una delle manifestazioni piu importanti del territorio: rappresentazione della Passione e Morte di Cristo, legata alla spiritualita locale.",
    contacts: "Parrocchia e Comune di Apecchio",
    website: "www.vivereapecchio.it/dove-siamo",
    posterTitle: "Passio",
    posterSubtitle: "Storia e fede",
    posterColors: [Color(0xFF3C2F2F), Color(0xFFC9A46A)],
    icon: Icons.church_rounded,
    bookingRewardPoints: 20,
    bookingActionLabel: "Segna partecipazione",
  ),
  AppEvent(
    id: "fiera_ss_crocifisso",
    title: "Fiera e festa del SS. Crocifisso",
    category: "comunita_spiritualita",
    dateLabel: "1-3 giugno",
    timeLabel: "Fiera, messa e processione",
    place: "Santuario SS. Crocifisso e vie del borgo",
    description:
        "Triduo di preparazione, fiera nelle vie del paese, celebrazione e processione con il simulacro del SS. Crocifisso.",
    contacts: "Santuario SS. Crocifisso - Ufficio Turistico",
    website: "www.vivereapecchio.it/eventi",
    posterTitle: "SS. Crocifisso",
    posterSubtitle: "Fiera e processione",
    posterColors: [Color(0xFF5B3F32), Color(0xFFE8C07D)],
    icon: Icons.church_rounded,
  ),
  AppEvent(
    id: "feste_medievali",
    title: "Feste Medievali e Palio del Drago",
    category: "feste_tradizioni",
    dateLabel: "14 settembre",
    timeLabel: "Dalle 17:00",
    place: "Vie di Apecchio e Piazza S. Martino",
    description:
        "Corteo storico per le vie del borgo e Palio del Drago in piazza, a cura dell'Associazione ACURSA.",
    contacts: "Ass. ACURSA - Ufficio Turistico",
    website: "www.vivereapecchio.it/eventi",
    posterTitle: "Palio del Drago",
    posterSubtitle: "Feste Medievali",
    posterColors: [Color(0xFF5C1F1F), Color(0xFFD9A441)],
    icon: Icons.flag_rounded,
  ),
  AppEvent(
    id: "sagra_coradella",
    title: "Sagra della coradella d'agnello De.C.O.",
    category: "eventi_gastronomici",
    dateLabel: "19-20 luglio",
    timeLabel: "Weekend",
    place: "Serravalle di Carda",
    description:
        "Sagra dedicata a una ricetta De.C.O. del territorio, organizzata dalla Pro Loco Serravalle di Carda e Monte Nerone APS.",
    contacts: "Pro Loco Serravalle di Carda e Monte Nerone APS",
    website: "www.vivereapecchio.it/eventi",
    posterTitle: "Coradella",
    posterSubtitle: "Ricetta De.C.O.",
    posterColors: [Color(0xFF6B4F3A), Color(0xFFE4B56A)],
    icon: Icons.restaurant_rounded,
    bookingRewardPoints: 25,
    bookingActionLabel: "Prenota tavolo",
  ),
  AppEvent(
    id: "tank_fotografia",
    title: "Tank - Immagine analogica",
    category: "cultura_spettacoli",
    dateLabel: "18-19 ottobre",
    timeLabel: "Festival di fotografia",
    place: "Palazzo Ubaldini",
    description:
        "Festival di fotografia analogica ospitato a Palazzo Ubaldini, a cura dell'Associazione TERRAE.",
    contacts: "Associazione TERRAE",
    website: "www.vivereapecchio.it/eventi",
    posterTitle: "Tank",
    posterSubtitle: "Immagine analogica",
    posterColors: [Color(0xFF222831), Color(0xFFDDDDDD)],
    icon: Icons.camera_alt_rounded,
  ),
  AppEvent(
    id: "giro_italia_women",
    title: "Giro Italia Women - passaggio di tappa",
    category: "sport_outdoor",
    dateLabel: "Estate",
    timeLabel: "Passaggio tappa",
    place: "Serravalle di Carda e territorio",
    description:
        "Evento sportivo e di comunita collegato alla cura e al decoro del paese di Serravalle di Carda.",
    contacts: "Comune di Apecchio - Ufficio Turistico",
    website: "www.vivereapecchio.it/eventi",
    posterTitle: "Giro Women",
    posterSubtitle: "Territorio in corsa",
    posterColors: [Color(0xFFD81B60), Color(0xFFFFD166)],
    icon: Icons.directions_bike_rounded,
    bookingRewardPoints: 30,
    bookingActionLabel: "Prenota esperienza",
  ),
  AppEvent(
    id: "foraging_retreat",
    title: "Foraging retreat con Nerone Experience",
    category: "sport_outdoor",
    dateLabel: "21 aprile",
    timeLabel: "Esperienza outdoor",
    place: "Monte Nerone",
    description:
        "Proposta naturalistica segnalata da Apecchio.Net: uscita esperienziale tra erbe, paesaggio e conoscenza del territorio.",
    contacts: "Nerone Experience",
    website: "www.apecchio.net",
    posterTitle: "Foraging",
    posterSubtitle: "Nerone Experience",
    posterColors: [Color(0xFF2E7D57), Color(0xFFA7C957)],
    icon: Icons.forest_rounded,
  ),
  AppEvent(
    id: "liberazione",
    title: "Anniversario della Liberazione",
    category: "comunita_spiritualita",
    dateLabel: "25 aprile",
    timeLabel: "Cerimonie del mattino",
    place: "Serravalle di Carda e Apecchio",
    description:
        "Programma commemorativo segnalato da Apecchio.Net, con momenti pubblici presso monumenti e luoghi della memoria.",
    contacts: "Comune di Apecchio",
    website: "www.apecchio.net",
    posterTitle: "Liberazione",
    posterSubtitle: "Memoria civica",
    posterColors: [Color(0xFF1D3557), Color(0xFFE63946)],
    icon: Icons.flag_rounded,
  ),
  AppEvent(
    id: "festa_lavoro_circolo",
    title: "Festa del Lavoro al Circolo",
    category: "comunita_spiritualita",
    dateLabel: "1 maggio",
    timeLabel: "Programma del circolo",
    place: "Apecchio",
    description:
        "Appuntamento comunitario segnalato da Apecchio.Net per il primo maggio, utile nel feed notizie/eventi locali dell'app.",
    contacts: "Apecchio.Net - Comunita locale",
    website: "www.apecchio.net",
    posterTitle: "1 Maggio",
    posterSubtitle: "Festa al Circolo",
    posterColors: [Color(0xFF386641), Color(0xFFF2E8CF)],
    icon: Icons.groups_rounded,
  ),
];

class AppNotice {
  const AppNotice({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.kindLabel,
    required this.sourceLabel,
    required this.icon,
    required this.accentColor,
    this.imageAsset,
    this.imageUrl,
    this.highlighted = false,
  });

  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String kindLabel;
  final String sourceLabel;
  final IconData icon;
  final Color accentColor;
  final String? imageAsset;
  final String? imageUrl;
  final bool highlighted;

  bool get hasImage => imageAsset != null || imageUrl != null;
  String get dateLabel => _formatNoticeDate(date);
}

class NoticeController extends ChangeNotifier {
  NoticeController(List<AppNotice> notices) : _notices = List.of(notices) {
    _sortNotices();
  }

  factory NoticeController.demo() {
    final today = _dateOnly(DateTime.now());
    return NoticeController([
      AppNotice(
        id: "viabilita-centro",
        title: "Viabilita modificata in centro",
        description:
            "Dalle 9:00 alle 13:00 la circolazione nel tratto tra piazza San Martino e via XX Settembre viene regolata per lavori urgenti. Sono consigliati parcheggi esterni e accesso pedonale al centro storico.",
        date: today.add(const Duration(hours: 9)),
        kindLabel: "Viabilita",
        sourceLabel: "Comune di Apecchio",
        icon: Icons.traffic_rounded,
        accentColor: const Color(0xFFB5472F),
        imageAsset: "assets/images/appecchio_bg.png",
        highlighted: true,
      ),
      AppNotice(
        id: "raccolta-rifiuti",
        title: "Raccolta rifiuti anticipata",
        description:
            "Per festivita e mercato settimanale il passaggio della raccolta organico viene anticipato al mattino. Esporre i mastelli entro le 6:30 nella propria zona.",
        date: today.add(const Duration(days: 1)),
        kindLabel: "Ambiente",
        sourceLabel: "Ufficio Ambiente",
        icon: Icons.recycling_rounded,
        accentColor: const Color(0xFF2E7D57),
      ),
      AppNotice(
        id: "acqua-pianello",
        title: "Possibile calo pressione acqua",
        description:
            "Intervento programmato sulla rete idrica in localita Pianello. Durante la manutenzione possono verificarsi cali di pressione e brevi interruzioni.",
        date: today.add(const Duration(days: 3)),
        kindLabel: "Servizi",
        sourceLabel: "Servizi tecnici",
        icon: Icons.water_drop_rounded,
        accentColor: const Color(0xFF2D6F88),
      ),
      AppNotice(
        id: "biblioteca-orario",
        title: "Biblioteca aperta nel pomeriggio",
        description:
            "Apertura straordinaria della biblioteca comunale con spazio studio, prestito libri e supporto per consultare i servizi digitali del Comune.",
        date: today.add(const Duration(days: 5)),
        kindLabel: "Comunita",
        sourceLabel: "Biblioteca comunale",
        icon: Icons.local_library_rounded,
        accentColor: const Color(0xFF6E4AA0),
      ),
    ]);
  }

  final List<AppNotice> _notices;

  List<AppNotice> get notices => List.unmodifiable(_notices);

  List<AppNotice> get todayNotices {
    final today = _dateOnly(DateTime.now());
    return _notices
        .where((notice) => _sameDay(notice.date, today))
        .toList(growable: false);
  }

  AppNotice? get leadingNotice {
    if (_notices.isEmpty) {
      return null;
    }
    for (final notice in _notices) {
      if (notice.highlighted) {
        return notice;
      }
    }
    return _notices.first;
  }

  void addNotice({
    required String title,
    required String description,
    required DateTime date,
    String? imageAsset,
    String? imageUrl,
  }) {
    _notices.add(
      AppNotice(
        id: "notice-${DateTime.now().microsecondsSinceEpoch}",
        title: title,
        description: description,
        date: _dateOnly(date),
        kindLabel: "Segnalazione",
        sourceLabel: "Inviata dall'app",
        icon: Icons.report_problem_rounded,
        accentColor: const Color(0xFFB5472F),
        imageAsset: imageAsset,
        imageUrl: imageUrl,
        highlighted: true,
      ),
    );
    _sortNotices();
    notifyListeners();
  }

  void _sortNotices() {
    _notices.sort((a, b) => b.date.compareTo(a.date));
  }
}

class NoticesArchiveScreen extends StatelessWidget {
  const NoticesArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F1),
        title: const Text("Archivio avvisi"),
      ),
      body: AnimatedBuilder(
        animation: appNotices,
        builder: (context, _) {
          final notices = appNotices.notices;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              _NoticeArchiveHeader(
                noticeCount: notices.length,
                onOpenCalendar: () => _openCalendar(context),
                onCreateNotice: () => _openReport(context),
              ),
              const SizedBox(height: 18),
              const Text(
                "Tutti gli avvisi",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              for (final notice in notices)
                _NoticeArchiveTile(
                  notice: notice,
                  onTap: () => _openDetail(context, notice),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openCalendar(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const NoticeCalendarScreen()),
    );
  }

  Future<void> _openReport(BuildContext context) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const NoticeReportScreen()),
    );
    if (added == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Segnalazione salvata negli avvisi.")),
      );
    }
  }

  void _openDetail(BuildContext context, AppNotice notice) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NoticeDetailScreen(notice: notice),
      ),
    );
  }
}

class _NoticeArchiveHeader extends StatelessWidget {
  const _NoticeArchiveHeader({
    required this.noticeCount,
    required this.onOpenCalendar,
    required this.onCreateNotice,
  });

  final int noticeCount;
  final VoidCallback onOpenCalendar;
  final VoidCallback onCreateNotice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF203B2C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton.filledTonal(
                onPressed: onOpenCalendar,
                tooltip: "Apri calendario avvisi",
                icon: const Icon(Icons.calendar_month_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF203B2C),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Avvisi e segnalazioni",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$noticeCount elementi archiviati con data, descrizione e dettagli.",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCreateNotice,
              icon: const Icon(Icons.add_alert_rounded),
              label: const Text("Nuova segnalazione"),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFFCF5A),
                foregroundColor: const Color(0xFF203B2C),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeArchiveTile extends StatelessWidget {
  const _NoticeArchiveTile({required this.notice, required this.onTap});

  final AppNotice notice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: notice.highlighted ? const Color(0xFFFFF3CF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _NoticeThumb(notice: notice),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${notice.dateLabel} · ${notice.kindLabel}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notice.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(height: 1.25),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoticeThumb extends StatelessWidget {
  const _NoticeThumb({required this.notice});

  final AppNotice notice;

  @override
  Widget build(BuildContext context) {
    if (notice.imageAsset != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          notice.imageAsset!,
          width: 58,
          height: 58,
          fit: BoxFit.cover,
        ),
      );
    }
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: notice.accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(notice.icon, color: notice.accentColor),
    );
  }
}

class NoticeCalendarScreen extends StatefulWidget {
  const NoticeCalendarScreen({super.key});

  @override
  State<NoticeCalendarScreen> createState() => _NoticeCalendarScreenState();
}

class _NoticeCalendarScreenState extends State<NoticeCalendarScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _focusedMonth = DateTime(today.year, today.month);
    _selectedDay = today;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F1),
        title: const Text("Calendario avvisi"),
      ),
      body: AnimatedBuilder(
        animation: appNotices,
        builder: (context, _) {
          final notices = appNotices.notices;
          final selectedNotices = _noticesForDay(_selectedDay, notices);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              _NoticeMonthCalendar(
                focusedMonth: _focusedMonth,
                selectedDay: _selectedDay,
                notices: notices,
                onPreviousMonth: () => setState(
                  () => _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month - 1,
                  ),
                ),
                onNextMonth: () => setState(
                  () => _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month + 1,
                  ),
                ),
                onDaySelected: (day) => setState(() {
                  _selectedDay = day;
                  _focusedMonth = DateTime(day.year, day.month);
                }),
              ),
              const SizedBox(height: 14),
              _SelectedDayNoticesPanel(
                day: _selectedDay,
                notices: selectedNotices,
                onNoticeTap: (notice) => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => NoticeDetailScreen(notice: notice),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NoticeMonthCalendar extends StatelessWidget {
  const _NoticeMonthCalendar({
    required this.focusedMonth,
    required this.selectedDay,
    required this.notices,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDaySelected,
  });

  final DateTime focusedMonth;
  final DateTime selectedDay;
  final List<AppNotice> notices;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final days = _calendarDays(focusedMonth);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE1E8DD)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: "Mese precedente",
              ),
              Expanded(
                child: Text(
                  _formatMonthYear(focusedMonth),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: "Mese successivo",
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final label in [
                "Lun",
                "Mar",
                "Mer",
                "Gio",
                "Ven",
                "Sab",
                "Dom",
              ])
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.90,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              return _NoticeCalendarDayCell(
                day: day,
                inMonth: _sameMonth(day, focusedMonth),
                selected: _sameDay(day, selectedDay),
                notices: _noticesForDay(day, notices),
                onTap: () => onDaySelected(day),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NoticeCalendarDayCell extends StatelessWidget {
  const _NoticeCalendarDayCell({
    required this.day,
    required this.inMonth,
    required this.selected,
    required this.notices,
    required this.onTap,
  });

  final DateTime day;
  final bool inMonth;
  final bool selected;
  final List<AppNotice> notices;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasNotices = notices.isNotEmpty;
    final highlighted = notices.any((notice) => notice.highlighted);
    return Material(
      color: selected
          ? const Color(0xFFE4F2E8)
          : highlighted
              ? const Color(0xFFFFF3CF)
              : inMonth
                  ? const Color(0xFFFAFCF7)
                  : const Color(0xFFF1F2EE),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2E7D57)
                  : hasNotices
                      ? const Color(0xFFC9A13A)
                      : const Color(0xFFE7ECE2),
              width: selected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "${day.day}",
                  style: TextStyle(
                    color: inMonth ? Colors.black87 : Colors.black38,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (hasNotices)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      Icon(
                        highlighted
                            ? Icons.campaign_rounded
                            : Icons.circle_rounded,
                        color: highlighted
                            ? const Color(0xFF9A5A00)
                            : const Color(0xFF2E7D57),
                        size: highlighted ? 16 : 9,
                      ),
                      if (notices.length > 1) ...[
                        const SizedBox(width: 3),
                        Text(
                          "${notices.length}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedDayNoticesPanel extends StatelessWidget {
  const _SelectedDayNoticesPanel({
    required this.day,
    required this.notices,
    required this.onNoticeTap,
  });

  final DateTime day;
  final List<AppNotice> notices;
  final ValueChanged<AppNotice> onNoticeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1E8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDayLong(day),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (notices.isEmpty)
            const Text(
              "Nessun avviso per questa giornata.",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            for (final notice in notices)
              _SelectedDayNoticeRow(
                notice: notice,
                onTap: () => onNoticeTap(notice),
              ),
        ],
      ),
    );
  }
}

class _SelectedDayNoticeRow extends StatelessWidget {
  const _SelectedDayNoticeRow({required this.notice, required this.onTap});

  final AppNotice notice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: notice.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(notice.icon, color: notice.accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notice.kindLabel,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoticeDetailScreen extends StatelessWidget {
  const NoticeDetailScreen({super.key, required this.notice});

  final AppNotice notice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F1),
        title: const Text("Dettaglio avviso"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _NoticeHero(notice: notice),
          const SizedBox(height: 18),
          Text(
            notice.title,
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _NoticeInfoRow(
            icon: Icons.calendar_month_rounded,
            text: notice.dateLabel,
          ),
          _NoticeInfoRow(icon: notice.icon, text: notice.kindLabel),
          _NoticeInfoRow(
            icon: Icons.verified_rounded,
            text: notice.sourceLabel,
          ),
          const SizedBox(height: 16),
          _NoticeDetailSection(title: "Descrizione", body: notice.description),
          const _NoticeDetailSection(
            title: "Aggiornamenti",
            body:
                "La scheda resta collegata alle notifiche e al calendario degli avvisi, cosi ogni aggiornamento conserva data, contesto e archivio.",
          ),
        ],
      ),
    );
  }
}

class _NoticeHero extends StatelessWidget {
  const _NoticeHero({required this.notice});

  final AppNotice notice;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: SizedBox(
        height: 236,
        child: Stack(
          children: [
            Positioned.fill(child: _NoticeHeroBackground(notice: notice)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.62),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      notice.dateLabel,
                      style: TextStyle(
                        color: notice.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    notice.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeHeroBackground extends StatelessWidget {
  const _NoticeHeroBackground({required this.notice});

  final AppNotice notice;

  @override
  Widget build(BuildContext context) {
    if (notice.imageAsset != null) {
      return Image.asset(notice.imageAsset!, fit: BoxFit.cover);
    }
    if (notice.imageUrl != null) {
      return Image.network(
        notice.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _NoticeGradientBackground(notice: notice),
      );
    }
    return _NoticeGradientBackground(notice: notice);
  }
}

class _NoticeGradientBackground extends StatelessWidget {
  const _NoticeGradientBackground({required this.notice});

  final AppNotice notice;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [notice.accentColor, const Color(0xFF203B2C)],
        ),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Icon(
            notice.icon,
            color: Colors.white.withValues(alpha: 0.42),
            size: 82,
          ),
        ),
      ),
    );
  }
}

class _NoticeInfoRow extends StatelessWidget {
  const _NoticeInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2E7D57)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeDetailSection extends StatelessWidget {
  const _NoticeDetailSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(height: 1.35)),
        ],
      ),
    );
  }
}

class NoticeReportScreen extends StatefulWidget {
  const NoticeReportScreen({super.key});

  @override
  State<NoticeReportScreen> createState() => _NoticeReportScreenState();
}

class _NoticeReportScreenState extends State<NoticeReportScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  DateTime _selectedDate = _dateOnly(DateTime.now());

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F1),
        title: const Text("Nuova segnalazione"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "Titolo",
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Inserisci un titolo";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: "Descrizione",
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Inserisci una descrizione";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: Text(_formatNoticeDate(_selectedDate)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _imageController,
                    decoration: const InputDecoration(
                      labelText: "Immagine opzionale",
                      hintText: "URL o assets/images/appecchio_bg.png",
                      prefixIcon: Icon(Icons.image_rounded),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text("Salva segnalazione"),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D57),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = _dateOnly(picked));
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final imageValue = _imageController.text.trim();
    final imageAsset = imageValue.startsWith("assets/") ? imageValue : null;
    final imageUrl =
        imageValue.isNotEmpty && imageAsset == null ? imageValue : null;
    appNotices.addNotice(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      imageAsset: imageAsset,
      imageUrl: imageUrl,
    );
    Navigator.of(context).pop(true);
  }
}

List<AppNotice> _noticesForDay(DateTime day, List<AppNotice> notices) {
  return notices
      .where((notice) => _sameDay(notice.date, day))
      .toList(growable: false);
}

String _formatNoticeDate(DateTime date) {
  return "${date.day} ${_monthName(date.month)} ${date.year}";
}

String _formatNoticeShortDate(DateTime date) {
  final today = _dateOnly(DateTime.now());
  final tomorrow = today.add(const Duration(days: 1));
  if (_sameDay(date, today)) {
    return "Oggi";
  }
  if (_sameDay(date, tomorrow)) {
    return "Domani";
  }
  const months = [
    "gen",
    "feb",
    "mar",
    "apr",
    "mag",
    "giu",
    "lug",
    "ago",
    "set",
    "ott",
    "nov",
    "dic",
  ];
  return "${date.day} ${months[date.month - 1]}";
}

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, this.initialFilter});

  final String? initialFilter;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late String _selectedFilter;
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  static const Map<String, String> _filters = {
    "tutti": "Tutti",
    "feste_tradizioni": "Feste e tradizioni",
    "eventi_gastronomici": "Eventi gastronomici",
    "cultura_spettacoli": "Cultura e spettacoli",
    "mostre": "Mostre",
    "sport_outdoor": "Sport e outdoor",
    "comunita_spiritualita": "Comunita e spiritualita",
  };

  @override
  void initState() {
    super.initState();
    _selectedFilter = _filters.containsKey(widget.initialFilter)
        ? widget.initialFilter!
        : "tutti";
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = _dateOnly(now);
  }

  @override
  Widget build(BuildContext context) {
    final events = _selectedFilter == "tutti"
        ? _mockEvents
        : _mockEvents
            .where((event) => event.category == _selectedFilter)
            .toList(growable: false);
    final selectedDayEvents = _eventsForDay(_selectedDay, events);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F1),
        title: const Text("Calendario eventi"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _EventsHeader(),
          const SizedBox(height: 16),
          _EventFilterBar(
            filters: _filters,
            selectedFilter: _selectedFilter,
            onChanged: (value) => setState(() => _selectedFilter = value),
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: appEventParticipation,
            builder: (context, _) {
              return _EventMonthCalendar(
                focusedMonth: _focusedMonth,
                selectedDay: _selectedDay,
                events: events,
                participation: appEventParticipation,
                onPreviousMonth: () => setState(
                  () => _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month - 1,
                  ),
                ),
                onNextMonth: () => setState(
                  () => _focusedMonth = DateTime(
                    _focusedMonth.year,
                    _focusedMonth.month + 1,
                  ),
                ),
                onDaySelected: (day) => setState(() {
                  _selectedDay = day;
                  _focusedMonth = DateTime(day.year, day.month);
                }),
              );
            },
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: appEventParticipation,
            builder: (context, _) {
              return _SelectedDayEventsPanel(
                day: _selectedDay,
                events: selectedDayEvents,
                participation: appEventParticipation,
                onEventTap: _openEventDetail,
                onParticipationChanged: (event) =>
                    appEventParticipation.toggle(event),
              );
            },
          ),
          const SizedBox(height: 22),
          Text(
            _selectedFilter == "tutti"
                ? "In evidenza"
                : _filters[_selectedFilter]!,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 314,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final event = events[index];
                return AnimatedBuilder(
                  animation: appEventParticipation,
                  builder: (context, _) {
                    return _EventPosterCard(
                      event: event,
                      joined: appEventParticipation.isJoined(event),
                      onTap: () => _openEventDetail(event),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            "Prossimi appuntamenti",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (final event in events)
            AnimatedBuilder(
              animation: appEventParticipation,
              builder: (context, _) {
                return _EventListTile(
                  event: event,
                  joined: appEventParticipation.isJoined(event),
                  onTap: () => _openEventDetail(event),
                );
              },
            ),
        ],
      ),
    );
  }

  void _openEventDetail(AppEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => EventDetailScreen(event: event)),
    );
  }
}

class _EventsHeader extends StatelessWidget {
  const _EventsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF203B2C),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Eventi ad AppEcchio",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Calendario, locandine e dettagli utili in un unico posto.",
            style: TextStyle(
              color: Color(0xFFDCE9DD),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventFilterBar extends StatelessWidget {
  const _EventFilterBar({
    required this.filters,
    required this.selectedFilter,
    required this.onChanged,
  });

  final Map<String, String> filters;
  final String selectedFilter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final entry in filters.entries) ...[
            ChoiceChip(
              label: Text(entry.value),
              selected: selectedFilter == entry.key,
              selectedColor: const Color(0xFF2E7D57),
              labelStyle: TextStyle(
                color: selectedFilter == entry.key
                    ? Colors.white
                    : const Color(0xFF1B2E21),
                fontWeight: FontWeight.w800,
              ),
              onSelected: (_) => onChanged(entry.key),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

List<DateTime> _calendarDays(DateTime month) {
  final first = DateTime(month.year, month.month);
  final leadingDays = first.weekday - DateTime.monday;
  final start = first.subtract(Duration(days: leadingDays));
  return List<DateTime>.generate(
    42,
    (index) => _dateOnly(start.add(Duration(days: index))),
  );
}

List<AppEvent> _eventsForDay(DateTime day, List<AppEvent> events) {
  return events
      .where((event) => _eventDates(event).any((date) => _sameDay(date, day)))
      .toList(growable: false);
}

Color _eventCategoryColor(String category) {
  switch (category) {
    case "feste_tradizioni":
      return const Color(0xFFB5472F);
    case "eventi_gastronomici":
      return const Color(0xFFC9902E);
    case "cultura_spettacoli":
      return const Color(0xFF6E4AA0);
    case "mostre":
      return const Color(0xFF2D6F88);
    case "sport_outdoor":
      return const Color(0xFF2E7D57);
    case "comunita_spiritualita":
      return const Color(0xFF536B2F);
    default:
      return const Color(0xFF52615A);
  }
}

String _formatMonthYear(DateTime month) {
  return "${_capitalize(_monthName(month.month))} ${month.year}";
}

String _formatDayLong(DateTime day) {
  return "${day.day} ${_monthName(day.month)} ${day.year}";
}

String _capitalize(String value) {
  if (value.isEmpty) {
    return value;
  }
  return value[0].toUpperCase() + value.substring(1);
}

String _monthName(int month) {
  const names = [
    "gennaio",
    "febbraio",
    "marzo",
    "aprile",
    "maggio",
    "giugno",
    "luglio",
    "agosto",
    "settembre",
    "ottobre",
    "novembre",
    "dicembre",
  ];
  return names[(month - 1).clamp(0, 11).toInt()];
}

List<DateTime> _eventDates(AppEvent event) {
  final year = DateTime.now().year;
  switch (event.id) {
    case "tartufo_birra_osterie":
      return _dateRange(DateTime(year, 10, 3), DateTime(year, 10, 5));
    case "rembrandt_barocci":
      return _dateRange(DateTime(2025, 6, 8), DateTime(2025, 9, 7));
    case "museo_fossili_minerali":
      return List<DateTime>.generate(12, (index) => DateTime(year, index + 1));
    case "torneo_tennis_birra":
      return [
        DateTime(year, 6, 1),
        DateTime(year, 6, 8),
        DateTime(year, 6, 15),
        DateTime(year, 6, 22),
      ];
    case "estate_musicale":
      return [
        DateTime(year, 7, 16),
        DateTime(year, 7, 23),
        DateTime(year, 7, 30),
      ];
    case "passio":
      return [_easterSunday(year).subtract(const Duration(days: 2))];
    case "fiera_ss_crocifisso":
      return _dateRange(DateTime(year, 6, 1), DateTime(year, 6, 3));
    case "feste_medievali":
      return [DateTime(year, 9, 14)];
    case "sagra_coradella":
      return _dateRange(DateTime(year, 7, 19), DateTime(year, 7, 20));
    case "tank_fotografia":
      return _dateRange(DateTime(year, 10, 18), DateTime(year, 10, 19));
    case "giro_italia_women":
      return [DateTime(year, 7, 7)];
    case "foraging_retreat":
      return [DateTime(year, 4, 21)];
    case "liberazione":
      return [DateTime(year, 4, 25)];
    case "festa_lavoro_circolo":
      return [DateTime(year, 5, 1)];
    default:
      return const <DateTime>[];
  }
}

List<DateTime> _dateRange(DateTime start, DateTime end) {
  final normalizedStart = _dateOnly(start);
  final normalizedEnd = _dateOnly(end);
  final length = normalizedEnd.difference(normalizedStart).inDays + 1;
  if (length <= 0) {
    return [normalizedStart];
  }
  return List<DateTime>.generate(
    length,
    (index) => normalizedStart.add(Duration(days: index)),
  );
}

DateTime _easterSunday(int year) {
  final a = year % 19;
  final b = year ~/ 100;
  final c = year % 100;
  final d = b ~/ 4;
  final e = b % 4;
  final f = (b + 8) ~/ 25;
  final g = (b - f + 1) ~/ 3;
  final h = (19 * a + b - d - g + 15) % 30;
  final i = c ~/ 4;
  final k = c % 4;
  final l = (32 + 2 * e + 2 * i - h - k) % 7;
  final m = (a + 11 * h + 22 * l) ~/ 451;
  final month = (h + l - 7 * m + 114) ~/ 31;
  final day = ((h + l - 7 * m + 114) % 31) + 1;
  return DateTime(year, month, day);
}

class _EventMonthCalendar extends StatelessWidget {
  const _EventMonthCalendar({
    required this.focusedMonth,
    required this.selectedDay,
    required this.events,
    required this.participation,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDaySelected,
  });

  final DateTime focusedMonth;
  final DateTime selectedDay;
  final List<AppEvent> events;
  final EventParticipationController participation;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final days = _calendarDays(focusedMonth);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE1E8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: onPreviousMonth,
                icon: const Icon(Icons.chevron_left_rounded),
                tooltip: "Mese precedente",
              ),
              Expanded(
                child: Text(
                  _formatMonthYear(focusedMonth),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded),
                tooltip: "Mese successivo",
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final label in [
                "Lun",
                "Mar",
                "Mer",
                "Gio",
                "Ven",
                "Sab",
                "Dom",
              ])
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              final day = days[index];
              final dayEvents = _eventsForDay(day, events);
              final inMonth = _sameMonth(day, focusedMonth);
              final selected = _sameDay(day, selectedDay);
              final joined = dayEvents.any(
                (event) => participation.isJoined(event),
              );
              return _CalendarDayCell(
                day: day,
                inMonth: inMonth,
                selected: selected,
                joined: joined,
                events: dayEvents,
                onTap: () => onDaySelected(day),
              );
            },
          ),
          const SizedBox(height: 12),
          const _EventCalendarLegend(filters: _EventsScreenState._filters),
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.inMonth,
    required this.selected,
    required this.joined,
    required this.events,
    required this.onTap,
  });

  final DateTime day;
  final bool inMonth;
  final bool selected;
  final bool joined;
  final List<AppEvent> events;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final eventCount = events.length;
    final bgColor = selected
        ? const Color(0xFFE4F2E8)
        : joined
            ? const Color(0xFFEAF5EA)
            : inMonth
                ? const Color(0xFFFAFCF7)
                : const Color(0xFFF1F2EE);
    final borderColor = selected
        ? const Color(0xFF2E7D57)
        : joined
            ? const Color(0xFF78A65D)
            : eventCount > 0
                ? const Color(0xFFCAD8C7)
                : const Color(0xFFE7ECE2);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "${day.day}",
                  style: TextStyle(
                    color: inMonth ? Colors.black87 : Colors.black38,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (eventCount > 1)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 19,
                    constraints: const BoxConstraints(minWidth: 19),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF263E2B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "$eventCount",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              if (joined)
                const Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF2E7D57),
                    size: 18,
                  ),
                ),
              Align(
                alignment: Alignment.bottomLeft,
                child: _OverlappingEventMarks(events: events),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlappingEventMarks extends StatelessWidget {
  const _OverlappingEventMarks({required this.events});

  final List<AppEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }
    final visible = events.take(4).toList(growable: false);
    return SizedBox(
      width: 42,
      height: 16,
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * 8,
              bottom: 0,
              child: Container(
                width: 22,
                height: 6,
                decoration: BoxDecoration(
                  color: _eventCategoryColor(visible[i].category),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EventCalendarLegend extends StatelessWidget {
  const _EventCalendarLegend({required this.filters});

  final Map<String, String> filters;

  @override
  Widget build(BuildContext context) {
    final entries = filters.entries.where((entry) => entry.key != "tutti");
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final entry in entries)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: _eventCategoryColor(entry.key).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _eventCategoryColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  entry.value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SelectedDayEventsPanel extends StatelessWidget {
  const _SelectedDayEventsPanel({
    required this.day,
    required this.events,
    required this.participation,
    required this.onEventTap,
    required this.onParticipationChanged,
  });

  final DateTime day;
  final List<AppEvent> events;
  final EventParticipationController participation;
  final ValueChanged<AppEvent> onEventTap;
  final ValueChanged<AppEvent> onParticipationChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE1E8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDayLong(day),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (events.isEmpty)
            const Text(
              "Nessun evento marcato per questa giornata.",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            for (final event in events)
              _SelectedDayEventRow(
                event: event,
                joined: participation.isJoined(event),
                onOpen: () => onEventTap(event),
                onParticipationChanged: () => onParticipationChanged(event),
              ),
        ],
      ),
    );
  }
}

class _SelectedDayEventRow extends StatelessWidget {
  const _SelectedDayEventRow({
    required this.event,
    required this.joined,
    required this.onOpen,
    required this.onParticipationChanged,
  });

  final AppEvent event;
  final bool joined;
  final VoidCallback onOpen;
  final VoidCallback onParticipationChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _eventCategoryColor(event.category).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 54,
            decoration: BoxDecoration(
              color: _eventCategoryColor(event.category),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onOpen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    event.timeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onParticipationChanged,
            child: Text(joined ? "Partecipo" : "Partecipa"),
          ),
        ],
      ),
    );
  }
}

class _EventPosterCard extends StatelessWidget {
  const _EventPosterCard({
    required this.event,
    required this.joined,
    required this.onTap,
  });

  final AppEvent event;
  final bool joined;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: EventPoster(event: event)),
            const SizedBox(height: 10),
            if (joined) ...[
              const _ParticipationPill(compact: true),
              const SizedBox(height: 6),
            ],
            Text(
              event.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            Text(
              "${event.dateLabel} · ${event.place}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class EventPoster extends StatelessWidget {
  const EventPoster({
    super.key,
    required this.event,
    this.compact = false,
    this.micro = false,
  });

  final AppEvent event;
  final bool compact;
  final bool micro;

  @override
  Widget build(BuildContext context) {
    if (micro) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: event.posterColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(event.icon, color: Colors.white, size: 24),
      );
    }

    return AspectRatio(
      aspectRatio: compact ? 1.35 : 0.72,
      child: Container(
        padding: EdgeInsets.all(compact ? 16 : 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: event.posterColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(compact ? 22 : 18),
          boxShadow: [
            BoxShadow(
              color: event.posterColors.first.withValues(alpha: 0.30),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                event.icon,
                color: Colors.white.withValues(alpha: 0.55),
                size: compact ? 46 : 54,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.dateLabel.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.posterTitle,
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 30 : 34,
                    height: 0.98,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.posterSubtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EventListTile extends StatelessWidget {
  const _EventListTile({
    required this.event,
    required this.joined,
    required this.onTap,
  });

  final AppEvent event;
  final bool joined;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: SizedBox(
          width: 54,
          height: 54,
          child: EventPoster(event: event, micro: true),
        ),
        title: Text(
          event.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          "${event.dateLabel} · ${event.timeLabel}\n${event.place}",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: joined
            ? const _ParticipationPill(compact: true)
            : const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _ParticipationPill extends StatelessWidget {
  const _ParticipationPill({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D57),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_rounded,
            size: compact ? 13 : 15,
            color: Colors.white,
          ),
          SizedBox(width: compact ? 3 : 5),
          Text(
            compact ? "Si" : "Partecipo",
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.event});

  final AppEvent event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7F1),
        title: Text(event.categoryLabel),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          EventPoster(event: event, compact: true),
          const SizedBox(height: 20),
          Text(
            event.title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          _EventInfoRow(icon: Icons.schedule_rounded, text: event.timeLabel),
          _EventInfoRow(
            icon: Icons.calendar_month_rounded,
            text: event.dateLabel,
          ),
          _EventInfoRow(icon: Icons.place_rounded, text: event.place),
          const SizedBox(height: 18),
          _EventParticipationCard(event: event),
          _EventDetailSection(title: "Descrizione", body: event.description),
          _EventDetailSection(title: "Riferimenti", body: event.contacts),
          _EventDetailSection(title: "Sito web", body: event.website),
          if (event.bookingRewardPoints > 0)
            _EventBookingRewardCard(event: event),
          _EventCheckinRewardCard(event: event),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Aprirebbe ${event.website}")),
              );
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text("Apri sito web"),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D57),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventParticipationCard extends StatelessWidget {
  const _EventParticipationCard({required this.event});

  final AppEvent event;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appEventParticipation,
      builder: (context, _) {
        final joined = appEventParticipation.isJoined(event);
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: joined
                ? _eventCategoryColor(event.category).withValues(alpha: 0.14)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: joined
                  ? _eventCategoryColor(event.category)
                  : const Color(0xFFE1E8DD),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _eventCategoryColor(event.category),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  joined
                      ? Icons.check_circle_rounded
                      : Icons.event_available_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      joined
                          ? "Partecipazione salvata"
                          : "Segna partecipazione",
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      joined
                          ? "Il giorno dell'evento resta evidenziato nel calendario."
                          : "Il calendario colorera' il riquadro della giornata.",
                      style: const TextStyle(height: 1.25),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: () {
                  appEventParticipation.toggle(event);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        joined
                            ? "Partecipazione rimossa dal calendario."
                            : "Partecipazione aggiunta al calendario.",
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: joined
                      ? const Color(0xFF55615B)
                      : const Color(0xFF2E7D57),
                ),
                child: Text(joined ? "Rimuovi" : "Partecipa"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EventCheckinRewardCard extends StatelessWidget {
  const _EventCheckinRewardCard({required this.event});

  final AppEvent event;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appGamification,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE1E8DD)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Check-in ricompensa",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                "Genera il QR evento e simula la scansione staff per accreditare 120 token una sola volta.",
                style: TextStyle(height: 1.35),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7F1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: CustomPaint(painter: _MockQrPainter(seed: event.id)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        final awarded = appGamification.recordEventCheckin(
                          event,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              awarded
                                  ? "Check-in valido: +120 token accreditati."
                                  : "Check-in gia registrato per questo evento.",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text("Simula scansione"),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D57),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EventBookingRewardCard extends StatelessWidget {
  const _EventBookingRewardCard({required this.event});

  final AppEvent event;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appGamification,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFE0A3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Prenotazione: +${event.bookingRewardPoints} token",
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                "La prenotazione da app crea un movimento nel wallet. Il check-in staff, quando previsto, resta separato.",
                style: TextStyle(height: 1.35),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  final awarded = appGamification.recordBooking(
                    sourceId: "event:${event.id}",
                    label: "${event.bookingActionLabel}: ${event.title}",
                    points: event.bookingRewardPoints,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        awarded
                            ? "${event.bookingActionLabel} confermata: +${event.bookingRewardPoints} token."
                            : "Prenotazione gia registrata per questa attivita.",
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.event_available_rounded),
                label: Text(event.bookingActionLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF8A6400),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MockQrPainter extends CustomPainter {
  const _MockQrPainter({required this.seed});

  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF203B2C);
    final cell = size.width / 7;
    for (var row = 0; row < 7; row += 1) {
      for (var col = 0; col < 7; col += 1) {
        final code = seed.codeUnitAt((row + col) % seed.length);
        final finder =
            row < 2 && col < 2 || row < 2 && col > 4 || row > 4 && col < 2;
        if (finder || (code + row + col).isEven) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(col * cell + 3, row * cell + 3, cell - 6, cell - 6),
              const Radius.circular(2),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MockQrPainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}

extension on AppEvent {
  String get categoryLabel {
    switch (category) {
      case "feste_tradizioni":
        return "Feste e tradizioni";
      case "eventi_gastronomici":
        return "Eventi gastronomici";
      case "cultura_spettacoli":
        return "Cultura e spettacoli";
      case "mostre":
        return "Mostre";
      case "sport_outdoor":
        return "Sport e outdoor";
      case "comunita_spiritualita":
        return "Comunita e spiritualita";
      default:
        return "Evento";
    }
  }
}

class _EventInfoRow extends StatelessWidget {
  const _EventInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2E7D57)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventDetailSection extends StatelessWidget {
  const _EventDetailSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(height: 1.35)),
        ],
      ),
    );
  }
}

class LocalProduct {
  const LocalProduct({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.season,
    required this.whereToBuy,
    required this.sourceLabel,
    required this.highlights,
    required this.colors,
    required this.icon,
  });

  final String id;
  final String title;
  final String subtitle;
  final String season;
  final String whereToBuy;
  final String sourceLabel;
  final List<String> highlights;
  final List<Color> colors;
  final IconData icon;
}

const List<LocalProduct> _localProducts = [
  LocalProduct(
    id: "prodotto_tartufo",
    title: "Tartufo",
    subtitle: "Oro bianco, nero pregiato, bianchetto e nero estivo.",
    season:
        "Bianco: ultima domenica di settembre - 31 dicembre. Nero pregiato: 1 dicembre - 15 marzo. Bianchetto: 15 gennaio - 30 aprile. Nero estivo: 1 giugno - 31 dicembre.",
    whereToBuy:
        "Stand della Mostra Mercato nel primo weekend di ottobre, commercianti di tartufo fresco, ristoranti e osterie aderenti. Per contatti aggiornati: Ufficio Turistico in piazza San Martino.",
    sourceLabel: "Fonte: Vivere Apecchio Gusto / Tartufo e Birra",
    highlights: [
      "Territorio vocato alla produzione di tartufi in ogni stagione",
      "Mostra Mercato del Tartufo nel centro storico",
      "Abbinamenti con birra artigianale e prodotti del bosco",
    ],
    colors: [Color(0xFF3B2F2A), Color(0xFFD8B45D)],
    icon: Icons.spa_rounded,
  ),
  LocalProduct(
    id: "prodotto_birra",
    title: "Birra artigianale",
    subtitle: "La vocazione brassicola di Apecchio, Citta della Birra.",
    season:
        "Tutto l'anno. Picco di visibilita durante Tartufo & Birra e negli itinerari delle Strade della Birra.",
    whereToBuy:
        "Birrifici artigianali locali, ristoranti aderenti all'alogastronomia e stand degli eventi. Riferimenti di territorio: Amarcord, Tenute Collesi e Ufficio Turistico.",
    sourceLabel: "Fonte: Vivere Apecchio Tartufo e Birra",
    highlights: [
      "Apecchio e riconosciuta come prima Citta della Birra Italiana",
      "Acqua del Monte Nerone e orzo locale nella narrazione brassicola",
      "Prodotto centrale per percorsi di gusto e alogastronomia",
    ],
    colors: [Color(0xFF51331D), Color(0xFFF0A33A)],
    icon: Icons.sports_bar_rounded,
  ),
  LocalProduct(
    id: "tartufo_birra",
    title: "Alogastronomia",
    subtitle: "Il legame tra birra artigianale, cucina locale e tartufo.",
    season:
        "Tutto l'anno nei ristoranti aderenti; esperienza diffusa nelle osterie temporanee del primo weekend di ottobre.",
    whereToBuy:
        "Ristoranti con adesivo Alogastronomia, osterie del centro storico durante Tartufo & Birra, calendario eventi gastronomici dell'app.",
    sourceLabel: "Fonte: Vivere Apecchio Gusto",
    highlights: [
      "Abbinamento identitario tra birra, tartufo e prodotti locali",
      "Percorsi di gusto collegati a cultura, artigianato e ambiente",
      "Ponte naturale tra Food & Drink ed Eventi gastronomici",
    ],
    colors: [Color(0xFF253C2A), Color(0xFFC9902E)],
    icon: Icons.local_bar_rounded,
  ),
  LocalProduct(
    id: "tipicita_deco",
    title: "Tipicita De.C.O.",
    subtitle: "Ricette comunali e prodotti del bosco da valorizzare.",
    season:
        "Ricette De.C.O. tutto l'anno. Funghi e prodotti del bosco seguono raccolta e disponibilita stagionale.",
    whereToBuy:
        "Ristoranti del territorio, sagre di frazione, botteghe e alimentari locali. Per eventi dedicati: categoria Eventi gastronomici.",
    sourceLabel: "Fonte: Vivere Apecchio Gusto",
    highlights: [
      "Salmi del Prete, Bostrengo e Coradella d'Agnello",
      "Schede utili per prenotare tavolo o degustazione",
      "Rimando a sagre, ristoranti e produttori locali",
    ],
    colors: [Color(0xFF6B4F3A), Color(0xFFE4B56A)],
    icon: Icons.verified_rounded,
  ),
];

class LocalProductsScreen extends StatefulWidget {
  const LocalProductsScreen({super.key, required this.initialProductId});

  final String initialProductId;

  @override
  State<LocalProductsScreen> createState() => _LocalProductsScreenState();
}

class _LocalProductsScreenState extends State<LocalProductsScreen> {
  late LocalProduct _selectedProduct;

  @override
  void initState() {
    super.initState();
    _selectedProduct = _localProducts.firstWhere(
      (product) => product.id == widget.initialProductId,
      orElse: () => _localProducts.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F4EC),
        title: const Text("Prodotti locali"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _LocalProductHero(product: _selectedProduct),
          const SizedBox(height: 16),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _localProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final product = _localProducts[index];
                return _LocalProductCard(
                  product: product,
                  selected: product.id == _selectedProduct.id,
                  onTap: () => setState(() => _selectedProduct = product),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _ProductInfoTile(
            icon: Icons.calendar_month_rounded,
            title: "Stagione",
            body: _selectedProduct.season,
          ),
          _ProductInfoTile(
            icon: Icons.shopping_basket_rounded,
            title: "Dove comprarlo",
            body: _selectedProduct.whereToBuy,
          ),
          _ProductInfoTile(
            icon: Icons.verified_rounded,
            title: "Riferimento",
            body: _selectedProduct.sourceLabel,
          ),
          const SizedBox(height: 6),
          const Text(
            "In evidenza",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (final highlight in _selectedProduct.highlights)
            _ProductHighlight(label: highlight),
        ],
      ),
    );
  }
}

class _LocalProductHero extends StatelessWidget {
  const _LocalProductHero({required this.product});

  final LocalProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: product.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              product.icon,
              color: Colors.white.withValues(alpha: 0.55),
              size: 72,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PRODOTTO LOCALE",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.84),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  height: 0.98,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocalProductCard extends StatelessWidget {
  const _LocalProductCard({
    required this.product,
    required this.selected,
    required this.onTap,
  });

  final LocalProduct product;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 152,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF243C2A) : Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                product.icon,
                color: selected ? Colors.white : const Color(0xFF2E7D57),
              ),
              const Spacer(),
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w900,
                  height: 1.04,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductInfoTile extends StatelessWidget {
  const _ProductInfoTile({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2E7D57)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(body, style: const TextStyle(height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductHighlight extends StatelessWidget {
  const _ProductHighlight({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 19,
            color: Color(0xFF2E7D57),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

enum DiningKind { restaurant, agriturismo, bar, bnb, locale, mostra }

String _diningTitle(DiningKind kind) {
  switch (kind) {
    case DiningKind.restaurant:
      return "Ristoranti";
    case DiningKind.agriturismo:
      return "Agriturismi";
    case DiningKind.bar:
      return "Bar";
    case DiningKind.bnb:
      return "B&B";
    case DiningKind.locale:
      return "Locali";
    case DiningKind.mostra:
      return "Mostre e musei";
  }
}

class DiningVenue {
  const DiningVenue({
    required this.id,
    required this.name,
    required this.kind,
    required this.tagline,
    required this.area,
    required this.address,
    required this.contact,
    required this.todayStatus,
    required this.priceHint,
    required this.sourceLabel,
    required this.bookingRewardPoints,
    required this.bookingActionLabel,
    required this.coverColors,
    required this.icon,
    required this.menuSections,
    required this.bookingSlots,
  });

  final String id;
  final String name;
  final DiningKind kind;
  final String tagline;
  final String area;
  final String address;
  final String contact;
  final String todayStatus;
  final String priceHint;
  final String sourceLabel;
  final int bookingRewardPoints;
  final String bookingActionLabel;
  final List<Color> coverColors;
  final IconData icon;
  final Map<String, List<String>> menuSections;
  final List<String> bookingSlots;

  String get kindLabel {
    switch (kind) {
      case DiningKind.restaurant:
        return "Ristorante";
      case DiningKind.agriturismo:
        return "Agriturismo";
      case DiningKind.bar:
        return "Bar";
      case DiningKind.bnb:
        return "B&B";
      case DiningKind.locale:
        return "Locale";
      case DiningKind.mostra:
        return "Mostra";
    }
  }

  String get sectionsTitle {
    switch (kind) {
      case DiningKind.bnb:
        return "Servizi";
      case DiningKind.mostra:
        return "Cosa prenoti";
      default:
        return "Dettagli";
    }
  }
}

const List<DiningVenue> _diningVenues = [
  DiningVenue(
    id: "civico_14_5",
    name: "Civico 14+5",
    kind: DiningKind.restaurant,
    tagline: "Ristorante pizzeria e bike point in via Dante Alighieri.",
    area: "Centro storico",
    address: "Via Dante Alighieri, 19 - Apecchio",
    contact: "Cell. 338 9769898",
    todayStatus: "Oggi: tavoli a cena",
    priceHint: "Cucina locale, pizza e piatti De.C.O.",
    sourceLabel: "Fonte: Vivere Apecchio / Civico 14+5",
    bookingRewardPoints: 35,
    bookingActionLabel: "Prenota cena",
    coverColors: [Color(0xFF1F3A35), Color(0xFFE6B85C)],
    icon: Icons.restaurant_menu_rounded,
    menuSections: {
      "Identita": ["Pasta fatta in casa", "Tartufo e funghi stagionali"],
      "De.C.O.": ["Salmi del Prete", "Bostrengo di Apecchio"],
      "Bike": ["Bike Point Civico 14+5", "Sosta ristoro per ciclisti"],
    },
    bookingSlots: ["12:30", "13:15", "19:45", "20:30", "21:15"],
  ),
  DiningVenue(
    id: "pizzeria_il_greco",
    name: "Pizzeria Il Greco",
    kind: DiningKind.restaurant,
    tagline: "Pizzeria e bar nel paese, comoda per una prenotazione rapida.",
    area: "Apecchio",
    address: "Via Circonvallazione, 4 - Apecchio",
    contact: "Tel. 0722 989038",
    todayStatus: "Oggi: pranzo e cena",
    priceHint: "Pizzeria e bar",
    sourceLabel: "Fonte: Vivere Apecchio / Tuttocitta",
    bookingRewardPoints: 25,
    bookingActionLabel: "Prenota tavolo",
    coverColors: [Color(0xFF355070), Color(0xFFE56B6F)],
    icon: Icons.local_pizza_rounded,
    menuSections: {
      "Ideale per": ["Pizza", "Pausa bar", "Cena informale"],
      "Prenotazione": ["Tavolo serale", "Gruppi piccoli"],
    },
    bookingSlots: ["12:15", "13:00", "19:30", "20:15", "21:00"],
  ),
  DiningVenue(
    id: "locanda_sp257",
    name: "Locanda SP257",
    kind: DiningKind.restaurant,
    tagline: "Locale in localita Pian di Molino per pranzo, cena e gruppi.",
    area: "Pian di Molino",
    address: "Loc. Pian di Molino - Apecchio",
    contact: "Cell. 334 2259110",
    todayStatus: "Oggi: cucina e bar",
    priceHint: "Ristorante, bar e pizzeria",
    sourceLabel: "Fonte: Vivere Apecchio / Tripadvisor",
    bookingRewardPoints: 30,
    bookingActionLabel: "Prenota cena",
    coverColors: [Color(0xFF2A6F97), Color(0xFFA9D6E5)],
    icon: Icons.storefront_rounded,
    menuSections: {
      "Servizi": ["Pranzo e cena", "Tavoli per gruppi", "Bar"],
      "Prenotabile": ["Cena", "Pizza", "Ristoro dopo outdoor"],
    },
    bookingSlots: ["19:30", "20:00", "20:45", "21:15"],
  ),
  DiningVenue(
    id: "le_ciocche",
    name: "Locanda Le Ciocche",
    kind: DiningKind.restaurant,
    tagline: "Locanda in campagna, presente anche tra le strutture ricettive.",
    area: "Le Ciocche",
    address: "Loc. Le Ciocche - Apecchio",
    contact: "Cell. 333 9356984",
    todayStatus: "Oggi: pochi posti",
    priceHint: "Ristorante e ospitalita rurale",
    sourceLabel: "Fonte: Vivere Apecchio",
    bookingRewardPoints: 30,
    bookingActionLabel: "Prenota tavolo",
    coverColors: [Color(0xFF6B4F3A), Color(0xFFDDA15E)],
    icon: Icons.dinner_dining_rounded,
    menuSections: {
      "Esperienza": ["Cucina rustica", "Ambiente familiare"],
      "Prenotabile": ["Pranzo", "Cena", "Soggiorni collegati"],
    },
    bookingSlots: ["12:45", "13:30", "20:00", "20:45"],
  ),
  DiningVenue(
    id: "monte_nerone_ristorante",
    name: "Ristorante Pizzeria Monte Nerone",
    kind: DiningKind.restaurant,
    tagline:
        "Albergo, ristorante, pizzeria e bike hotel a Serravalle di Carda.",
    area: "Serravalle di Carda",
    address: "Loc. Pian di Trebbio, Serravalle di Carda",
    contact: "Tel. 0722 90136",
    todayStatus: "Oggi: tavoli e pizzeria",
    priceHint: "Ristorante, pizzeria, bike hotel",
    sourceLabel: "Fonte: Vivere Apecchio / Ristomille",
    bookingRewardPoints: 35,
    bookingActionLabel: "Prenota tavolo",
    coverColors: [Color(0xFF264653), Color(0xFF2A9D8F)],
    icon: Icons.hotel_rounded,
    menuSections: {
      "Specialita": ["Funghi", "Tartufo", "Pasta fatta in casa"],
      "Servizi": ["Cerimonie e gruppi", "Bike rent", "Bike hotel"],
    },
    bookingSlots: ["12:30", "13:15", "19:45", "20:30"],
  ),
  DiningVenue(
    id: "da_mario",
    name: "Ristorante Da Mario",
    kind: DiningKind.restaurant,
    tagline: "Ristorante in localita Acquapartita.",
    area: "Acquapartita",
    address: "Loc. Acquapartita - Apecchio",
    contact: "Tel. 0722 90216",
    todayStatus: "Oggi: su prenotazione",
    priceHint: "Cucina del territorio",
    sourceLabel: "Fonte: Vivere Apecchio",
    bookingRewardPoints: 30,
    bookingActionLabel: "Prenota pranzo",
    coverColors: [Color(0xFF3A5A40), Color(0xFFA3B18A)],
    icon: Icons.restaurant_rounded,
    menuSections: {
      "Esperienza": ["Cucina locale", "Tavoli in frazione"],
      "Prenotabile": ["Pranzo", "Cena", "Tavolo famiglia"],
    },
    bookingSlots: ["12:30", "13:15", "19:45", "20:30"],
  ),
  DiningVenue(
    id: "biancospino",
    name: "Ristorante Pizzeria Il Biancospino",
    kind: DiningKind.restaurant,
    tagline: "Ristorante pizzeria a Pian di Trebbio.",
    area: "Serravalle di Carda",
    address: "Loc. Pian di Trebbio - Serravalle di Carda",
    contact: "Tel. 0722 90218",
    todayStatus: "Oggi: cena disponibile",
    priceHint: "Ristorante e pizzeria",
    sourceLabel: "Fonte: Vivere Apecchio",
    bookingRewardPoints: 30,
    bookingActionLabel: "Prenota pizza",
    coverColors: [Color(0xFF5F0F40), Color(0xFFE36414)],
    icon: Icons.local_pizza_rounded,
    menuSections: {
      "Servizi": ["Pizzeria", "Ristorante"],
      "Prenotabile": ["Tavolo cena", "Gruppi"],
    },
    bookingSlots: ["19:30", "20:15", "21:00"],
  ),
  DiningVenue(
    id: "trattoria_rossana",
    name: "Trattoria Rossana",
    kind: DiningKind.restaurant,
    tagline:
        "Trattoria nota per la coradella d'agnello di Serravalle di Carda.",
    area: "Serravalle di Carda",
    address: "Via Cagli, 97 - Serravalle di Carda",
    contact: "Tel. 0722 90146",
    todayStatus: "Oggi: cucina tipica",
    priceHint: "Dove mangiare la Coradella d'agnello De.C.O.",
    sourceLabel: "Fonte: Vivere Apecchio / Piatti De.C.O.",
    bookingRewardPoints: 35,
    bookingActionLabel: "Prenota piatto De.C.O.",
    coverColors: [Color(0xFF7F5539), Color(0xFFE6CCB2)],
    icon: Icons.restaurant_rounded,
    menuSections: {
      "De.C.O.": ["Coradella d'agnello di Serravalle di Carda"],
      "Esperienza": ["Cucina tradizionale", "Trattoria di frazione"],
    },
    bookingSlots: ["12:30", "13:15", "19:45", "20:30"],
  ),
  DiningVenue(
    id: "pian_di_molino",
    name: "Agriturismo Pian di Molino",
    kind: DiningKind.agriturismo,
    tagline: "Agriturismo a Pian di Molino con cucina rurale e soggiorni.",
    area: "Campagna",
    address: "Loc. Pian di Molino - Apecchio",
    contact: "Cell. 329 2016664",
    todayStatus: "Oggi: su prenotazione",
    priceHint: "Ristorazione e ricettivita",
    sourceLabel: "Fonte: Vivere Apecchio",
    bookingRewardPoints: 45,
    bookingActionLabel: "Prenota agriturismo",
    coverColors: [Color(0xFF386641), Color(0xFFA7C957)],
    icon: Icons.agriculture_rounded,
    menuSections: {
      "Esperienza": ["Cucina rurale", "Soggiorno nel verde"],
      "Prenotabile": ["Pranzo", "Cena", "Pernottamento"],
    },
    bookingSlots: ["12:30", "13:00", "19:30", "20:00"],
  ),
  DiningVenue(
    id: "ca_cirigiolo",
    name: "Agriturismo Ca' Cirigiolo",
    kind: DiningKind.agriturismo,
    tagline: "Agriturismo con ristorante, piscina e vista in alta collina.",
    area: "Ca' Cirigiolo",
    address: "Loc. Ca' Cirigiolo - Apecchio",
    contact: "Cell. 348 0058169",
    todayStatus: "Oggi: cena disponibile",
    priceHint: "Ristorante, piscina, appartamenti",
    sourceLabel: "Fonte: Vivere Apecchio / Agriturismi.it",
    bookingRewardPoints: 45,
    bookingActionLabel: "Prenota cena",
    coverColors: [Color(0xFF606C38), Color(0xFFDDA15E)],
    icon: Icons.local_florist_rounded,
    menuSections: {
      "De.C.O.": ["Salmi del Prete", "Prodotti locali"],
      "Servizi": ["Ristorante", "Piscina", "Appartamenti"],
    },
    bookingSlots: ["19:30", "20:15", "21:00"],
  ),
  DiningVenue(
    id: "agriturismo_chignoni",
    name: "Agriturismo Chignoni",
    kind: DiningKind.agriturismo,
    tagline: "Ospitalita rurale in localita Chignoni.",
    area: "Chignoni",
    address: "Loc. Chignoni - Apecchio",
    contact: "Cell. 340 3353492 / 338 8060533",
    todayStatus: "Oggi: richiesta soggiorno",
    priceHint: "Appartamenti, campagna, piscina",
    sourceLabel: "Fonte: Vivere Apecchio / Agriturismi.it",
    bookingRewardPoints: 40,
    bookingActionLabel: "Richiedi soggiorno",
    coverColors: [Color(0xFF283618), Color(0xFFBC6C25)],
    icon: Icons.park_rounded,
    menuSections: {
      "Servizi": ["Appartamenti", "Piscina", "Vacanza in campagna"],
      "Prenotabile": ["Soggiorno", "Weekend", "Gruppi"],
    },
    bookingSlots: ["09:30", "11:00", "16:00", "17:30"],
  ),
  DiningVenue(
    id: "agriturismo_la_rocca",
    name: "Agriturismo La Rocca",
    kind: DiningKind.agriturismo,
    tagline: "Agriturismo in localita La Rocca.",
    area: "La Rocca",
    address: "Loc. La Rocca - Apecchio",
    contact: "Cell. 339 1866663",
    todayStatus: "Oggi: richiesta disponibilita",
    priceHint: "Soggiorni in agriturismo",
    sourceLabel: "Fonte: Vivere Apecchio",
    bookingRewardPoints: 40,
    bookingActionLabel: "Richiedi soggiorno",
    coverColors: [Color(0xFF31572C), Color(0xFF90A955)],
    icon: Icons.cabin_rounded,
    menuSections: {
      "Servizi": ["Ospitalita rurale", "Natura", "Soggiorno"],
      "Prenotabile": ["Weekend", "Settimana", "Famiglie"],
    },
    bookingSlots: ["09:30", "11:00", "16:00", "17:30"],
  ),
  DiningVenue(
    id: "agriturismo_fontesomma",
    name: "Agriturismo Fontesomma",
    kind: DiningKind.agriturismo,
    tagline: "Agriturismo in localita Fontesomma.",
    area: "Fontesomma",
    address: "Loc. Fontesomma - Apecchio",
    contact: "Cell. 338 2636602",
    todayStatus: "Oggi: richiesta soggiorno",
    priceHint: "Soggiorni in agriturismo",
    sourceLabel: "Fonte: Vivere Apecchio",
    bookingRewardPoints: 40,
    bookingActionLabel: "Richiedi soggiorno",
    coverColors: [Color(0xFF386641), Color(0xFFF2E8CF)],
    icon: Icons.nature_people_rounded,
    menuSections: {
      "Servizi": ["Ospitalita rurale", "Collina", "Relax"],
      "Prenotabile": ["Soggiorno", "Weekend"],
    },
    bookingSlots: ["09:30", "11:00", "16:00", "17:30"],
  ),
  DiningVenue(
    id: "agriturismo_la_spina",
    name: "Agriturismo La Spina",
    kind: DiningKind.agriturismo,
    tagline: "Country house in collina con vista sulla vallata di Apecchio.",
    area: "La Spina",
    address: "Loc. La Spina - Apecchio",
    contact: "Cell. 339 8063402",
    todayStatus: "Oggi: disponibilita da verificare",
    priceHint: "Country house, piscina, campagna",
    sourceLabel: "Fonte: Vivere Apecchio / Agriturismi.it",
    bookingRewardPoints: 40,
    bookingActionLabel: "Richiedi soggiorno",
    coverColors: [Color(0xFF588157), Color(0xFFDAD7CD)],
    icon: Icons.house_siding_rounded,
    menuSections: {
      "Servizi": ["Country house", "Piscina", "Vista in collina"],
      "Prenotabile": ["Camere", "Appartamenti", "Weekend"],
    },
    bookingSlots: ["09:30", "11:00", "16:00", "17:30"],
  ),
  DiningVenue(
    id: "bb_il_borgo",
    name: "B&B Il Borgo",
    kind: DiningKind.bnb,
    tagline: "B&B nel borgo, comodo per visitare il centro storico.",
    area: "Centro storico",
    address: "Via Borgo Mazzini, 28 - Apecchio",
    contact: "Cell. 333 4251224",
    todayStatus: "Oggi: richiesta camere",
    priceHint: "B&B",
    sourceLabel: "Fonte: Vivere Apecchio",
    bookingRewardPoints: 50,
    bookingActionLabel: "Richiedi camera",
    coverColors: [Color(0xFF3D405B), Color(0xFFF2CC8F)],
    icon: Icons.bed_rounded,
    menuSections: {
      "Servizi": ["Pernottamento", "Posizione nel borgo"],
      "Prenotabile": ["Camera", "Weekend", "Soggiorno turistico"],
    },
    bookingSlots: ["09:30", "11:30", "15:30", "17:30"],
  ),
  DiningVenue(
    id: "bb_d_dodo",
    name: "B&B D' Dodo",
    kind: DiningKind.bnb,
    tagline: "B&B in via Dante Alighieri.",
    area: "Centro paese",
    address: "Via Dante Alighieri, 41 - Apecchio",
    contact: "Cell. 320 4911626 / 334 7308339",
    todayStatus: "Oggi: richiesta camere",
    priceHint: "B&B",
    sourceLabel: "Fonte: Vivere Apecchio",
    bookingRewardPoints: 50,
    bookingActionLabel: "Richiedi camera",
    coverColors: [Color(0xFF4A4E69), Color(0xFFC9ADA7)],
    icon: Icons.king_bed_rounded,
    menuSections: {
      "Servizi": ["Pernottamento", "Centro paese"],
      "Prenotabile": ["Camera", "Soggiorno breve"],
    },
    bookingSlots: ["09:30", "11:30", "15:30", "17:30"],
  ),
  DiningVenue(
    id: "bb_lospitale",
    name: "B&B Lospitale",
    kind: DiningKind.bnb,
    tagline: "B&B in via Garibaldi.",
    area: "Centro storico",
    address: "Via G. Garibaldi, 2 - Apecchio",
    contact: "Cell. 339 4606824",
    todayStatus: "Oggi: richiesta camere",
    priceHint: "B&B",
    sourceLabel: "Fonte: Vivere Apecchio",
    bookingRewardPoints: 50,
    bookingActionLabel: "Richiedi camera",
    coverColors: [Color(0xFF6D597A), Color(0xFFE5989B)],
    icon: Icons.night_shelter_rounded,
    menuSections: {
      "Servizi": ["Pernottamento", "Centro storico"],
      "Prenotabile": ["Camera", "Soggiorno turistico"],
    },
    bookingSlots: ["09:30", "11:30", "15:30", "17:30"],
  ),
  DiningVenue(
    id: "bb_da_simone",
    name: "B&B Da Simone",
    kind: DiningKind.bnb,
    tagline: "B&B e Bike Point a Pian di Molino.",
    area: "Pian di Molino",
    address: "Loc. Pian di Molino - Apecchio",
    contact: "Cell. 339 8968470",
    todayStatus: "Oggi: camere e bike point",
    priceHint: "B&B, Bar Maria, Bike Point",
    sourceLabel: "Fonte: Vivere Apecchio",
    bookingRewardPoints: 55,
    bookingActionLabel: "Richiedi camera",
    coverColors: [Color(0xFF006D77), Color(0xFF83C5BE)],
    icon: Icons.directions_bike_rounded,
    menuSections: {
      "Servizi": ["Pernottamento", "Bar Maria", "Bike Point"],
      "Prenotabile": ["Camera", "Servizi per ciclisti"],
    },
    bookingSlots: ["09:30", "11:30", "15:30", "17:30"],
  ),
  DiningVenue(
    id: "bar_maria",
    name: "Bar Alimentari Maria",
    kind: DiningKind.bar,
    tagline: "Bar alimentari a Pian di Molino e punto di riferimento bike.",
    area: "Pian di Molino",
    address: "Pian di Molino, 8 - Apecchio",
    contact: "Cell. 339 8968470",
    todayStatus: "Oggi: colazioni e pausa",
    priceHint: "Bar, alimentari, tavoli all'aperto",
    sourceLabel: "Fonte: Vivere Apecchio / PagineGialle",
    bookingRewardPoints: 15,
    bookingActionLabel: "Prenota pausa",
    coverColors: [Color(0xFF9A031E), Color(0xFFFB8B24)],
    icon: Icons.local_cafe_rounded,
    menuSections: {
      "Servizi": ["Prima colazione", "Bar", "Alimentari"],
      "Bike": ["Bike Point Bar Maria", "Sosta a Pian di Molino"],
    },
    bookingSlots: ["07:30", "09:00", "12:30", "17:30"],
  ),
  DiningVenue(
    id: "bar_greco",
    name: "Bar Greco",
    kind: DiningKind.bar,
    tagline: "Bar e pizzeria in via Circonvallazione.",
    area: "Apecchio",
    address: "Via Circonvallazione, 4 - Apecchio",
    contact: "Tel. 0722 989038",
    todayStatus: "Oggi: bar e pizza",
    priceHint: "Bar, caffe, pizzeria",
    sourceLabel: "Fonte: Tuttocitta / Vivere Apecchio",
    bookingRewardPoints: 15,
    bookingActionLabel: "Prenota tavolo",
    coverColors: [Color(0xFF5F0F40), Color(0xFFFB8B24)],
    icon: Icons.coffee_rounded,
    menuSections: {
      "Servizi": ["Caffe", "Bar", "Pizzeria"],
      "Prenotabile": ["Pausa", "Tavolo pizzeria"],
    },
    bookingSlots: ["08:00", "10:30", "18:30", "20:30"],
  ),
  DiningVenue(
    id: "bar_sp257",
    name: "Bar SP257",
    kind: DiningKind.bar,
    tagline: "Bar e ristorante in localita Pian di Molino.",
    area: "Pian di Molino",
    address: "Loc. Pian di Molino - Apecchio",
    contact: "Cell. 334 2259110",
    todayStatus: "Oggi: bar, pranzo e cena",
    priceHint: "Bar, ristorante, pizzeria",
    sourceLabel: "Fonte: Vivere Apecchio / Tripadvisor",
    bookingRewardPoints: 20,
    bookingActionLabel: "Prenota tavolo",
    coverColors: [Color(0xFF283618), Color(0xFFBC6C25)],
    icon: Icons.sports_bar_rounded,
    menuSections: {
      "Servizi": ["Bar", "Ristorante", "Pizzeria"],
      "Prenotabile": ["Pausa", "Pranzo", "Cena"],
    },
    bookingSlots: ["08:30", "12:30", "19:30", "20:30"],
  ),
  DiningVenue(
    id: "bike_point_civico",
    name: "Civico 14+5 - Ristobike",
    kind: DiningKind.locale,
    tagline: "Locale aderente alla rete Bike Point in Apecchio.",
    area: "Centro storico",
    address: "Via Dante Alighieri, 19 - Apecchio",
    contact: "Cell. 338 9769898",
    todayStatus: "Oggi: ristoro ciclisti",
    priceHint: "Bike Point e ristorazione",
    sourceLabel: "Fonte: Vivere Apecchio Outdoor",
    bookingRewardPoints: 25,
    bookingActionLabel: "Prenota bike stop",
    coverColors: [Color(0xFF2D6A4F), Color(0xFF95D5B2)],
    icon: Icons.electric_bike_rounded,
    menuSections: {
      "Bike Point": ["Ristoro", "Punto info ciclisti"],
      "Prenotabile": ["Sosta gruppo", "Tavolo post-uscita"],
    },
    bookingSlots: ["09:00", "11:30", "16:30", "19:30"],
  ),
  DiningVenue(
    id: "rifugio_la_cupa",
    name: "Rifugio La Cupa",
    kind: DiningKind.locale,
    tagline: "Rifugio in quota sul Monte Nerone.",
    area: "Monte Nerone",
    address: "Loc. La Cupa di Monte Nerone",
    contact: "Tel. 0722 90117 / Cell. 339 3353541",
    todayStatus: "Oggi: meteo e disponibilita da verificare",
    priceHint: "Rifugio e ristoro outdoor",
    sourceLabel: "Fonte: Vivere Apecchio",
    bookingRewardPoints: 35,
    bookingActionLabel: "Prenota rifugio",
    coverColors: [Color(0xFF1D3557), Color(0xFFA8DADC)],
    icon: Icons.landscape_rounded,
    menuSections: {
      "Outdoor": ["Monte Nerone", "Ristoro escursionisti"],
      "Prenotabile": ["Tavolo", "Gruppo trekking"],
    },
    bookingSlots: ["10:30", "12:30", "16:30", "19:30"],
  ),
  DiningVenue(
    id: "chalet_corsini",
    name: "Rifugio Chalet Principe Corsini",
    kind: DiningKind.locale,
    tagline: "Rifugio sul Monte Nerone, presente nella ricettivita locale.",
    area: "Monte Nerone",
    address: "Monte Nerone",
    contact: "Cell. 331 8766610",
    todayStatus: "Oggi: richiesta disponibilita",
    priceHint: "Rifugio e accoglienza in quota",
    sourceLabel: "Fonte: Vivere Apecchio",
    bookingRewardPoints: 35,
    bookingActionLabel: "Prenota rifugio",
    coverColors: [Color(0xFF003049), Color(0xFFF77F00)],
    icon: Icons.chalet_rounded,
    menuSections: {
      "Servizi": ["Rifugio", "Monte Nerone", "Sosta panoramica"],
      "Prenotabile": ["Tavolo", "Gruppo outdoor"],
    },
    bookingSlots: ["10:30", "12:30", "16:30", "19:30"],
  ),
  DiningVenue(
    id: "palazzo_ubaldini_mostre",
    name: "Sale espositive di Palazzo Ubaldini",
    kind: DiningKind.mostra,
    tagline:
        "Sale del Palazzo Ubaldini dedicate a mostre e iniziative culturali.",
    area: "Centro storico",
    address: "Piazza S. Martino - Apecchio",
    contact: "Ufficio IAT +39 0722 99279",
    todayStatus: "Oggi: visite su calendario",
    priceHint: "Mostre, visite guidate e iniziative culturali",
    sourceLabel: "Fonte: Vivere Apecchio / Palazzo Ubaldini",
    bookingRewardPoints: 30,
    bookingActionLabel: "Prenota mostra",
    coverColors: [Color(0xFF493548), Color(0xFFE6C17A)],
    icon: Icons.museum_rounded,
    menuSections: {
      "Spazi": ["Sale espositive", "Palazzo Ubaldini", "Piazza S. Martino"],
      "Prenotabile": ["Visita mostra", "Ingresso gruppo", "Visita guidata"],
    },
    bookingSlots: ["10:00", "11:30", "15:30", "17:00"],
  ),
  DiningVenue(
    id: "museo_fossili",
    name: "Museo dei Fossili e Minerali",
    kind: DiningKind.mostra,
    tagline: "Museo interattivo nei sotterranei di Palazzo Ubaldini.",
    area: "Palazzo Ubaldini",
    address: "Piazza S. Martino - Apecchio",
    contact: "Prenotazioni: prenotazioni@lamacina.it",
    todayStatus: "Oggi: visite prenotabili",
    priceHint: "Museo dei Fossili e Minerali del Monte Nerone",
    sourceLabel: "Fonte: Vivere Apecchio Cultura",
    bookingRewardPoints: 30,
    bookingActionLabel: "Prenota visita",
    coverColors: [Color(0xFF1B4332), Color(0xFF74C69D)],
    icon: Icons.science_rounded,
    menuSections: {
      "Collezione": ["Fossili", "Minerali", "Reperti del Monte Nerone"],
      "Prenotabile": ["Visita museo", "Gruppi", "Scuole"],
    },
    bookingSlots: ["10:00", "11:30", "15:30", "17:00"],
  ),
  DiningVenue(
    id: "rembrandt_barocci_mostra",
    name: "Rembrandt e Barocci",
    kind: DiningKind.mostra,
    tagline: "Archivio della mostra Incidere la luce a Palazzo Ubaldini.",
    area: "Palazzo Ubaldini",
    address: "Piazza S. Martino - Apecchio",
    contact: "Ufficio IAT +39 0722 99279",
    todayStatus: "Archivio mostra: 8 giugno - 7 settembre 2025",
    priceHint: "Oltre quaranta incisioni originali",
    sourceLabel: "Fonte: Vivere Apecchio / Palazzo Ubaldini",
    bookingRewardPoints: 20,
    bookingActionLabel: "Salva scheda mostra",
    coverColors: [Color(0xFF3D2B3D), Color(0xFFC9A227)],
    icon: Icons.palette_rounded,
    menuSections: {
      "Mostra": ["Rembrandt van Rijn", "Federico Barocci", "Incisioni"],
      "Nota": ["Scheda archivio utile per materiali veritieri nel mockup"],
    },
    bookingSlots: ["10:00", "11:30", "15:30", "17:00"],
  ),
];

class DiningScreen extends StatelessWidget {
  const DiningScreen({super.key, this.initialKind = DiningKind.restaurant});

  final DiningKind initialKind;

  @override
  Widget build(BuildContext context) {
    final venues = _diningVenues
        .where((venue) => venue.kind == initialKind)
        .toList(growable: false);
    final title = _diningTitle(initialKind);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F4EC),
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _DiningHero(
            highlightedVenue: venues.first,
            onTap: () => _openVenue(context, venues.first),
          ),
          const SizedBox(height: 18),
          const _TodayDiningBar(),
          const SizedBox(height: 22),
          _DiningSection(
            title: title,
            venues: venues,
            onTap: (venue) => _openVenue(context, venue),
          ),
        ],
      ),
    );
  }

  void _openVenue(BuildContext context, DiningVenue venue) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DiningVenueDetailScreen(venue: venue),
      ),
    );
  }
}

class _DiningHero extends StatelessWidget {
  const _DiningHero({required this.highlightedVenue, required this.onTap});

  final DiningVenue highlightedVenue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: highlightedVenue.coverColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                highlightedVenue.icon,
                color: Colors.white.withValues(alpha: 0.55),
                size: 64,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlightedVenue.todayStatus.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  highlightedVenue.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    height: 0.98,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  highlightedVenue.tagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayDiningBar extends StatelessWidget {
  const _TodayDiningBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.today_rounded, color: Color(0xFF2E7D57)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Priorita a oggi: disponibilita, menu e prenotazioni rapide.",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiningSection extends StatelessWidget {
  const _DiningSection({
    required this.title,
    required this.venues,
    required this.onTap,
  });

  final String title;
  final List<DiningVenue> venues;
  final ValueChanged<DiningVenue> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 214,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: venues.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final venue = venues[index];
              return _DiningVenueCard(venue: venue, onTap: () => onTap(venue));
            },
          ),
        ),
      ],
    );
  }
}

class _DiningVenueCard extends StatelessWidget {
  const _DiningVenueCard({required this.venue, required this.onTap});

  final DiningVenue venue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 178,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: venue.coverColors),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(venue.icon, color: Colors.white),
              ),
              const Spacer(),
              Text(
                venue.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                venue.todayStatus,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF2E7D57),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                venue.area,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiningVenueDetailScreen extends StatefulWidget {
  const DiningVenueDetailScreen({super.key, required this.venue});

  final DiningVenue venue;

  @override
  State<DiningVenueDetailScreen> createState() =>
      _DiningVenueDetailScreenState();
}

class _DiningVenueDetailScreenState extends State<DiningVenueDetailScreen> {
  int _selectedDay = 0;
  String? _selectedSlot;
  String? _selectedVoucherCode;

  @override
  Widget build(BuildContext context) {
    final days = List<DateTime>.generate(
      7,
      (index) => DateTime.now().add(Duration(days: index)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F4EC),
        title: Text(widget.venue.kindLabel),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _DiningHero(highlightedVenue: widget.venue, onTap: () {}),
          const SizedBox(height: 18),
          Text(
            widget.venue.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            widget.venue.tagline,
            style: const TextStyle(height: 1.35, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          _VenueInfoRow(icon: Icons.place_rounded, text: widget.venue.area),
          _VenueInfoRow(icon: Icons.map_rounded, text: widget.venue.address),
          _VenueInfoRow(icon: Icons.phone_rounded, text: widget.venue.contact),
          _VenueInfoRow(
            icon: Icons.payments_rounded,
            text: widget.venue.priceHint,
          ),
          _VenueInfoRow(
            icon: Icons.event_available_rounded,
            text: widget.venue.todayStatus,
          ),
          _VenueInfoRow(
            icon: Icons.verified_rounded,
            text: widget.venue.sourceLabel,
          ),
          _TrailDetailCard(
            title: "Token prenotazione",
            child: Text(
              "Prenotando da app ottieni ${widget.venue.bookingRewardPoints} token. L'accredito e' idempotente: la stessa prenotazione non genera doppioni.",
            ),
          ),
          const SizedBox(height: 22),
          Text(
            widget.venue.sectionsTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (final entry in widget.venue.menuSections.entries)
            _MenuSection(title: entry.key, items: entry.value),
          const SizedBox(height: 22),
          const Text(
            "Prenota",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _BookingCalendar(
            days: days,
            selectedDay: _selectedDay,
            onChanged: (index) => setState(() {
              _selectedDay = index;
              _selectedSlot = null;
            }),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final slot in widget.venue.bookingSlots)
                ChoiceChip(
                  label: Text(slot),
                  selected: _selectedSlot == slot,
                  selectedColor: const Color(0xFF2E7D57),
                  labelStyle: TextStyle(
                    color:
                        _selectedSlot == slot ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w800,
                  ),
                  onSelected: (_) => setState(() => _selectedSlot = slot),
                ),
            ],
          ),
          const SizedBox(height: 18),
          _DiningVoucherSelector(
            selectedCode: _selectedVoucherCode,
            onChanged: (code) => setState(() => _selectedVoucherCode = code),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _selectedSlot == null
                ? null
                : () {
                    final dayLabel = _formatBookingDay(days[_selectedDay]);
                    final redeemed = _selectedVoucherCode == null
                        ? false
                        : appGamification.redeemVoucher(
                            code: _selectedVoucherCode!,
                            merchantName: widget.venue.name,
                          );
                    final awarded = appGamification.recordBooking(
                      sourceId: "${widget.venue.id}:$dayLabel:$_selectedSlot",
                      label:
                          "${widget.venue.bookingActionLabel}: ${widget.venue.name} · $dayLabel $_selectedSlot",
                      points: widget.venue.bookingRewardPoints,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          [
                            "Richiesta per ${widget.venue.name}: $dayLabel alle $_selectedSlot",
                            if (awarded)
                              "+${widget.venue.bookingRewardPoints} token",
                            if (redeemed) "voucher applicato",
                          ].join(" · "),
                        ),
                      ),
                    );
                    setState(() => _selectedVoucherCode = null);
                  },
            icon: const Icon(Icons.check_circle_rounded),
            label: Text(widget.venue.bookingActionLabel),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D57),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueInfoRow extends StatelessWidget {
  const _VenueInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2E7D57)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiningVoucherSelector extends StatelessWidget {
  const _DiningVoucherSelector({
    required this.selectedCode,
    required this.onChanged,
  });

  final String? selectedCode;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appGamification,
      builder: (context, _) {
        final vouchers = appGamification.activeVouchers;
        return _TrailDetailCard(
          title: "Voucher APPecchio",
          child: vouchers.isEmpty
              ? const Text("Nessun voucher attivo da applicare.")
              : DropdownButtonFormField<String?>(
                  initialValue:
                      vouchers.any((voucher) => voucher.code == selectedCode)
                          ? selectedCode
                          : null,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.confirmation_number_rounded),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text("Nessun voucher"),
                    ),
                    for (final voucher in vouchers)
                      DropdownMenuItem<String?>(
                        value: voucher.code,
                        child: Text(
                          "${voucher.label} (${voucher.code})",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: onChanged,
                ),
        );
      },
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Color(0xFF2E7D57)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BookingCalendar extends StatelessWidget {
  const _BookingCalendar({
    required this.days,
    required this.selectedDay,
    required this.onChanged,
  });

  final List<DateTime> days;
  final int selectedDay;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = selectedDay == index;
          return ChoiceChip(
            selected: isSelected,
            selectedColor: const Color(0xFF2E7D57),
            onSelected: (_) => onChanged(index),
            label: SizedBox(
              width: 64,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    index == 0 ? "Oggi" : _weekday(days[index]),
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${days[index].day}",
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _month(days[index]),
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

String _formatBookingDay(DateTime date) {
  return "${_weekday(date)} ${date.day} ${_month(date)}";
}

String _weekday(DateTime date) {
  const days = ["Lun", "Mar", "Mer", "Gio", "Ven", "Sab", "Dom"];
  return days[date.weekday - 1];
}

String _month(DateTime date) {
  const months = [
    "gen",
    "feb",
    "mar",
    "apr",
    "mag",
    "giu",
    "lug",
    "ago",
    "set",
    "ott",
    "nov",
    "dic",
  ];
  return months[date.month - 1];
}

class CulturePage {
  const CulturePage({
    required this.id,
    required this.title,
    required this.eyebrow,
    required this.summary,
    required this.location,
    required this.duration,
    required this.bestFor,
    required this.contact,
    required this.website,
    required this.coverColors,
    required this.icon,
    required this.highlights,
    required this.sections,
  });

  final String id;
  final String title;
  final String eyebrow;
  final String summary;
  final String location;
  final String duration;
  final String bestFor;
  final String contact;
  final String website;
  final List<Color> coverColors;
  final IconData icon;
  final List<String> highlights;
  final List<CultureSection> sections;
}

class CultureSection {
  const CultureSection({
    required this.title,
    required this.body,
    required this.items,
  });

  final String title;
  final String body;
  final List<String> items;
}

const List<CulturePage> _culturePages = [
  CulturePage(
    id: "musei",
    title: "Museo dei Fossili e Minerali del Monte Nerone",
    eyebrow: "Musei e mostre",
    summary:
        "Una visita nei sotterranei di Palazzo Ubaldini tra ammoniti, minerali, reperti del Monte Nerone e piccole esposizioni temporanee legate alla memoria del territorio.",
    location: "Palazzo Ubaldini, Via XX Settembre 24",
    duration: "45 - 75 min",
    bestFor: "Famiglie, scuole, appassionati di geologia",
    contact: "Comune di Apecchio - info@comune.apecchio.ps.it",
    website: "www.vivereapecchio.it/cultura",
    coverColors: [Color(0xFF234E52), Color(0xFFC49345)],
    icon: Icons.museum_rounded,
    highlights: [
      "Collezione di ammoniti del Monte Nerone",
      "Fossili, minerali e pietre fluorescenti",
      "Sale voltate sotto Palazzo Ubaldini",
    ],
    sections: [
      CultureSection(
        title: "Cosa trovi",
        body:
            "Il museo racconta la storia geologica dell'Appennino umbro-marchigiano con reperti locali e materiali di confronto. La parte piu scenografica e nei locali storici del palazzo.",
        items: [
          "Fossili marini e ammoniti",
          "Minerali e rocce del territorio",
          "Reperti paleontologici e pannelli didattici",
        ],
      ),
      CultureSection(
        title: "Mostre",
        body:
            "La pagina raccoglie anche le mostre ospitate nelle sale civiche e negli spazi culturali del centro, pensate come tappe brevi da abbinare alla visita del borgo.",
        items: [
          "Mostre fotografiche sulla memoria del paese",
          "Piccole esposizioni documentarie",
          "Percorsi per scuole e gruppi",
        ],
      ),
      CultureSection(
        title: "Prima di andare",
        body:
            "Gli orari possono cambiare in base a stagione, eventi e aperture straordinarie. Per gruppi e scuole conviene contattare il Comune prima della visita.",
        items: [
          "Ingresso dal centro storico",
          "Consigliata prenotazione per gruppi",
          "Abbinabile a Palazzo Ubaldini e Campanone",
        ],
      ),
    ],
  ),
  CulturePage(
    id: "borghi",
    title: "Centro storico di Apecchio e borghi del territorio",
    eyebrow: "Borghi",
    summary:
        "Una pagina per orientarsi tra il nucleo medievale, il ponte sul Biscubio, le frazioni e i punti panoramici che raccontano il rapporto tra paese, acqua e montagna.",
    location: "Centro storico, Biscubio, frazioni di Apecchio",
    duration: "1 - 3 ore",
    bestFor: "Passeggiate, foto, visite lente",
    contact: "Ufficio turistico - turismo@apppecchio.it",
    website: "www.vivereapecchio.it/percorso-consigliato",
    coverColors: [Color(0xFF5A3E2B), Color(0xFFBFD8B8)],
    icon: Icons.location_city_rounded,
    highlights: [
      "Ponte medievale a schiena d'asino",
      "Torre del Campanone",
      "Vicoli, mura e scorci sul Biscubio",
    ],
    sections: [
      CultureSection(
        title: "Passeggiata nel borgo",
        body:
            "Il percorso consigliato parte dal ponte medievale, entra nel centro attraverso il Campanone e prosegue verso Palazzo Ubaldini, chiese, vicoli e piccoli affacci.",
        items: [
          "Ponte sul torrente Biscubio",
          "Porta e Torre del Campanone",
          "Palazzo Ubaldini e piazza principale",
        ],
      ),
      CultureSection(
        title: "Frazioni e paesaggio",
        body:
            "Le frazioni permettono di leggere Apecchio come territorio diffuso: nuclei rurali, pievi, vecchi mulini e strade che salgono verso il Monte Nerone.",
        items: [
          "Pianello e la valle",
          "Serravalle di Carda",
          "Strade panoramiche verso il Nerone",
        ],
      ),
      CultureSection(
        title: "Come visitarlo",
        body:
            "La visita funziona bene a piedi, con scarpe comode e qualche sosta fotografica. Nei giorni di evento il centro puo diventare un itinerario con tappe gastronomiche e culturali.",
        items: [
          "Percorso breve: 45 minuti",
          "Percorso completo: mezza giornata",
          "Ideale al mattino o al tramonto",
        ],
      ),
    ],
  ),
  CulturePage(
    id: "arte",
    title: "Arte, chiese e segni urbani",
    eyebrow: "Arte",
    summary:
        "Una mappa culturale leggera per scoprire opere, architetture e dettagli del centro: dalle chiese alle facciate, dai portali in pietra ai luoghi della memoria collettiva.",
    location: "Centro storico e chiese principali",
    duration: "60 - 90 min",
    bestFor: "Visite culturali, scuole, itinerari fotografici",
    contact: "Biblioteca comunale - biblioteca@apppecchio.it",
    website: "www.vivereapecchio.it/cultura",
    coverColors: [Color(0xFF673D5C), Color(0xFFE9B872)],
    icon: Icons.palette_rounded,
    highlights: [
      "Chiesa di San Martino",
      "Madonna della Vita",
      "Portali, stemmi e dettagli in pietra",
    ],
    sections: [
      CultureSection(
        title: "Luoghi da cercare",
        body:
            "La pagina mette in fila i punti piu utili per chi vuole guardare il paese con occhio artistico, senza trasformare la visita in una lista fredda.",
        items: [
          "Chiesa parrocchiale di San Martino",
          "Piccole cappelle del centro",
          "Colonnato e cortile di Palazzo Ubaldini",
        ],
      ),
      CultureSection(
        title: "Dettagli urbani",
        body:
            "Portali, stemmi, archi, finestre e pietre lavorate aiutano a leggere le stratificazioni del borgo. Ogni tappa puo diventare una scheda con foto e note storiche.",
        items: [
          "Stemmi della famiglia Ubaldini",
          "Architravi e pietre scolpite",
          "Affacci sui vicoli medievali",
        ],
      ),
      CultureSection(
        title: "Percorso consigliato",
        body:
            "Si parte dalla piazza, si attraversano le vie interne e si chiude con una sosta al ponte o al palazzo. Il percorso e breve ma denso di dettagli.",
        items: [
          "Adatto anche con meteo incerto",
          "Buono per visite guidate",
          "Fotografie migliori con luce radente",
        ],
      ),
    ],
  ),
  CulturePage(
    id: "storia",
    title: "Percorso storico Ubaldini e Biscubio",
    eyebrow: "Percorsi storici",
    summary:
        "Un itinerario concreto per capire Apecchio attraverso Palazzo Ubaldini, le antiche porte, il ponte medievale, il torrente Biscubio e le tracce della vita di confine.",
    location: "Dal ponte medievale a Palazzo Ubaldini",
    duration: "90 min",
    bestFor: "Storia locale, gruppi, scuole secondarie",
    contact: "Archivio e biblioteca - biblioteca@apppecchio.it",
    website: "www.vivereapecchio.it/percorso-consigliato",
    coverColors: [Color(0xFF25364A), Color(0xFF9C7653)],
    icon: Icons.history_edu_rounded,
    highlights: [
      "Famiglia Ubaldini",
      "Palazzo attribuito a Francesco di Giorgio Martini",
      "Ponte e accessi storici al castello",
    ],
    sections: [
      CultureSection(
        title: "La linea del tempo",
        body:
            "La scheda traduce la storia in tappe: dal controllo degli accessi al borgo alla stagione degli Ubaldini, fino agli usi civici degli spazi monumentali.",
        items: [
          "Ponte medievale sul Biscubio",
          "Campanone e ingresso al castello",
          "Palazzo Ubaldini e sotterranei",
        ],
      ),
      CultureSection(
        title: "Cosa raccontare",
        body:
            "Il percorso mette insieme potere signorile, difesa, acqua, commercio e vita quotidiana. E pensato per essere usato anche da una guida o da un insegnante.",
        items: [
          "Apecchio come paese di passaggio",
          "La Vaccareccia e il corso del Biscubio",
          "Storie di famiglie, mestieri e confini",
        ],
      ),
      CultureSection(
        title: "Uso in app",
        body:
            "La pagina puo diventare una visita guidata con tappe geolocalizzate, audio brevi e schede di approfondimento da aprire solo quando si arriva sul posto.",
        items: [
          "Tappe ordinate a piedi",
          "Schede brevi per ogni monumento",
          "Modalita scuola con domande finali",
        ],
      ),
    ],
  ),
  CulturePage(
    id: "vicolo_ebrei",
    title: "Vicolo degli Ebrei",
    eyebrow: "Cultura",
    summary:
        "Una tappa minuta ma fortissima del centro storico: il vicolo legato alla presenza ebraica documentata ad Apecchio tra fine Quattrocento ed eta moderna.",
    location: "Centro storico di Apecchio",
    duration: "15 - 25 min",
    bestFor: "Storia locale, visite guidate, scuole",
    contact: "Ufficio Turistico - +39 0722 99279",
    website: "www.apecchio.net/storia",
    coverColors: [Color(0xFF3A4D39), Color(0xFFC9A66B)],
    icon: Icons.signpost_rounded,
    highlights: [
      "Uno dei vicoli piu stretti d'Italia",
      "Memoria della comunita ebraica locale",
      "Tappa breve nel reticolo medievale",
    ],
    sections: [
      CultureSection(
        title: "Perche e importante",
        body:
            "Il vicolo permette di raccontare una parte meno visibile della storia del borgo: convivenze, mestieri, statuti locali e vita quotidiana dentro le mura.",
        items: [
          "Da collegare al percorso storico",
          "Tappa adatta a contenuti audio brevi",
          "Ideale per una mappa dei luoghi della memoria",
        ],
      ),
      CultureSection(
        title: "In app",
        body:
            "La scheda puo funzionare come micro-tappa con foto, testo essenziale e rimando agli approfondimenti storici di Apecchio.Net.",
        items: [
          "Apri storia del luogo",
          "Salva nel percorso a piedi",
          "Condividi come curiosita del borgo",
        ],
      ),
    ],
  ),
  CulturePage(
    id: "teatro_perugini",
    title: "Teatro Comunale G. Perugini",
    eyebrow: "Cultura",
    summary:
        "Il teatro comunale e uno dei luoghi civici da valorizzare per spettacoli, incontri, assemblee e appuntamenti culturali del borgo.",
    location: "Centro storico di Apecchio",
    duration: "30 - 60 min",
    bestFor: "Spettacoli, incontri, visite culturali",
    contact: "Comune di Apecchio - Ufficio Cultura",
    website: "www.vivereapecchio.it/cultura",
    coverColors: [Color(0xFF4B2E39), Color(0xFFD6A157)],
    icon: Icons.theaters_rounded,
    highlights: [
      "Sala storica del paese",
      "Sede di eventi e assemblee",
      "Luogo utile per il calendario culturale",
    ],
    sections: [
      CultureSection(
        title: "Cosa mostrare",
        body:
            "La pagina raccoglie programma, accesso, capienza indicativa e collegamento agli eventi ospitati, cosi il teatro non resta solo un punto sulla mappa.",
        items: [
          "Eventi in programma",
          "Incontri pubblici e rassegne",
          "Note storiche essenziali",
        ],
      ),
      CultureSection(
        title: "Collegamenti",
        body:
            "La scheda si collega in modo naturale a Comunita, Pro Loco, Biblioteca ed Eventi, per far emergere il teatro come spazio vivo.",
        items: [
          "Apri calendario eventi",
          "Contatta ufficio cultura",
          "Vedi luoghi vicini",
        ],
      ),
    ],
  ),
  CulturePage(
    id: "globo_pace",
    title: "Globo della Pace",
    eyebrow: "Cultura",
    summary:
        "Una curiosita monumentale di Colombara: il grande mappamondo in legno, entrato nel racconto turistico di Apecchio per dimensioni e valore simbolico.",
    location: "Colombara, territorio di Apecchio",
    duration: "30 - 45 min",
    bestFor: "Famiglie, curiosita, gite fuori centro",
    contact: "Ufficio Turistico - +39 0722 99279",
    website: "www.vivereapecchio.it",
    coverColors: [Color(0xFF1E5162), Color(0xFF9DD6C8)],
    icon: Icons.public_rounded,
    highlights: [
      "Mappamondo visitabile in legno",
      "Simbolo di pace e multiculturalita",
      "Tappa fuori dal centro storico",
    ],
    sections: [
      CultureSection(
        title: "Esperienza",
        body:
            "Il Globo della Pace puo diventare una scheda turistica autonoma: posizione, storia, foto e indicazioni per inserirlo in un giro piu ampio.",
        items: [
          "Raggiungibile in auto",
          "Da abbinare a Monte Nerone e frazioni",
          "Buono per percorsi famiglia",
        ],
      ),
      CultureSection(
        title: "In app",
        body:
            "La pagina puo ospitare navigazione, tempi di visita e link ai contenuti multimediali della comunita.",
        items: [
          "Apri indicazioni",
          "Salva tra i preferiti",
          "Vedi foto e racconti",
        ],
      ),
    ],
  ),
];

final Map<String, CulturePage> _culturePagesById = {
  for (final page in _culturePages) page.id: page,
};

class CulturePageScreen extends StatelessWidget {
  const CulturePageScreen({super.key, required this.page});

  final CulturePage page;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F5EF),
        title: Text(page.eyebrow),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _CultureHero(page: page),
          const SizedBox(height: 18),
          _CultureFactGrid(page: page),
          const SizedBox(height: 22),
          const Text(
            "In evidenza",
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _CultureHighlights(items: page.highlights),
          const SizedBox(height: 22),
          for (final section in page.sections) _CultureSectionCard(section),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Aprirebbe ${page.website}")),
              );
            },
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text("Apri approfondimento"),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D57),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _CultureHero extends StatelessWidget {
  const _CultureHero({required this.page});

  final CulturePage page;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: page.coverColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              page.icon,
              color: Colors.white.withValues(alpha: 0.48),
              size: 72,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                page.eyebrow.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                page.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  height: 0.98,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                page.summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CultureFactGrid extends StatelessWidget {
  const _CultureFactGrid({required this.page});

  final CulturePage page;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        final width =
            compact ? constraints.maxWidth : (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _CultureFactCard(
              width: width,
              icon: Icons.place_rounded,
              title: "Dove",
              value: page.location,
            ),
            _CultureFactCard(
              width: width,
              icon: Icons.schedule_rounded,
              title: "Durata",
              value: page.duration,
            ),
            _CultureFactCard(
              width: width,
              icon: Icons.groups_rounded,
              title: "Ideale per",
              value: page.bestFor,
            ),
            _CultureFactCard(
              width: width,
              icon: Icons.mail_rounded,
              title: "Contatti",
              value: page.contact,
            ),
          ],
        );
      },
    );
  }
}

class _CultureFactCard extends StatelessWidget {
  const _CultureFactCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.value,
  });

  final double width;
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        constraints: const BoxConstraints(minHeight: 92),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF2E7D57)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CultureHighlights extends StatelessWidget {
  const _CultureHighlights({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Chip(
            avatar: const Icon(Icons.star_rounded, size: 17),
            label: Text(item),
            backgroundColor: Colors.white,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800),
            side: BorderSide.none,
          ),
      ],
    );
  }
}

class _CultureSectionCard extends StatelessWidget {
  const _CultureSectionCard(this.section);

  final CultureSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(section.body, style: const TextStyle(height: 1.35)),
          const SizedBox(height: 12),
          for (final item in section.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: Color(0xFF2E7D57),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class FinalInfoPage {
  const FinalInfoPage({
    required this.id,
    required this.familyId,
    required this.familyLabel,
    required this.title,
    required this.eyebrow,
    required this.summary,
    required this.primaryActionLabel,
    required this.actionFeedback,
    required this.coverColors,
    required this.icon,
    required this.facts,
    required this.highlights,
    required this.sections,
  });

  final String id;
  final String familyId;
  final String familyLabel;
  final String title;
  final String eyebrow;
  final String summary;
  final String primaryActionLabel;
  final String actionFeedback;
  final List<Color> coverColors;
  final IconData icon;
  final List<FinalInfoFact> facts;
  final List<String> highlights;
  final List<FinalInfoSection> sections;
}

class FinalInfoFact {
  const FinalInfoFact({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;
}

class FinalInfoSection {
  const FinalInfoSection({
    required this.title,
    required this.body,
    required this.items,
  });

  final String title;
  final String body;
  final List<String> items;
}

FinalInfoPage _finalPage({
  required String id,
  required String familyId,
  required String familyLabel,
  required String title,
  required String eyebrow,
  required String summary,
  required String primaryActionLabel,
  required String actionFeedback,
  required IconData icon,
  required List<Color> coverColors,
  required String access,
  required String timing,
  required String contact,
  required List<String> highlights,
  required String actionBody,
  required List<String> actionItems,
  required String detailBody,
  required List<String> detailItems,
}) {
  return FinalInfoPage(
    id: id,
    familyId: familyId,
    familyLabel: familyLabel,
    title: title,
    eyebrow: eyebrow,
    summary: summary,
    primaryActionLabel: primaryActionLabel,
    actionFeedback: actionFeedback,
    icon: icon,
    coverColors: coverColors,
    facts: [
      FinalInfoFact(icon: Icons.place_rounded, title: "Accesso", value: access),
      FinalInfoFact(
        icon: Icons.schedule_rounded,
        title: "Quando",
        value: timing,
      ),
      FinalInfoFact(
        icon: Icons.support_agent_rounded,
        title: "Contatto",
        value: contact,
      ),
    ],
    highlights: highlights,
    sections: [
      FinalInfoSection(
        title: "Cosa puoi fare",
        body: actionBody,
        items: actionItems,
      ),
      FinalInfoSection(
        title: "Dettagli operativi",
        body: detailBody,
        items: detailItems,
      ),
    ],
  );
}

final List<FinalInfoPage> _finalInfoPages = [
  _finalPage(
    id: "farmacia",
    familyId: "servizi_utili",
    familyLabel: "Servizi utili",
    title: "Farmacie",
    eyebrow: "Salute quotidiana",
    summary:
        "Una scheda rapida per trovare farmacie, turni, orari e contatti sanitari essenziali senza cercare fuori dall'app.",
    primaryActionLabel: "Chiama farmacia",
    actionFeedback: "Mockup: chiamerebbe la farmacia di turno.",
    icon: Icons.local_hospital_rounded,
    coverColors: const [Color(0xFF1D5D57), Color(0xFF8BC5A1)],
    access: "Farmacia del centro e turni territoriali",
    timing: "Orari e reperibilita da verificare in giornata",
    contact: "Farmacia, guardia medica, emergenza 112",
    highlights: const [
      "Turno in evidenza",
      "Indicazioni rapide",
      "Numeri sanitari utili",
    ],
    actionBody:
        "La pagina mette davanti le azioni che servono quando il bisogno e immediato.",
    actionItems: const [
      "Aprire chiamata alla farmacia",
      "Vedere indirizzo e percorso",
      "Controllare note su turno e reperibilita",
    ],
    detailBody:
        "Nel prodotto reale questa pagina puo agganciarsi a un feed comunale o regionale dei turni.",
    detailItems: const [
      "Mostrare ultimo aggiornamento disponibile",
      "Separare farmacie, guardia medica e numeri di emergenza",
      "Evitare prenotazioni sanitarie dentro il mockup",
    ],
  ),
  _finalPage(
    id: "trasporti",
    familyId: "servizi_utili",
    familyLabel: "Servizi utili",
    title: "Trasporti",
    eyebrow: "Muoversi ad Apecchio",
    summary:
        "Collegamenti, fermate, navette evento e alternative per raggiungere centro, frazioni e punti outdoor.",
    primaryActionLabel: "Apri percorso",
    actionFeedback: "Mockup: aprirebbe il percorso verso la fermata scelta.",
    icon: Icons.directions_bus_rounded,
    coverColors: const [Color(0xFF22577A), Color(0xFF80ED99)],
    access: "Fermate locali, parcheggi, navette evento",
    timing: "Linee feriali, festivi ed eventi speciali",
    contact: "Comune, trasporto locale, info turistiche",
    highlights: const [
      "Fermata piu vicina",
      "Navette per eventi",
      "Parcheggi consigliati",
    ],
    actionBody:
        "La scheda aiuta residenti e visitatori a scegliere subito come arrivare o rientrare.",
    actionItems: const [
      "Aprire percorso verso fermata o parcheggio",
      "Vedere note per eventi affollati",
      "Controllare collegamenti con frazioni e sentieri",
    ],
    detailBody:
        "I dati sono predisposti per essere sostituiti da orari ufficiali quando saranno disponibili.",
    detailItems: const [
      "Separare mobilita ordinaria e mobilita evento",
      "Evidenziare tratte con bassa frequenza",
      "Tenere un contatto rapido per informazioni aggiornate",
    ],
  ),
  _finalPage(
    id: "bancomat",
    familyId: "servizi_utili",
    familyLabel: "Servizi utili",
    title: "Bancomat",
    eyebrow: "Pagamenti e contante",
    summary:
        "Punti dove ritirare contante, pagare e orientarsi tra sportelli, servizi bancari e modalita digitali.",
    primaryActionLabel: "Trova sportello",
    actionFeedback: "Mockup: aprirebbe la mappa degli sportelli disponibili.",
    icon: Icons.atm_rounded,
    coverColors: const [Color(0xFF264653), Color(0xFFE9C46A)],
    access: "Sportelli e servizi pagamento nel territorio",
    timing: "Disponibilita da verificare in tempo reale",
    contact: "Istituti, esercenti, Comune",
    highlights: const [
      "Sportelli vicini",
      "Pagamenti digitali",
      "Avvisi su disponibilita",
    ],
    actionBody:
        "La pagina evita giri inutili, soprattutto per visitatori e durante eventi con alta affluenza.",
    actionItems: const [
      "Aprire posizione dello sportello",
      "Vedere alternative per pagamenti digitali",
      "Segnalare sportello non disponibile",
    ],
    detailBody:
        "La UI resta neutra e informativa: nessun dato bancario viene gestito dal mockup.",
    detailItems: const [
      "Nessuna raccolta di credenziali",
      "Solo informazioni logistiche",
      "Indicazioni compatibili con privacy e sicurezza",
    ],
  ),
  _finalPage(
    id: "salute",
    familyId: "servizi_utili",
    familyLabel: "Servizi utili",
    title: "Salute",
    eyebrow: "Numeri e presidi",
    summary:
        "Una pagina sobria per numeri sanitari, guardia medica, indicazioni di emergenza e presidi vicini.",
    primaryActionLabel: "Chiama numero utile",
    actionFeedback: "Mockup: aprirebbe il numero sanitario selezionato.",
    icon: Icons.health_and_safety_rounded,
    coverColors: const [Color(0xFF2D6A4F), Color(0xFF95D5B2)],
    access: "Guardia medica, emergenze, presidi vicini",
    timing: "Emergenze sempre 112; altri servizi su orario",
    contact: "112, guardia medica, Comune",
    highlights: const [
      "Emergenza separata",
      "Guardia medica",
      "Presidi vicini",
    ],
    actionBody:
        "La gerarchia distingue emergenze vere, bisogni non urgenti e informazioni logistiche.",
    actionItems: const [
      "Mettere il 112 sempre riconoscibile",
      "Aprire scheda guardia medica",
      "Mostrare indirizzo dei presidi piu vicini",
    ],
    detailBody:
        "Il mockup non sostituisce indicazioni sanitarie: organizza contatti e percorsi.",
    detailItems: const [
      "Nessuna diagnosi o triage",
      "Testi brevi e leggibili in stress",
      "Ultimo aggiornamento ben visibile nel prodotto reale",
    ],
  ),
  _finalPage(
    id: "sindaco_giunta",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Sindaco e Giunta",
    eyebrow: "Amministrazione comunale",
    summary:
        "Scheda istituzionale per conoscere amministratori, deleghe e riferimenti rapidi del Comune.",
    primaryActionLabel: "Contatta segreteria",
    actionFeedback: "Mockup: aprirebbe la segreteria comunale.",
    icon: Icons.groups_rounded,
    coverColors: const [Color(0xFF203B5B), Color(0xFF6AA1C8)],
    access: "Palazzo comunale e canali istituzionali",
    timing: "Ricevimento su appuntamento",
    contact: "Segreteria del Comune",
    highlights: const [
      "Deleghe leggibili",
      "Ricevimento",
      "Contatto istituzionale",
    ],
    actionBody:
        "Il cittadino deve capire a chi rivolgersi senza attraversare pagine amministrative dense.",
    actionItems: const [
      "Vedere composizione e deleghe",
      "Aprire contatto segreteria",
      "Prenotare un incontro quando previsto",
    ],
    detailBody:
        "La pagina resta informativa, con rimando agli atti ufficiali quando servono contenuti formali.",
    detailItems: const [
      "Separare ruoli politici e uffici",
      "Mantenere dati aggiornabili da fonte comunale",
      "Collegare sedute e comunicazioni pubbliche",
    ],
  ),
  _finalPage(
    id: "uffici_orari",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Uffici e orari",
    eyebrow: "Sportelli comunali",
    summary:
        "Orari, competenze e modalita di accesso agli uffici comunali, pensati per ridurre telefonate e passaggi a vuoto.",
    primaryActionLabel: "Prenota sportello",
    actionFeedback: "Mockup: aprirebbe la scelta dell'ufficio comunale.",
    icon: Icons.schedule_rounded,
    coverColors: const [Color(0xFF1F4E5F), Color(0xFF9AD1D4)],
    access: "Uffici comunali e sportelli al cittadino",
    timing: "Mattina, rientri e appuntamenti dedicati",
    contact: "Centralino e uffici",
    highlights: const [
      "Orari per ufficio",
      "Accesso su appuntamento",
      "Documenti da portare",
    ],
    actionBody:
        "La pagina trasforma l'elenco degli uffici in una scelta guidata per bisogno.",
    actionItems: const [
      "Scegliere ufficio o servizio",
      "Vedere orari e documenti necessari",
      "Prenotare una fascia disponibile",
    ],
    detailBody:
        "Le informazioni possono essere collegate in futuro a disponibilita reali e notifiche di conferma.",
    detailItems: const [
      "Mostrare eventuali chiusure straordinarie",
      "Rendere chiaro cosa e solo informativo",
      "Evidenziare canali digitali alternativi",
    ],
  ),
  _finalPage(
    id: "rubrica",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Contatti rapidi",
    eyebrow: "Rubrica comunale",
    summary:
        "Rubrica operativa con numeri, email e riferimenti divisi per ufficio, urgenza e tema.",
    primaryActionLabel: "Apri contatto",
    actionFeedback: "Mockup: aprirebbe il contatto comunale selezionato.",
    icon: Icons.contact_phone_rounded,
    coverColors: const [Color(0xFF24466B), Color(0xFF89C2D9)],
    access: "Telefono, email, PEC, sportelli",
    timing: "Contatti ordinari in orario d'ufficio",
    contact: "Centralino comunale",
    highlights: const [
      "Uffici filtrabili",
      "PEC in evidenza",
      "Numeri essenziali",
    ],
    actionBody:
        "La rubrica deve far arrivare al canale giusto in pochi tocchi.",
    actionItems: const [
      "Filtrare per ufficio",
      "Aprire chiamata o email",
      "Copiare PEC e riferimenti formali",
    ],
    detailBody:
        "Nel mockup i contatti sono dimostrativi, ma la struttura e pronta per dati ufficiali.",
    detailItems: const [
      "Separare canali urgenti e ordinari",
      "Mostrare responsabilita dell'ufficio",
      "Evitare numeri duplicati senza contesto",
    ],
  ),
  _finalPage(
    id: "diretta",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Diretta sedute",
    eyebrow: "Consiglio comunale",
    summary:
        "Accesso semplice alle sedute in diretta, con stato corrente, prossimo orario e canale video.",
    primaryActionLabel: "Apri diretta",
    actionFeedback: "Mockup: aprirebbe la diretta del consiglio.",
    icon: Icons.live_tv_rounded,
    coverColors: const [Color(0xFF2B4162), Color(0xFF7B9ACC)],
    access: "Canale streaming istituzionale",
    timing: "Solo durante sedute programmate",
    contact: "Segreteria consiglio",
    highlights: const ["Stato live", "Prossima seduta", "Ordine del giorno"],
    actionBody:
        "La pagina mette insieme streaming e contesto, cosi la diretta non resta un link isolato.",
    actionItems: const [
      "Aprire il video live",
      "Consultare ordine del giorno",
      "Vedere note tecniche se la seduta non e iniziata",
    ],
    detailBody:
        "Quando non c'e una seduta live, la stessa pagina orienta verso registrazioni e documenti.",
    detailItems: const [
      "Mostrare stato non in diretta",
      "Rimandare alle sedute registrate",
      "Non simulare votazioni o partecipazione",
    ],
  ),
  _finalPage(
    id: "registrazioni",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Sedute registrate",
    eyebrow: "Consiglio comunale",
    summary:
        "Archivio consultabile delle sedute precedenti, con data, tema e link a materiali collegati.",
    primaryActionLabel: "Apri archivio",
    actionFeedback: "Mockup: aprirebbe l'archivio video delle sedute.",
    icon: Icons.video_library_rounded,
    coverColors: const [Color(0xFF293241), Color(0xFF98C1D9)],
    access: "Archivio video e documenti",
    timing: "Disponibile dopo pubblicazione",
    contact: "Segreteria consiglio",
    highlights: const [
      "Ricerca per data",
      "Temi principali",
      "Documenti collegati",
    ],
    actionBody:
        "L'archivio deve aiutare a ritrovare una seduta senza conoscere gia il numero dell'atto.",
    actionItems: const [
      "Filtrare per mese",
      "Aprire video registrato",
      "Collegare delibere e ordine del giorno",
    ],
    detailBody:
        "La pagina mantiene separata la consultazione informale dagli atti con valore ufficiale.",
    detailItems: const [
      "Indicare stato di pubblicazione",
      "Aggiungere trascrizioni solo se disponibili",
      "Rimandare agli atti per versioni ufficiali",
    ],
  ),
  _finalPage(
    id: "ordine_giorno",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Ordine del giorno",
    eyebrow: "Consiglio comunale",
    summary:
        "Punti in discussione, allegati e stato della prossima seduta organizzati per lettura veloce.",
    primaryActionLabel: "Apri documento",
    actionFeedback: "Mockup: aprirebbe l'ordine del giorno ufficiale.",
    icon: Icons.list_alt_rounded,
    coverColors: const [Color(0xFF264653), Color(0xFFA8DADC)],
    access: "Documenti pubblicati dal Comune",
    timing: "Prima della seduta",
    contact: "Segreteria generale",
    highlights: const [
      "Punti numerati",
      "Allegati",
      "Collegamento alla seduta",
    ],
    actionBody:
        "La scheda traduce il documento in un riepilogo navigabile senza togliere valore all'atto ufficiale.",
    actionItems: const [
      "Aprire PDF ufficiale",
      "Vedere punti principali",
      "Collegare diretta e registrazione",
    ],
    detailBody:
        "Nel prodotto reale ogni punto puo aprire delibere, allegati e materiali correlati.",
    detailItems: const [
      "Mantenere il PDF come fonte primaria",
      "Mostrare data e numero seduta",
      "Evidenziare aggiornamenti o integrazioni",
    ],
  ),
  _finalPage(
    id: "albo_pretorio",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Albo pretorio",
    eyebrow: "Atti e trasparenza",
    summary:
        "Accesso agli atti pubblicati, con categorie, scadenze e ricerca semplificata.",
    primaryActionLabel: "Consulta albo",
    actionFeedback: "Mockup: aprirebbe l'albo pretorio online.",
    icon: Icons.folder_shared_rounded,
    coverColors: const [Color(0xFF1D3557), Color(0xFFA8DADC)],
    access: "Albo pretorio digitale",
    timing: "Pubblicazioni con scadenza",
    contact: "Segreteria e protocollo",
    highlights: const [
      "Atti in pubblicazione",
      "Scadenze",
      "Filtro per categoria",
    ],
    actionBody:
        "L'utente deve capire se un atto e pubblicato, fino a quando e dove aprirlo.",
    actionItems: const [
      "Aprire elenco atti",
      "Filtrare per categoria",
      "Vedere scadenza di pubblicazione",
    ],
    detailBody:
        "Il mockup non conserva atti: prepara solo una navigazione comprensibile verso la fonte ufficiale.",
    detailItems: const [
      "Fonte ufficiale sempre riconoscibile",
      "Nessuna copia non verificata",
      "Link a trasparenza quando pertinente",
    ],
  ),
  _finalPage(
    id: "delibere",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Delibere e determine",
    eyebrow: "Atti e trasparenza",
    summary:
        "Archivio orientato ai bisogni: delibere, determine e documenti collegati con ricerca chiara.",
    primaryActionLabel: "Cerca atto",
    actionFeedback: "Mockup: aprirebbe la ricerca degli atti.",
    icon: Icons.description_rounded,
    coverColors: const [Color(0xFF2F3E46), Color(0xFF84A98C)],
    access: "Archivio atti amministrativi",
    timing: "Consultazione continua",
    contact: "Segreteria generale",
    highlights: const ["Ricerca per anno", "Tipo atto", "Documenti collegati"],
    actionBody:
        "La pagina serve cittadini che cercano un atto specifico e cittadini che partono da un tema.",
    actionItems: const [
      "Cercare per parola chiave",
      "Filtrare per anno e tipologia",
      "Aprire allegati disponibili",
    ],
    detailBody:
        "Il contenuto ufficiale resta nel sistema documentale del Comune.",
    detailItems: const [
      "Mostrare numero e data atto",
      "Segnalare eventuale allegato assente",
      "Collegare sedute quando utile",
    ],
  ),
  _finalPage(
    id: "bandi",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Bandi e concorsi",
    eyebrow: "Atti e opportunita",
    summary:
        "Scadenze, requisiti e documenti per bandi, avvisi pubblici e concorsi comunali.",
    primaryActionLabel: "Apri bando",
    actionFeedback: "Mockup: aprirebbe il bando selezionato.",
    icon: Icons.campaign_rounded,
    coverColors: const [Color(0xFF3D405B), Color(0xFFE07A5F)],
    access: "Avvisi e bandi pubblicati",
    timing: "Scadenze in evidenza",
    contact: "Ufficio competente",
    highlights: const [
      "Scadenza chiara",
      "Documenti richiesti",
      "Stato candidatura",
    ],
    actionBody:
        "La pagina mette in primo piano la scadenza e i passaggi da fare.",
    actionItems: const [
      "Aprire avviso ufficiale",
      "Vedere requisiti principali",
      "Preparare documenti richiesti",
    ],
    detailBody:
        "Nel mockup le candidature non vengono inviate; la CTA rimanda alla fonte ufficiale.",
    detailItems: const [
      "Distinguere aperto, in chiusura e scaduto",
      "Mostrare ufficio responsabile",
      "Rendere scaricabili allegati e moduli",
    ],
  ),
  _finalPage(
    id: "pagamenti",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Pagamenti e tributi",
    eyebrow: "Servizi al cittadino",
    summary:
        "Accesso guidato a pagamenti, tributi, avvisi e informazioni prima di procedere su canali ufficiali.",
    primaryActionLabel: "Avvia pagamento",
    actionFeedback: "Mockup: aprirebbe il portale pagamenti ufficiale.",
    icon: Icons.payments_rounded,
    coverColors: const [Color(0xFF2A6F97), Color(0xFFBDE0FE)],
    access: "Portale pagamenti e ufficio tributi",
    timing: "Scadenze tributarie e avvisi",
    contact: "Ufficio tributi",
    highlights: const ["PagoPA", "Avvisi", "Scadenze"],
    actionBody:
        "La pagina prepara il cittadino prima del portale esterno, riducendo errori e confusione.",
    actionItems: const [
      "Scegliere tipologia pagamento",
      "Aprire canale ufficiale",
      "Vedere cosa serve prima di iniziare",
    ],
    detailBody:
        "Il mockup non tratta denaro: simula solo l'ingresso al servizio.",
    detailItems: const [
      "Nessun dato di carta salvato",
      "Rimando esplicito al portale ufficiale",
      "Riepilogo informativo prima del click",
    ],
  ),
  _finalPage(
    id: "appuntamenti",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Prenota appuntamento",
    eyebrow: "Sportelli comunali",
    summary:
        "Prenotazione guidata per uffici e servizi, con motivo, documenti necessari e fascia richiesta.",
    primaryActionLabel: "Scegli ufficio",
    actionFeedback: "Mockup: aprirebbe la selezione della fascia.",
    icon: Icons.event_available_rounded,
    coverColors: const [Color(0xFF006D77), Color(0xFF83C5BE)],
    access: "Sportelli su appuntamento",
    timing: "Fasce disponibili secondo ufficio",
    contact: "Centralino e ufficio scelto",
    highlights: const ["Scelta motivo", "Promemoria", "Documenti necessari"],
    actionBody:
        "Il flusso mette prima il bisogno del cittadino e poi l'ufficio competente.",
    actionItems: const [
      "Scegliere servizio",
      "Selezionare fascia desiderata",
      "Ricevere promemoria in app",
    ],
    detailBody:
        "Il mockup simula l'invio; nel prodotto reale servira conferma dal calendario comunale.",
    detailItems: const [
      "Gestire annullamento e spostamento",
      "Mostrare documenti da portare",
      "Evitare doppie prenotazioni",
    ],
  ),
  _finalPage(
    id: "certificati",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Certificati anagrafici",
    eyebrow: "Servizi al cittadino",
    summary:
        "Guida ai certificati disponibili, con differenza tra richiesta online, sportello e documenti necessari.",
    primaryActionLabel: "Richiedi certificato",
    actionFeedback: "Mockup: aprirebbe la richiesta del certificato.",
    icon: Icons.badge_rounded,
    coverColors: const [Color(0xFF355070), Color(0xFFB8C0FF)],
    access: "Servizi anagrafici",
    timing: "Secondo tipologia e canale",
    contact: "Ufficio anagrafe",
    highlights: const [
      "Tipi certificato",
      "Online o sportello",
      "Documenti richiesti",
    ],
    actionBody:
        "La pagina aiuta a scegliere il certificato corretto prima di iniziare la richiesta.",
    actionItems: const [
      "Scegliere tipologia",
      "Vedere canale disponibile",
      "Preparare documento di identita",
    ],
    detailBody:
        "Per richieste con valore legale il mockup rimanda sempre ai canali ufficiali.",
    detailItems: const [
      "Indicare eventuali costi o marche",
      "Mostrare tempi stimati",
      "Non generare certificati nel mockup",
    ],
  ),
  _finalPage(
    id: "segnalazioni",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Segnalazioni al Comune",
    eyebrow: "Cura del territorio",
    summary:
        "Invio guidato di segnalazioni su manutenzione, decoro, viabilita e servizi pubblici.",
    primaryActionLabel: "Invia segnalazione",
    actionFeedback: "Mockup: salverebbe la segnalazione per l'ufficio.",
    icon: Icons.report_problem_rounded,
    coverColors: const [Color(0xFF6A4C93), Color(0xFFFFCA3A)],
    access: "Modulo segnalazioni e uffici competenti",
    timing: "Presa in carico secondo priorita",
    contact: "URP o ufficio tecnico",
    highlights: const [
      "Categoria problema",
      "Foto e posizione",
      "Stato pratica",
    ],
    actionBody:
        "Il cittadino deve poter inviare una segnalazione chiara senza conoscere l'ufficio responsabile.",
    actionItems: const [
      "Scegliere categoria",
      "Aggiungere posizione e foto",
      "Seguire stato di lavorazione",
    ],
    detailBody:
        "Nel mockup non viene inviata una pratica reale, ma il flusso definisce l'esperienza finale.",
    detailItems: const [
      "Separare emergenze da segnalazioni ordinarie",
      "Mostrare privacy per foto e posizione",
      "Notificare aggiornamenti di stato",
    ],
  ),
  _finalPage(
    id: "scuola",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Servizi scolastici",
    eyebrow: "Scuola e famiglie",
    summary:
        "Mensa, trasporto, calendario e avvisi utili alle famiglie, raccolti in un unico punto.",
    primaryActionLabel: "Apri servizi scuola",
    actionFeedback: "Mockup: aprirebbe i servizi scolastici.",
    icon: Icons.school_rounded,
    coverColors: const [Color(0xFF006D77), Color(0xFFFFDDD2)],
    access: "Scuola, Comune, servizi famiglia",
    timing: "Anno scolastico e scadenze iscrizione",
    contact: "Ufficio scuola",
    highlights: const ["Mensa", "Trasporto scolastico", "Avvisi famiglie"],
    actionBody:
        "La pagina ordina servizi ricorrenti e scadenze stagionali per genitori e studenti.",
    actionItems: const [
      "Consultare calendario e avvisi",
      "Aprire richiesta mensa o trasporto",
      "Vedere contatti scuola-Comune",
    ],
    detailBody:
        "Quando collegata ai sistemi reali, la pagina puo diventare un cruscotto famiglia.",
    detailItems: const [
      "Mostrare solo contenuti pertinenti all'anno corrente",
      "Distinguere moduli da semplici avvisi",
      "Prevedere notifiche per scadenze",
    ],
  ),
  _finalPage(
    id: "mobilita",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Viabilita e trasporto locale",
    eyebrow: "Mobilita pubblica",
    summary:
        "Avvisi su strade, cantieri, ordinanze, parcheggi e collegamenti locali.",
    primaryActionLabel: "Vedi avvisi",
    actionFeedback: "Mockup: aprirebbe gli avvisi di mobilita.",
    icon: Icons.traffic_rounded,
    coverColors: const [Color(0xFF495057), Color(0xFFFFD166)],
    access: "Strade comunali, parcheggi, trasporto locale",
    timing: "Avvisi temporanei e ordinanze",
    contact: "Polizia locale e ufficio tecnico",
    highlights: const ["Cantieri", "Ordinanze", "Parcheggi evento"],
    actionBody:
        "La pagina separa mobilita quotidiana e avvisi temporanei che cambiano il comportamento del cittadino.",
    actionItems: const [
      "Consultare avvisi attivi",
      "Aprire mappa delle modifiche",
      "Vedere alternative consigliate",
    ],
    detailBody:
        "La stessa struttura serve per eventi, neve, lavori e chiusure stradali.",
    detailItems: const [
      "Mostrare periodo di validita",
      "Evidenziare ordinanze ufficiali",
      "Collegare notifiche locali",
    ],
  ),
  _finalPage(
    id: "rifiuti",
    familyId: "myapecchio",
    familyLabel: "myApecchio",
    title: "Raccolta rifiuti",
    eyebrow: "Ambiente",
    summary:
        "Calendario raccolta, regole di conferimento, ingombranti e avvisi ambientali.",
    primaryActionLabel: "Apri calendario",
    actionFeedback: "Mockup: aprirebbe il calendario della raccolta.",
    icon: Icons.recycling_rounded,
    coverColors: const [Color(0xFF386641), Color(0xFFA7C957)],
    access: "Calendario e servizi ambientali",
    timing: "Giorni di raccolta e avvisi",
    contact: "Gestore rifiuti e Comune",
    highlights: const ["Calendario", "Ingombranti", "Regole conferimento"],
    actionBody:
        "La pagina deve rispondere alla domanda pratica: cosa espongo, quando e dove.",
    actionItems: const [
      "Vedere prossima raccolta",
      "Consultare regole per frazione",
      "Richiedere ritiro ingombranti",
    ],
    detailBody:
        "Nel prodotto reale notifiche e calendario potranno adattarsi alla zona dell'utente.",
    detailItems: const [
      "Mostrare variazioni festive",
      "Separare centro e frazioni",
      "Evidenziare numero per segnalazioni ambientali",
    ],
  ),
  _finalPage(
    id: "dove_siamo",
    familyId: "territorio",
    familyLabel: "Territorio",
    title: "Dove siamo",
    eyebrow: "Orientamento",
    summary:
        "Una scheda geografica per collocare Apecchio tra Marche, Appennino, valle del Biscubio e Monte Nerone.",
    primaryActionLabel: "Apri indicazioni",
    actionFeedback: "Mockup: aprirebbe le indicazioni verso Apecchio.",
    icon: Icons.location_on_rounded,
    coverColors: const [Color(0xFF31572C), Color(0xFFA7C957)],
    access: "Centro, frazioni e principali direttrici",
    timing: "Utile prima della visita",
    contact: "Ufficio turistico",
    highlights: const [
      "Centro storico",
      "Valle del Biscubio",
      "Strade verso il Nerone",
    ],
    actionBody:
        "La pagina orienta chi arriva da fuori e chi deve spiegare dove si trova un luogo.",
    actionItems: const [
      "Aprire indicazioni verso il centro",
      "Vedere distanze indicative",
      "Collegare parcheggi e punti informativi",
    ],
    detailBody:
        "Nel mockup la mappa resta informativa, ma pronta per coordinate reali.",
    detailItems: const [
      "Distinguere centro e frazioni",
      "Collegare sentieri e punti panoramici",
      "Evidenziare accessi in caso di eventi",
    ],
  ),
  _finalPage(
    id: "monte_nerone",
    familyId: "territorio",
    familyLabel: "Territorio",
    title: "Monte Nerone",
    eyebrow: "Natura e paesaggio",
    summary:
        "Punto cardine del territorio: sentieri, panorami, rifugi, meteo e accessi verso la montagna.",
    primaryActionLabel: "Apri mappa",
    actionFeedback: "Mockup: aprirebbe la mappa del Monte Nerone.",
    icon: Icons.landscape_rounded,
    coverColors: const [Color(0xFF1B4332), Color(0xFF74C69D)],
    access: "Strade, sentieri e rifugi del Nerone",
    timing: "Controllare meteo e luce prima di partire",
    contact: "Guide, rifugi, ufficio turistico",
    highlights: const [
      "Sentieri collegati",
      "Meteo in quota",
      "Rifugi e punti panoramici",
    ],
    actionBody:
        "La scheda collega contenuti turistici, outdoor e sicurezza base prima dell'uscita.",
    actionItems: const [
      "Aprire mappa sentieri",
      "Vedere servizi outdoor collegati",
      "Controllare avvisi e meteo",
    ],
    detailBody:
        "Il Monte Nerone e gia presente in eventi, dining e sentieri: qui diventa una porta unificata.",
    detailItems: const [
      "Rimandare ai sentieri gia implementati",
      "Mostrare rifugi e soste",
      "Evidenziare prudenza in caso di meteo instabile",
    ],
  ),
  _finalPage(
    id: "citta_birra",
    familyId: "territorio",
    familyLabel: "Territorio",
    title: "Citta della Birra",
    eyebrow: "Identita locale",
    summary:
        "La vocazione brassicola di Apecchio raccontata tra acqua, birrifici, ristorazione e alogastronomia.",
    primaryActionLabel: "Scopri itinerario",
    actionFeedback: "Mockup: aprirebbe l'itinerario alogastronomico.",
    icon: Icons.sports_bar_rounded,
    coverColors: const [Color(0xFF6B4F3A), Color(0xFFE4B56A)],
    access: "Birrifici, ristoranti, eventi a tema",
    timing: "Tutto l'anno, forte durante eventi gastronomici",
    contact: "Ufficio turistico e operatori locali",
    highlights: const [
      "Alogastronomia",
      "Birra artigianale",
      "Abbinamenti locali",
    ],
    actionBody:
        "La pagina collega racconto identitario, prodotti locali e luoghi dove vivere l'esperienza.",
    actionItems: const [
      "Aprire prodotti locali",
      "Vedere ristoranti e locali collegati",
      "Scoprire eventi gastronomici",
    ],
    detailBody:
        "Il contenuto valorizza la narrazione senza diventare catalogo commerciale.",
    detailItems: const [
      "Rimandare alle schede food gia presenti",
      "Evidenziare abbinamenti De.C.O.",
      "Collegare calendario eventi",
    ],
  ),
  _finalPage(
    id: "mappa_turistica",
    familyId: "territorio",
    familyLabel: "Territorio",
    title: "Mappa turistica",
    eyebrow: "Esplora il paese",
    summary:
        "Punti di interesse, servizi, percorsi e tappe consigliate in una mappa pensata per la visita.",
    primaryActionLabel: "Apri mappa turistica",
    actionFeedback: "Mockup: aprirebbe la mappa turistica.",
    icon: Icons.map_outlined,
    coverColors: const [Color(0xFF264653), Color(0xFF2A9D8F)],
    access: "Centro, cultura, servizi, natura",
    timing: "Prima e durante la visita",
    contact: "Ufficio turistico",
    highlights: const ["Tappe consigliate", "Servizi vicini", "Percorsi brevi"],
    actionBody:
        "La mappa turistica deve essere piu selettiva della mappa base: poche cose, ben ordinate.",
    actionItems: const [
      "Filtrare per cultura, food, servizi",
      "Salvare tappe in un percorso",
      "Aprire schede gia presenti",
    ],
    detailBody:
        "Nel mockup si collega alla mappa immersiva della home e alle pagine specialistiche.",
    detailItems: const [
      "Mostrare tappe con tempo stimato",
      "Evitare sovraccarico di pin",
      "Adattare suggerimenti a turista o residente",
    ],
  ),
  _finalPage(
    id: "webcam_meteo",
    familyId: "territorio",
    familyLabel: "Territorio",
    title: "Webcam e meteo",
    eyebrow: "Condizioni locali",
    summary:
        "Meteo del borgo e della montagna, webcam, avvisi e suggerimenti prima di eventi o uscite outdoor.",
    primaryActionLabel: "Aggiorna meteo",
    actionFeedback: "Mockup: aggiornerebbe webcam e meteo.",
    icon: Icons.wb_cloudy_rounded,
    coverColors: const [Color(0xFF457B9D), Color(0xFFA8DADC)],
    access: "Borgo, frazioni, Monte Nerone",
    timing: "Da controllare prima di partire",
    contact: "Fonti meteo e Comune",
    highlights: const ["Webcam", "Meteo in quota", "Avvisi utili"],
    actionBody:
        "La pagina aiuta a scegliere attivita e abbigliamento con un colpo d'occhio.",
    actionItems: const [
      "Controllare meteo borgo",
      "Vedere condizioni in montagna",
      "Aprire suggerimenti indoor/outdoor",
    ],
    detailBody:
        "I dati meteo reali potranno arrivare da API dedicate; ora il mockup definisce priorita e layout.",
    detailItems: const [
      "Mostrare ultimo aggiornamento",
      "Separare webcam da previsioni",
      "Collegare eventi al coperto se piove",
    ],
  ),
  _finalPage(
    id: "ss_crocifisso",
    familyId: "spiritualita",
    familyLabel: "Spiritualita",
    title: "Santuario SS. Crocifisso",
    eyebrow: "Luoghi spirituali",
    summary:
        "Scheda di visita, culto e tradizione per uno dei riferimenti religiosi piu sentiti del territorio.",
    primaryActionLabel: "Apri indicazioni",
    actionFeedback: "Mockup: aprirebbe le indicazioni verso il santuario.",
    icon: Icons.church_rounded,
    coverColors: const [Color(0xFF4B3D6B), Color(0xFFD7B46A)],
    access: "Santuario e percorso di visita",
    timing: "Orari da verificare con parrocchia",
    contact: "Parrocchia e ufficio turistico",
    highlights: const [
      "Festa religiosa",
      "Visita raccolta",
      "Collegamento agli eventi",
    ],
    actionBody:
        "La pagina unisce informazioni spirituali, logistiche e calendario delle ricorrenze.",
    actionItems: const [
      "Aprire indicazioni",
      "Vedere eventi collegati",
      "Contattare la parrocchia",
    ],
    detailBody:
        "La scheda mantiene tono rispettoso e pratico, senza sovraccaricare la visita.",
    detailItems: const [
      "Separare culto e visita turistica",
      "Mostrare eventuali accessibilita",
      "Collegare avvisi parrocchiali",
    ],
  ),
  _finalPage(
    id: "madonna_vita",
    familyId: "spiritualita",
    familyLabel: "Spiritualita",
    title: "Madonna della Vita",
    eyebrow: "Luoghi spirituali",
    summary:
        "Una tappa devozionale da raccontare con contesto, indicazioni e collegamenti agli itinerari del borgo.",
    primaryActionLabel: "Vedi luogo",
    actionFeedback: "Mockup: aprirebbe la scheda del luogo.",
    icon: Icons.volunteer_activism_rounded,
    coverColors: const [Color(0xFF66545E), Color(0xFFE8C7A9)],
    access: "Luogo devozionale del territorio",
    timing: "Visita breve o ricorrenze",
    contact: "Parrocchia",
    highlights: const ["Memoria locale", "Percorso spirituale", "Sosta breve"],
    actionBody:
        "La pagina aiuta a inserire la tappa in un percorso piu ampio senza perderne il valore.",
    actionItems: const [
      "Vedere posizione",
      "Leggere breve contesto",
      "Collegare San Martino e santuario",
    ],
    detailBody:
        "La scheda e pensata per essere arricchita con foto e testi verificati dalla comunita.",
    detailItems: const [
      "Mantenere testi brevi",
      "Indicare accesso e rispetto del luogo",
      "Collegare eventi o ricorrenze",
    ],
  ),
  _finalPage(
    id: "san_martino",
    familyId: "spiritualita",
    familyLabel: "Spiritualita",
    title: "San Martino",
    eyebrow: "Parrocchia e arte",
    summary:
        "Chiesa, comunita e patrimonio locale: una scheda per visita, avvisi e riferimenti parrocchiali.",
    primaryActionLabel: "Apri avvisi",
    actionFeedback: "Mockup: aprirebbe gli avvisi di San Martino.",
    icon: Icons.account_balance_rounded,
    coverColors: const [Color(0xFF3D405B), Color(0xFFF2CC8F)],
    access: "Chiesa parrocchiale e centro storico",
    timing: "Orari e celebrazioni da verificare",
    contact: "Parrocchia di San Martino",
    highlights: const ["Chiesa principale", "Avvisi", "Percorso culturale"],
    actionBody:
        "La pagina rende San Martino un punto di connessione tra cultura, fede e vita comunitaria.",
    actionItems: const [
      "Aprire avvisi parrocchiali",
      "Vedere informazioni di visita",
      "Collegare arte e percorso storico",
    ],
    detailBody:
        "Contenuti liturgici e turistici restano separati ma raggiungibili dalla stessa scheda.",
    detailItems: const [
      "Mostrare contatto parrocchia",
      "Indicare rispetto durante celebrazioni",
      "Collegare eventi spirituali",
    ],
  ),
  _finalPage(
    id: "parrocchia",
    familyId: "spiritualita",
    familyLabel: "Spiritualita",
    title: "Parrocchia",
    eyebrow: "Comunita religiosa",
    summary:
        "Contatti, celebrazioni, gruppi e avvisi parrocchiali organizzati per residenti e visitatori.",
    primaryActionLabel: "Contatta parrocchia",
    actionFeedback: "Mockup: aprirebbe i contatti parrocchiali.",
    icon: Icons.diversity_3_rounded,
    coverColors: const [Color(0xFF5A4E7C), Color(0xFFC9ADA7)],
    access: "Parrocchia e gruppi collegati",
    timing: "Celebrazioni, incontri, avvisi",
    contact: "Segreteria parrocchiale",
    highlights: const ["Orari celebrazioni", "Gruppi", "Avvisi"],
    actionBody:
        "La pagina serve chi cerca orari, contatti o attivita senza dover seguire canali separati.",
    actionItems: const [
      "Aprire contatto",
      "Vedere ultimi avvisi",
      "Scoprire gruppi e attivita",
    ],
    detailBody:
        "Nel prodotto reale puo collegarsi a un feed parrocchiale moderato.",
    detailItems: const [
      "Mostrare data dell'avviso",
      "Separare eventi ricorrenti e straordinari",
      "Lasciare chiara la fonte",
    ],
  ),
  _finalPage(
    id: "oratorio",
    familyId: "spiritualita",
    familyLabel: "Spiritualita",
    title: "Oratorio San Martino",
    eyebrow: "Giovani e famiglie",
    summary:
        "Attivita, incontri, spazi educativi e appuntamenti per bambini, ragazzi e famiglie.",
    primaryActionLabel: "Vedi attivita",
    actionFeedback: "Mockup: aprirebbe il calendario dell'oratorio.",
    icon: Icons.child_care_rounded,
    coverColors: const [Color(0xFF7A5AA6), Color(0xFFFFD6A5)],
    access: "Oratorio e spazi parrocchiali",
    timing: "Pomeriggi, estate, appuntamenti speciali",
    contact: "Referenti oratorio",
    highlights: const ["Attivita ragazzi", "Estate", "Famiglie"],
    actionBody:
        "La scheda rende visibili iniziative che spesso circolano solo nel passaparola.",
    actionItems: const [
      "Vedere calendario attivita",
      "Contattare referenti",
      "Salvare appuntamenti per famiglia",
    ],
    detailBody:
        "Nel prodotto reale serviranno attenzione a privacy e contenuti per minori.",
    detailItems: const [
      "Niente dati personali dei minori nel mockup",
      "Comunicazioni gestite da referenti",
      "Calendario semplice e controllato",
    ],
  ),
  _finalPage(
    id: "avvisi_parrocchiali",
    familyId: "spiritualita",
    familyLabel: "Spiritualita",
    title: "Avvisi parrocchiali",
    eyebrow: "Comunicazioni",
    summary:
        "Bacheca ordinata per messe, incontri, ricorrenze, raccolte e appuntamenti della comunita.",
    primaryActionLabel: "Leggi avvisi",
    actionFeedback: "Mockup: aprirebbe la bacheca degli avvisi.",
    icon: Icons.campaign_rounded,
    coverColors: const [Color(0xFF6D597A), Color(0xFFE9C46A)],
    access: "Bacheca parrocchiale",
    timing: "Aggiornamento settimanale o straordinario",
    contact: "Parrocchia",
    highlights: const ["Ultimi avvisi", "Ricorrenze", "Gruppi"],
    actionBody:
        "La pagina mette davanti gli avvisi recenti e permette di ritrovare quelli ancora validi.",
    actionItems: const [
      "Leggere ultimi avvisi",
      "Filtrare per celebrazioni o incontri",
      "Salvare un appuntamento",
    ],
    detailBody:
        "Gli avvisi non devono confondersi con eventi pubblici turistici, ma possono collegarsi al calendario.",
    detailItems: const [
      "Mostrare fonte e data",
      "Evidenziare avvisi scaduti",
      "Collegare solo eventi aperti al pubblico",
    ],
  ),
  _finalPage(
    id: "notizie_paese",
    familyId: "comunita",
    familyLabel: "Comunita",
    title: "Notizie del paese",
    eyebrow: "Bacheca locale",
    summary:
        "Notizie brevi, avvisi civici e racconti dal territorio raccolti in un feed leggibile.",
    primaryActionLabel: "Apri notizie",
    actionFeedback: "Mockup: aprirebbe il feed delle notizie locali.",
    icon: Icons.newspaper_rounded,
    coverColors: const [Color(0xFF5A3E2B), Color(0xFFE1A85F)],
    access: "Comune, associazioni, comunita",
    timing: "Aggiornamenti periodici",
    contact: "Redazione locale o Comune",
    highlights: const ["Avvisi brevi", "Storie locali", "Link a eventi"],
    actionBody:
        "La pagina raccoglie contenuti piccoli ma importanti, senza trasformarli in notifiche invasive.",
    actionItems: const [
      "Leggere notizie recenti",
      "Aprire evento collegato",
      "Filtrare per tema",
    ],
    detailBody:
        "Il feed dovra distinguere comunicazioni ufficiali e racconti di comunita.",
    detailItems: const [
      "Mostrare fonte chiara",
      "Evitare contenuti non verificati",
      "Tenere storico breve e navigabile",
    ],
  ),
  _finalPage(
    id: "pro_loco",
    familyId: "comunita",
    familyLabel: "Comunita",
    title: "Pro Loco",
    eyebrow: "Associazioni",
    summary:
        "Scheda per iniziative, contatti, volontariato e calendario degli appuntamenti promossi dalla Pro Loco.",
    primaryActionLabel: "Contatta Pro Loco",
    actionFeedback: "Mockup: aprirebbe il contatto della Pro Loco.",
    icon: Icons.groups_2_rounded,
    coverColors: const [Color(0xFF386641), Color(0xFFDDA15E)],
    access: "Associazioni e sedi operative",
    timing: "Eventi, sagre, iniziative stagionali",
    contact: "Referenti Pro Loco",
    highlights: const ["Eventi", "Volontariato", "Tradizioni"],
    actionBody:
        "La pagina rende la Pro Loco un ponte tra eventi, territorio e partecipazione.",
    actionItems: const [
      "Vedere prossimi eventi",
      "Aprire contatto referenti",
      "Scoprire come collaborare",
    ],
    detailBody:
        "La scheda puo collegare sagre, calendario eventi e richieste operative.",
    detailItems: const [
      "Separare informazioni pubbliche da gestione interna",
      "Mostrare iniziative attive",
      "Collegare eventi gastronomici",
    ],
  ),
  _finalPage(
    id: "associazioni",
    familyId: "comunita",
    familyLabel: "Comunita",
    title: "Associazioni",
    eyebrow: "Vita locale",
    summary:
        "Panoramica delle associazioni del territorio, con ambiti, contatti e iniziative aperte.",
    primaryActionLabel: "Esplora associazioni",
    actionFeedback: "Mockup: aprirebbe l'elenco delle associazioni.",
    icon: Icons.handshake_rounded,
    coverColors: const [Color(0xFF4A5759), Color(0xFFB0C4B1)],
    access: "Associazioni culturali, sportive, sociali",
    timing: "Attivita durante l'anno",
    contact: "Referenti associativi",
    highlights: const ["Ambiti", "Contatti", "Iniziative aperte"],
    actionBody:
        "La pagina deve aiutare a trovare il gruppo giusto, non solo elencare nomi.",
    actionItems: const [
      "Filtrare per ambito",
      "Vedere iniziative attive",
      "Aprire contatto referente",
    ],
    detailBody:
        "Il mockup prepara una struttura aggiornabile anche da fonti associative.",
    detailItems: const [
      "Mostrare stato attivo",
      "Rendere chiaro chi gestisce la scheda",
      "Collegare eventi e spazi comunali",
    ],
  ),
  _finalPage(
    id: "avis",
    familyId: "comunita",
    familyLabel: "Comunita",
    title: "AVIS",
    eyebrow: "Volontariato",
    summary:
        "Informazioni su donazione, appuntamenti, contatti e iniziative di sensibilizzazione.",
    primaryActionLabel: "Contatta AVIS",
    actionFeedback: "Mockup: aprirebbe il contatto AVIS.",
    icon: Icons.bloodtype_rounded,
    coverColors: const [Color(0xFF9B2226), Color(0xFFFFB4A2)],
    access: "Gruppo AVIS locale e punti donazione",
    timing: "Calendario raccolte e appuntamenti",
    contact: "Referenti AVIS",
    highlights: const ["Donazione", "Appuntamenti", "Sensibilizzazione"],
    actionBody:
        "La pagina rende immediato il contatto e spiega i passaggi senza entrare in ambito medico.",
    actionItems: const [
      "Aprire contatto AVIS",
      "Vedere prossimi appuntamenti",
      "Leggere requisiti generali da fonte ufficiale",
    ],
    detailBody:
        "Per indicazioni sanitarie specifiche si rimanda sempre ai canali AVIS ufficiali.",
    detailItems: const [
      "Nessun questionario sanitario nel mockup",
      "Fonte ufficiale evidenziata",
      "Collegamento a eventi di comunita",
    ],
  ),
  _finalPage(
    id: "biblioteca",
    familyId: "comunita",
    familyLabel: "Comunita",
    title: "Biblioteca comunale",
    eyebrow: "Cultura quotidiana",
    summary:
        "Orari, servizi, prestiti, iniziative e contatti della biblioteca come presidio culturale del paese.",
    primaryActionLabel: "Apri biblioteca",
    actionFeedback: "Mockup: aprirebbe la scheda biblioteca.",
    icon: Icons.local_library_rounded,
    coverColors: const [Color(0xFF3A506B), Color(0xFFBEE3DB)],
    access: "Biblioteca e spazi culturali",
    timing: "Orari di apertura e iniziative",
    contact: "Biblioteca comunale",
    highlights: const ["Prestiti", "Eventi culturali", "Spazi studio"],
    actionBody:
        "La pagina trasforma la biblioteca in un servizio vivo, collegato a cultura e comunita.",
    actionItems: const [
      "Vedere orari",
      "Scoprire iniziative",
      "Contattare la biblioteca",
    ],
    detailBody:
        "In futuro potra collegarsi a catalogo, prenotazioni e mediateca.",
    detailItems: const [
      "Separare servizi ordinari ed eventi",
      "Mostrare chiusure straordinarie",
      "Collegare mediateca e percorsi culturali",
    ],
  ),
  _finalPage(
    id: "mediateca",
    familyId: "comunita",
    familyLabel: "Comunita",
    title: "Mediateca",
    eyebrow: "Archivio e memoria",
    summary:
        "Foto, video, materiali digitali e memoria locale organizzati per tema e raccolta.",
    primaryActionLabel: "Esplora mediateca",
    actionFeedback: "Mockup: aprirebbe la mediateca.",
    icon: Icons.photo_library_rounded,
    coverColors: const [Color(0xFF343A40), Color(0xFFCED4DA)],
    access: "Archivio digitale locale",
    timing: "Consultazione continua",
    contact: "Biblioteca o redazione locale",
    highlights: const ["Foto storiche", "Video", "Raccolte tematiche"],
    actionBody:
        "La mediateca valorizza contenuti che altrimenti restano dispersi tra archivi e social.",
    actionItems: const [
      "Esplorare raccolte",
      "Aprire contenuti collegati ai luoghi",
      "Proporre materiali da verificare",
    ],
    detailBody:
        "Il prodotto reale dovra gestire diritti, liberatorie e fonti dei materiali.",
    detailItems: const [
      "Mostrare autore o fonte",
      "Gestire permessi immagini",
      "Collegare foto a luoghi e storie",
    ],
  ),
  _finalPage(
    id: "foto_giorno",
    familyId: "comunita",
    familyLabel: "Comunita",
    title: "Foto del giorno",
    eyebrow: "Racconto visivo",
    summary:
        "Una piccola finestra quotidiana su paesaggi, dettagli, eventi e vita del paese.",
    primaryActionLabel: "Guarda foto",
    actionFeedback: "Mockup: aprirebbe la foto del giorno.",
    icon: Icons.camera_alt_rounded,
    coverColors: const [Color(0xFF1D3557), Color(0xFFF4A261)],
    access: "Contributi della comunita e archivio",
    timing: "Aggiornamento giornaliero o editoriale",
    contact: "Redazione locale",
    highlights: const [
      "Scatto in evidenza",
      "Luogo collegato",
      "Archivio visuale",
    ],
    actionBody:
        "La pagina e leggera ma utile per far sentire l'app viva ogni giorno.",
    actionItems: const [
      "Vedere foto e luogo",
      "Aprire scheda collegata",
      "Salvare tra preferiti",
    ],
    detailBody:
        "Nel prodotto reale servira moderazione prima della pubblicazione.",
    detailItems: const [
      "Mostrare credito fotografico",
      "Evitare volti non autorizzati",
      "Collegare mediateca e notizie",
    ],
  ),
];

final Map<String, FinalInfoPage> _finalInfoPagesById = {
  for (final page in _finalInfoPages) page.id: page,
};

class FinalInfoPageScreen extends StatefulWidget {
  const FinalInfoPageScreen({super.key, required this.initialPageId});

  final String initialPageId;

  @override
  State<FinalInfoPageScreen> createState() => _FinalInfoPageScreenState();
}

class _FinalInfoPageScreenState extends State<FinalInfoPageScreen> {
  late FinalInfoPage _selectedPage;

  @override
  void initState() {
    super.initState();
    _selectedPage =
        _finalInfoPagesById[widget.initialPageId] ?? _finalInfoPages.first;
  }

  @override
  void didUpdateWidget(covariant FinalInfoPageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPageId != widget.initialPageId) {
      _selectedPage =
          _finalInfoPagesById[widget.initialPageId] ?? _finalInfoPages.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final relatedPages = _finalInfoPages
        .where((page) => page.familyId == _selectedPage.familyId)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F5EF),
        title: Text(_selectedPage.familyLabel),
      ),
      body: ListView(
        key: ValueKey(_selectedPage.id),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _FinalInfoHero(page: _selectedPage),
          const SizedBox(height: 16),
          if (relatedPages.length > 1) ...[
            _FinalInfoSelector(
              pages: relatedPages,
              selectedPage: _selectedPage,
              onChanged: (page) => setState(() => _selectedPage = page),
            ),
            const SizedBox(height: 16),
          ],
          _FinalInfoFactGrid(facts: _selectedPage.facts),
          const SizedBox(height: 22),
          const Text(
            "In evidenza",
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _FinalInfoHighlights(items: _selectedPage.highlights),
          const SizedBox(height: 22),
          for (final section in _selectedPage.sections)
            _FinalInfoSectionCard(section: section),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_selectedPage.actionFeedback)),
              );
            },
            icon: const Icon(Icons.touch_app_rounded),
            label: Text(_selectedPage.primaryActionLabel),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D57),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinalInfoHero extends StatelessWidget {
  const _FinalInfoHero({required this.page});

  final FinalInfoPage page;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 246,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: page.coverColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              page.icon,
              color: Colors.white.withValues(alpha: 0.46),
              size: 76,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                page.eyebrow.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.84),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                page.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  height: 0.98,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                page.summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinalInfoSelector extends StatelessWidget {
  const _FinalInfoSelector({
    required this.pages,
    required this.selectedPage,
    required this.onChanged,
  });

  final List<FinalInfoPage> pages;
  final FinalInfoPage selectedPage;
  final ValueChanged<FinalInfoPage> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final page = pages[index];
          final selected = page.id == selectedPage.id;
          return SizedBox(
            width: 154,
            child: Material(
              color: selected ? const Color(0xFF243C2A) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onChanged(page),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        page.icon,
                        color:
                            selected ? Colors.white : const Color(0xFF2E7D57),
                      ),
                      const Spacer(),
                      Text(
                        page.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w900,
                          height: 1.04,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FinalInfoFactGrid extends StatelessWidget {
  const _FinalInfoFactGrid({required this.facts});

  final List<FinalInfoFact> facts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        final width =
            compact ? constraints.maxWidth : (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final fact in facts)
              _FinalInfoFactCard(width: width, fact: fact),
          ],
        );
      },
    );
  }
}

class _FinalInfoFactCard extends StatelessWidget {
  const _FinalInfoFactCard({required this.width, required this.fact});

  final double width;
  final FinalInfoFact fact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        constraints: const BoxConstraints(minHeight: 92),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(fact.icon, color: const Color(0xFF2E7D57)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fact.title,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fact.value,
                    style: const TextStyle(
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinalInfoHighlights extends StatelessWidget {
  const _FinalInfoHighlights({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Chip(
            avatar: const Icon(Icons.check_circle_rounded, size: 17),
            label: Text(item),
            backgroundColor: Colors.white,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800),
            side: BorderSide.none,
          ),
      ],
    );
  }
}

class _FinalInfoSectionCard extends StatelessWidget {
  const _FinalInfoSectionCard({required this.section});

  final FinalInfoSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(section.body, style: const TextStyle(height: 1.35)),
          const SizedBox(height: 12),
          for (final item in section.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: Color(0xFF2E7D57),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

enum BackofficeSection {
  dashboard,
  page,
  menu,
  events,
  vouchers,
  members,
  stats,
  permissions,
  support,
}

enum BackofficeEventVisibility {
  public,
  orgPage,
  orgMembers,
  group,
  invite,
  municipalInternal,
  council,
}

class BackofficeOrganization {
  BackofficeOrganization({
    required this.id,
    required this.name,
    required this.type,
    required this.shortDescription,
    required this.longDescription,
    required this.address,
    required this.contact,
    required this.opening,
    required this.services,
    required this.coverColors,
    this.coverFitContain = false,
    this.coverFocusX = 0.5,
    this.coverFocusY = 0.5,
  });

  final String id;
  String name;
  String type;
  String shortDescription;
  String longDescription;
  String address;
  String contact;
  String opening;
  List<String> services;
  List<Color> coverColors;
  bool coverFitContain;
  double coverFocusX;
  double coverFocusY;
}

class BackofficeEvent {
  BackofficeEvent({
    required this.id,
    required this.orgId,
    required this.title,
    required this.type,
    required this.date,
    required this.time,
    required this.visibility,
    required this.audience,
    required this.status,
    required this.capacity,
    required this.rsvpCount,
    required this.checkinCount,
    required this.waitlistCount,
    required this.participationTrend,
  });

  final String id;
  final String orgId;
  String title;
  String type;
  String date;
  String time;
  BackofficeEventVisibility visibility;
  String audience;
  String status;
  int capacity;
  int rsvpCount;
  int checkinCount;
  int waitlistCount;
  String participationTrend;
}

class BackofficeMenuItem {
  BackofficeMenuItem({
    required this.id,
    required this.orgId,
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.active,
  });

  final String id;
  final String orgId;
  final String category;
  final String name;
  final String description;
  final String price;
  bool active;
}

class BackofficeMember {
  const BackofficeMember({
    required this.orgId,
    required this.name,
    required this.group,
    required this.role,
  });

  final String orgId;
  final String name;
  final String group;
  final String role;
}

class BackofficeGroup {
  const BackofficeGroup({
    required this.orgId,
    required this.name,
    required this.visibility,
    required this.members,
  });

  final String orgId;
  final String name;
  final String visibility;
  final int members;
}

class BackofficeVoucher {
  const BackofficeVoucher({
    required this.orgId,
    required this.code,
    required this.label,
    required this.status,
    required this.amount,
  });

  final String orgId;
  final String code;
  final String label;
  final String status;
  final String amount;
}

class BackofficeController extends ChangeNotifier {
  BackofficeController.demo()
      : organizations = [
          BackofficeOrganization(
            id: "osteria",
            name: "Osteria Monte Nerone",
            type: "Ristorante",
            shortDescription: "Cucina tipica, prodotti locali e serate.",
            longDescription:
                "Locale nel centro di Apecchio con menu stagionale, piatti del territorio, birre artigianali e piccole degustazioni.",
            address: "Via Roma 12, Apecchio",
            contact: "info@osteria.example · +39 0722 000000",
            opening: "Oggi 12:00-14:30, 19:00-22:00",
            services: ["Prenotazione", "Voucher", "Menu stagionale"],
            coverColors: const [Color(0xFF0B7285), Color(0xFFC97824)],
          ),
          BackofficeOrganization(
            id: "proloco",
            name: "Pro Loco Apecchio",
            type: "Associazione",
            shortDescription: "Eventi, volontariato e territorio.",
            longDescription:
                "Organizzazione locale per iniziative pubbliche, supporto eventi, volontari e valorizzazione della comunita.",
            address: "Piazza del Comune, Apecchio",
            contact: "proloco@apecchio.example",
            opening: "Su appuntamento",
            services: ["Eventi", "Volontari", "Assemblee"],
            coverColors: const [Color(0xFF2F855A), Color(0xFF6A4C93)],
            coverFocusY: 0.45,
          ),
          BackofficeOrganization(
            id: "comune",
            name: "Comune di Apecchio",
            type: "Ente",
            shortDescription: "Servizi comunali e vita pubblica.",
            longDescription:
                "Area istituzionale per coordinare servizi, uffici, comunicazioni, sedute e segnalazioni.",
            address: "Piazza San Martino, Apecchio",
            contact: "segreteria@comune.apecchio.example",
            opening: "Uffici su appuntamento",
            services: ["Segnalazioni", "Uffici", "Sedute"],
            coverColors: const [Color(0xFF1D3557), Color(0xFF89C2D9)],
            coverFocusY: 0.48,
          ),
        ],
        events = [
          BackofficeEvent(
            id: "e1",
            orgId: "osteria",
            title: "Cena degustazione del Monte Nerone",
            type: "Degustazione",
            date: "16/05",
            time: "20:30",
            visibility: BackofficeEventVisibility.public,
            audience: "Tutti",
            status: "In revisione",
            capacity: 42,
            rsvpCount: 34,
            checkinCount: 0,
            waitlistCount: 3,
            participationTrend: "+18%",
          ),
          BackofficeEvent(
            id: "e2",
            orgId: "osteria",
            title: "Briefing staff weekend",
            type: "Riunione interna",
            date: "03/05",
            time: "10:00",
            visibility: BackofficeEventVisibility.orgMembers,
            audience: "Staff attività",
            status: "Pubblicato interno",
            capacity: 8,
            rsvpCount: 7,
            checkinCount: 6,
            waitlistCount: 0,
            participationTrend: "+2",
          ),
          BackofficeEvent(
            id: "e3",
            orgId: "proloco",
            title: "Riunione direttivo Pro Loco",
            type: "Consiglio",
            date: "08/05",
            time: "21:00",
            visibility: BackofficeEventVisibility.group,
            audience: "Direttivo",
            status: "Riservato",
            capacity: 12,
            rsvpCount: 9,
            checkinCount: 0,
            waitlistCount: 0,
            participationTrend: "stabile",
          ),
          BackofficeEvent(
            id: "e4",
            orgId: "comune",
            title: "Consiglio comunale",
            type: "Consiglio",
            date: "12/05",
            time: "18:30",
            visibility: BackofficeEventVisibility.council,
            audience: "Cittadini e consiglieri",
            status: "Pubblico con allegati interni",
            capacity: 80,
            rsvpCount: 28,
            checkinCount: 0,
            waitlistCount: 0,
            participationTrend: "+6%",
          ),
        ],
        menuItems = [
          BackofficeMenuItem(
            id: "m1",
            orgId: "osteria",
            category: "Primi",
            name: "Tagliatelle al tartufo",
            description: "Pasta fresca e tartufo locale.",
            price: "14",
            active: true,
          ),
          BackofficeMenuItem(
            id: "m2",
            orgId: "osteria",
            category: "Secondi",
            name: "Brasato alla birra",
            description: "Cottura lenta con birra artigianale.",
            price: "18",
            active: true,
          ),
        ],
        members = const [
          BackofficeMember(
            orgId: "proloco",
            name: "Maria Rossi",
            group: "Direttivo",
            role: "Proprietario organizzazione",
          ),
          BackofficeMember(
            orgId: "proloco",
            name: "Luca Bianchi",
            group: "Eventi",
            role: "Editor eventi",
          ),
          BackofficeMember(
            orgId: "osteria",
            name: "Giulia Ferri",
            group: "Staff attività",
            role: "Editor menu",
          ),
          BackofficeMember(
            orgId: "osteria",
            name: "Paolo Neri",
            group: "Staff attività",
            role: "Scanner voucher",
          ),
        ],
        groups = const [
          BackofficeGroup(
            orgId: "osteria",
            name: "Staff attività",
            visibility: "Eventi interni e turni",
            members: 6,
          ),
          BackofficeGroup(
            orgId: "proloco",
            name: "Direttivo",
            visibility: "Riunioni riservate",
            members: 7,
          ),
          BackofficeGroup(
            orgId: "proloco",
            name: "Volontari",
            visibility: "Turni e comunicazioni",
            members: 34,
          ),
          BackofficeGroup(
            orgId: "comune",
            name: "Giunta",
            visibility: "Agenda istituzionale",
            members: 6,
          ),
        ],
        vouchers = const [
          BackofficeVoucher(
            orgId: "osteria",
            code: "VCH-5MONTE",
            label: "Sconto 5%",
            status: "Validato",
            amount: "3,40",
          ),
          BackofficeVoucher(
            orgId: "osteria",
            code: "VCH-10NERONE",
            label: "Sconto 10%",
            status: "Disponibile",
            amount: "7,80",
          ),
        ];

  final List<BackofficeOrganization> organizations;
  final List<BackofficeEvent> events;
  final List<BackofficeMenuItem> menuItems;
  final List<BackofficeMember> members;
  final List<BackofficeGroup> groups;
  final List<BackofficeVoucher> vouchers;

  BackofficeOrganization organization(String id) =>
      organizations.firstWhere((org) => org.id == id);

  void addMenuItem(String orgId) {
    menuItems.insert(
      0,
      BackofficeMenuItem(
        id: "m${DateTime.now().millisecondsSinceEpoch}",
        orgId: orgId,
        category: "Specialità",
        name: "Nuova proposta del giorno",
        description: "Descrizione sintetica visibile nella scheda.",
        price: "12",
        active: true,
      ),
    );
    notifyListeners();
  }

  void toggleMenuItem(BackofficeMenuItem item) {
    item.active = !item.active;
    notifyListeners();
  }

  void addEvent(String orgId) {
    events.insert(
      0,
      BackofficeEvent(
        id: "e${DateTime.now().millisecondsSinceEpoch}",
        orgId: orgId,
        title: "Nuovo appuntamento",
        type: "Evento",
        date: "15/05",
        time: "20:30",
        visibility: BackofficeEventVisibility.public,
        audience: "Tutti",
        status: "In revisione",
        capacity: 0,
        rsvpCount: 0,
        checkinCount: 0,
        waitlistCount: 0,
        participationTrend: "nuovo",
      ),
    );
    notifyListeners();
  }

  void setEventStatus(BackofficeEvent event, String status) {
    event.status = status;
    notifyListeners();
  }
}

final BackofficeController appBackoffice = BackofficeController.demo();

class BackofficeScreen extends StatefulWidget {
  const BackofficeScreen({super.key, required this.initialProfile});

  final UserProfile initialProfile;

  @override
  State<BackofficeScreen> createState() => _BackofficeScreenState();
}

class _BackofficeScreenState extends State<BackofficeScreen> {
  late UserProfile _role;
  late String _organizationId;
  BackofficeSection _section = BackofficeSection.dashboard;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shortController = TextEditingController();
  final TextEditingController _servicesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _role = widget.initialProfile;
    _organizationId = _defaultOrganizationFor(_role);
    _syncEditors();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appBackoffice,
      builder: (context, _) {
        final wide = MediaQuery.sizeOf(context).width >= 920;
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7F1),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF5F7F1),
            title: const Text("Backoffice APPecchio"),
            actions: [
              IconButton(
                tooltip: "Cambia ruolo",
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                ),
                icon: const Icon(Icons.switch_account_rounded),
              ),
            ],
          ),
          body: wide
              ? Row(
                  children: [
                    SizedBox(width: 290, child: _sideRail()),
                    const VerticalDivider(width: 1),
                    Expanded(child: _content()),
                  ],
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [_sideRail(compact: true), _contentBody()],
                ),
        );
      },
    );
  }

  Widget _sideRail({bool compact = false}) {
    return ListView(
      padding: EdgeInsets.all(compact ? 0 : 16),
      shrinkWrap: compact,
      children: [
        _BackofficeCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ruolo",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<UserProfile>(
                isExpanded: true,
                initialValue: _role,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _backofficeProfiles
                    .map(
                      (profile) => DropdownMenuItem<UserProfile>(
                        value: profile,
                        child: Text(_profileBackofficeLabel(profile)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _role = value;
                    _organizationId = _defaultOrganizationFor(_role);
                    _section = BackofficeSection.dashboard;
                    _syncEditors();
                  });
                },
              ),
              const SizedBox(height: 12),
              const Text(
                "Contesto",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _organizationId,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _visibleOrganizations()
                    .map(
                      (org) => DropdownMenuItem<String>(
                        value: org.id,
                        child: Text(org.name, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: _canChangeOrganization()
                    ? (value) {
                        if (value == null) return;
                        setState(() {
                          _organizationId = value;
                          _syncEditors();
                        });
                      }
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (compact)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final section in _sectionsForRole())
                ChoiceChip(
                  key: ValueKey("backoffice-section-${section.name}"),
                  avatar: Icon(_sectionIcon(section), size: 18),
                  label: Text(_sectionLabel(section)),
                  selected: _section == section,
                  selectedColor: const Color(0xFF2E7D57),
                  labelStyle: TextStyle(
                    color: _section == section ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w800,
                  ),
                  onSelected: (_) => setState(() => _section = section),
                ),
            ],
          )
        else
          for (final section in _sectionsForRole())
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                key: ValueKey("backoffice-section-${section.name}"),
                selected: _section == section,
                selectedTileColor: const Color(0xFFE3F1E8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: Icon(_sectionIcon(section)),
                title: Text(
                  _sectionLabel(section),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                onTap: () => setState(() => _section = section),
              ),
            ),
      ],
    );
  }

  Widget _content() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [_contentBody()],
    );
  }

  Widget _contentBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BackofficeHero(
          title: _section == BackofficeSection.dashboard
              ? _dashboardTitle()
              : _sectionLabel(_section),
          subtitle: _dashboardSubtitle(),
          action: _role == UserProfile.mayor ? "Report eventi" : "Apri eventi",
          onAction: () => setState(() => _section = BackofficeSection.events),
        ),
        const SizedBox(height: 16),
        switch (_section) {
          BackofficeSection.dashboard => _dashboard(),
          BackofficeSection.page => _pageEditor(),
          BackofficeSection.menu => _menuList(),
          BackofficeSection.events => _events(),
          BackofficeSection.vouchers => _vouchers(),
          BackofficeSection.members => _members(),
          BackofficeSection.stats => _stats(),
          BackofficeSection.permissions => _permissions(),
          BackofficeSection.support => _support(),
        },
      ],
    );
  }

  Widget _dashboard() {
    final metrics = _roleMetrics();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 780
                ? 4
                : constraints.maxWidth > 520
                    ? 2
                    : 1;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.02,
              children: [
                for (final metric in metrics)
                  _MetricCard(
                    label: metric.$1,
                    value: metric.$2,
                    trend: metric.$3,
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        _participationPanel(),
        const SizedBox(height: 16),
        _twoCards(
          leftTitle: "Priorità",
          left: _rolePriorities()
              .map((text) => _InfoLine(text: text, trailing: "Da gestire"))
              .toList(),
          rightTitle: "Attività recenti",
          right: const [
            _InfoLine(
              text: "Scheda organizzazione aggiornata",
              trailing: "oggi",
            ),
            _InfoLine(
              text: "Evento interno creato con visibilità limitata",
              trailing: "oggi",
            ),
            _InfoLine(
              text: "Voucher validato senza anomalie",
              trailing: "oggi",
            ),
          ],
        ),
      ],
    );
  }

  Widget _participationPanel() {
    final events = _dashboardEvents();
    final capacity = events.fold<int>(0, (sum, event) => sum + event.capacity);
    final rsvp = events.fold<int>(0, (sum, event) => sum + event.rsvpCount);
    final checkin = events.fold<int>(
      0,
      (sum, event) => sum + event.checkinCount,
    );
    final waitlist = events.fold<int>(
      0,
      (sum, event) => sum + event.waitlistCount,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 780;
        final summary = _BackofficeCard(
          title: _role == UserProfile.mayor
              ? "Partecipazione eventi pubblici e istituzionali"
              : "Partecipazione eventi",
          child: Column(
            children: [
              _miniKpiGrid([
                ("RSVP", "$rsvp", "${_percent(rsvp, capacity)}% capienza"),
                (
                  "Check-in",
                  "$checkin",
                  "${_percent(checkin, rsvp)}% presenze",
                ),
                (
                  "Posti",
                  "${math.max(capacity - rsvp, 0)}",
                  "$capacity totali",
                ),
                ("Attesa", "$waitlist", "lista attesa"),
              ]),
            ],
          ),
        );
        final list = _BackofficeCard(
          title: "Prossimi eventi",
          child: Column(
            children: [
              if (events.isEmpty)
                const Text("Nessun evento con partecipazione visibile.")
              else
                for (final event in events) _ParticipationTile(event: event),
            ],
          ),
        );
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: summary),
                  const SizedBox(width: 12),
                  Expanded(flex: 6, child: list),
                ],
              )
            : Column(children: [summary, const SizedBox(height: 12), list]);
      },
    );
  }

  Widget _pageEditor() {
    final org = appBackoffice.organization(_organizationId);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 820;
        final editor = Column(
          children: [
            _BackofficeCard(
              title: "Immagine pagina",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OrganizationCover(org: org, height: 210),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: org.coverFitContain,
                    title: const Text("Mostra intera"),
                    subtitle: const Text(
                      "Disattiva per riempire l'area copertina.",
                    ),
                    onChanged: (value) => setState(() {
                      org.coverFitContain = value;
                    }),
                  ),
                  const Text(
                    "Fuoco orizzontale",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Slider(
                    value: org.coverFocusX,
                    onChanged: (value) => setState(() {
                      org.coverFocusX = value;
                    }),
                  ),
                  const Text(
                    "Fuoco verticale",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Slider(
                    value: org.coverFocusY,
                    onChanged: (value) => setState(() {
                      org.coverFocusY = value;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _BackofficeCard(
              title: "Informazioni principali",
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nome",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => org.name = value,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _shortController,
                    decoration: const InputDecoration(
                      labelText: "Descrizione breve",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => org.shortDescription = value,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _servicesController,
                    decoration: const InputDecoration(
                      labelText: "Servizi separati da virgola",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => org.services = value
                        .split(",")
                        .map((item) => item.trim())
                        .where((item) => item.isNotEmpty)
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        );
        final preview = _PhoneOrganizationPreview(org: org);
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: editor),
                  const SizedBox(width: 14),
                  SizedBox(width: 360, child: preview),
                ],
              )
            : Column(children: [editor, const SizedBox(height: 14), preview]);
      },
    );
  }

  Widget _menuList() {
    final items = _scopedMenuItems();
    return _BackofficeCard(
      title: "Menu / listino",
      trailing: FilledButton.icon(
        onPressed: () => appBackoffice.addMenuItem(_organizationId),
        icon: const Icon(Icons.add_rounded),
        label: const Text("Aggiungi voce"),
      ),
      child: Column(
        children: [
          if (items.isEmpty) const Text("Nessuna voce per questo contesto."),
          for (final item in items)
            _InfoLine(
              text: "${item.name} · €${item.price}",
              subtitle: "${item.category} · ${item.description}",
              trailing: item.active ? "Attiva" : "Non disponibile",
              onTap: () => appBackoffice.toggleMenuItem(item),
            ),
        ],
      ),
    );
  }

  Widget _events() {
    final events = _visibleEvents();
    final canReview =
        _role == UserProfile.admin || _role == UserProfile.supervisor;
    return Column(
      children: [
        _BackofficeCard(
          title: "Eventi",
          trailing: FilledButton.icon(
            onPressed: () => appBackoffice.addEvent(_organizationId),
            icon: const Icon(Icons.add_rounded),
            label: const Text("Crea evento"),
          ),
          child: Column(
            children: [
              for (final event in events)
                _EventAdminTile(
                  event: event,
                  orgName: appBackoffice.organization(event.orgId).name,
                  canReview: canReview && event.status == "In revisione",
                  canManageOwn: event.orgId == _organizationId,
                  onApprove: () =>
                      appBackoffice.setEventStatus(event, "Pubblicato"),
                  onChanges: () => appBackoffice.setEventStatus(
                    event,
                    "Correzioni richieste",
                  ),
                  onCancel: () =>
                      appBackoffice.setEventStatus(event, "Annullato"),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vouchers() {
    final vouchers = _scopedVouchers();
    return _twoCards(
      leftTitle: "Storico voucher",
      left: vouchers
          .map(
            (voucher) => _InfoLine(
              text: "${voucher.label} · ${voucher.code}",
              trailing: voucher.status,
              subtitle: "Valore €${voucher.amount}",
            ),
          )
          .toList(),
      rightTitle: "Regole convenzione",
      right: const [
        _InfoLine(text: "Voucher 5% e 10%", trailing: "Accettati"),
        _InfoLine(text: "Uso singolo per codice", trailing: "Obbligatorio"),
        _InfoLine(text: "Problemi voucher", trailing: "Ticket supervisore"),
      ],
    );
  }

  Widget _members() {
    final groups = _scopedGroups();
    final members = _scopedMembers();
    return _twoCards(
      leftTitle: "Gruppi",
      left: groups
          .map(
            (group) => _InfoLine(
              text: group.name,
              subtitle: group.visibility,
              trailing: "${group.members} membri",
            ),
          )
          .toList(),
      rightTitle: "Membri",
      right: members
          .map(
            (member) => _InfoLine(
              text: member.name,
              subtitle: "${member.group} · ${member.role}",
              trailing: member.group,
            ),
          )
          .toList(),
    );
  }

  Widget _stats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760 ? 3 : 1;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: const [
            _BackofficeChartCard(title: "Visite", values: [82, 38, 56, 71]),
            _BackofficeChartCard(title: "Eventi", values: [45, 25, 30, 60]),
            _BackofficeChartCard(title: "Servizi", values: [81, 12, 37, 22]),
          ],
        );
      },
    );
  }

  Widget _permissions() {
    return const _BackofficeCard(
      title: "Ruoli e permessi",
      child: Column(
        children: [
          _InfoLine(
            text: "Admin",
            subtitle: "Utenti, ruoli, audit",
            trailing: "Tutto",
          ),
          _InfoLine(
            text: "Supervisore",
            subtitle: "Approva e coordina",
            trailing: "Operativo",
          ),
          _InfoLine(
            text: "Sindaco",
            subtitle: "KPI e comunicazioni",
            trailing: "Decisionale",
          ),
          _InfoLine(
            text: "Esercente",
            subtitle: "Pagina, menu, eventi",
            trailing: "Proprio",
          ),
        ],
      ),
    );
  }

  Widget _support() {
    return _twoCards(
      leftTitle: "Ticket rapidi",
      left: const [
        _InfoLine(text: "Problema voucher", trailing: "Apri"),
        _InfoLine(text: "Cambio categoria", trailing: "Apri"),
        _InfoLine(text: "Evento in revisione", trailing: "Apri"),
      ],
      rightTitle: "Stato richieste",
      right: const [
        _InfoLine(
          text: "Validazione voucher non riuscita",
          trailing: "In carico",
        ),
        _InfoLine(
          text: "Foto copertina da approvare",
          trailing: "In revisione",
        ),
      ],
    );
  }

  Widget _twoCards({
    required String leftTitle,
    required List<Widget> left,
    required String rightTitle,
    required List<Widget> right,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final first = _BackofficeCard(
          title: leftTitle,
          child: Column(children: left),
        );
        final second = _BackofficeCard(
          title: rightTitle,
          child: Column(children: right),
        );
        return constraints.maxWidth > 760
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: first),
                  const SizedBox(width: 12),
                  Expanded(child: second),
                ],
              )
            : Column(children: [first, const SizedBox(height: 12), second]);
      },
    );
  }

  Widget _miniKpiGrid(List<(String, String, String)> rows) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.05,
      children: [
        for (final row in rows)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE1E8DD)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.$1,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  row.$2,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  row.$3,
                  style: const TextStyle(
                    color: Color(0xFF2E7D57),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _syncEditors() {
    final org = appBackoffice.organization(_organizationId);
    _nameController.text = org.name;
    _shortController.text = org.shortDescription;
    _servicesController.text = org.services.join(", ");
  }

  List<BackofficeOrganization> _visibleOrganizations() {
    if (_role == UserProfile.merchant) {
      return [appBackoffice.organization("osteria")];
    }
    if (_role == UserProfile.organization) {
      return [appBackoffice.organization("proloco")];
    }
    return appBackoffice.organizations;
  }

  bool _canChangeOrganization() =>
      _role == UserProfile.admin ||
      _role == UserProfile.supervisor ||
      _role == UserProfile.mayor;

  List<BackofficeEvent> _visibleEvents() {
    if (_role == UserProfile.admin || _role == UserProfile.supervisor) {
      return appBackoffice.events;
    }
    if (_role == UserProfile.mayor) {
      return appBackoffice.events
          .where(
            (event) =>
                event.visibility == BackofficeEventVisibility.public ||
                event.visibility == BackofficeEventVisibility.council,
          )
          .toList(growable: false);
    }
    return appBackoffice.events
        .where((event) => event.orgId == _organizationId)
        .toList(growable: false);
  }

  List<BackofficeEvent> _dashboardEvents() => _visibleEvents().take(5).toList();
  List<BackofficeMenuItem> _scopedMenuItems() => appBackoffice.menuItems
      .where(
        (item) => _canChangeOrganization() || item.orgId == _organizationId,
      )
      .toList(growable: false);
  List<BackofficeVoucher> _scopedVouchers() => appBackoffice.vouchers
      .where(
        (item) => _canChangeOrganization() || item.orgId == _organizationId,
      )
      .toList(growable: false);
  List<BackofficeMember> _scopedMembers() => appBackoffice.members
      .where(
        (item) => _canChangeOrganization() || item.orgId == _organizationId,
      )
      .toList(growable: false);
  List<BackofficeGroup> _scopedGroups() => appBackoffice.groups
      .where(
        (item) => _canChangeOrganization() || item.orgId == _organizationId,
      )
      .toList(growable: false);

  List<BackofficeSection> _sectionsForRole() {
    if (_role == UserProfile.mayor) {
      return const [
        BackofficeSection.dashboard,
        BackofficeSection.events,
        BackofficeSection.stats,
        BackofficeSection.support,
      ];
    }
    return const [
      BackofficeSection.dashboard,
      BackofficeSection.page,
      BackofficeSection.menu,
      BackofficeSection.events,
      BackofficeSection.vouchers,
      BackofficeSection.members,
      BackofficeSection.stats,
      BackofficeSection.permissions,
      BackofficeSection.support,
    ];
  }

  List<(String, String, String)> _roleMetrics() {
    return switch (_role) {
      UserProfile.merchant => [
          ("Visite pagina", "1.248", "+18%"),
          ("Aperture menu", "432", "+9%"),
          ("Voucher riscattati", "37", "+12%"),
          ("Eventi attivi", "3", "2 privati"),
        ],
      UserProfile.organization => [
          ("Eventi pubblici", "8", "+3"),
          ("Riunioni interne", "5", "mese"),
          ("Membri attivi", "64", "+6"),
          ("Inviti in attesa", "12", "RSVP"),
        ],
      UserProfile.supervisor => [
          ("Segnalazioni aperte", "23", "5 urgenti"),
          ("Eventi in revisione", "7", "oggi"),
          ("Notifiche pronte", "4", "2 comunali"),
          ("Anomalie voucher", "2", "bassa"),
        ],
      UserProfile.mayor => [
          ("Segnalazioni risolte", "81%", "+7%"),
          ("Tempo medio risposta", "2,4 gg", "-0,6"),
          ("Eventi mese", "19", "+5"),
          ("Avvisi pubblici", "6", "2 da approvare"),
        ],
      _ => [
          ("Utenti backoffice", "42", "+4"),
          ("Ruoli configurati", "9", "RBAC"),
          ("Schede pubblicate", "118", "+11"),
          ("Azioni sensibili", "16", "audit"),
        ],
    };
  }

  List<String> _rolePriorities() {
    return switch (_role) {
      UserProfile.merchant => [
          "Confermare orario speciale di domenica",
          "Aggiornare due piatti stagionali",
          "Evento degustazione in revisione URP",
        ],
      UserProfile.organization => [
          "Assemblea soci da confermare",
          "Turni volontari festa del paese",
          "Comunicazione Pro Loco da inviare",
        ],
      UserProfile.supervisor => [
          "Approvare calendario weekend",
          "Smistare segnalazioni viabilità",
          "Verificare doppia scansione voucher",
        ],
      UserProfile.mayor => [
          "Comunicazione lavori viabilità",
          "Report mensile servizi",
          "Evento patrocinato in attesa",
        ],
      _ => [
          "Rivedere permessi editor eventi",
          "Aggiornare categorie attività",
          "Controllare log esportazione dati",
        ],
    };
  }

  String _dashboardTitle() {
    return switch (_role) {
      UserProfile.merchant => "Gestisci pagina, menu, offerte ed eventi",
      UserProfile.organization => "Eventi pubblici, riunioni interne e gruppi",
      UserProfile.supervisor => "Code operative, approvazioni e anomalie",
      UserProfile.mayor => "Priorità del territorio e comunicazioni pubbliche",
      _ => "Ruoli, permessi, contenuti e audit",
    };
  }

  String _dashboardSubtitle() {
    return _role == UserProfile.mayor
        ? "Vista istituzionale con aggregati pubblici e priorità."
        : "Area demo frontend-only con dati in memoria.";
  }

  int _percent(int value, int max) {
    if (max <= 0) return 0;
    return math.min(100, ((value / max) * 100).round());
  }
}

const List<UserProfile> _backofficeProfiles = [
  UserProfile.merchant,
  UserProfile.organization,
  UserProfile.supervisor,
  UserProfile.mayor,
  UserProfile.admin,
];

String _defaultOrganizationFor(UserProfile profile) => switch (profile) {
      UserProfile.merchant => "osteria",
      UserProfile.organization => "proloco",
      _ => "comune",
    };

String _profileBackofficeLabel(UserProfile profile) => switch (profile) {
      UserProfile.merchant => "Esercente",
      UserProfile.organization => "Organizzazione",
      UserProfile.supervisor => "Supervisore",
      UserProfile.mayor => "Sindaco",
      UserProfile.admin => "Amministratore",
      _ => "Backoffice",
    };

String _sectionLabel(BackofficeSection section) => switch (section) {
      BackofficeSection.dashboard => "Cruscotto",
      BackofficeSection.page => "La mia pagina",
      BackofficeSection.menu => "Menu / listino",
      BackofficeSection.events => "Eventi",
      BackofficeSection.vouchers => "Voucher",
      BackofficeSection.members => "Membri",
      BackofficeSection.stats => "Statistiche",
      BackofficeSection.permissions => "Permessi",
      BackofficeSection.support => "Assistenza",
    };

IconData _sectionIcon(BackofficeSection section) => switch (section) {
      BackofficeSection.dashboard => Icons.dashboard_rounded,
      BackofficeSection.page => Icons.edit_note_rounded,
      BackofficeSection.menu => Icons.restaurant_menu_rounded,
      BackofficeSection.events => Icons.event_rounded,
      BackofficeSection.vouchers => Icons.confirmation_number_rounded,
      BackofficeSection.members => Icons.groups_rounded,
      BackofficeSection.stats => Icons.bar_chart_rounded,
      BackofficeSection.permissions => Icons.admin_panel_settings_rounded,
      BackofficeSection.support => Icons.support_agent_rounded,
    };

String _visibilityLabel(BackofficeEventVisibility visibility) =>
    switch (visibility) {
      BackofficeEventVisibility.public => "Pubblico",
      BackofficeEventVisibility.orgPage => "Pagina organizzazione",
      BackofficeEventVisibility.orgMembers => "Solo membri",
      BackofficeEventVisibility.group => "Gruppo",
      BackofficeEventVisibility.invite => "Su invito",
      BackofficeEventVisibility.municipalInternal => "Interno Comune",
      BackofficeEventVisibility.council => "Consiglio / Giunta",
    };

class _BackofficeHero extends StatelessWidget {
  const _BackofficeHero({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE6F2EA), Color(0xFFF7ECD8)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDDE7D8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "APPecchio backoffice",
                  style: TextStyle(
                    color: Color(0xFF2E7D57),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          FilledButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    );
  }
}

class _BackofficeCard extends StatelessWidget {
  const _BackofficeCard({this.title, this.trailing, required this.child});

  final String? title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1E8DD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.trend,
  });

  final String label;
  final String value;
  final String trend;

  @override
  Widget build(BuildContext context) {
    return _BackofficeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          Text(
            trend,
            style: const TextStyle(
              color: Color(0xFF2E7D57),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.text,
    required this.trailing,
    this.subtitle,
    this.onTap,
  });

  final String text;
  final String? subtitle;
  final String trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(color: Colors.black54),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Chip(label: Text(trailing)),
          ],
        ),
      ),
    );
  }
}

class _ParticipationTile extends StatelessWidget {
  const _ParticipationTile({required this.event});

  final BackofficeEvent event;

  @override
  Widget build(BuildContext context) {
    final rsvpRate =
        event.capacity == 0 ? 0.0 : event.rsvpCount / event.capacity;
    final checkinRate =
        event.rsvpCount == 0 ? 0.0 : event.checkinCount / event.rsvpCount;
    final label = event.capacity > 0 && event.rsvpCount >= event.capacity
        ? "Sold out"
        : event.capacity > 0 && rsvpRate >= 0.85
            ? "Quasi pieno"
            : event.capacity > 0 && rsvpRate < 0.35
                ? "Bassa partecipazione"
                : "Posti disponibili";
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Chip(label: Text(label)),
            ],
          ),
          Text(
            "${event.date} · ${event.time} · ${event.audience}",
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 8),
          _ProgressLine(
            label: "RSVP",
            value: rsvpRate,
            text: "${event.rsvpCount}/${event.capacity}",
          ),
          _ProgressLine(
            label: "Check-in",
            value: checkinRate,
            text: "${event.checkinCount}/${event.rsvpCount}",
          ),
          Text(
            "${event.waitlistCount} in attesa · Trend ${event.participationTrend}",
            style: const TextStyle(
              color: Color(0xFF2E7D57),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({
    required this.label,
    required this.value,
    required this.text,
  });

  final String label;
  final double value;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label)),
        Expanded(child: LinearProgressIndicator(value: value.clamp(0, 1))),
        const SizedBox(width: 8),
        SizedBox(width: 54, child: Text(text, textAlign: TextAlign.end)),
      ],
    );
  }
}

class _OrganizationCover extends StatelessWidget {
  const _OrganizationCover({required this.org, required this.height});

  final BackofficeOrganization org;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: EdgeInsets.all(org.coverFitContain ? 26 : 0),
      decoration: BoxDecoration(
        color: org.coverFitContain ? const Color(0xFFEAF0E6) : null,
        gradient: org.coverFitContain
            ? null
            : LinearGradient(
                colors: org.coverColors,
                begin: Alignment(-1 + org.coverFocusX, -1 + org.coverFocusY),
                end: Alignment(1 - org.coverFocusX, 1 - org.coverFocusY),
              ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: org.coverFitContain
          ? DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: org.coverColors),
                borderRadius: BorderRadius.circular(14),
              ),
            )
          : Align(
              alignment: Alignment(
                -1 + org.coverFocusX * 2,
                -1 + org.coverFocusY * 2,
              ),
              child: Icon(
                Icons.image_rounded,
                color: Colors.white.withValues(alpha: 0.56),
                size: 62,
              ),
            ),
    );
  }
}

class _PhoneOrganizationPreview extends StatelessWidget {
  const _PhoneOrganizationPreview({required this.org});

  final BackofficeOrganization org;

  @override
  Widget build(BuildContext context) {
    return _BackofficeCard(
      title: "Anteprima mobile",
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2D35),
          borderRadius: BorderRadius.circular(26),
        ),
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ColoredBox(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OrganizationCover(org: org, height: 150),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Chip(label: Text(org.type)),
                      Text(
                        org.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(org.shortDescription),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final service in org.services)
                            Chip(label: Text(service)),
                        ],
                      ),
                    ],
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

class _EventAdminTile extends StatelessWidget {
  const _EventAdminTile({
    required this.event,
    required this.orgName,
    required this.canReview,
    required this.canManageOwn,
    required this.onApprove,
    required this.onChanges,
    required this.onCancel,
  });

  final BackofficeEvent event;
  final String orgName;
  final bool canReview;
  final bool canManageOwn;
  final VoidCallback onApprove;
  final VoidCallback onChanges;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE1E8DD)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                Chip(label: Text(_visibilityLabel(event.visibility))),
              ],
            ),
            Text(
              "$orgName · ${event.type} · ${event.date} ${event.time}",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(event.status)),
                Chip(label: Text(event.audience)),
                Chip(label: Text("${event.rsvpCount}/${event.capacity} RSVP")),
              ],
            ),
            if (canReview || canManageOwn) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (canReview)
                    FilledButton(
                      onPressed: onApprove,
                      child: const Text("Approva"),
                    ),
                  if (canReview)
                    OutlinedButton(
                      onPressed: onChanges,
                      child: const Text("Correzioni"),
                    ),
                  if (canManageOwn)
                    OutlinedButton(
                      onPressed: onCancel,
                      child: const Text("Annulla"),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BackofficeChartCard extends StatelessWidget {
  const _BackofficeChartCard({required this.title, required this.values});

  final String title;
  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return _BackofficeCard(
      title: title,
      child: Column(
        children: [
          for (final value in values)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LinearProgressIndicator(value: value / 100),
            ),
        ],
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  const DetailScreen({
    super.key,
    required this.title,
    required this.type,
    required this.ctaLabel,
  });

  final String title;
  final String type;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 280,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D57), Color(0xFF8BBE9A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(20),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SafeArea(
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(Icons.schedule, size: 18),
                      SizedBox(width: 8),
                      Text("18:00 - 22:30"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.place, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text("Centro storico, territorio APPecchio"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.category, size: 18),
                      SizedBox(width: 8),
                      Expanded(child: Text("Suggerimento locale intelligente")),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF2E7D57),
                      ),
                      child: Text(ctaLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
