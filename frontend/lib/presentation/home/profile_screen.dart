import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepOrange,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              AuthService.instance.userName ?? 'Kullanıcı',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              AuthService.instance.userEmail ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 32),
            _buildSettingsItem(
              icon: Icons.add_circle_outline,
              title: 'Yeni Tarif Ekle',
              onTap: () {
                context.push('/add-recipe');
              },
            ),
            _buildSettingsItem(
              icon: Icons.dark_mode_outlined,
              title: 'Karanlık Mod',
              trailing: Switch(
                value: true,
                onChanged: (val) {},
                activeColor: Colors.deepOrange,
              ),
            ),
            _buildSettingsItem(
              icon: Icons.notifications_none,
              title: 'Bildirimler',
              trailing: Switch(
                value: true,
                onChanged: (val) {},
                activeColor: Colors.deepOrange,
              ),
            ),
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: 'Hakkında',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E2C),
                    title: const Text('TarifApp Pro', style: TextStyle(color: Colors.white)),
                    content: const Text('Sürüm 1.0.0\n\nBEU Mobil Programlama dersi için geliştirilmiştir.', style: TextStyle(color: Colors.white70)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Kapat', style: TextStyle(color: Colors.deepOrange)),
                      )
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              icon: Icons.logout,
              title: 'Çıkış Yap',
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () {
                AuthService.instance.logout();
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Colors.white70),
        title: Text(title, style: TextStyle(color: textColor ?? Colors.white, fontSize: 16)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: trailing == null ? onTap : null,
      ),
    );
  }
}
