import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class KnowMoreFull extends StatefulWidget {
  final bool forceBoxMode; // 🔹 Cart veya Order ekranı gibi durumlar için
  const KnowMoreFull({super.key, this.forceBoxMode = false});

  @override
  State<KnowMoreFull> createState() => _KnowMoreFullState();
}

class _KnowMoreFullState extends State<KnowMoreFull>
    with SingleTickerProviderStateMixin {
  bool expanded = false;
  late final AnimationController _controller;

  static const String _text = '''
🔔 Mobil Alım ve Teslimat Kuralları
📱 Mobil Alım Zorunluluğu: Bu indirimler sadece mobil uygulama üzerinden yapılan alımlarda geçerlidir. Direkt mağazadan alımlarda bu indirim uygulanmamaktadır.
⏰ Teslimat Saat Aralığı: Ürünü, siparişinizde belirtilen saat aralığında mağazadan teslim alabilirsiniz.
↩️ İptal Hakkı: Siparişinizi teslim alma zamanına 3 saate kadar iptal etme hakkınız bulunmaktadır.
❌ Teslim Almama Durumu: Belirtilen zaman diliminde teslim alınmayan ürünler için, işletmenin bu ürünü başkasına satma hakkı bulunmaktadır (iade yapılmaz).

🎁 Paket İçeriği ve Güvenlik
💚 Sürprizleri Seviyoruz! Her paket birbirinden farklıdır. Gün sonunda gıda israfını önlemek amacıyla, yenilebilir durumda kalan ürünlerle her seferinde yeni bir sürpriz hazırlanır.
⚠️ Önemli Alerji Bilgisi: Alerjiniz veya özel bir isteğiniz varsa, paketi teslim almadan önce lütfen işletmeye danışmanızı şiddetle öneririz.

🌱 Doğa Dostu Hatırlatma
🌿 Çantanızı Getirin: Sürpriz paketinizi alırken kendi çantanızı getirerek hem doğaya hem de kendinize katkıda bulunun! Yanınızda çantanız yoksa, işletmeden uygun fiyata kraft kâğıt ambalaj temin edebilirsiniz.
''';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🔹 Eğer CustomScrollView içinde değilse normal Box olarak davran
    final parent = context.findAncestorWidgetOfExactType<CustomScrollView>();
    final bool useSliver = !widget.forceBoxMode && parent != null;

    final content = _buildCard(context, theme);

    return useSliver
        ? SliverToBoxAdapter(child: content)
        : content;
  }

  Widget _buildCard(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity, // ✅ Sonsuz değil, parent genişliğini alır
      margin: widget.forceBoxMode
          ? const EdgeInsets.only(top: 8)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔸 Başlık ve "Devamını Gör"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bilmeniz Gerekenler",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              InkWell(
                onTap: _toggleExpanded,
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: Text(
                        expanded ? "Daha Az Göster" : "Devamını Gör",
                        key: ValueKey(expanded),
                        style: const TextStyle(
                          color: AppColors.primaryDarkGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    RotationTransition(
                      turns: Tween(begin: 0.0, end: 0.5).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: Curves.easeInOut,
                        ),
                      ),
                      child: const Icon(
                        Icons.expand_more_rounded,
                        color: AppColors.primaryDarkGreen,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.primaryDarkGreen.withOpacity(0.3),
          ),
          const SizedBox(height: 12),

          // 🔽 Expandable metin
          AnimatedCrossFade(
            firstChild: _clipped(_text),
            secondChild: Text(
              _text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            crossFadeState:
            expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  void _toggleExpanded() {
    setState(() {
      expanded = !expanded;
      expanded ? _controller.forward() : _controller.reverse();
    });
  }

  /// 🔽 Fade’li kısa metin görünümü
  Widget _clipped(String text) => ClipRect(
    child: ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black, Colors.black, Colors.transparent],
        stops: [0.0, 0.8, 1.0],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 0.33, // yaklaşık 5–6 satır
        child: Text(
          text,
          style: const TextStyle(color: Colors.black87, height: 1.4),
        ),
      ),
    ),
  );
}
