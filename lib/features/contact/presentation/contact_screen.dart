// lib/features/contact/presentation/contact_screen.dart

import 'dart:io';

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
  String? selectedSubject;
  OrderListItem? selectedOrder;

  final messageController = TextEditingController();
  final List<File> _photos = [];

  @override
  Widget build(BuildContext context) {
    final orderHistory = ref.watch(orderHistoryProvider);

    final orders = ref.watch(orderHistoryProvider).maybeWhen(
      data: (summary) => summary.orders,
      orElse: () => <OrderListItem>[],
    );



    return Scaffold(
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
              style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.3),
            ),

            const SizedBox(height: 24),

            /// ⭐ KONU
            const Text("Konu Başlığı", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _dropdown<String>(
              hint: "Konu başlığı seçiniz...",
              value: selectedSubject,
              items: contactSubjects,
              onChanged: (v) => setState(() => selectedSubject = v),
            ),

            const SizedBox(height: 20),

            /// ⭐ SİPARİŞ
            const Text("Hangi siparişiniz ile ilgili",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _dropdown<OrderListItem>(
              hint: "Sipariş seçiniz...",
              value: selectedOrder,
              items: orders,
              display: (o) => "${o.storeName} • ${o.totalAmount.toInt()} TL",
              onChanged: (v) => setState(() => selectedOrder = v),
            ),

            const SizedBox(height: 20),

            /// ⭐ FOTOĞRAF
            const Text("Fotoğraf ekleyin",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            Row(
              children: List.generate(3, (index) {
                final hasPhoto = index < _photos.length;

                return GestureDetector(
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
                      await _pickPhoto(index);
                    }
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    margin: const EdgeInsets.only(right: 12),
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
                        ? _removePhotoButton(index)
                        : const Icon(Icons.camera_alt, color: Colors.black54),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            /// ⭐ MESAJ
            const Text("Mesaj", style: TextStyle(fontWeight: FontWeight.w600)),
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

            CustomButton(
              text: "Gönder",
              onPressed: _submit,
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  Future<void> _submit() async {
    if (selectedSubject == null) {
      _toast("Lütfen konu başlığı seçin");
      return;
    }

    if (selectedOrder == null) {
      _toast("Lütfen ilgili siparişi seçin");
      return;
    }

    if (selectedSubject == "Diğer" &&
        messageController.text.trim().isEmpty) {
      _toast("Lütfen mesajınızı yazın");
      return;
    }

    final msg = ContactMessage(
      subjects: [selectedSubject!],
      orderId: selectedOrder!.id,
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

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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
        items: items.map((e) {
          return DropdownMenuItem(
            value: e,
            child: Text(display != null ? display(e) : e.toString()),
          );
        }).toList(),
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
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.black54,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, size: 14, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _pickPhoto(int index) async {
    if (_photos.length >= 10) return;

    final picker = ImagePicker();
    final picked =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;

    setState(() => _photos.add(File(picked.path)));
  }

  Widget _homeExitButton() {
    return IconButton(
      icon: const Icon(Icons.home_outlined, color: Colors.white),
      onPressed: () => context.go('/home'),
    );
  }
}
