import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ContractHtmlContent extends StatelessWidget {
  final String htmlContent;

  const ContractHtmlContent({super.key, required this.htmlContent});

  // Metni hem temizleyen hem de değişkenleri dolduran fonksiyon
    String _prepareHtml(String html) {
      return html
          .replaceAll('{{SELLER_NAME}}', 'Daily Good')
      // Satır sonlarındaki gereksiz boşlukları ve çift BR'leri temizleyelim
          .replaceAll(RegExp(r'(<br\s*/?>\s*){2,}'), '<br/>')
          .replaceAll(RegExp(r'(<p>&nbsp;</p>)'), '')
          .trim();
    }

    @override
    Widget build(BuildContext context) {
      return HtmlWidget(
        _prepareHtml(htmlContent),
        customStylesBuilder: (element) {
          final tag = element.localName;
          if (tag == null) return null;

          // --- BAŞLIKLAR (SÖZLEŞME, SATICI BİLGİLERİ vb.) ---
          if (tag.startsWith('h')) {
            return {
              'margin-top': '10px',
              'margin-bottom': '2px',
              'font-weight': 'bold',
              'text-transform': 'uppercase',
              'display': 'block',
            };
          }

          // --- KRİTİK NOKTA: SATIR ARALARINI SIFIRLAMA ---
          // Ünvan, Adres, Tel, Eposta gibi satırların birbirine yapışması için:
          if (tag == 'p' || tag == 'div' || tag == 'span') {
            return {
              'margin': '0px',         // Dış boşluğu tamamen kaldır
              'padding': '0px',        // İç boşluğu tamamen kaldır
              'line-height': '1.0',    // Satır yüksekliğini en dar seviyeye çek
              'display': 'block',      // Bloğu koru ama boşluğu yok et
            };
          }

          // --- TABLO HÜCRELERİ ---
          if (tag == 'td' || tag == 'th') {
            return {
              'padding': '0px 2px',    // Hücre içi dikey boşluğu sıfırladık
              'line-height': '1.0',
            };
          }

          return null;
        },
      // Genel yazı karakteri ve metin sıkışıklığı
      textStyle: const TextStyle(
        fontSize: 12.5, // Sözleşme için ideal küçük puntolu okuma boyutu
        height: 1.15,   // Genel satır arası mesafeyi daralttık
        color: Colors.black,
      ),
      onTapUrl: (url) {
        debugPrint("Link tıklandı: $url");
        return true;
      },
    );
  }
}