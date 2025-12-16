import 'dart:io';

import 'package:daily_good/core/widgets/dismiss_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
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
  static const String otherOrderKey = "__OTHER__";

  /// 🔑 backend key tutulur
  String? selectedSubjectKey;

  /// OrderListItem veya "__OTHER__"
  Object? selectedOrder;

  final messageController = TextEditingController();
  final List<File> _photos = [];

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderHistoryProvider).maybeWhen(
      data: (summary) => summary.orders,
      orElse: () => <OrderListItem>[],
    );

    final orderItems = [
      ...orders,
      otherOrderKey,
    ];

    return DismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryDarkGreen,
          foregroundColor: Colors.white,
          centerTitle: true,
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
              const Text("Konu Başlığı",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _dropdown<String>(
                hint: "Konu başlığı seçiniz...",
                value: selectedSubjectKey,
                items: contactSubjects.keys.toList(),
                display: (k) => contactSubjects[k]!,
                onChanged: (v) => setState(() => selectedSubjectKey = v),
              ),

              const SizedBox(height: 20),

              /// SİPARİŞ
              const Text("Hangi siparişiniz ile ilgili",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              _dropdown<Object>(
                hint: "Sipariş seçiniz...",
                value: selectedOrder,
                items: orderItems,
                display: (o) {
                  if (o == otherOrderKey) return "Diğer";
                  final order = o as OrderListItem;
                  return "${order.storeName} • ${order.totalAmount.toInt()} TL";
                },
                onChanged: (v) => setState(() => selectedOrder = v),
              ),

              const SizedBox(height: 20),

              /// FOTOĞRAF
              const Text("Fotoğraf ekleyin",
                  style: TextStyle(fontWeight: FontWeight.w600)),
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
                            child: hasPhoto
                                ? null
                                : const Icon(Icons.camera_alt,
                                color: Colors.black54),
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
              const Text("Mesaj",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Mesajınızı buraya yazabilirsiniz...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// ✅ CUSTOM BUTTON
              CustomButton(
                text: "Gönder",
                onPressed: _submit,
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUBMIT
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    if (selectedSubjectKey == null) {
      _toast("Lütfen konu başlığı seçin");
      return;
    }

    if (selectedOrder == null) {
      _toast("Lütfen bir seçim yapın");
      return;
    }

    final isOtherOrder = selectedOrder == otherOrderKey;
    final isOtherSubject = selectedSubjectKey == "other";

    if ((isOtherOrder || isOtherSubject) &&
        messageController.text.trim().isEmpty) {
      _toast("Diğer seçeneğinde mesaj zorunludur");
      return;
    }

    final msg = ContactMessage(
      subjects: [selectedSubjectKey!],
      orderId:
      isOtherOrder ? null : (selectedOrder as OrderListItem).id,
      message: messageController.text.trim(),
      attachments: _photos,
    );

    await ref.read(sendContactMessageProvider(msg).future);

    if (!mounted) return;
    context.go('/contact-success');
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Future<void> _pickPhotoSource(BuildContext context) async {
    if (_photos.length >= 10) return;

    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _PickerTile(ImageSource.camera, Icons.camera_alt, "Kamera"),
            _PickerTile(ImageSource.gallery, Icons.photo_library, "Galeriden Seç"),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked =
    await picker.pickImage(source: source, imageQuality: 70);
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
        onTap: () => setState(() => _photos.removeAt(index)),
        child: const CircleAvatar(
          radius: 10,
          backgroundColor: Colors.black54,
          child: Icon(Icons.close, size: 12, color: Colors.white),
        ),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _homeExitButton() {
    return IconButton(
      icon: const Icon(Icons.home_outlined),
      onPressed: () => context.go('/home'),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final ImageSource source;
  final IconData icon;
  final String title;

  const _PickerTile(this.source, this.icon, this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Navigator.pop(context, source),
    );
  }
}
