import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final h = await HistoryService.getHistory();
    if (mounted) setState(() { _history = h; _loading = false; });
  }

  Future<void> _clear() async {
    await HistoryService.clearHistory();
    if (mounted) setState(() => _history = []);
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}  ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: AppTheme.bgWhite,
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.05),
        title: Text('سجل العمليات', style: GoogleFonts.cairo(color: AppTheme.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.redVF),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: AppTheme.bgWhite,
                  title: Text('مسح السجل', style: GoogleFonts.cairo(color: AppTheme.black)),
                  content: Text('هل تريد مسح كل السجل؟', style: GoogleFonts.cairo(color: AppTheme.grey)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text('إلغاء', style: GoogleFonts.cairo(color: AppTheme.grey))),
                    TextButton(onPressed: () { Navigator.pop(context); _clear(); }, child: Text('مسح', style: GoogleFonts.cairo(color: AppTheme.redVF))),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.redVF))
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, color: AppTheme.greyLight, size: 64),
                      const SizedBox(height: 16),
                      Text('لا يوجد سجل بعد', style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (ctx, i) {
                    final item = _history[i];
                    final success = item['success'] == true;
                    final statusColor = success ? Colors.green : AppTheme.redVF;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.bgWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: statusColor.withOpacity(0.15),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              success ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: statusColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['card'] ?? '', style: GoogleFonts.cairo(color: AppTheme.black, fontWeight: FontWeight.bold)),
                                Text(item['phone'] ?? '', style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 13)),
                                Text(_formatDate(item['date'] ?? ''), style: GoogleFonts.cairo(color: AppTheme.grey, fontSize: 11)),
                              ],
                            ),
                          ),
                          Text(
                            '${item['charge']} ج',
                            style: GoogleFonts.cairo(color: AppTheme.redVF, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (i * 40).ms).slideX(begin: 0.1);
                  },
                ),
    );
  }
}
