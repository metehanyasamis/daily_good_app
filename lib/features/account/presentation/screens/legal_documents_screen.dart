import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart'; // ✅ BU IMPORT ŞART
import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/domain/providers/legal_settings_provider.dart';


class LegalDocumentsScreen extends ConsumerWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(legalSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Yasal Bilgiler",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: settingsAsync.when(
        data: (settings) {
          final c = settings.contracts;
          final List<Map<String, String?>> docList = [
            {'title': 'Üyelik Sözleşmesi', 'url': c['uyelik_sozlesmesi']?.url},
            {'title': 'KVKK Aydınlatma Metni', 'url': c['kvkk_aydinlatma_metni']?.url},
            {'title': 'Gizlilik Sözleşmesi', 'url': c['gizlilik_sozlesmesi']?.url},
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildCard(
              title: "Sözleşmeler ve Metinler",
              children: docList.map((doc) {
                final isLast = docList.indexOf(doc) == docList.length - 1;
                return Column(
                  children: [
                    InkWell(
                      onTap: () => _showLegalSheet(context, doc['title']!, doc['url']),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14), // Satır ferahlığı burada
                        child: Row(
                          children: [
                            const Icon(Icons.description_outlined, size: 20, color: AppColors.primaryDarkGreen),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                doc['title']!,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast) Divider(height: 1, color: Colors.grey.shade300), // Satır arası ince çizgi
                  ],
                );
              }).toList(),
            ),
          );
        },
        loading: () => Center(child: PlatformWidgets.loader()),
        error: (e, _) => Center(child: Text("Hata: $e")),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  // ✅ Fonksiyonu sınıfın içine aldık
  void _showLegalSheet(BuildContext context, String title, String? url) {
    if (url == null || url.isEmpty || url == "string") return;

    final String viewUrl = "https://docs.google.com/gview?embedded=true&url=$url";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);

        final controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.white)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (_) => isLoading.value = false,
            ),
          )
          ..loadRequest(Uri.parse(viewUrl));

        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // --- ÜST BAR (HEADER) ---
                  SizedBox(
                    height: 56, // Standart toolbar yüksekliği
                    child: Stack(
                      children: [
                        // 1. Gri Çizgi (Handle)
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: const EdgeInsets.only(top: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // 2. Dinamik Başlık (Tıklanan sözleşmenin adı)
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 48),
                            child: Text(
                              title, // 🔥 Burası artık dinamik!
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black87
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        // 3. Kapat Butonu (Tam sağda)
                        Positioned(
                          right: 0, // En sağa yasla
                          top: 0,
                          bottom: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.black54),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade300),

                  // --- WEBVIEW İÇERİĞİ ---
                  Expanded(
                    child: Stack(
                      children: [
                        WebViewWidget(controller: controller),
                        ValueListenableBuilder<bool>(
                          valueListenable: isLoading,
                          builder: (context, loading, _) {
                            return loading
                                ? Center(
                              child: PlatformWidgets.loader(),
                            )
                                : const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

}