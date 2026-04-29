import "dart:math" as math;
import "dart:ui";

import "package:flutter/material.dart";

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

enum UserProfile { resident, tourist }

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
    }
  }
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController =
      TextEditingController(text: "utente@apppecchio.it");
  final TextEditingController _passwordController =
      TextEditingController(text: "demo");
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
                            : "Profilo turista: mostra esperienze, luoghi, eventi e servizi pubblici essenziali.",
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
      name: _selectedProfile == UserProfile.resident ? "Giulia" : "Luca",
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
        builder: (_) => HomeScreen(user: user),
      ),
    );
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
            SegmentedButton<UserProfile>(
              segments: const [
                ButtonSegment<UserProfile>(
                  value: UserProfile.resident,
                  icon: Icon(Icons.home_work_rounded),
                  label: Text("Residenti"),
                ),
                ButtonSegment<UserProfile>(
                  value: UserProfile.tourist,
                  icon: Icon(Icons.hiking_rounded),
                  label: Text("Turisti"),
                ),
              ],
              selected: {selectedProfile},
              onSelectionChanged: (selection) =>
                  onProfileChanged(selection.first),
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.user,
  });

  final AppUser user;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class MenuNode {
  const MenuNode({
    required this.id,
    required this.label,
    required this.icon,
    this.children = const <MenuNode>[],
  });

  final String id;
  final String label;
  final IconData icon;
  final List<MenuNode> children;

  bool get isLeaf => children.isEmpty;
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showRadialMenu = false;
  String _activeQuickFilter = "oggi";

  static const List<HomeQuickAction> _quickActions = [
    HomeQuickAction(
      id: "oggi",
      label: "Oggi",
      icon: Icons.today_rounded,
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
        id: "eventi",
        label: "Eventi",
        icon: Icons.celebration_rounded,
        children: <MenuNode>[
          MenuNode(
              id: "calendario",
              label: "Calendario",
              icon: Icons.calendar_month_rounded),
          MenuNode(
              id: "feste_tradizioni",
              label: "Feste e tradizioni",
              icon: Icons.celebration_rounded),
          MenuNode(
              id: "cultura_spettacoli",
              label: "Cultura e spettacoli",
              icon: Icons.theater_comedy_rounded),
          MenuNode(
              id: "sport_outdoor",
              label: "Sport e outdoor",
              icon: Icons.terrain_rounded),
          MenuNode(
              id: "comunita_spiritualita",
              label: "Comunita e spiritualita",
              icon: Icons.groups_rounded),
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
              icon: Icons.restaurant_rounded),
          MenuNode(
              id: "agriturismi",
              label: "Agriturismi",
              icon: Icons.park_rounded),
          MenuNode(id: "bar", label: "Bar", icon: Icons.local_cafe_rounded),
          MenuNode(
              id: "enogastronomia",
              label: "Eventi enogastronomici",
              icon: Icons.wine_bar_rounded),
          MenuNode(
              id: "tipicita_deco",
              label: "Tipicita De.C.O.",
              icon: Icons.verified_rounded),
          MenuNode(
              id: "tartufo_birra",
              label: "Tartufo e birra",
              icon: Icons.local_bar_rounded),
          MenuNode(
              id: "prodotti_locali",
              label: "Prodotti locali",
              icon: Icons.shopping_basket_rounded),
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
              icon: Icons.park_rounded),
        ],
      ),
      MenuNode(
        id: "cultura",
        label: "Cultura",
        icon: Icons.account_balance_rounded,
        children: <MenuNode>[
          MenuNode(
              id: "musei", label: "Musei e mostre", icon: Icons.museum_rounded),
          MenuNode(
              id: "borghi", label: "Borghi", icon: Icons.location_city_rounded),
          MenuNode(id: "arte", label: "Arte", icon: Icons.palette_rounded),
          MenuNode(
              id: "storia",
              label: "Percorsi storici",
              icon: Icons.history_edu_rounded),
          MenuNode(
              id: "vicolo_ebrei",
              label: "Vicolo degli Ebrei",
              icon: Icons.signpost_rounded),
          MenuNode(
              id: "teatro_perugini",
              label: "Teatro G. Perugini",
              icon: Icons.theaters_rounded),
          MenuNode(
              id: "globo_pace",
              label: "Globo della Pace",
              icon: Icons.public_rounded),
          MenuNode(
            id: "territorio",
            label: "Territorio",
            icon: Icons.map_rounded,
            children: <MenuNode>[
              MenuNode(
                  id: "dove_siamo",
                  label: "Dove siamo",
                  icon: Icons.location_on_rounded),
              MenuNode(
                  id: "monte_nerone",
                  label: "Monte Nerone",
                  icon: Icons.landscape_rounded),
              MenuNode(
                  id: "citta_birra",
                  label: "Citta della Birra",
                  icon: Icons.sports_bar_rounded),
              MenuNode(
                  id: "mappa_turistica",
                  label: "Mappa turistica",
                  icon: Icons.map_outlined),
              MenuNode(
                  id: "webcam_meteo",
                  label: "Webcam e meteo",
                  icon: Icons.wb_cloudy_rounded),
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
                  icon: Icons.church_rounded),
              MenuNode(
                  id: "madonna_vita",
                  label: "Madonna della Vita",
                  icon: Icons.volunteer_activism_rounded),
              MenuNode(
                  id: "san_martino",
                  label: "San Martino",
                  icon: Icons.account_balance_rounded),
              MenuNode(
                  id: "parrocchia",
                  label: "Parrocchia",
                  icon: Icons.diversity_3_rounded),
              MenuNode(
                  id: "oratorio",
                  label: "Oratorio San Martino",
                  icon: Icons.child_care_rounded),
              MenuNode(
                  id: "avvisi_parrocchiali",
                  label: "Avvisi parrocchiali",
                  icon: Icons.campaign_rounded),
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
                  icon: Icons.newspaper_rounded),
              MenuNode(
                  id: "pro_loco",
                  label: "Pro Loco",
                  icon: Icons.groups_2_rounded),
              MenuNode(
                  id: "associazioni",
                  label: "Associazioni",
                  icon: Icons.handshake_rounded),
              MenuNode(
                  id: "avis", label: "AVIS", icon: Icons.bloodtype_rounded),
              MenuNode(
                  id: "biblioteca",
                  label: "Biblioteca comunale",
                  icon: Icons.local_library_rounded),
              MenuNode(
                  id: "mediateca",
                  label: "Mediateca",
                  icon: Icons.photo_library_rounded),
              MenuNode(
                  id: "foto_giorno",
                  label: "Foto del giorno",
                  icon: Icons.camera_alt_rounded),
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
              icon: Icons.local_hospital_rounded),
          MenuNode(
              id: "trasporti",
              label: "Trasporti",
              icon: Icons.directions_bus_rounded),
          MenuNode(id: "bancomat", label: "Bancomat", icon: Icons.atm_rounded),
          MenuNode(
              id: "salute",
              label: "Salute",
              icon: Icons.health_and_safety_rounded),
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
                  icon: Icons.groups_rounded),
              MenuNode(
                  id: "uffici_orari",
                  label: "Uffici e orari",
                  icon: Icons.schedule_rounded),
              MenuNode(
                  id: "rubrica",
                  label: "Contatti rapidi",
                  icon: Icons.contact_phone_rounded),
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
                  icon: Icons.live_tv_rounded),
              MenuNode(
                  id: "registrazioni",
                  label: "Sedute registrate",
                  icon: Icons.video_library_rounded),
              MenuNode(
                  id: "ordine_giorno",
                  label: "Ordine del giorno",
                  icon: Icons.list_alt_rounded),
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
                  icon: Icons.folder_shared_rounded),
              MenuNode(
                  id: "delibere",
                  label: "Delibere e determine",
                  icon: Icons.description_rounded),
              MenuNode(
                  id: "bandi",
                  label: "Bandi e concorsi",
                  icon: Icons.campaign_rounded),
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
                  icon: Icons.payments_rounded),
              MenuNode(
                  id: "appuntamenti",
                  label: "Prenota appuntamento",
                  icon: Icons.event_available_rounded),
              MenuNode(
                  id: "certificati",
                  label: "Certificati anagrafici",
                  icon: Icons.badge_rounded),
              MenuNode(
                  id: "segnalazioni",
                  label: "Segnalazioni al Comune",
                  icon: Icons.report_problem_rounded),
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
                  icon: Icons.school_rounded),
              MenuNode(
                  id: "mobilita",
                  label: "Viabilita e trasporto locale",
                  icon: Icons.traffic_rounded),
              MenuNode(
                  id: "rifiuti",
                  label: "Raccolta rifiuti",
                  icon: Icons.recycling_rounded),
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
                  icon: Icons.grass_rounded),
              MenuNode(
                id: "palazzetto",
                label: "Palazzetto",
                icon: Icons.sports_handball_rounded,
                children: <MenuNode>[
                  MenuNode(
                      id: "palazzetto_calcetto",
                      label: "Calcetto",
                      icon: Icons.sports_soccer_rounded),
                  MenuNode(
                      id: "palazzetto_city_tennis",
                      label: "City tennis",
                      icon: Icons.sports_handball_rounded),
                  MenuNode(
                      id: "palazzetto_pallavolo",
                      label: "Pallavolo",
                      icon: Icons.sports_volleyball_rounded),
                ],
              ),
              MenuNode(
                  id: "campo_tennis",
                  label: "Campo da tennis",
                  icon: Icons.sports_tennis_rounded),
              MenuNode(
                id: "regole_prenotazione",
                label: "Regolamenti e tariffe",
                icon: Icons.rule_rounded,
                children: <MenuNode>[
                  MenuNode(
                      id: "fasce_orarie",
                      label: "Fasce orarie",
                      icon: Icons.schedule_rounded),
                  MenuNode(
                      id: "tariffe",
                      label: "Tariffe",
                      icon: Icons.euro_rounded),
                  MenuNode(
                      id: "annulla_sposta",
                      label: "Annulla o sposta prenotazione",
                      icon: Icons.swap_horiz_rounded),
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
                  icon: Icons.map_rounded),
              MenuNode(
                  id: "difficolta_tempo",
                  label: "Difficolta e tempi",
                  icon: Icons.hiking_rounded),
              MenuNode(
                  id: "prenota_guida",
                  label: "Prenota guida ambientale",
                  icon: Icons.support_agent_rounded),
              MenuNode(
                  id: "prenota_istruttore",
                  label: "Prenota istruttore outdoor",
                  icon: Icons.fitness_center_rounded),
              MenuNode(
                  id: "noleggio_ebike",
                  label: "Noleggio bici elettriche",
                  icon: Icons.electric_bike_rounded),
              MenuNode(
                  id: "tour_famiglie",
                  label: "Tour famiglie e scuole",
                  icon: Icons.family_restroom_rounded),
              MenuNode(
                  id: "canoa_trekking",
                  label: "Canoa e trekking guidato",
                  icon: Icons.kayaking_rounded),
              MenuNode(
                  id: "parco_avventura",
                  label: "Parco Avventura Furlo",
                  icon: Icons.forest_rounded),
              MenuNode(
                  id: "birdwatching",
                  label: "Birdwatching",
                  icon: Icons.visibility_rounded),
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
                      const _SearchGlassBar(),
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
      "cultura_spettacoli",
      "sport_outdoor",
      "comunita_spiritualita",
    }.contains(node.id);
  }

  bool _isDiningNode(MenuNode node) {
    return const {
      "ristoranti",
      "agriturismi",
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
    return const {"fasce_orarie", "tariffe", "annulla_sposta"}
        .contains(node.id);
  }

  bool _isOutdoorServiceNode(MenuNode node) {
    return const {
      "prenota_guida",
      "prenota_istruttore",
      "noleggio_ebike",
      "tour_famiglie",
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
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
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
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
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
    final initialKind = nodeId == "agriturismi"
        ? DiningKind.agriturismo
        : DiningKind.restaurant;
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
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

  void _openTrails() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (_, animation, __) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(
              opacity: curved,
              child: const TrailsScreen(),
            ),
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
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
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
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
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
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
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
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
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
                      Color(0xFFB1C8AF)
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _MapPathPainter(),
          ),
        ),
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
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.22,
          size.width - 30, size.height * 0.35)
      ..quadraticBezierTo(
          size.width * 0.4, size.height * 0.54, 40, size.height * 0.68)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.76, size.width - 40,
          size.height * 0.9);
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: "Impostazioni",
                  onPressed: onSettings,
                  icon: const Icon(Icons.settings_rounded, color: Colors.white),
                ),
              ),
              Center(
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
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: "Logout",
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchGlassBar extends StatelessWidget {
  const _SearchGlassBar();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          color: Colors.white.withValues(alpha: 0.22),
          child: const Row(
            children: [
              Icon(Icons.search, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Cerca luoghi, eventi, servizi...",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
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
    required this.onOpenEvents,
    required this.onOpenDining,
    required this.onOpenTrails,
  });

  final String selectedAction;
  final AppUser user;
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
    required this.onOpenEvents,
    required this.onOpenDining,
    required this.onOpenTrails,
  });

  final String selectedAction;
  final AppUser user;
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
                    onOpenEvents: onOpenEvents,
                    onOpenDining: onOpenDining,
                    onOpenTrails: onOpenTrails,
                  )
                else if (selectedAction == "aperti")
                  _OpenNowOverview(onOpenDining: onOpenDining)
                else if (selectedAction == "vicino")
                  _NearbyOverview(
                    raining: raining,
                    onOpenTrails: onOpenTrails,
                  )
                else
                  const _NotificationsOverview(),
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
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
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
    required this.onOpenEvents,
    required this.onOpenDining,
    required this.onOpenTrails,
  });

  final bool raining;
  final VoidCallback onOpenEvents;
  final VoidCallback onOpenDining;
  final VoidCallback onOpenTrails;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PanelTitle(title: "Oggi in paese"),
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
          subtitle: "Civico 14+5 e Dal Greco hanno slot liberi stasera.",
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
          subtitle: "Dal Greco e Le Ciocche accettano prenotazioni per cena.",
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
  const _NearbyOverview({
    required this.raining,
    required this.onOpenTrails,
  });

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

class _NotificationsOverview extends StatelessWidget {
  const _NotificationsOverview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PanelTitle(title: "Notifiche"),
        _InsightTile(
          icon: Icons.notifications_active_rounded,
          title: "Meteo aggiornato",
          subtitle:
              "Pioggia possibile nel pomeriggio: consigliati eventi al coperto.",
        ),
        _InsightTile(
          icon: Icons.event_available_rounded,
          title: "Prenotazioni",
          subtitle: "Palazzetto libero dalle 18:30 per attivita indoor.",
        ),
        _InsightTile(
          icon: Icons.restaurant_rounded,
          title: "Cena",
          subtitle: "Nuovi slot disponibili da Civico 14+5.",
        ),
      ],
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
                  const Icon(Icons.chevron_right_rounded,
                      color: Color(0xFF2E7D57)),
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 520),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offsetAnim = Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(animation);
        final scaleAnim = Tween<double>(begin: 0.96, end: 1).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnim,
            child: ScaleTransition(scale: scaleAnim, child: child),
          ),
        );
      },
      child: _RadialMenuStage(
        key: ValueKey<String>(currentNode.id),
        currentNode: currentNode,
        parentNode: parentNode,
        onNodeTap: onNodeTap,
        onBackTap: onBackTap,
      ),
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
    final compact = size.width < 360 || size.height < 560;
    final tablet = shortest >= 600;

    return _MenuLayoutSpec(
      useCompactMenu: compact || (isLandscape && size.height < 640),
      edgePadding: shortest < 390 ? 10 : 16,
      bottomPadding: shortest < 390 ? 82 : 96,
      titleTop: isLandscape ? 24 : (shortest < 390 ? 54 : 70),
      titleClearance: shortest < 390 ? 62 : 74,
      centerYFactor: isLandscape ? 0.54 : 0.52,
      nodeWidthFactor: tablet ? 0.20 : 0.27,
      nodeHeightFactor: tablet ? 0.16 : 0.21,
      minNodeWidth: shortest < 390 ? 76 : 86,
      maxNodeWidth: tablet ? 148 : 122,
      minNodeHeight: shortest < 390 ? 66 : 74,
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
  const _CompactBackButton({
    required this.label,
    required this.onTap,
  });

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
              const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 116),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
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
  const _CompactMenuCard({
    required this.node,
    required this.onTap,
  });

  final MenuNode node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
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
                    color: const Color(0xFF1B2E21),
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
                        color: const Color(0xFF1B2E21),
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

        final countFactor = currentNode.children.length > 5 ? 0.88 : 1.0;
        final nodeWidth = ((shortest * spec.nodeWidthFactor) * countFactor)
            .clamp(spec.minNodeWidth, spec.maxNodeWidth)
            .toDouble();
        final nodeHeight = ((shortest * spec.nodeHeightFactor) * countFactor)
            .clamp(spec.minNodeHeight, spec.maxNodeHeight)
            .toDouble();
        final center = Offset(constraints.maxWidth / 2,
            constraints.maxHeight * spec.centerYFactor);
        final targets = _computeTargets(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          center: center,
          total: currentNode.children.length,
          hasParent: parentNode != null,
          nodeWidth: nodeWidth,
          nodeHeight: nodeHeight,
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
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22)),
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
                        progress: progress,
                        hasParent: parentNode != null,
                      ),
                    ),
                  ),
                  if (parentNode != null)
                    _RadialNode(
                      center: center,
                      fixedAngle: math.pi,
                      radius: (shortest * spec.backRadiusFactor)
                          .clamp(spec.minBackRadius, spec.maxBackRadius)
                          .toDouble(),
                      label: parentNode!.label,
                      icon: Icons.undo_rounded,
                      selected: false,
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
                      label: currentNode.children[i].label,
                      icon: currentNode.children[i].icon,
                      selected: false,
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
    required _MenuLayoutSpec spec,
  }) {
    if (total == 0) {
      return const <Offset>[];
    }
    final start = hasParent ? -math.pi / 2.25 : -math.pi * 0.86;
    final end = hasParent ? math.pi / 2.25 : math.pi * 0.86;
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
    final childMinX = hasParent ? center.dx + nodeWidth * 0.10 : minX;

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
      final ringGap = (nodeHeight * spec.ringGapFactor)
          .clamp(spec.minRingGap, spec.maxRingGap)
          .toDouble();
      final rings = <double>[radius];
      if (total > 7) {
        rings.add((radius - ringGap).clamp(74.0, radius).toDouble());
      }
      if (total > 12) {
        rings.add((radius - (ringGap * 2)).clamp(62.0, radius).toDouble());
      }

      var remaining = total;
      final points = <Offset>[];
      final outerCount =
          rings.length == 1 ? total : math.min(total, (total * 0.58).ceil());

      for (var ringIndex = 0; ringIndex < rings.length; ringIndex++) {
        final ringRadius = rings[ringIndex];
        final take = ringIndex == 0 || ringIndex == rings.length - 1
            ? math.min(remaining, outerCount)
            : math.min(remaining, (remaining / 2).ceil());
        if (take <= 0) {
          continue;
        }

        final ringInset = ringIndex * 0.16;
        final ringStart = start + (end - start) * ringInset;
        final ringEnd = end - (end - start) * ringInset;
        final offsetStep = ringIndex.isOdd && take > 1 ? 0.5 / take : 0.0;

        for (var i = 0; i < take; i++) {
          final t = take == 1 ? 0.5 : (i + offsetStep) / (take - 1);
          final angle = ringStart + (ringEnd - ringStart) * t.clamp(0.0, 1.0);
          final dx = center.dx + math.cos(angle) * ringRadius;
          final dy = center.dy + math.sin(angle) * ringRadius;
          points.add(clampToViewport(Offset(dx, dy)));
        }
        remaining -= take;
        if (remaining <= 0) {
          break;
        }
      }

      // Fallback: if nodes still remain, place near center arc.
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
      final backPoint = Offset(
        center.dx -
            (shortest * spec.backRadiusFactor)
                .clamp(spec.minBackRadius, spec.maxBackRadius)
                .toDouble(),
        center.dy,
      );

      for (var iteration = 0; iteration < 96; iteration++) {
        var moved = false;
        final deltas = List<Offset>.filled(total, Offset.zero);

        for (var i = 0; i < total; i++) {
          deltas[i] += (ideals[i] - positions[i]) * 0.025;

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
}

class _TreeBranchPainter extends CustomPainter {
  _TreeBranchPainter({
    required this.center,
    required this.targets,
    required this.progress,
    required this.hasParent,
  });

  final Offset center;
  final List<Offset> targets;
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
      final midX = (center.dx + target.dx) / 2;
      final wave = (i.isEven ? 1 : -1) * 24.0;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..cubicTo(
          midX - 38,
          center.dy + wave,
          midX + 16,
          target.dy - wave,
          target.dx,
          target.dy,
        );
      canvas.drawPath(path, paint);
    }

    if (hasParent) {
      final back = Offset(center.dx - 128 * progress, center.dy);
      final backPath = Path()
        ..moveTo(center.dx, center.dy)
        ..quadraticBezierTo(center.dx - 72, center.dy - 14, back.dx, back.dy);
      canvas.drawPath(
        backPath,
        paint
          ..color = const Color(0xFFE4EFE8).withValues(alpha: 0.35 * progress),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TreeBranchPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.targets != targets ||
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
    final openSize = (shortest * 0.31).clamp(98.0, 118.0).toDouble();
    final closedSize = (shortest * 0.24).clamp(80.0, 92.0).toDouble();
    final openFont = (shortest * 0.030).clamp(10.0, 12.0).toDouble();
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
                    color: const Color(0xFF1F5D3E)
                        .withValues(alpha: isOpen ? 0.45 : 0.60),
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
                    size: isOpen ? 30 : 32,
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
    required this.label,
    required this.icon,
    required this.selected,
    required this.progress,
    required this.onTap,
    this.fixedAngle,
    this.fixedOffset,
  });

  final Offset center;
  final double radius;
  final double width;
  final double height;
  final String label;
  final IconData icon;
  final bool selected;
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
    final dx = center.dx + (targetDx - center.dx) * progress;
    final dy = center.dy + (targetDy - center.dy) * progress;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutCubic,
      left: dx - (width / 2),
      top: dy - (height / 2),
      child: GestureDetector(
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
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black38, blurRadius: 14, offset: Offset(0, 7))
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
                        Icon(icon,
                            size: adaptiveIconSize,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF1B2E21)),
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
  const SettingsScreen({
    super.key,
    required this.user,
  });

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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE4EFE8),
          child: Icon(icon, color: const Color(0xFF2E7D57)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _SettingsDetailScreen extends StatefulWidget {
  const _SettingsDetailScreen({
    required this.user,
    required this.kind,
  });

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
            DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ),
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
    required this.mapPoints,
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
  final List<Offset> mapPoints;
  final Color color;
  final Set<String> tags;

  String get distanceLabel =>
      "${lengthKm.toStringAsFixed(1).replaceAll(".", ",")} km";
  String get elevationLabel => "+$elevationGainM m";
  bool get hasGpx => gpxUrl.isNotEmpty;
}

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
      "Sentiero Italia"
    ],
    sourceLabel: "Pesaro Trekking - Sentiero 39 Monte Nerone",
    sourceUrl: "https://www.pesarotrekking.it/monte-nerone/sentiero-39.html",
    gpxUrl: "",
    mapPoints: [
      Offset(0.29, 0.63),
      Offset(0.35, 0.58),
      Offset(0.43, 0.53),
      Offset(0.53, 0.47),
      Offset(0.62, 0.39),
      Offset(0.72, 0.32),
    ],
    color: Color(0xFF1D8A6A),
    tags: {"e", "panoramici"},
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
    mapPoints: [
      Offset(0.19, 0.77),
      Offset(0.28, 0.72),
      Offset(0.39, 0.69),
      Offset(0.49, 0.62),
      Offset(0.58, 0.56),
      Offset(0.68, 0.49),
    ],
    color: Color(0xFFD6802B),
    tags: {"e", "famiglie", "panoramici"},
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
    mapPoints: [
      Offset(0.42, 0.79),
      Offset(0.47, 0.71),
      Offset(0.51, 0.62),
      Offset(0.56, 0.54),
      Offset(0.61, 0.46),
    ],
    color: Color(0xFF6B5BA8),
    tags: {"e"},
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
    mapPoints: [
      Offset(0.18, 0.31),
      Offset(0.27, 0.36),
      Offset(0.37, 0.32),
      Offset(0.49, 0.27),
      Offset(0.62, 0.22),
      Offset(0.78, 0.19),
    ],
    color: Color(0xFFC83E4D),
    tags: {"ee", "panoramici"},
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

  static const Map<String, String> _filters = {
    "tutti": "Tutti",
    "facili": "Facili",
    "e": "E",
    "ee": "EE",
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
            onTrailSelected: (trail) => setState(() => _selectedTrail = trail),
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
              onTap: () => setState(() => _selectedTrail = trail),
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
      MaterialPageRoute<void>(
        builder: (_) => TrailDetailScreen(trail: trail),
      ),
    );
  }
}

class _TrailsHero extends StatelessWidget {
  const _TrailsHero({
    required this.trails,
    required this.selectedTrail,
    required this.onTrailSelected,
  });

  final List<TrailRoute> trails;
  final TrailRoute selectedTrail;
  final ValueChanged<TrailRoute> onTrailSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 330,
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.16),
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.42),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _TrailMapPainter(
                  trails: trails,
                  selectedTrail: selectedTrail,
                  showOnlySelected: false,
                ),
              ),
            ),
            for (final pin in _trailMapPins) _TrailMapPin(pin: pin),
            for (final trail in trails)
              _TrailMapButton(
                trail: trail,
                selected: trail.id == selectedTrail.id,
                onTap: () => onTrailSelected(trail),
              ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: _TrailMapLegend(selectedTrail: selectedTrail),
            ),
            const Positioned(
              left: 16,
              top: 16,
              child: _TrailMapBadge(),
            ),
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
          Icon(Icons.terrain_rounded, color: Color(0xFF2E7D57), size: 18),
          SizedBox(width: 7),
          Text(
            "Territorio dall'alto",
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

class TrailMapPin {
  const TrailMapPin(this.label, this.position, this.icon);

  final String label;
  final Offset position;
  final IconData icon;
}

const List<TrailMapPin> _trailMapPins = [
  TrailMapPin("Apecchio", Offset(0.29, 0.63), Icons.location_city_rounded),
  TrailMapPin("Pianello", Offset(0.19, 0.77), Icons.home_work_rounded),
  TrailMapPin("Pieia", Offset(0.68, 0.49), Icons.church_rounded),
  TrailMapPin("San Lorenzo", Offset(0.42, 0.79), Icons.place_rounded),
  TrailMapPin("Valcellone", Offset(0.61, 0.46), Icons.terrain_rounded),
  TrailMapPin("Monte Nerone", Offset(0.78, 0.19), Icons.filter_hdr_rounded),
  TrailMapPin("Fondarca", Offset(0.58, 0.56), Icons.landscape_rounded),
  TrailMapPin("Gorgaccia", Offset(0.43, 0.53), Icons.water_rounded),
];

class _TrailMapPin extends StatelessWidget {
  const _TrailMapPin({required this.pin});

  final TrailMapPin pin;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dx = pin.position.dx * constraints.maxWidth;
          final dy = pin.position.dy * constraints.maxHeight;
          return Stack(
            children: [
              Positioned(
                left: (dx - 54).clamp(4.0, constraints.maxWidth - 108),
                top: (dy - 15).clamp(42.0, constraints.maxHeight - 44),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.52),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(pin.icon, color: Colors.white, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        pin.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
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

class _TrailMapButton extends StatelessWidget {
  const _TrailMapButton({
    required this.trail,
    required this.selected,
    required this.onTap,
  });

  final TrailRoute trail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final midPoint = trail.mapPoints[trail.mapPoints.length ~/ 2];
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = selected ? 46.0 : 38.0;
          return Stack(
            children: [
              Positioned(
                left: (midPoint.dx * constraints.maxWidth) - (size / 2),
                top: (midPoint.dy * constraints.maxHeight) - (size / 2),
                child: Material(
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TrailMapPainter extends CustomPainter {
  const _TrailMapPainter({
    required this.trails,
    required this.selectedTrail,
    required this.showOnlySelected,
  });

  final List<TrailRoute> trails;
  final TrailRoute selectedTrail;
  final bool showOnlySelected;

  @override
  void paint(Canvas canvas, Size size) {
    final visibleTrails = showOnlySelected ? [selectedTrail] : trails;
    for (final trail in visibleTrails) {
      final selected = trail.id == selectedTrail.id;
      final path = Path();
      for (var i = 0; i < trail.mapPoints.length; i++) {
        final point = Offset(
          trail.mapPoints[i].dx * size.width,
          trail.mapPoints[i].dy * size.height,
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: selected ? 0.38 : 0.18)
        ..strokeWidth = selected ? 9 : 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, shadowPaint);

      final paint = Paint()
        ..color = trail.color.withValues(alpha: selected ? 1 : 0.66)
        ..strokeWidth = selected ? 5.4 : 3.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrailMapPainter oldDelegate) {
    return oldDelegate.trails != trails ||
        oldDelegate.selectedTrail != selectedTrail ||
        oldDelegate.showOnlySelected != showOnlySelected;
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

class _TrailSelectedPanel extends StatelessWidget {
  const _TrailSelectedPanel({
    required this.trail,
    required this.onOpenDetail,
  });

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
                  icon: Icons.straighten_rounded, label: trail.distanceLabel),
              _TrailStatChip(
                  icon: Icons.trending_up_rounded, label: trail.elevationLabel),
              _TrailStatChip(
                  icon: Icons.schedule_rounded, label: trail.timeLabel),
              _TrailStatChip(
                  icon: Icons.hiking_rounded, label: trail.difficulty),
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
  const _TrailStatChip({
    required this.icon,
    required this.label,
  });

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
                        color: Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _TrailMapPainter(
                        trails: _trailRoutes,
                        selectedTrail: trail,
                        showOnlySelected: true,
                      ),
                    ),
                  ),
                  for (final pin in _trailMapPins)
                    if (trail.highlights.any((highlight) =>
                        highlight
                            .toLowerCase()
                            .contains(pin.label.toLowerCase()) ||
                        pin.label
                            .toLowerCase()
                            .contains(highlight.toLowerCase())))
                      _TrailMapPin(pin: pin),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _TrailMapLegend(selectedTrail: trail),
                  ),
                ],
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
                  icon: Icons.straighten_rounded, label: trail.distanceLabel),
              _TrailStatChip(
                  icon: Icons.trending_up_rounded,
                  label: "+${trail.elevationGainM} m"),
              _TrailStatChip(
                  icon: Icons.trending_down_rounded,
                  label: "-${trail.elevationLossM} m"),
              _TrailStatChip(
                  icon: Icons.schedule_rounded, label: trail.timeLabel),
              _TrailStatChip(
                  icon: Icons.hiking_rounded,
                  label: "Difficolta ${trail.difficulty}"),
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
                    value: "${trail.start} · ${trail.startAltitudeM} m"),
                _TrailInfoRow(
                    icon: Icons.place_rounded,
                    label: "Arrivo",
                    value: "${trail.end} · ${trail.endAltitudeM} m"),
                _TrailInfoRow(
                    icon: Icons.filter_hdr_rounded,
                    label: "Quota massima",
                    value: "${trail.maxAltitudeM} m"),
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
  const _TrailDetailCard({
    required this.title,
    required this.child,
  });

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
  String? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _selectedFacility = _sportFacilities.firstWhere(
      (facility) => facility.id == widget.initialFacilityId,
      orElse: () => _sportFacilities.first,
    );
    _selectedSlot = _selectedFacility.nextSlots.first;
  }

  @override
  Widget build(BuildContext context) {
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
              _selectedSlot = facility.nextSlots.first;
            }),
          ),
          const SizedBox(height: 16),
          _TrailDetailCard(
            title: "Disponibilita rapide",
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final slot in _selectedFacility.nextSlots)
                  ChoiceChip(
                    label: Text(slot),
                    selected: _selectedSlot == slot,
                    selectedColor: _selectedFacility.color,
                    labelStyle: TextStyle(
                      color:
                          _selectedSlot == slot ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                    onSelected: (_) => setState(() => _selectedSlot = slot),
                  ),
              ],
            ),
          ),
          _TrailDetailCard(
            title: "Dettagli impianto",
            child: Column(
              children: [
                _TrailInfoRow(
                    icon: Icons.place_rounded,
                    label: "Luogo",
                    value: _selectedFacility.place),
                _TrailInfoRow(
                    icon: Icons.layers_rounded,
                    label: "Fondo",
                    value: _selectedFacility.surface),
                _TrailInfoRow(
                    icon: Icons.groups_rounded,
                    label: "Formato",
                    value: _selectedFacility.capacity),
                _TrailInfoRow(
                    icon: Icons.euro_rounded,
                    label: "Tariffa",
                    value: _selectedFacility.priceLabel),
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
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Mockup: richiesta inviata per ${_selectedFacility.activity} · $_selectedSlot.",
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
            "Calcetto e volley da 18 euro/ora"
          ],
        ),
        _SportRuleBlock(
          title: "Agevolazioni",
          icon: Icons.volunteer_activism_rounded,
          lines: [
            "Scuole e associazioni: tariffa convenzionata",
            "Residenti: priorita sugli slot feriali"
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
            "Dopo la scadenza resta visibile allo sportello"
          ],
        ),
        _SportRuleBlock(
          title: "Sposta prenotazione",
          icon: Icons.swap_horiz_rounded,
          lines: [
            "Una modifica rapida per prenotazione",
            "Conferma immediata se lo slot e libero"
          ],
        ),
        _SportRuleBlock(
          title: "Maltempo",
          icon: Icons.water_drop_rounded,
          lines: [
            "Campi outdoor riprogrammabili",
            "Palazzetto suggerito come alternativa"
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
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
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
                    value: _selectedService.duration),
                _TrailInfoRow(
                    icon: Icons.euro_rounded,
                    label: "Costo",
                    value: _selectedService.priceLabel),
                _TrailInfoRow(
                    icon: Icons.groups_rounded,
                    label: "Ideale per",
                    value: _selectedService.bestFor),
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
                      "Mockup: richiesta inviata per ${_selectedService.title}."),
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
          const Icon(Icons.check_circle_rounded,
              size: 18, color: Color(0xFF2E7D57)),
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
}

const List<AppEvent> _mockEvents = [
  AppEvent(
    id: "tartufo_birra_osterie",
    title: "Tartufo e Birra - Andar per osterie",
    category: "feste_tradizioni",
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
  ),
  AppEvent(
    id: "rembrandt_barocci",
    title: "Rembrandt e Barocci, incidere la luce",
    category: "cultura_spettacoli",
    dateLabel: "8 giugno - 7 settembre",
    timeLabel: "Orari mostra",
    place: "Palazzo Ubaldini",
    description:
        "Mostra culturale segnalata nel calendario estivo, con Palazzo Ubaldini come sede naturale per arte e storia del territorio.",
    contacts: "Comune di Apecchio - Ufficio Turistico",
    website: "www.vivereapecchio.it/eventi",
    posterTitle: "Incidere la luce",
    posterSubtitle: "Rembrandt e Barocci",
    posterColors: [Color(0xFF493548), Color(0xFFE6C17A)],
    icon: Icons.image_rounded,
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
    category: "feste_tradizioni",
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

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, this.initialFilter});

  final String? initialFilter;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late String _selectedFilter;

  static const Map<String, String> _filters = {
    "tutti": "Tutti",
    "feste_tradizioni": "Feste e tradizioni",
    "cultura_spettacoli": "Cultura e spettacoli",
    "sport_outdoor": "Sport e outdoor",
    "comunita_spiritualita": "Comunita e spiritualita",
  };

  @override
  void initState() {
    super.initState();
    _selectedFilter = _filters.containsKey(widget.initialFilter)
        ? widget.initialFilter!
        : "tutti";
  }

  @override
  Widget build(BuildContext context) {
    final events = _selectedFilter == "tutti"
        ? _mockEvents
        : _mockEvents
            .where((event) => event.category == _selectedFilter)
            .toList(growable: false);

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
          _EventCalendarStrip(events: events),
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
                return _EventPosterCard(
                  event: event,
                  onTap: () => _openEventDetail(event),
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
            _EventListTile(event: event, onTap: () => _openEventDetail(event)),
        ],
      ),
    );
  }

  void _openEventDetail(AppEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailScreen(event: event),
      ),
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

class _EventCalendarStrip extends StatelessWidget {
  const _EventCalendarStrip({required this.events});

  final List<AppEvent> events;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: events.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final event = events[index];
          final pieces = event.dateLabel.split(" ");
          return Container(
            width: 96,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE1E8DD)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  pieces.first,
                  style: const TextStyle(
                    color: Color(0xFF2E7D57),
                    fontSize: 11,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pieces.length > 1 ? pieces[1] : event.dateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.category.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    height: 1,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EventPosterCard extends StatelessWidget {
  const _EventPosterCard({required this.event, required this.onTap});

  final AppEvent event;
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
                const Spacer(),
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
  const _EventListTile({required this.event, required this.onTap});

  final AppEvent event;
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
            child: EventPoster(event: event, micro: true)),
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
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
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
              icon: Icons.calendar_month_rounded, text: event.dateLabel),
          _EventInfoRow(icon: Icons.place_rounded, text: event.place),
          const SizedBox(height: 18),
          _EventDetailSection(title: "Descrizione", body: event.description),
          _EventDetailSection(title: "Riferimenti", body: event.contacts),
          _EventDetailSection(title: "Sito web", body: event.website),
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

extension on AppEvent {
  String get categoryLabel {
    switch (category) {
      case "feste_tradizioni":
        return "Feste e tradizioni";
      case "cultura_spettacoli":
        return "Cultura e spettacoli";
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

enum DiningKind { restaurant, agriturismo }

class DiningVenue {
  const DiningVenue({
    required this.id,
    required this.name,
    required this.kind,
    required this.tagline,
    required this.area,
    required this.todayStatus,
    required this.priceHint,
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
  final String todayStatus;
  final String priceHint;
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
    }
  }
}

const List<DiningVenue> _diningVenues = [
  DiningVenue(
    id: "civico_14_5",
    name: "Civico 14+5",
    kind: DiningKind.restaurant,
    tagline: "Cucina contemporanea, tavoli raccolti e carta stagionale.",
    area: "Centro storico",
    todayStatus: "Oggi: tavoli a cena",
    priceHint: "Menu medio 30-40 euro",
    coverColors: [Color(0xFF1F3A35), Color(0xFFE6B85C)],
    icon: Icons.restaurant_menu_rounded,
    menuSections: {
      "Antipasti": ["Crostini misti", "Tagliere del territorio"],
      "Primi": ["Tagliatelle al ragu", "Ravioli burro e salvia"],
      "Secondi": ["Coniglio in porchetta", "Verdure grigliate"],
    },
    bookingSlots: ["12:30", "13:15", "19:45", "20:30", "21:15"],
  ),
  DiningVenue(
    id: "dal_greco",
    name: "Dal Greco",
    kind: DiningKind.restaurant,
    tagline: "Piatti sinceri, griglia e sapori di casa.",
    area: "Zona paese",
    todayStatus: "Oggi: pranzo e cena",
    priceHint: "Menu medio 25-35 euro",
    coverColors: [Color(0xFF355070), Color(0xFFE56B6F)],
    icon: Icons.local_fire_department_rounded,
    menuSections: {
      "Antipasti": ["Bruschette", "Affettati e formaggi"],
      "Primi": ["Pappardelle al cinghiale", "Passatelli asciutti"],
      "Secondi": ["Grigliata mista", "Patate al forno"],
    },
    bookingSlots: ["12:15", "13:00", "19:30", "20:15", "21:00"],
  ),
  DiningVenue(
    id: "acquapartita",
    name: "Acquapartita",
    kind: DiningKind.restaurant,
    tagline: "Sosta informale con cucina del territorio e tavoli all'aperto.",
    area: "Acquapartita",
    todayStatus: "Oggi: aperto a cena",
    priceHint: "Menu medio 25-30 euro",
    coverColors: [Color(0xFF2A6F97), Color(0xFFA9D6E5)],
    icon: Icons.water_drop_rounded,
    menuSections: {
      "Antipasti": ["Focaccia calda", "Verdure sottolio"],
      "Primi": ["Gnocchi al sugo", "Maltagliati ai funghi"],
      "Dolci": ["Crostata", "Crema della casa"],
    },
    bookingSlots: ["19:30", "20:00", "20:45", "21:15"],
  ),
  DiningVenue(
    id: "le_ciocche",
    name: "Le Ciocche",
    kind: DiningKind.restaurant,
    tagline: "Cucina rustica, porzioni generose e ambiente familiare.",
    area: "Dintorni",
    todayStatus: "Oggi: pochi posti",
    priceHint: "Menu medio 20-30 euro",
    coverColors: [Color(0xFF6B4F3A), Color(0xFFDDA15E)],
    icon: Icons.dinner_dining_rounded,
    menuSections: {
      "Antipasti": ["Erbe di campo", "Crescia e salumi"],
      "Primi": ["Polenta con sugo", "Cappelletti"],
      "Secondi": ["Arrosto misto", "Fagioli in umido"],
    },
    bookingSlots: ["12:45", "13:30", "20:00", "20:45"],
  ),
  DiningVenue(
    id: "pian_di_molino",
    name: "Pian Di Molino",
    kind: DiningKind.agriturismo,
    tagline: "Agriturismo immerso nel verde, cucina rurale e prodotti propri.",
    area: "Campagna",
    todayStatus: "Oggi: su prenotazione",
    priceHint: "Menu degustazione 35 euro",
    coverColors: [Color(0xFF386641), Color(0xFFA7C957)],
    icon: Icons.agriculture_rounded,
    menuSections: {
      "Dalla terra": ["Ortaggi dell'orto", "Formaggi locali"],
      "Primi": ["Tagliolini alle erbe", "Zuppa contadina"],
      "Degustazione": ["Percorso della casa", "Dolci al forno"],
    },
    bookingSlots: ["12:30", "13:00", "19:30", "20:00"],
  ),
  DiningVenue(
    id: "casserantonio",
    name: "Casserantonio",
    kind: DiningKind.agriturismo,
    tagline: "Tavola agricola, sapori semplici e atmosfera lenta.",
    area: "Collina",
    todayStatus: "Oggi: cena disponibile",
    priceHint: "Menu medio 30 euro",
    coverColors: [Color(0xFF606C38), Color(0xFFFEFAE0)],
    icon: Icons.local_florist_rounded,
    menuSections: {
      "Antipasti": ["Crostoni dell'aia", "Sottoli"],
      "Primi": ["Strozzapreti", "Minestra di legumi"],
      "Secondi": ["Carni al forno", "Verdure di stagione"],
    },
    bookingSlots: ["19:30", "20:15", "21:00"],
  ),
  DiningVenue(
    id: "osteria_nuova",
    name: "Osteria nuova",
    kind: DiningKind.agriturismo,
    tagline: "Osteria agricola con menu del giorno e sala accogliente.",
    area: "Fuori paese",
    todayStatus: "Oggi: pranzo disponibile",
    priceHint: "Menu medio 25 euro",
    coverColors: [Color(0xFF283618), Color(0xFFBC6C25)],
    icon: Icons.restaurant_rounded,
    menuSections: {
      "Menu del giorno": ["Antipasto della casa", "Primo stagionale"],
      "Secondi": ["Spezzatino", "Contorni caldi"],
      "Dolci": ["Ciambellone", "Cantucci"],
    },
    bookingSlots: ["12:15", "12:45", "13:30", "20:00"],
  ),
];

class DiningScreen extends StatelessWidget {
  const DiningScreen({
    super.key,
    this.initialKind = DiningKind.restaurant,
  });

  final DiningKind initialKind;

  @override
  Widget build(BuildContext context) {
    final venues = _diningVenues
        .where((venue) => venue.kind == initialKind)
        .toList(growable: false);
    final title =
        initialKind == DiningKind.restaurant ? "Ristoranti" : "Agriturismi";

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
              return _DiningVenueCard(
                venue: venue,
                onTap: () => onTap(venue),
              );
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
          _DiningHero(
            highlightedVenue: widget.venue,
            onTap: () {},
          ),
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
          _VenueInfoRow(
              icon: Icons.payments_rounded, text: widget.venue.priceHint),
          _VenueInfoRow(
              icon: Icons.event_available_rounded,
              text: widget.venue.todayStatus),
          const SizedBox(height: 22),
          const Text(
            "Menu",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
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
          FilledButton.icon(
            onPressed: _selectedSlot == null
                ? null
                : () {
                    final dayLabel = _formatBookingDay(days[_selectedDay]);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Richiesta per ${widget.venue.name}: $dayLabel alle $_selectedSlot",
                        ),
                      ),
                    );
                  },
            icon: const Icon(Icons.check_circle_rounded),
            label: const Text("Richiedi prenotazione"),
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
    "dic"
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
                      fontWeight: FontWeight.w800),
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
                  Text(type,
                      style: const TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.w700)),
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
                          child: Text("Centro storico, territorio APPecchio")),
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
