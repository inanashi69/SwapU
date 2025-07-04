import 'package:flutter/material.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  String _namaBarang = '';
  String _deskripsi = '';
  String _kondisi = 'Baru';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,        // biarkan; kita beri jarak manual
      appBar: AppBar(
        title: const Text('Tambah Barang'),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.yellow),
          onPressed: () => Navigator.pop(context),   // ← kembali
        ),
      ),

      // ────────── BODY ──────────
      body: Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft:  Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // ---------------- Tambah Foto ----------------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.camera_alt_outlined,
                              size: 48, color: Colors.black54),
                          SizedBox(height: 8),
                          Text('Tambah Foto',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Maksimal 5 foto',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ---------------- Nama Barang ----------------
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nama Barang',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      onChanged: (value) => _namaBarang = value,
                      validator: (value) =>
                          (value == null || value.isEmpty)
                              ? 'Nama wajib diisi'
                              : null,
                    ),
                    const SizedBox(height: 16),

                    // ---------------- Deskripsi ----------------
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                      maxLines: 3,
                      onChanged: (value) => _deskripsi = value,
                    ),
                    const SizedBox(height: 16),

                    // ---------------- Kondisi ----------------
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Kondisi',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Baru'),
                            value: 'Baru',
                            groupValue: _kondisi,
                            onChanged: (v) => setState(() => _kondisi = v!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Bekas'),
                            value: 'Bekas',
                            groupValue: _kondisi,
                            onChanged: (v) => setState(() => _kondisi = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // ---------------- Tombol Unggah ----------------
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.yellow[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 2,
                          shadowColor: Colors.black,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            debugPrint('Nama: $_namaBarang');
                            debugPrint('Deskripsi: $_deskripsi');
                            debugPrint('Kondisi: $_kondisi');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Barang berhasil diunggah')),
                            );
                          }
                        },
                        child: const Text(
                          'Unggah',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
