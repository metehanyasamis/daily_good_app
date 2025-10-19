// 📄 lib/features/account/presentation/screens/account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_state_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStateNotifier = ref.read(appStateProvider.notifier);

    Future<void> _logout() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Oturumu Kapat'),
          content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Vazgeç')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Evet, Çıkış Yap'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        ref.read(appStateProvider.notifier).logout();
        context.go('/login');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesabım'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6ABF7C),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Kullanıcı Bilgisi
            const SizedBox(height: 16),
            const CircleAvatar(
              radius: 42,
              backgroundColor: Color(0xFFE6F4EA),
              child: Icon(Icons.person, size: 48, color: Color(0xFF6ABF7C)),
            ),
            const SizedBox(height: 12),
            const Text('Metehan Yaşamış',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

            const SizedBox(height: 24),

            // 🔹 Profil Kartı
            _buildCard(
              title: 'Profil',
              children: [
                _infoRow(Icons.person_outline, 'Ad Soyad', 'Ad & soyad bilgisi giriniz', true),
                _infoRow(Icons.mail_outline, 'E-posta', 'E-mailinizi doğrulayın', true),
                _infoRow(Icons.phone_outlined, 'Telefon', '+90 530 500 30 30', false),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 Kurtardığın Paketler
            _buildCard(
              title: 'Kurtardığın Paketler & Kazançların',
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _StatItem(title: '25 Paket', subtitle: 'Kurtardın', icon: Icons.shopping_bag_outlined),
                    _StatItem(title: '1.465 TL', subtitle: 'Tasarruf Ettin', icon: Icons.savings_outlined),
                    _StatItem(title: '8 kg CO₂', subtitle: 'Önledin', icon: Icons.eco_outlined),
                  ],
                ),
                const Divider(height: 28),
                ListTile(
                  leading: const Icon(Icons.history_outlined, color: Colors.black54),
                  title: const Text('Geçmiş Siparişlerim'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/orders'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 🔹 Hesap Ayarları
            _buildCard(
              title: 'Hesap Ayarları',
              children: [
                ListTile(
                  leading: const Icon(Icons.description_outlined, color: Colors.black54),
                  title: const Text('Yasal Bilgiler'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined, color: Colors.black54),
                  title: const Text('Bize Ulaşın'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout_outlined, color: Colors.black54),
                  title: const Text('Oturumu Kapat'),
                  onTap: _logout,
                ),
                ListTile(
                  leading: const Icon(Icons.person_off_outlined, color: Colors.red),
                  title: const Text('Hesabımı Kapat', style: TextStyle(color: Colors.red)),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔸 Bilgi Kartı
  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  // 🔸 Profil bilgi satırı
  static Widget _infoRow(IconData icon, String label, String value, bool editable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text('$label : ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: value.contains('giriniz') || value.contains('doğrulayın')
                    ? Colors.red
                    : Colors.black87,
              ),
            ),
          ),
          if (editable) const Icon(Icons.edit_outlined, color: Colors.green, size: 18),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _StatItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.green, size: 28),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        Text(subtitle, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
