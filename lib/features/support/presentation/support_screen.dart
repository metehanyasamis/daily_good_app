// lib/features/support/presentation/support_screen.dart

import 'package:daily_good/features/support/presentation/photo_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../account/domain/providers/user_notifier.dart';
import '../../orders/data/mock_orders.dart';
import '../../orders/data/order_model.dart';
import '../data/support_message_model.dart';
import '../data/support_topics.dart';
import '../domain/support_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  String? selectedTopic;
  OrderItem? selectedOrder;

  final messageController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final List<File> _photos = []; // MAX 3 FOTO

  @override
  void initState() {
    super.initState();

    // Profilden bilgileri çek
    final userState = ref.read(userNotifierProvider);

    if (userState.user != null) {
      final user = userState.user!;

      nameController.text = "${user.name ?? ''} ${user.surname ?? ''}".trim();
      phoneController.text = user.phoneNumber;
      emailController.text = user.email ?? '';
    }
  }


  @override
  Widget build(BuildContext context) {
    final orders = mockOrders;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Bize Ulaşın"),
        actions: [
          _homeExitButton(),
        ],
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
              "Her türlü soru, öneri veya geri bildirimin bizim için değerli.\nAşağıdaki formu doldur — en kısa sürede sana dönüş yapacağız.",
              style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.3),
            ),
            const SizedBox(height: 24),

            // KONULAR
            const Text("Konu Başlığı", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _dropdown(
              hint: "Konu başlığı seçiniz...",
              value: selectedTopic,
              items: supportTopics,
              onChanged: (v) => setState(() => selectedTopic = v),
            ),

            const SizedBox(height: 20),

            // SİPARİŞ
            const Text("Hangi Siparişiniz ile ilgili", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _dropdown<OrderItem>(
              hint: "Sipariş seçiniz...",
              value: selectedOrder,
              items: orders,
              display: (o) => "${o.businessName} • ${o.newPrice.toInt()} TL",
              onChanged: (v) => setState(() => selectedOrder = v),
            ),

            const SizedBox(height: 20),
            const Text("Fotoğraf ekleyin", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            // 🔥 HER ZAMAN 3 FOTO KUTUSU
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
                        ? Stack(
                      children: [
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _photos.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                        : const Icon(Icons.camera_alt, color: Colors.black54),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            const Text("Mesaj", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Mesajınızı buraya yazabilirsiniz...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const SizedBox(height: 24),

            const Text("İletişim Bilgileriniz",
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),

            _input(nameController, "İsim Soyisim"),
            const SizedBox(height: 12),

            _input(phoneController, "Cep telefonu", keyboard: TextInputType.phone),
            const SizedBox(height: 12),

            _input(emailController, "E-mail", keyboard: TextInputType.emailAddress),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: CustomButton(
                text: "Gönder",
                onPressed: () async {
                  // 1️⃣ Konu zorunlu
                  if (selectedTopic == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lütfen konu başlığı seçin")),
                    );
                    return;
                  }

                  // 0️⃣ Sipariş zorunlu
                  if (selectedOrder == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lütfen ilgili siparişi seçin")),
                    );
                    return;
                  }

                  // 2️⃣ İsim Zorunlu
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lütfen isim soyisim girin")),
                    );
                    return;
                  }

                  // 3️⃣ Telefon veya Email’den EN AZ BİRİ zorunlu
                  final phone = phoneController.text.trim();
                  final email = emailController.text.trim();

                  if (phone.isEmpty && email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cep telefonu veya e-mail bilgisinden en az birini giriniz")),
                    );
                    return;
                  }

                  // 4️⃣ Mesaj oluştur
                  final msg = SupportMessage(
                    topic: selectedTopic!,
                    orderId: selectedOrder?.id,
                    message: messageController.text,
                    name: nameController.text.trim(),
                    phone: phone,
                    email: email,
                    photos: _photos,
                  );

                  await ref.read(sendSupportMessageProvider(msg).future);

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.go('/support-success');
                  });
                },
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // DROPDOWN
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
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: DropdownButton<T>(
        isExpanded: true,
        value: value,
        underline: const SizedBox(),
        borderRadius: BorderRadius.circular(12),
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

  Widget _input(TextEditingController c, String label,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // 🔥 FOTO SEÇME (INDEX DESTEKLİ)
  Future<void> _pickPhoto(int index) async {
    if (_photos.length >= 3 && index >= _photos.length) return;

    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Kamera"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galeriden Seç"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (picked == null) return;

    setState(() {
      if (index < _photos.length) {
        _photos[index] = File(picked.path);
      } else {
        _photos.add(File(picked.path));
      }
    });
  }

// 🔥 AppBar için mini home exit buton widget'ı
  Widget _homeExitButton() {
    return IconButton(
      icon: const Icon(Icons.home_outlined, color: Colors.white),
      onPressed: () async {
        final result = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              "Formu göndermeden ayrılmak üzeresiniz!",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            content: const Text(
                "Bu sayfadan çıkarsanız yazdıklarınız kaybolacak."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("İptal",
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "Anasayfa'ya Dön",
                  style: TextStyle(
                    color: AppColors.primaryDarkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );

        if (result == true) {
          context.go('/home');
        }
      },
    );
  }


}
