import 'package:flutter/material.dart';
import 'package:apk_bakso/models/paket.dart';
import 'package:apk_bakso/services/paket_service.dart';

class PaketFormScreen extends StatefulWidget {
  final Paket? paket;

  const PaketFormScreen({super.key, this.paket});

  @override
  State<PaketFormScreen> createState() => _PaketFormScreenState();
}

class _PaketFormScreenState extends State<PaketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _keteranganController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.paket?.namaPaket ?? '');
    _keteranganController = TextEditingController(text: widget.paket?.keterangan ?? '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.paket == null) {
        await PaketService.createPaket(Paket(
          id: 0,
          namaPaket: _namaController.text.trim(),
          keterangan: _keteranganController.text.trim(),
        ));
      } else {
        await PaketService.updatePaket(widget.paket!.id, Paket(
          id: widget.paket!.id,
          namaPaket: _namaController.text.trim(),
          keterangan: _keteranganController.text.trim(),
        ));
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.paket != null;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEBF4DD),
              Color(0xFFE0EAD2),
              Color(0xFFD5E0C7),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header Hijau - Mentok Atas
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 40,
                bottom: 40,
                left: 32,
                right: 32,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5A7863),
                    Color(0xFF506B58),
                    Color(0xFF465F4D),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Text(
                isEdit ? 'Edit Alamat' : 'Tambah Alamat',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Form Bagian Bawah
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Nama Paket
                      TextFormField(
                        controller: _namaController,
                        style: const TextStyle(color: Color(0xFF3B4953)),
                        decoration: InputDecoration(
                          hintText: 'Alamat',
                          hintStyle: const TextStyle(color: Color(0xFF3B4953)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.location_on, color: Color(0xFF90AB8B)),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        validator: (value) => value!.trim().isEmpty ? 'Nama alamat wajib diisi' : null,
                      ),
                      const SizedBox(height: 32),

                      // Keterangan
                      TextFormField(
                        controller: _keteranganController,
                        style: const TextStyle(color: Color(0xFF3B4953)),
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Keterangan',
                          hintStyle: const TextStyle(color: Color(0xFF3B4953)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.description, color: Color(0xFF90AB8B)),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        validator: (value) => value!.trim().isEmpty ? 'Keterangan wajib diisi' : null,
                      ),
                      const SizedBox(height: 60),

                      // Button Simpan
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF90AB8B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 10,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            isEdit ? 'Update' : 'Simpan',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }
}