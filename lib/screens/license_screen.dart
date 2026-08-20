import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/license_service.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});
  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final _keyCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _keyVisible = true;

  Future<void> _activate() async {
    final key = _keyCtrl.text.trim().toUpperCase();
    if (key.isEmpty) {
      setState(() => _error = 'ادخل مفتاح التفعيل');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final result = await LicenseService.activateKey(key);
      if (!mounted) return;
      if (result.success) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, a, __) => const HomeScreen(),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ));
      } else {
        setState(() => _error = result.message ?? 'المفتاح غير صحيح');
      }
    } catch (e) {
      setState(() => _error = 'خطأ في الاتصال، حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Stack(
        children: [
          Positioned(top: -100, right: -80,
            child: Container(width: 280, height: 280,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.redPale, Colors.transparent])))),
          Positioned(bottom: -80, left: -60,
            child: Container(width: 240, height: 240,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppTheme.goldLight.withOpacity(0.3), Colors.transparent])))),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.bgWhite,
                      boxShadow: [
                        BoxShadow(color: AppTheme.redVF.withOpacity(0.15), blurRadius: 30, spreadRadius: 2),
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 6)),
                      ],
                      border: Border.all(color: AppTheme.redVF.withOpacity(0.1), width: 2),
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.redGradient,
                      ),
                      child: const Icon(Icons.vpn_key_rounded, color: Colors.white, size: 45),
                    ),
                  ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 32),

                  Text('𝘼𝙡-𝙃𝙖𝙢𝙯𝙖𝙬𝙞',
                    style: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.redVF),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                  const SizedBox(height: 6),

                  Text('𝙏𝙚𝙖𝙢 𝙅𝙤𝙆𝙨 𝙎𝙩𝙤𝙧𝙚',
                    style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.grey, letterSpacing: 3, fontWeight: FontWeight.w600),
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: 48),

                  Container(
                    decoration: AppTheme.whiteCard(),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.redPale,
                                borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.vpn_key_rounded, color: AppTheme.redVF, size: 22)),
                            const SizedBox(width: 12),
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('تفعيل التطبيق',
                                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.black)),
                              Text('أدخل مفتاح التفعيل الخاص بك',
                                style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.grey)),
                            ]),
                          ]),

                          const SizedBox(height: 24),

                          TextField(
                            controller: _keyCtrl,
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.characters,
                            obscureText: !_keyVisible,
                            style: GoogleFonts.cairo(
                              fontSize: 18, fontWeight: FontWeight.bold,
                              color: AppTheme.black, letterSpacing: 3),
                            decoration: InputDecoration(
                              hintText: 'XXXX-XXXX-XXXX',
                              hintStyle: GoogleFonts.cairo(color: AppTheme.grey, letterSpacing: 3),
                              filled: true,
                              fillColor: AppTheme.bgLight,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppTheme.redVF, width: 2)),
                              prefixIcon: const Icon(Icons.key_rounded, color: AppTheme.redVF),
                              suffixIcon: IconButton(
                                icon: Icon(_keyVisible ? Icons.visibility_off : Icons.visibility, color: AppTheme.grey),
                                onPressed: () => setState(() => _keyVisible = !_keyVisible),
                              ),
                            ),
                          ),

                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.redPale,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.redLight.withOpacity(0.3)),
                              ),
                              child: Row(children: [
                                const Icon(Icons.error_outline_rounded, color: AppTheme.redVF, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_error!,
                                  style: GoogleFonts.cairo(color: AppTheme.redDark, fontSize: 13))),
                              ]),
                            ),
                          ],

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity, height: 54,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.redLight,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0),
                              onPressed: _loading ? null : _activate,
                              child: _loading
                                  ? const SizedBox(width: 24, height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                                      const SizedBox(width: 10),
                                      Text('تفعيل', style: GoogleFonts.cairo(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                                    ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => launchUrl(
                      Uri.parse('https://wa.me/201017226806'),
                      mode: LaunchMode.externalApplication,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.bgWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.greyLight),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 20),
                        const SizedBox(width: 8),
                        Text('التواصل مع المطور',
                          style: GoogleFonts.cairo(color: AppTheme.greyDark, fontSize: 13, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
