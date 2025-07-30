// tukar_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TukarPage extends StatelessWidget {
  const TukarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Penawaran Masuk'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.yellow,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('penawaran')
            .where('idPenerima', isEqualTo: currentUid)
            .where('status', isEqualTo: 'menunggu')
            .orderBy('dibuatPada', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('Belum ada penawaran',
                  style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) =>
                _OfferCard(penawaran: docs[i]),
          );
        },
      ),
    );
  }
}

/// kartu satu penawaran
class _OfferCard extends StatelessWidget {
  final QueryDocumentSnapshot penawaran;
  const _OfferCard({required this.penawaran});

  Future<Map<String, dynamic>> _getBarang(String id) async {
    final doc =
        await FirebaseFirestore.instance.collection('barang').doc(id).get();
    return doc.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    final data = penawaran.data()! as Map<String, dynamic>;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait([
        _getBarang(data['barangPenawar']),
        _getBarang(data['barangTarget'])
      ]),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final barangPenawar = snap.data![0];
        final barangTarget = snap.data![1];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  _BarangMiniCard(
                    foto: barangPenawar['fotoUrl'],
                    nama: barangPenawar['nama'],
                    label: 'Menukar',
                  ),
                  const Icon(Icons.swap_horiz, color: Colors.yellow),
                  _BarangMiniCard(
                    foto: barangTarget['fotoUrl'],
                    nama: barangTarget['nama'],
                    label: 'Dengan',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        await penawaran.reference
                            .update({'status': 'disetujui'});
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Penawaran disetujui')),
                          );
                        }
                      },
                      child: const Text('Setujui'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white12,
                        foregroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        await penawaran.reference
                            .update({'status': 'ditolak'});
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Penawaran ditolak')),
                          );
                        }
                      },
                      child: const Text('Tolak'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// kartu ringkas mini
class _BarangMiniCard extends StatelessWidget {
  final String? foto;
  final String? nama;
  final String label;
  const _BarangMiniCard({this.foto, this.nama, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              foto ?? '',
              height: 60,
              width: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 60,
                width: 60,
                color: Colors.grey,
                child: const Icon(Icons.broken_image, size: 24),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            nama ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}