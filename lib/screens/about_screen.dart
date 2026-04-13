import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/app_localizations.dart';
import 'profile_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  double _scrollOffset = 0.0;

  // ====== FEATURE CAROUSEL ======
  final PageController _featureController = PageController(
    viewportFraction: 0.82,
  );
  int _featurePage = 0;
  Timer? _featureTimer;

  final List<_FeatureInfo> _features = const [
    _FeatureInfo(
      icon: Icons.search,
      titleKey: 'featureAiScanTitle',
      descriptionKey: 'featureAiScanDesc',
    ),
    _FeatureInfo(
      icon: Icons.water_drop,
      titleKey: 'featureIrrigationTitle',
      descriptionKey: 'featureIrrigationDesc',
    ),
    _FeatureInfo(
      icon: Icons.timeline,
      titleKey: 'featureMonitoringTitle',
      descriptionKey: 'featureMonitoringDesc',
    ),
    _FeatureInfo(
      icon: Icons.cloud,
      titleKey: 'featureWeatherTitle',
      descriptionKey: 'featureWeatherDesc',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Auto-slide features every 3 seconds
    _featureTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_featureController.hasClients || _features.isEmpty) return;

      int nextPage = _featurePage + 1;
      if (nextPage >= _features.length) nextPage = 0;

      _featureController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );

      setState(() => _featurePage = nextPage);
    });
  }

  @override
  void dispose() {
    _featureTimer?.cancel();
    _featureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppLocalizations.of(context);
    final Color primary = Colors.green.shade600;
    const Color background = Color(0xFFF2F4F7);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: Text(
          app.aboutTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  final currentUser = snapshot.data;
                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    backgroundImage: currentUser?.photoURL != null
                        ? NetworkImage(currentUser!.photoURL!)
                        : null,
                    child: currentUser?.photoURL == null
                        ? Text(
                            (currentUser?.displayName != null &&
                                    currentUser!.displayName!.isNotEmpty)
                                ? currentUser!.displayName![0].toUpperCase()
                                : "U",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade600,
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.axis == Axis.vertical) {
            setState(() {
              _scrollOffset = scroll.metrics.pixels;
            });
          }
          return false;
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🌿 HERO SECTION
              _AnimatedHeroSection(
                primary: primary,
                scrollOffset: _scrollOffset,
              ),

              const SizedBox(height: 24),

              // 👨‍💻 DEVELOPERS
              _SectionTitle(title: app.developers),
              const SizedBox(height: 10),

              _DeveloperCard(
                name: "Apurva Patel",
                role: "Hardware & AI/ML Integration",
                description:
                    "Handled Arduino Uno hardware setup, sensor interfacing, and relay-based irrigation control. Integrated AI/ML plant disease detection and enabled Bluetooth (HC-05) communication for real-time monitoring through the mobile app.",
                skills: const [
                  "Arduino Uno",
                  "C/C++",
                  "Circuit Design",
                  "AI/ML Integration",
                  "Bluetooth (HC-05)",
                  "Power Management",
                  "Sensors & Relays",
                ],
                // photo: "assets/images/co_dev.png", // Image not available
              ),

              const SizedBox(height: 16),

              _DeveloperCard(
                name: "Aryan Parmar",
                role: "App Developer • UI/UX • IoT Integration",
                description:
                    "Leads the mobile app, user experience, and bridges data between Arduino Uno hardware and the app.",
                skills: const [
                  "Flutter",
                  "UI/UX",
                  "Arduino Uno",
                  "Sensors & Relays",
                  "Firebase",
                ],
                // photo: "assets/images/aryan.png", // Image not available
              ),

              const SizedBox(height: 26),

              // ✨ FEATURES – auto sliding carousel
              _DepthWrapper(
                depth: _scrollOffset,
                start: 150,
                end: 420,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: app.keyFeatures),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 210,
                      child: Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _featureController,
                              itemCount: _features.length,
                              onPageChanged: (index) {
                                setState(() => _featurePage = index);
                              },
                              itemBuilder: (context, index) {
                                final feature = _features[index];
                                final isActive = index == _featurePage;

                                return AnimatedScale(
                                  scale: isActive ? 1.0 : 0.94,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOut,
                                  child: _FeatureCard(
                                    icon: feature.icon,
                                    title: _resolveFeatureTitle(
                                      app,
                                      feature.titleKey,
                                    ),
                                    description: _resolveFeatureDesc(
                                      app,
                                      feature.descriptionKey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_features.length, (index) {
                              final bool isActive = index == _featurePage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                width: isActive ? 16 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? primary
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // 🚀 HOW TO USE – timeline
              _DepthWrapper(
                depth: _scrollOffset,
                start: 280,
                end: 550,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: app.howToUse),
                    const SizedBox(height: 10),
                    _StepTimeline(
                      steps: [
                        app.howStep1,
                        app.howStep2,
                        app.howStep3,
                        app.howStep4,
                        app.howStep5,
                        app.howStep6,
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // 🌾 USE CASES + ADVANTAGES
              _DepthWrapper(
                depth: _scrollOffset,
                start: 420,
                end: 750,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: app.useCases),
                    const SizedBox(height: 10),
                    const _UseCasesAdvantagesCard(),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Center(
                child: Text(
                  app.versionInfo,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  String _resolveFeatureTitle(AppLocalizations app, String key) {
    switch (key) {
      case 'featureAiScanTitle':
        return app.featureAiScanTitle;
      case 'featureIrrigationTitle':
        return app.featureIrrigationTitle;
      case 'featureMonitoringTitle':
        return app.featureMonitoringTitle;
      case 'featureWeatherTitle':
        return app.featureWeatherTitle;
      default:
        return '';
    }
  }

  String _resolveFeatureDesc(AppLocalizations app, String key) {
    switch (key) {
      case 'featureAiScanDesc':
        return app.featureAiScanDesc;
      case 'featureIrrigationDesc':
        return app.featureIrrigationDesc;
      case 'featureMonitoringDesc':
        return app.featureMonitoringDesc;
      case 'featureWeatherDesc':
        return app.featureWeatherDesc;
      default:
        return '';
    }
  }
}

String _getInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

/// Wraps a child and adjusts its opacity / slight translate based on scroll depth.
class _DepthWrapper extends StatelessWidget {
  final double depth;
  final double start;
  final double end;
  final Widget child;

  const _DepthWrapper({
    super.key,
    required this.depth,
    required this.start,
    required this.end,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Normalize 0–1 based on scroll range
    double t = ((depth - start) / (end - start)).clamp(0.0, 1.0);
    final double opacity = t;
    final double offsetY = (1 - t) * 18; // moves slightly up as it appears

    return Opacity(
      opacity: opacity,
      child: Transform.translate(offset: Offset(0, offsetY), child: child),
    );
  }
}

// ===================== HERO & TITLES ==========================

class _AnimatedHeroSection extends StatelessWidget {
  final Color primary;
  final double scrollOffset;

  const _AnimatedHeroSection({
    super.key,
    required this.primary,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    // shrink + fade slightly based on scroll
    final double t = (scrollOffset / 160).clamp(0.0, 1.0);
    final double scale = 1.0 - (t * 0.06); // min ~0.94
    final double opacity = 1.0 - (t * 0.3); // min ~0.7

    return Transform.scale(
      scale: scale,
      alignment: Alignment.center,
      child: Opacity(
        opacity: opacity,
        child: Container(
          height: 210,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [primary, primary.withOpacity(0.9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(0.18),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -14,
                top: -6,
                child: Icon(
                  Icons.agriculture,
                  size: 110,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              Positioned(
                left: -6,
                bottom: -14,
                child: Icon(
                  Icons.grass,
                  size: 80,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AgroXpert Plus",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Farming assistant with sensors, irrigation control, and disease scan.",
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: const [
                        _InfoChip(label: "AI powered"),
                        SizedBox(width: 8),
                        _InfoChip(label: "Arduino Uno"),
                        SizedBox(width: 8),
                        _InfoChip(label: "For farmers"),
                      ],
                    ),
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

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11.5,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    );
  }
}

// ===================== FEATURE MODEL + CARD ==========================

class _FeatureInfo {
  final IconData icon;
  final String titleKey;
  final String descriptionKey;

  const _FeatureInfo({
    required this.icon,
    required this.titleKey,
    required this.descriptionKey,
  });
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = Colors.green.shade600;

    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primary, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== TIMELINE ==========================

class _StepTimeline extends StatelessWidget {
  final List<String> steps;
  const _StepTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    final Color primary = Colors.green.shade600;

    return Column(
      children: List.generate(steps.length, (index) {
        final isLast = index == steps.length - 1;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 30, color: Colors.green.shade200),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 12),
                child: Text(
                  steps[index],
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ===================== DEVELOPERS + POPUP ==========================

class _DeveloperCard extends StatelessWidget {
  final String name;
  final String role;
  final String description;
  final List<String> skills;
  final String? photo;

  const _DeveloperCard({
    super.key,
    required this.name,
    required this.role,
    required this.description,
    required this.skills,
    this.photo,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = Colors.green.shade600;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) {
            return _DeveloperPopup(
              name: name,
              role: role,
              description: description,
              skills: skills,
              photo: photo,
            );
          },
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.green.shade100,
              backgroundImage: photo != null ? AssetImage(photo!) : null,
              child: photo == null
                  ? Text(
                      _getInitials(name),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.3,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: skills.map((s) => _SkillChip(label: s)).toList(),
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

class _DeveloperPopup extends StatelessWidget {
  final String name;
  final String role;
  final String description;
  final List<String> skills;
  final String? photo;

  const _DeveloperPopup({
    super.key,
    required this.name,
    required this.role,
    required this.description,
    required this.skills,
    this.photo,
  });

  @override
  Widget build(BuildContext context) {
    final Color primary = Colors.green.shade600;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Stack(
            children: [
              // top-right close icon
              Positioned(
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 26),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // main content
              SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    // drag handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    // photo
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.green.shade100,
                      backgroundImage: photo != null
                          ? AssetImage(photo!)
                          : null,
                      child: photo == null
                          ? Text(
                              _getInitials(name),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // role
                    Text(
                      role,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // description
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // skills title
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Skills",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // skills chips
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: skills
                            .map((s) => _SkillChip(label: s))
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // outlined close button
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primary, width: 1.4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ===================== USE CASES / ADVANTAGES ==========================

class _UseCasesAdvantagesCard extends StatelessWidget {
  const _UseCasesAdvantagesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 320;

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Use cases",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                _BulletRow(text: "Small and medium farms."),
                _BulletRow(text: "Polyhouse / greenhouse monitoring."),
                _BulletRow(text: "Student and academic demos."),
                SizedBox(height: 12),
                Text(
                  "Advantages",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6),
                _BulletRow(text: "Saves time and manual checks."),
                _BulletRow(text: "Reduces water and resource wastage."),
                _BulletRow(text: "Supports early issue detection."),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Use cases",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      _BulletRow(text: "Small and medium farms."),
                      _BulletRow(text: "Polyhouse / greenhouse monitoring."),
                      _BulletRow(text: "Student and academic demos."),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Advantages",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      _BulletRow(text: "Saves time and manual checks."),
                      _BulletRow(text: "Reduces water and resource wastage."),
                      _BulletRow(text: "Supports early issue detection."),
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

class _BulletRow extends StatelessWidget {
  final String text;
  const _BulletRow({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(fontSize: 13.5)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.5, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
