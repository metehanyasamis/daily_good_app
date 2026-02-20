
/*
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
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Bize Ulaşın",
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
          ),
          actions: [
            _homeExitButton(),
          ],
          centerTitle: true,
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

*/


import 'dart:io';
import 'package:daily_good/core/widgets/dismiss_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
  OrderListItem? selectedOrder;
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
            "Bize Ulaşın",
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home_outlined, color: AppColors.primaryDarkGreen),
              onPressed: () => context.go('/home'),
            ),
          ],
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bizimle iletişime geçin 🌱",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                "Her türlü soru, öneri veya geri bildirimin bizim için değerli. En kısa sürede sana dönüş yapacağız.",
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 24),

              // --- FORM KARTI ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Konu Başlığı"),
                    _buildPickerField(
                      hint: "Bir konu seçin",
                      value: selectedSubjectKey != null ? contactSubjects[selectedSubjectKey!] : null,
                      onTap: () => _showSubjectPicker(context),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("İlgili Sipariş (Opsiyonel)"),
                    _buildPickerField(
                      hint: "Sipariş seçebilirsiniz",
                      value: selectedOrder != null
                          ? "${selectedOrder!.storeName} (${selectedOrder!.totalAmount.toInt()} TL)"
                          : null,
                      onTap: () => _showOrderPicker(context, orders),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Mesajınız"),
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Mesajınızı buraya yazabilirsiniz...",
                        fillColor: AppColors.surface,
                        filled: true,
                        contentPadding: const EdgeInsets.all(16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Fotoğraf Ekle (Maks. 3)"),
                    const SizedBox(height: 8),
                    _buildPhotoList(),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: _isLoading ? "Gönderiliyor..." : "Mesajı Gönder",
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
    );
  }

  Widget _buildPickerField({required String hint, String? value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  color: value == null ? Colors.grey : AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoList() {
    return Row(
      children: [
        ...List.generate(_photos.length, (index) => _photoPreviewItem(index)),
        if (_photos.length < 3) _addPhotoButton(),
      ],
    );
  }

  Widget _photoPreviewItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PhotoPreviewScreen(photos: _photos, initialIndex: index),
              ),
            ),
            child: Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: FileImage(_photos[index]), fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            top: -5, right: -5,
            child: GestureDetector(
              onTap: () => setState(() => _photos.removeAt(index)),
              child: const CircleAvatar(
                radius: 10,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addPhotoButton() {
    return GestureDetector(
      onTap: () => _pickPhotoSource(context),
      child: Container(
        width: 70, height: 70,
        decoration: BoxDecoration(
          color: AppColors.gray.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryLightGreen.withValues(alpha: 0.3), width: 1.5),
        ),
        child: const Icon(Icons.add_a_photo_rounded, color: AppColors.primaryLightGreen),
      ),
    );
  }

  // --- PICKERS & ACTIONS ---

  void _showSubjectPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nasıl Yardımcı Olabiliriz?", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: contactSubjects.entries.map((e) {
                final isSelected = selectedSubjectKey == e.key;
                return InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      // 🎯 SEÇİLİ OLANA TEKRAR TIKLARSA TEMİZLE
                      selectedSubjectKey = isSelected ? null : e.key;
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLightGreen : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? AppColors.primaryLightGreen : Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(Icons.check, color: Colors.white, size: 16),
                        ),
                        Text(
                          e.value,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showOrderPicker(BuildContext context, List<OrderListItem> orders) {
    // Tarih formatı için yerel ayar
    final DateFormat pickerDateFormatter = DateFormat('dd MMMM yyyy', 'tr_TR');

    if (orders.isEmpty) {
      Toasts.error(context, "Henüz bir siparişiniz bulunmuyor.");
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6, // Biraz daha genişlettik içeriği görmesi için
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) => Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("İlgili Siparişi Seçin", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: orders.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (_, i) {
                    final order = orders[i];
                    final isSelected = selectedOrder?.id == order.id;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          selectedOrder = isSelected ? null : order;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // İç padding'i daralttık (14'ten 8'e)
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryDarkGreen.withValues(alpha: 0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryDarkGreen : Colors.grey.shade200,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Sol taraf: İkon alanı
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryDarkGreen
                                    : AppColors.primaryDarkGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isSelected ? Icons.check_rounded : Icons.storefront_rounded,
                                color: isSelected ? Colors.white : AppColors.primaryDarkGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Orta taraf: Mağaza ve Tarih bilgisi
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.storeName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pickerDateFormatter.format(order.createdAt),
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "No: ${order.orderNumber}",
                                    style: const TextStyle(
                                      color: AppColors.primaryDarkGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Sağ taraf: Tutar bilgisi
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryDarkGreen.withValues(alpha: 0.1)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "${order.totalAmount.toStringAsFixed(0)} ₺",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDarkGreen,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPhotoSource(BuildContext context) async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text("Kamera"), onTap: () => Navigator.pop(context, ImageSource.camera)),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text("Galeri"), onTap: () => Navigator.pop(context, ImageSource.gallery)),
          ],
        ),
      ),
    );
    if (source != null) {
      final picked = await picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) setState(() => _photos.add(File(picked.path)));
    }
  }

  Future<void> _submit() async {
    final messageText = messageController.text.trim();
    if (selectedSubjectKey == null) {
      Toasts.error(context, "Lütfen bir konu başlığı seçin");
      return;
    }
    if (selectedSubjectKey == "other" && messageText.isEmpty) {
      Toasts.error(context, "Lütfen bir mesaj yazın");
      return;
    }

    setState(() => _isLoading = true);
    final msg = ContactMessage(
      subject: selectedSubjectKey!,
      orderId: selectedOrder?.id,
      message: messageText.isNotEmpty ? messageText : null,
      attachments: _photos,
    );

    try {
      await ref.read(sendContactMessageProvider(msg).future);
      if (!mounted) return;
      _showSuccessPopup();
    } catch (e) {
      Toasts.error(context, "Hata oluştu: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.primaryLightGreen, size: 70),
            const SizedBox(height: 16),
            const Text("Mesajın Alındı!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("En kısa sürede sana dönüş yapacağız.", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 24),
            CustomButton(text: "Ana Sayfaya Dön", onPressed: () => context.go('/home')),
          ],
        ),
      ),
    );
  }
}

