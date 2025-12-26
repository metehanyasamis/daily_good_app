import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart'; // ✅ BU IMPORT ŞART
import '../../../settings/domain/providers/legal_settings_provider.dart';


class LegalDocumentsScreen extends ConsumerWidget {
  const LegalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("🚀 [LegalDocumentsScreen] Sade liste oluşturuluyor.");
    final settingsAsync = ref.watch(legalSettingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Hafif gri zemin
      appBar: AppBar(
        title: const Text("Yasal Bilgiler",
            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: settingsAsync.when(
        data: (settings) {
          final c = settings.contracts;
          final List<Map<String, String?>> docList = [
            {'title': 'Üyelik Sözleşmesi', 'url': c['uyelik_sozlesmesi']?.url},
            {'title': 'KVKK Aydınlatma Metni', 'url': c['kvkk_aydinlatma_metni']?.url},
            {'title': 'Gizlilik Sözleşmesi', 'url': c['gizlilik_sozlesmesi']?.url},
            {'title': 'Ön Bilgilendirme Formu', 'url': c['on_bilgilendirme_formu']?.url},
            {'title': 'Mesafeli Satış Sözleşmesi', 'url': c['mesafeli_satis_sozlesmesi']?.url},
          ];

          return ListView.separated(
            padding: const EdgeInsets.only(top: 16),
            itemCount: docList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 1), // Kutular arası çok ince boşluk
            itemBuilder: (context, index) {
              return Container(
                color: Colors.white, // Satır içi bembeyaz
                child: ListTile(
                  title: Text(docList[index]['title']!,
                      style: const TextStyle(fontSize: 14, color: Colors.black87)),
                  trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                  onTap: () => _showLegalSheet(context, docList[index]['title']!, docList[index]['url']),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Hata: $e")),
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
                  const Divider(height: 1),

                  // --- WEBVIEW İÇERİĞİ ---
                  Expanded(
                    child: Stack(
                      children: [
                        WebViewWidget(controller: controller),
                        ValueListenableBuilder<bool>(
                          valueListenable: isLoading,
                          builder: (context, loading, _) {
                            return loading
                                ? const Center(child: CircularProgressIndicator())
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