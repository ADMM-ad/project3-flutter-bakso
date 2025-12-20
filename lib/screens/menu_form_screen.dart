import 'package:flutter/material.dart';
import 'package:apk_bakso/models/menu.dart';
import 'package:apk_bakso/services/menu_service.dart';

class MenuFormScreen extends StatefulWidget {
  final Menu? menu; // null = tambah baru, tidak null = edit

  const MenuFormScreen({super.key, this.menu});

  @override
  State<MenuFormScreen> createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends State<MenuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.menu?.namaMenu ?? '');
    _hargaController = TextEditingController(text: widget.menu?.hargaSatuan.toString() ?? '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.menu == null) {
        await MenuService.createMenu(Menu(
          id: 0,
          namaMenu: _namaController.text.trim(),
          hargaSatuan: int.parse(_hargaController.text),
        ));
      } else {
        await MenuService.updateMenu(widget.menu!.id, Menu(
          id: widget.menu!.id,
          namaMenu: _namaController.text.trim(),
          hargaSatuan: int.parse(_hargaController.text),
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
    final bool isEdit = widget.menu != null;

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
            // Header Card Hijau - Mentok Atas, Rounded Bawah
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 40, // Aman dari notch
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
                isEdit ? 'Edit Menu' : 'Tambah Menu',
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Form Bagian Bawah - Background Krem Langsung
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Nama Menu
                      TextFormField(
                        controller: _namaController,
                        style: const TextStyle(color: Color(0xFF3B4953)),
                        decoration: InputDecoration(
                          hintText: 'Nama Menu',
                          hintStyle: const TextStyle(color: Color(0xFF3B4953)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.restaurant_menu, color: Color(0xFF90AB8B)),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        validator: (value) => value!.trim().isEmpty ? 'Nama menu wajib diisi' : null,
                      ),
                      const SizedBox(height: 32),

                      // Harga Satuan
                      TextFormField(
                        controller: _hargaController,
                        style: const TextStyle(color: Color(0xFF3B4953)),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Harga Satuan',
                          hintStyle: const TextStyle(color: Color(0xFF3B4953)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF90AB8B)),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                        validator: (value) {
                          if (value!.trim().isEmpty) return 'Harga wajib diisi';
                          if (int.tryParse(value) == null) return 'Harus berupa angka';
                          if (int.parse(value) <= 0) return 'Harga harus lebih dari 0';
                          return null;
                        },
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
    _hargaController.dispose();
    super.dispose();
  }
}