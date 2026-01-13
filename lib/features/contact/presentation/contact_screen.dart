
import 'dart:io';

import 'package:daily_good/core/widgets/dismiss_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/platform/toasts.dart';
import '../../orders/data/models/order_list_item.dart';
import '../../orders/domain/providers/order_provider.dart';
import '../data/contact_message_model.dart';
import '../data/contact_subjects.dart';
import '../domain/contact_provider.dart';
import 'photo_preview_screen.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {

  String? selectedSubjectKey;
  Object? selectedOrder;
  bool _isLoading = false;

  final messageController = TextEditingController();
  final List<File> _photos = [];

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderHistoryProvider).maybeWhen(
      data: (summary) => summary.orders,
      orElse: () => <OrderListItem>[],
    );

    return DismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.greenAppBarTheme.backgroundColor,
          foregroundColor: AppTheme.greenAppBarTheme.foregroundColor,
          systemOverlayStyle: AppTheme.greenAppBarTheme.systemOverlayStyle,
          iconTheme: AppTheme.greenAppBarTheme.iconTheme,
          titleTextStyle: AppTheme.greenAppBarTheme.titleTextStyle,
          centerTitle: AppTheme.greenAppBarTheme.centerTitle,
          title: const Text("Bize Ulaşın"),
          actions: [_homeExitButton()],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bizimle iletişime geçin 🌱",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                "Her türlü soru, öneri veya geri bildirimin bizim için değerli.\n"
                    "Aşağıdaki formu doldur — en kısa sürede sana dönüş yapacağız.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              /// KONU
              const Text("Konu Başlığı", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _dropdown<String>(
                hint: "Konu başlığı seçiniz...",
                value: selectedSubjectKey,
                items: contactSubjects.keys.toList(),
                display: (k) => contactSubjects[k]!,
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => selectedSubjectKey = v);
                },
              ),
              const SizedBox(height: 20),

              /// SİPARİŞ
              const Text("Hangi siparişiniz ile ilgili (Opsiyonel)", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _dropdown<Object>(
                hint: "Sipariş seçebilirsiniz...",
                value: selectedOrder,
                items: orders,
                display: (o) {
                  final order = o as OrderListItem;
                  return "${order.storeName} • ${order.totalAmount.toInt()} TL";
                },
                onChanged: (v) {
                  HapticFeedback.selectionClick();
                  setState(() => selectedOrder = v);
                },
              ),
              const SizedBox(height: 20),

              /// FOTOĞRAF
              const Text("Fotoğraf ekleyin", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(3, (index) {
                  final hasPhoto = index < _photos.length;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () async {
                        if (hasPhoto) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PhotoPreviewScreen(
                                photos: _photos,
                                initialIndex: index,
                              ),
                            ),
                          );
                        } else {
                          await _pickPhotoSource(context);
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              image: hasPhoto
                                  ? DecorationImage(
                                image: FileImage(_photos[index]),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: hasPhoto ? null : const Icon(Icons.camera_alt, color: Colors.black54),
                          ),
                          if (hasPhoto) _removePhotoButton(index),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              /// MESAJ
              const Text("Mesaj", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Mesajınızı buraya yazabilirsiniz...",
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// GÖNDER BUTONU
              CustomButton(
                text: _isLoading ? "Gönderiliyor..." : "Gönder",
                onPressed: _isLoading ? null : _submit,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUBMIT & SUCCESS POPUP
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    final messageText = messageController.text.trim();

    if (selectedSubjectKey == null) {
      HapticFeedback.vibrate();
      Toasts.error(context, "Lütfen bir konu başlığı seçin");
      return;
    }

    if (selectedSubjectKey == "other" && messageText.isEmpty) {
      HapticFeedback.vibrate();
      Toasts.error(context, "Konu 'Diğer' olduğunda mesaj yazmanız zorunludur.");
      return;
    }

    setState(() => _isLoading = true);

    final msg = ContactMessage(
      subject: selectedSubjectKey!,
      orderId: selectedOrder != null ? (selectedOrder as OrderListItem).id : null,
      message: messageText.isNotEmpty ? messageText : null,
      attachments: _photos,
    );

    try {
      await ref.read(sendContactMessageProvider(msg).future);
      if (!mounted) return;

      HapticFeedback.mediumImpact();
      _showSuccessPopup();
    } catch (e) {
      HapticFeedback.vibrate();
      Toasts.error(context, "Hata: ${e.toString().replaceAll("Exception: ", "")}");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primaryDarkGreen, size: 80),
            const SizedBox(height: 16),
            const Text("Mesajın Alındı!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              "Geri bildirimin için teşekkürler. En kısa sürede sana dönüş yapacağız.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: "Ana Sayfaya Dön",
                onPressed: () => context.go('/home'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Future<void> _pickPhotoSource(BuildContext context) async {
    if (_photos.length >= 10) return;

    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryDarkGreen),
              title: const Text("Kamera"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryDarkGreen),
              title: const Text("Galeriden Seç"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked == null) return;

    setState(() => _photos.add(File(picked.path)));
  }

  Widget _dropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
    String Function(T)? display,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<T>(
        isExpanded: true,
        value: value,
        underline: const SizedBox(),
        hint: Text(hint),
        items: items
            .map((e) => DropdownMenuItem(
          value: e,
          child: Text(display != null ? display(e) : e.toString()),
        ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _removePhotoButton(int index) {
    return Positioned(
      top: 4,
      right: 4,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _photos.removeAt(index));
        },
        child: const CircleAvatar(
          radius: 10,
          backgroundColor: Colors.black54,
          child: Icon(Icons.close, size: 12, color: Colors.white),
        ),
      ),
    );
  }

  Widget _homeExitButton() {
    return IconButton(
      icon: const Icon(Icons.home_outlined),
      onPressed: () {
        HapticFeedback.selectionClick();
        context.go('/home');
      },
    );
  }
}