import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BarangSayaPage extends StatelessWidget {
  const BarangSayaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;


    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Barang Saya'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('barang')
            .where('userId', isEqualTo: myUid)   // ⬅️ hanya milik user ini
            .orderBy('dibuatPada', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('Kamu belum mengunggah barang',
                  style: TextStyle(color: Colors.white70)),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data()! as Map<String, dynamic>;
              return _ProductCard(
                image: d['fotoUrl'] ?? '',
                title: d['nama'] ?? 'Tanpa Nama',
                kondisi: d['kondisi'] ?? '',
              );
            },
          );
        },
      ),
    );
  }
}

/* --- kartu barang sederhana --- */
class _ProductCard extends StatelessWidget {
  final String image, title, kondisi;
  const _ProductCard(
      {required this.image, required this.title, required this.kondisi});

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
                  height: 100, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
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
          ],
        ),
      );
}