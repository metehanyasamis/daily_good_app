import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/platform/toasts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_app_bar.dart';

/// PayTR ödeme sayfasını WebView'da açar. Backend success/fail URL'lerine
/// gidildiğinde yakalayıp native ekrana yönlendirir.
class PaymentWebViewScreen extends ConsumerStatefulWidget {
  final String checkoutUrl;

  const PaymentWebViewScreen({super.key, required this.checkoutUrl});

  @override
  ConsumerState<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _successNavigated = false;
  bool _failNavigated = false;

  @override
  void initState() {
    super.initState();
    debugPrint("🔔 [PAYMENT_WEBVIEW] initState() checkoutUrl: ${widget.checkoutUrl}");
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
            // Viewport + tam ekran yükseklik: PayTR sayfasının dar alanda scroll etmemesi için
            _controller.runJavaScript('''
              (function() {
                var m = document.querySelector("meta[name=viewport]");
                var v = "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no";
                if (m) m.setAttribute("content", v);
                else {
                  var meta = document.createElement("meta"); meta.name = "viewport"; meta.content = v;
                  document.getElementsByTagName("head")[0].appendChild(meta);
                }
                var style = document.createElement("style");
                style.textContent = "html, body { margin: 0 !important; padding: 0 !important; min-height: 100vh !important; height: 100% !important; } " +
                  "body > div, #content, .container, main { min-height: 100vh !important; height: auto !important; } " +
                  "iframe { min-height: 100vh !important; height: 100% !important; }";
                document.head.appendChild(style);
              })();
            ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint("🔔 [PAYMENT_WEBVIEW] onNavigationRequest: $url");
            if (url.contains('payment/success')) {
              if (_successNavigated) {
                debugPrint("🔔 [PAYMENT_WEBVIEW] Success zaten işlendi, tekrar yönlendirme yapılmıyor.");
                return NavigationDecision.prevent;
              }
              _successNavigated = true;
              debugPrint("🔔 [PAYMENT_WEBVIEW] Success URL yakalandı, native ekrana yönlendiriliyor.");
              if (mounted) {
                context.go('/order-success');
              }
              return NavigationDecision.prevent;
            }
            if (url.contains('payment/fail')) {
              if (_failNavigated) {
                return NavigationDecision.prevent;
              }
              _failNavigated = true;
              debugPrint("🔔 [PAYMENT_WEBVIEW] Fail URL yakalandı.");
              if (mounted) {
                Toasts.error(context, 'Ödeme tamamlanamadı.');
                context.pop();
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Ödeme',
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, top:16, right: 16, bottom: 32),
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: WebViewWidget(controller: _controller),
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
