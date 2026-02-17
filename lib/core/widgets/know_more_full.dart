import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
// Örn: SettingsProvider'dan veriyi çektiğini varsayalım

class KnowMoreFull extends StatefulWidget {
  final bool forceBoxMode;
  final String? customInfo; // 👈 Backend'den gelen "important_info" buraya gelecek

  const KnowMoreFull({
    super.key,
    this.forceBoxMode = false,
    this.customInfo,
  });

  @override
  State<KnowMoreFull> createState() => _KnowMoreFullState();
}

class _KnowMoreFullState extends State<KnowMoreFull>
    with SingleTickerProviderStateMixin {
  bool expanded = false;
  late final AnimationController _controller;

  // 📝 Backend'den veri gelmezse kullanılacak yedek (fallback) metin
  static const String _defaultText = '''
🔔 Mobil Alım ve Teslimat Kuralları
📱 Mobil Alım Zorunluluğu: Bu indirimler sadece mobil uygulama üzerinden yapılan alımlarda geçerlidir.
⏰ Teslimat Saat Aralığı: Ürünü, siparişinizde belirtilen saat aralığında mağazadan teslim alabilirsiniz.
↩️ İptal Hakkı: Siparişinizi teslim alma zamanına 3 saate kadar iptal etme hakkınız bulunmaktadır.
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

    // widget.customInfo varsa onu kullan, yoksa default metni kullan
    final infoText = (widget.customInfo != null && widget.customInfo!.isNotEmpty)
        ? widget.customInfo!
        : _defaultText;

    final parent = context.findAncestorWidgetOfExactType<CustomScrollView>();
    final bool useSliver = !widget.forceBoxMode && parent != null;

    final content = _buildCard(context, theme, infoText);

    return useSliver ? SliverToBoxAdapter(child: content) : content;
  }

  Widget _buildCard(BuildContext context, ThemeData theme, String text) {
    return Container(
      width: double.infinity,
      margin: widget.forceBoxMode
          ? const EdgeInsets.only(top: 8)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryDarkGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          const SizedBox(height: 8),
          _divider(),
          const SizedBox(height: 12),

          // 🔽 Expandable metin (Backend'den gelen veri)
          AnimatedCrossFade(
            firstChild: _clipped(text),
            secondChild: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            crossFadeState: expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
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
              Text(
                expanded ? "Daha Az Göster" : "Devamını Gör",
                style: const TextStyle(
                  color: AppColors.primaryDarkGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(_controller),
                child: const Icon(Icons.expand_more_rounded, color: AppColors.primaryDarkGreen),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() => Container(height: 1, color: AppColors.primaryDarkGreen.withValues(alpha: 0.1));

  void _toggleExpanded() {
    setState(() {
      expanded = !expanded;
      expanded ? _controller.forward() : _controller.reverse();
    });
  }

  Widget _clipped(String text) => ShaderMask(
    shaderCallback: (rect) => const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.black, Colors.transparent],
    ).createShader(rect),
    blendMode: BlendMode.dstIn,
    child: Align(
      alignment: Alignment.topCenter,
      heightFactor: 0.3, // İlk 3-4 satırı gösterir
      child: Text(text, style: const TextStyle(color: Colors.black87, height: 1.5)),
    ),
  );
}