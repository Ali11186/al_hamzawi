import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../models/card_model.dart';
import '../theme/app_theme.dart';
import 'charge_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<CardModel> _cards = CardModel.getAll();

  String _search = '';
  bool _isLoading = true;
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startConnectivityMonitoring();
  }

  Future<void> _startConnectivityMonitoring() async {
    await _checkConnectivity();

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (!mounted) return;

      setState(() {
        _isOffline =
            results.isEmpty || results.contains(ConnectivityResult.none);
      });
    });
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();

    if (!mounted) return;

    setState(() {
      _isOffline =
          results.isEmpty || results.contains(ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<CardModel> get _filtered {
    return _cards
        .where(
          (card) =>
              card.name.contains(_search) ||
              card.netCharge.contains(_search),
        )
        .toList();
  }

  Future<void> _contactDeveloper() async {
    final uri = Uri.parse('https://wa.me/201017226806');

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر فتح واتساب',
              style: GoogleFonts.cairo(),
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذر فتح واتساب',
            style: GoogleFonts.cairo(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppTheme.bgWhite,
            surfaceTintColor: Colors.transparent,
            elevation: 0.5,
            shadowColor: Colors.black.withOpacity(0.05),
            flexibleSpace: FlexibleSpaceBar(
              background: const _AppBarBg(),
              title: const _ShimmerTitle(),
              centerTitle: false,
              titlePadding: const EdgeInsetsDirectional.only(
                start: 16,
                bottom: 14,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'السجل',
                icon: const Icon(
                  Icons.history_rounded,
                  color: AppTheme.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    _SlideRoute(
                      page: const HistoryScreen(),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: TextButton.icon(
                  onPressed: _contactDeveloper,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.support_agent_rounded,
                    size: 20,
                  ),
                  label: Text(
                    'الدعم',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_isOffline)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.redPale,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.redLight.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      color: AppTheme.redVF,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'لا يوجد اتصال بالإنترنت',
                        style: GoogleFonts.cairo(
                          color: AppTheme.redDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _checkConnectivity,
                      child: Text(
                        'إعادة المحاولة',
                        style: GoogleFonts.cairo(
                          color: AppTheme.redVF,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                onChanged: (value) {
                  setState(() => _search = value);
                },
                style: GoogleFonts.cairo(
                  color: AppTheme.black,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث عن باقة...',
                  hintStyle: GoogleFonts.cairo(
                    color: AppTheme.grey,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.grey,
                  ),
                  filled: true,
                  fillColor: AppTheme.bgWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.greyLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.redVF,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppTheme.greyLight,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppTheme.redVF,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الباقات المتاحة',
                    style: GoogleFonts.cairo(
                      color: AppTheme.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_filtered.length} باقة',
                    style: GoogleFonts.cairo(
                      color: AppTheme.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const _SkeletonCard(),
                  childCount: 6,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _CardTile(
                      card: _filtered[index],
                    )
                        .animate()
                        .fadeIn(
                          delay: (index * 30).ms,
                          duration: 300.ms,
                        )
                        .scale(
                          begin: const Offset(0.9, 0.9),
                        );
                  },
                  childCount: _filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShimmerTitle extends StatefulWidget {
  const _ShimmerTitle();

  @override
  State<_ShimmerTitle> createState() => _ShimmerTitleState();
}

class _ShimmerTitleState extends State<_ShimmerTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) => AppTheme.shimmerRed(t: _controller.value).createShader(bounds),
          child: Text(
            '𝘼𝙡-𝙃𝙖𝙢𝙯𝙖𝙬𝙞',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppTheme.redVF,
            ),
          ),
        );
      },
    );
  }
}

class _AppBarBg extends StatelessWidget {
  const _AppBarBg();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgWhite,
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.redPale,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Image.asset(
                'assets/images/app_icon.png',
                height: 45,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.redGradient,
                    ),
                    child: const Icon(Icons.signal_cellular_alt, color: Colors.white, size: 24),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final CardModel card;

  const _CardTile({
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          _SlideRoute(
            page: ChargeScreen(card: card),
          ),
        );
      },
      child: Container(
        decoration: AppTheme.redCard(radius: 18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // خلفية الكارت الأحمر
              Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.cardGradient,
                ),
              ),
              
              // محتوى الكارت
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // شعار فودافون
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppTheme.redGradient,
                              ),
                            ),
                          ),
                        ),
                        if (card.duration.contains('جديد') || card.name.contains('جديد'))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.gold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'جديد',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // السعر الكبير
                    Text(
                      card.netCharge.replaceAll('.00', ''),
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),

                    // التفاصيل
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.units,
                          style: GoogleFonts.cairo(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          card.duration,
                          style: GoogleFonts.cairo(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // صورة الجنّي (placeholder)
              Positioned(
                bottom: -10,
                right: -10,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 80,
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

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.redLight.withOpacity(_animation.value * 0.3),
            borderRadius: BorderRadius.circular(18),
          ),
        );
      },
    );
  }
}

class _SlideRoute extends PageRouteBuilder {
  final Widget page;

  _SlideRoute({
    required this.page,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInOutCubic,
            );

            final slide = Tween<Offset>(
              begin: const Offset(0.12, 0.0),
              end: Offset.zero,
            ).animate(curvedAnimation);

            final fade = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation);

            return FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: slide,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}
