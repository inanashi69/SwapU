import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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

  File? _selectedImage;
  Uint8List? _imageBytes; // ← untuk Flutter Web
  String? _uploadedUrl;
  bool _uploading = false;

  static const _cloudName = 'dg2uqrfb5';
  static const _uploadPreset = 'upload';

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _selectedImage = null;
          _uploadedUrl = null;
        });
      } else {
        setState(() {
          _selectedImage = File(picked.path);
          _imageBytes = null;
          _uploadedUrl = null;
        });
      }
    }
  }

  Future<void> _uploadToCloudinary() async {
    if (_selectedImage == null && _imageBytes == null) return;
    setState(() => _uploading = true);

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final req = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset;

    if (kIsWeb && _imageBytes != null) {
      final multipartFile = http.MultipartFile.fromBytes(
        'file',
        _imageBytes!,
        filename: 'upload.jpg',
      );
      req.files.add(multipartFile);
    } else if (_selectedImage != null) {
      req.files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));
    }

    final res = await req.send();
    if (res.statusCode == 200) {
      final body = await res.stream.bytesToString();
      final jsonResp = jsonDecode(body) as Map<String, dynamic>;
      setState(() => _uploadedUrl = jsonResp['secure_url'] as String);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload (${res.statusCode})')),
        );
      }
    }

    setState(() => _uploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Tambah Barang'),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.yellow),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(top: kToolbarHeight),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
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
                    
                    InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: _imageBytes == null && _selectedImage == null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.camera_alt_outlined,
                                      size: 48, color: Colors.black54),
                                  SizedBox(height: 8),
                                  Text('Tambah Foto',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(height: 4),
                                  Text('Maksimal 1 foto',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                ],
                              )
                            : Column(
                                children: [
                                  if (_imageBytes != null)
                                    Image.memory(_imageBytes!,
                                        height: 160, fit: BoxFit.cover),
                                  if (_selectedImage != null && !kIsWeb)
                                    Image.file(_selectedImage!,
                                        height: 160, fit: BoxFit.cover),
                                  if (_uploading) ...[
                                    const SizedBox(height: 8),
                                    const CircularProgressIndicator(),
                                  ],
                                  if (_uploadedUrl != null) ...[
                                    const SizedBox(height: 8),
                                    const Icon(Icons.check_circle,
                                        color: Colors.green),
                                  ]
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nama Barang',
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                      onChanged: (v) => _namaBarang = v,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                      maxLines: 3,
                      onChanged: (v) => _deskripsi = v,
                    ),
                    const SizedBox(height: 16),
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
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.yellow[700],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () async {
                          if (_imageBytes == null && _selectedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Pilih foto terlebih dahulu')),
                            );
                            return;
                          }
                          if (_uploadedUrl == null && !_uploading) {
                            await _uploadToCloudinary();
                            if (_uploadedUrl == null) return;
                          }

                          if (_formKey.currentState!.validate()) {
                            debugPrint('Nama: $_namaBarang');
                            debugPrint('Deskripsi: $_deskripsi');
                            debugPrint('Kondisi: $_kondisi');
                            debugPrint('Foto URL: $_uploadedUrl');

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Barang berhasil diunggah')),
                            );
                            if (mounted) Navigator.pop(context);
                          }
                        },
                        child: const Text('Unggah',
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
