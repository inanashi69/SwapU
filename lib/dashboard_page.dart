import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add.dart';
import 'swap.dart';
import 'akun.dart';

/* ───────────────────────── DASHBOARD ───────────────────────── */

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      _HomeTab(),      // Beranda
      TukarPage(),     // Tukar
      AkunPage(),      // Akun
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.displayName ?? 'User';

    return Scaffold(
      backgroundColor: Colors.black,

      /* ─── APP BAR ─── */
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Hai, $username!',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications, color: Colors.yellow),
          ),
        ],
      ),

      /* ─── BODY ─── */
      body: IndexedStack(index: _selectedIndex, children: _pages),

      /* ─── FAB ─── */
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        foregroundColor: Colors.black,
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPage()),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /* ─── BOTTOM NAV ─── */
      bottomNavigationBar: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.yellow, width: 2)),
          ),
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home,     'Beranda', 0),
                _navItem(Icons.sync_alt, 'Tukar',   1),
                const SizedBox(width: 48), // ruang FAB
                _navItem(Icons.message,  'Pesan',   2),
                _navItem(Icons.person,   'Akun',    3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ─── ITEM NAV ─── */
  Widget _navItem(IconData icon, String label, int index) {
    final selected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? Colors.yellow : Colors.white70),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.yellow : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ───────────────────────── TAB BERANDA ───────────────────────── */

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /* 🔍 Search */
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: Colors.yellow),
                hintText: 'Cari barang yang kamu butuhkan...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          /* 🧷 Kategori */
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _Category(icon: Icons.menu_book, label: 'Buku'),
                _Category(icon: Icons.checkroom, label: 'Pakaian'),
                _Category(icon: Icons.videogame_asset, label: 'Elektronik'),
                _Category(icon: Icons.watch, label: 'Aksesoris'),
                _Category(icon: Icons.chair, label: 'Furnitur'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Barter Yuk!',
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          /* 📦 Grid Firestore (barang orang lain) */
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('barang')
                .orderBy('userId')                      // syarat filter !=
                .orderBy('dibuatPada', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text('Belum ada barang',
                        style: TextStyle(color: Colors.white)),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final d = docs[i].data()! as Map<String, dynamic>;
                  if (d['userId'] == myUid) return const SizedBox();
                  return _ProductCard(
                    image: d['fotoUrl'] ?? '',
                    title: d['nama'] ?? 'Tanpa Nama',
                    desc: d['deskripsi'] ?? '',
                    kondisi: d['kondisi'] ?? 'N/A',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── KOMPONEN KECIL ───────────────────────── */

class _Category extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Category({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        width: 70,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.yellow,
              child: Icon(icon, color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      );
}

class _ProductCard extends StatelessWidget {
  final String image, title, desc, kondisi;
  const _ProductCard(
      {required this.image,
      required this.title,
      required this.desc,
      required this.kondisi});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(image,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(kondisi,
                    style:
                        const TextStyle(color: Colors.black, fontSize: 10)),
              ),
            ),
            const Spacer(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  minimumSize: const Size(double.infinity, 36),
                ),
                child: const Text('Ajak barter'),
              ),
            )
          ],
        ),
      );
}
