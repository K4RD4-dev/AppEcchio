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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
  String _activeQuickFilter = "Oggi";

  static const List<String> _quickFilters = ["Oggi", "Aperti ora", "Vicino a me"];

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
          MenuNode(id: "calendario", label: "Calendario", icon: Icons.calendar_month_rounded),
          MenuNode(id: "festival", label: "Festival", icon: Icons.music_note_rounded),
          MenuNode(id: "sport", label: "Sport", icon: Icons.sports_soccer_rounded),
          MenuNode(id: "teatro", label: "Teatro", icon: Icons.theater_comedy_rounded),
        ],
      ),
      MenuNode(
        id: "food",
        label: "Cibo e Drink",
        icon: Icons.restaurant_menu_rounded,
        children: <MenuNode>[
          MenuNode(id: "ristoranti", label: "Ristoranti", icon: Icons.restaurant_rounded),
          MenuNode(
            id: "agriturismi",
            label: "Agriturismi",
            icon: Icons.park_rounded,
            children: <MenuNode>[
              MenuNode(id: "agri_piscina", label: "Con piscina", icon: Icons.pool_rounded),
              MenuNode(id: "agri_pet", label: "Pet friendly", icon: Icons.pets_rounded),
              MenuNode(id: "agri_km0", label: "Km 0", icon: Icons.local_florist_rounded),
            ],
          ),
          MenuNode(id: "bar", label: "Bar", icon: Icons.local_cafe_rounded),
          MenuNode(id: "enogastronomia", label: "Eventi enogastronomici", icon: Icons.wine_bar_rounded),
        ],
      ),
      MenuNode(
        id: "cultura",
        label: "Cultura",
        icon: Icons.account_balance_rounded,
        children: <MenuNode>[
          MenuNode(id: "musei", label: "Musei", icon: Icons.museum_rounded),
          MenuNode(id: "borghi", label: "Borghi", icon: Icons.location_city_rounded),
          MenuNode(id: "arte", label: "Arte", icon: Icons.palette_rounded),
          MenuNode(id: "storia", label: "Percorsi storici", icon: Icons.history_edu_rounded),
        ],
      ),
      MenuNode(
        id: "servizi",
        label: "Servizi",
        icon: Icons.miscellaneous_services_rounded,
        children: <MenuNode>[
          MenuNode(id: "farmacia", label: "Farmacie", icon: Icons.local_hospital_rounded),
          MenuNode(id: "trasporti", label: "Trasporti", icon: Icons.directions_bus_rounded),
          MenuNode(id: "bancomat", label: "Bancomat", icon: Icons.atm_rounded),
          MenuNode(id: "salute", label: "Salute", icon: Icons.health_and_safety_rounded),
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
              MenuNode(id: "sindaco_giunta", label: "Sindaco e Giunta", icon: Icons.groups_rounded),
              MenuNode(id: "uffici_orari", label: "Uffici e orari", icon: Icons.schedule_rounded),
              MenuNode(id: "rubrica", label: "Contatti rapidi", icon: Icons.contact_phone_rounded),
            ],
          ),
          MenuNode(
            id: "consiglio_comunale",
            label: "Consiglio comunale",
            icon: Icons.how_to_vote_rounded,
            children: <MenuNode>[
              MenuNode(id: "diretta", label: "Diretta sedute", icon: Icons.live_tv_rounded),
              MenuNode(id: "registrazioni", label: "Sedute registrate", icon: Icons.video_library_rounded),
              MenuNode(id: "ordine_giorno", label: "Ordine del giorno", icon: Icons.list_alt_rounded),
            ],
          ),
          MenuNode(
            id: "atti_trasparenza",
            label: "Atti e Trasparenza",
            icon: Icons.gavel_rounded,
            children: <MenuNode>[
              MenuNode(id: "albo_pretorio", label: "Albo pretorio", icon: Icons.folder_shared_rounded),
              MenuNode(id: "delibere", label: "Delibere e determine", icon: Icons.description_rounded),
              MenuNode(id: "bandi", label: "Bandi e concorsi", icon: Icons.campaign_rounded),
            ],
          ),
          MenuNode(
            id: "servizi_cittadino",
            label: "Servizi al cittadino",
            icon: Icons.volunteer_activism_rounded,
            children: <MenuNode>[
              MenuNode(id: "pagamenti", label: "Pagamenti e tributi", icon: Icons.payments_rounded),
              MenuNode(id: "appuntamenti", label: "Prenota appuntamento", icon: Icons.event_available_rounded),
              MenuNode(id: "certificati", label: "Certificati anagrafici", icon: Icons.badge_rounded),
              MenuNode(id: "segnalazioni", label: "Segnalazioni al Comune", icon: Icons.report_problem_rounded),
            ],
          ),
          MenuNode(
            id: "vita_pubblica",
            label: "Scuola, mobilita e ambiente",
            icon: Icons.public_rounded,
            children: <MenuNode>[
              MenuNode(id: "scuola", label: "Servizi scolastici", icon: Icons.school_rounded),
              MenuNode(id: "mobilita", label: "Viabilita e trasporto locale", icon: Icons.traffic_rounded),
              MenuNode(id: "rifiuti", label: "Raccolta rifiuti", icon: Icons.recycling_rounded),
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
              MenuNode(id: "campo_tennis", label: "Campo da tennis", icon: Icons.sports_tennis_rounded),
              MenuNode(id: "palazzetto_pallavolo", label: "Palazzetto - Pallavolo", icon: Icons.sports_volleyball_rounded),
              MenuNode(id: "palazzetto_city_tennis", label: "Palazzetto - City tennis", icon: Icons.sports_handball_rounded),
              MenuNode(id: "palazzetto_calcetto", label: "Palazzetto - Calcetto", icon: Icons.sports_soccer_rounded),
              MenuNode(id: "campo_del_prete", label: "Campo del prete", icon: Icons.grass_rounded),
              MenuNode(
                id: "regole_prenotazione",
                label: "Regolamenti e tariffe",
                icon: Icons.rule_rounded,
                children: <MenuNode>[
                  MenuNode(id: "fasce_orarie", label: "Fasce orarie", icon: Icons.schedule_rounded),
                  MenuNode(id: "tariffe", label: "Tariffe", icon: Icons.euro_rounded),
                  MenuNode(id: "annulla_sposta", label: "Annulla o sposta prenotazione", icon: Icons.swap_horiz_rounded),
                ],
              ),
            ],
          ),
          MenuNode(
            id: "sentieri",
            label: "Sentieri e percorsi naturalistici",
            icon: Icons.terrain_rounded,
            children: <MenuNode>[
              MenuNode(id: "mappa_sentieri", label: "Mappa sentieri", icon: Icons.map_rounded),
              MenuNode(id: "difficolta_tempo", label: "Difficolta e tempi", icon: Icons.hiking_rounded),
              MenuNode(id: "prenota_guida", label: "Prenota guida ambientale", icon: Icons.support_agent_rounded),
              MenuNode(id: "prenota_istruttore", label: "Prenota istruttore outdoor", icon: Icons.fitness_center_rounded),
              MenuNode(id: "noleggio_ebike", label: "Noleggio bici elettriche", icon: Icons.electric_bike_rounded),
              MenuNode(id: "tour_famiglie", label: "Tour famiglie e scuole", icon: Icons.family_restroom_rounded),
            ],
          ),
        ],
      ),
    ],
  );

  late List<MenuNode> _menuPath;

  MenuNode get _currentNode => _menuPath.last;
  MenuNode? get _parentNode => _menuPath.length > 1 ? _menuPath[_menuPath.length - 2] : null;

  @override
  void initState() {
    super.initState();
    _menuPath = <MenuNode>[_menuRoot];
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
                      const _SearchGlassBar(),
                      const SizedBox(height: 12),
                      _QuickFilterRow(
                        selected: _activeQuickFilter,
                        filters: _quickFilters,
                        onChanged: (value) => setState(() => _activeQuickFilter = value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 110,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _showRadialMenu ? 0.10 : 1,
              child: IgnorePointer(
                ignoring: _showRadialMenu,
                child: _TodayContextCard(
                  onTap: () => _openDetail(
                    title: "Cosa succede oggi",
                    type: "Suggerimenti intelligenti",
                    ctaLabel: "Apri",
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

  String _ctaForCategory(String category) {
    switch (category) {
      case "Events":
        return "Join";
      case "Food & Drink":
        return "Call / Navigate";
      case "Services":
        return "Access";
      default:
        return "View details";
    }
  }

  void _toggleExplore() {
    setState(() {
      if (!_showRadialMenu) {
        _menuPath = <MenuNode>[_menuRoot];
      }
      _showRadialMenu = !_showRadialMenu;
    });
  }

  void _onNodeTap(MenuNode node) {
    if (node.isLeaf) {
      setState(() => _showRadialMenu = false);
      Future<void>.delayed(const Duration(milliseconds: 560), () {
        if (!mounted) {
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
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
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
                    colors: [Color(0xFF4F7F62), Color(0xFF769F80), Color(0xFFB1C8AF)],
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
                  Colors.black.withOpacity(0.10),
                  Colors.black.withOpacity(0.18),
                  Colors.black.withOpacity(0.25),
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
      ..color = Colors.white.withOpacity(0.20)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(20, size.height * 0.24)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.22, size.width - 30, size.height * 0.35)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.54, 40, size.height * 0.68)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.76, size.width - 40, size.height * 0.9);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
          color: Colors.white.withOpacity(0.22),
          child: const Row(
            children: [
              Icon(Icons.search, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Cerca luoghi, eventi, servizi...",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickFilterRow extends StatelessWidget {
  const _QuickFilterRow({
    required this.selected,
    required this.filters,
    required this.onChanged,
  });

  final String selected;
  final List<String> filters;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: filters.map((filter) {
        final isActive = filter == selected;
        return ChoiceChip(
          label: Text(filter),
          selected: isActive,
          onSelected: (_) => onChanged(filter),
          selectedColor: const Color(0xFF2E7D57),
          labelStyle: TextStyle(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.88),
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.black.withOpacity(0.24),
        );
      }).toList(),
    );
  }
}

class _TodayContextCard extends StatelessWidget {
  const _TodayContextCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white.withOpacity(0.2),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Cosa succede oggi",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white),
            ],
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
        final shortest = math.min(constraints.maxWidth, constraints.maxHeight);
        final countFactor = currentNode.children.length > 5 ? 0.90 : 1.0;
        final nodeWidth = ((shortest * 0.27) * countFactor).clamp(84.0, 118.0).toDouble();
        final nodeHeight = ((shortest * 0.21) * countFactor).clamp(72.0, 98.0).toDouble();
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
        final targets = _computeTargets(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          center: center,
          total: currentNode.children.length,
          hasParent: parentNode != null,
          nodeWidth: nodeWidth,
          nodeHeight: nodeHeight,
        );
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.72),
                Colors.black.withOpacity(0.66),
                Colors.black.withOpacity(0.74),
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
                    top: 70,
                    left: 22,
                    right: 22,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 350),
                      opacity: progress,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.22)),
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
                      radius: (shortest * 0.27).clamp(102.0, 146.0).toDouble(),
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
  }) {
    if (total == 0) {
      return const <Offset>[];
    }
    final start = hasParent ? -math.pi / 2.8 : -math.pi * 0.86;
    final end = hasParent ? math.pi / 2.8 : math.pi * 0.86;
    final shortest = math.min(size.width, size.height);
    var baseRadius = (hasParent ? shortest * 0.34 : shortest * 0.38).clamp(108.0, 188.0).toDouble();

    const horizontalPadding = 12.0;
    const bottomPadding = 18.0;
    const topPadding = 128.0;

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
      final ringGap = (nodeHeight * 0.95).clamp(60.0, 78.0).toDouble();
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
        final capacity = math.max(1, (ringArcLength / (nodeWidth + 12)).floor());
        final take = ringIndex == rings.length - 1 ? remaining : math.min(remaining, capacity);
        if (take <= 0) {
          continue;
        }

        for (var i = 0; i < take; i++) {
          final t = take == 1 ? 0.5 : i / (take - 1);
          final angle = start + (end - start) * t;
          final dx = center.dx + math.cos(angle) * ringRadius;
          final dy = center.dy + math.sin(angle) * ringRadius;
          points.add(Offset(dx, dy));
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
          points.add(Offset(dx, dy));
        }
      }
      return points;
    }

    var points = buildPositions(baseRadius);
    while (baseRadius > 82 && !fits(points)) {
      baseRadius -= 6;
      points = buildPositions(baseRadius);
    }

    if (!fits(points)) {
      // Last-resort compact fallback without overlap checks.
      points = buildPositions(82);
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
      ..color = const Color(0xFFBFE8C7).withOpacity(0.58 * progress);

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
        paint..color = const Color(0xFFE4EFE8).withOpacity(0.35 * progress),
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
    final shortest = MediaQuery.of(context).size.shortestSide;
    final openSize = (shortest * 0.31).clamp(98.0, 118.0).toDouble();
    final closedSize = (shortest * 0.24).clamp(80.0, 92.0).toDouble();
    final openFont = (shortest * 0.030).clamp(10.0, 12.0).toDouble();
    final closedFont = (shortest * 0.038).clamp(12.0, 14.0).toDouble();
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
          alignment: isOpen ? Alignment.center : const Alignment(0, 0.92),
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
                    color: const Color(0xFF1F5D3E).withOpacity(isOpen ? 0.45 : 0.60),
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
    final targetDx = fixedOffset?.dx ?? (center.dx + math.cos(fixedAngle ?? 0) * radius);
    final targetDy = fixedOffset?.dy ?? (center.dy + math.sin(fixedAngle ?? 0) * radius);
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
              color: selected ? const Color(0xFF2E7D57) : Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.7)),
              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 14, offset: Offset(0, 7))],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 66 || constraints.maxWidth < 86;
                    final adaptiveIconSize = compact ? (iconSize - 3).clamp(14.0, 18.0) : iconSize;
                    final adaptiveTextSize = compact ? (textSize - 1.4).clamp(8.8, 10.6) : textSize;
                    final maxTextLines = compact ? 2 : 3;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: adaptiveIconSize, color: selected ? Colors.white : const Color(0xFF1B2E21)),
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
                                color: selected ? Colors.white : const Color(0xFF1B2E21),
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
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
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
                  Text(type, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
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
                      Expanded(child: Text("Centro storico, territorio APPecchio")),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.category, size: 18),
                      SizedBox(width: 8),
                      Text("Suggerimento locale intelligente"),
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
