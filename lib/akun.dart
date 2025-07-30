import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapu/myItems.dart';
import 'package:swapu/login_page.dart';

class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Akun Saya',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 🔹 Profil Ringkas
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(
                  'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user?.displayName ?? "User")}&background=random',
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'Nama Pengguna',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    user?.email ?? 'user@email.com',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),

          // 🔸 Edit Profil
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.yellow),
            title: const Text('Edit Profil',
                style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () {
              // TODO: Tambahkan navigasi ke halaman edit profil
            },
          ),

          // 🔸 Pengaturan
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.yellow),
            title: const Text('Pengaturan',
                style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () {
              // TODO: Tambahkan navigasi ke halaman pengaturan
            },
          ),

          // 🔸 Barang saya
          ListTile(
            leading: const Icon(Icons.inventory, color: Colors.yellow),
            title: const Text('Barang saya',
                style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BarangSayaPage()),
              );
            },
          ),

          // 🔸 Riwayat Tukar
          ListTile(
            leading: const Icon(Icons.history, color: Colors.yellow),
            title: const Text('Riwayat tukar',
                style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () {
              // TODO: Ganti ini dengan halaman riwayat tukar jika ada
            },
          ),

          // 🔸 Tentang Kami
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.yellow),
            title: const Text('Tentang kami',
                style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SwapU',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 SwapU Team',
              );
            },
          ),

          const Divider(color: Colors.white24, height: 40),

          // 🔴 Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Keluar',
              style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();

              if (context.mounted) {
              // tampilkan info sebentar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Berhasil logout')),
                );

                // alihkan ke LoginPage & hapus semua route lama
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}