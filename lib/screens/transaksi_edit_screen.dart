import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:apk_bakso/models/menu.dart';
import 'package:apk_bakso/models/paket.dart';
import 'package:apk_bakso/models/transaksi.dart';
import 'package:apk_bakso/services/menu_service.dart';
import 'package:apk_bakso/services/paket_service.dart';
import 'package:apk_bakso/services/transaksi_service.dart';

class TransaksiEditScreen extends StatefulWidget {
  final Transaksi transaksi;

  const TransaksiEditScreen({super.key, required this.transaksi});

  @override
  State<TransaksiEditScreen> createState() => _TransaksiEditScreenState();
}

class _TransaksiEditScreenState extends State<TransaksiEditScreen> {
  late DateTime _tanggal;
  late TextEditingController _namaController;
  late TextEditingController _qtyController;
  late TextEditingController _hargaController;
  late TextEditingController _totalController;

  Paket? _selectedPaket;
  Menu? _selectedMenu;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tanggal = widget.transaksi.tanggal;
    _namaController = TextEditingController(text: widget.transaksi.nama);
    _qtyController = TextEditingController(text: widget.transaksi.qty.toString());
    _hargaController = TextEditingController(text: widget.transaksi.harga.toString());
    _totalController = TextEditingController(text: widget.transaksi.total.toString());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pakets = await PaketService.getAllPaket();
      final menus = await MenuService.getAllMenu();

      final paket = pakets.firstWhere(
            (p) => p.id == widget.transaksi.paketId,
        orElse: () => Paket(id: 0, namaPaket: 'Tidak ditemukan', keterangan: ''),
      );

      final menu = menus.firstWhere(
            (m) => m.id == widget.transaksi.menuId,
        orElse: () => Menu(id: 0, namaMenu: 'Tidak ditemukan', hargaSatuan: 0),
      );

      setState(() {
        _selectedPaket = paket;
        _selectedMenu = menu;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat data menu/paket: $e';
      });
    }
  }

  void _calculateHarga() {
    if (_selectedMenu != null) {
      final qty = int.tryParse(_qtyController.text) ?? 1;
      final harga = _selectedMenu!.hargaSatuan * qty;
      setState(() {
        _hargaController.text = harga.toString();
      });
    }
  }

  Future<void> _updateTransaksi() async {
    if (_selectedPaket == null || _selectedMenu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paket dan Alamat wajib dipilih')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updated = Transaksi(
        id: widget.transaksi.id,
        tanggal: _tanggal,
        nama: _namaController.text.trim(),
        paketId: _selectedPaket!.id,
        menuId: _selectedMenu!.id,
        qty: int.parse(_qtyController.text),
        harga: int.parse(_hargaController.text),
        total: int.parse(_totalController.text),
      );

      await TransaksiService.updateTransaksi(widget.transaksi.id, updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil diupdate'),
            backgroundColor: Color(0xFF90AB8B),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF90AB8B))));
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEBF4DD), Color(0xFFE0EAD2), Color(0xFFD5E0C7)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning, color: Colors.orange, size: 80),
                const SizedBox(height: 20),
                Text(_errorMessage!, style: const TextStyle(fontSize: 16, color: Color(0xFF3B4953)), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadInitialData,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF90AB8B)),
                  child: const Text('Coba Muat Ulang', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
            // Header Hijau
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
              child: const Text(
                'Edit Transaksi',
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  children: [
                    // Tanggal
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: ListTile(
                        title: const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B4953))),
                        subtitle: Text(
                          '${_tanggal.year}-${_tanggal.month.toString().padLeft(2, '0')}-${_tanggal.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 18, color: Color(0xFF3B4953)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today, color: Color(0xFF90AB8B)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _tanggal,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() => _tanggal = picked);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nama Pelanggan
                    TextField(
                      controller: _namaController,
                      style: const TextStyle(color: Color(0xFF3B4953)),
                      decoration: InputDecoration(
                        hintText: 'Nama Pelanggan',
                        hintStyle: const TextStyle(color: Color(0xFF3B4953)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.person, color: Color(0xFF90AB8B)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pilih Paket
                    TypeAheadField<Paket>(
                      builder: (context, controller, focusNode) {
                        controller.text = _selectedPaket?.namaPaket ?? '';
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: const TextStyle(color: Color(0xFF3B4953)),
                          decoration: InputDecoration(
                            hintText: 'Pilih Alamat',
                            hintStyle: const TextStyle(color: Color(0xFF3B4953)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.location_on, color: Color(0xFF90AB8B)),
                          ),
                        );
                      },
                      suggestionsCallback: (pattern) async => await PaketService.getAllPaket(),
                      itemBuilder: (context, paket) => ListTile(
                        title: Text(paket.namaPaket, style: const TextStyle(color: Color(0xFF3B4953))),
                        subtitle: Text(paket.keterangan, style: const TextStyle(color: Color(0xFF3B4953))),
                      ),
                      onSelected: (paket) => setState(() => _selectedPaket = paket),
                    ),
                    const SizedBox(height: 24),

                    // Pilih Menu
                    TypeAheadField<Menu>(
                      builder: (context, controller, focusNode) {
                        controller.text = _selectedMenu?.namaMenu ?? '';
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: const TextStyle(color: Color(0xFF3B4953)),
                          decoration: InputDecoration(
                            hintText: 'Pilih Menu',
                            hintStyle: const TextStyle(color: Color(0xFF3B4953)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.restaurant_menu, color: Color(0xFF90AB8B)),
                          ),
                        );
                      },
                      suggestionsCallback: (pattern) async => await MenuService.getAllMenu(),
                      itemBuilder: (context, menu) => ListTile(
                        title: Text(menu.namaMenu, style: const TextStyle(color: Color(0xFF3B4953))),
                        subtitle: Text('Rp ${menu.hargaSatuan}', style: const TextStyle(color: Color(0xFF90AB8B))),
                      ),
                      onSelected: (menu) {
                        setState(() {
                          _selectedMenu = menu;
                          _calculateHarga();
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Qty
                    TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Color(0xFF3B4953)),
                      decoration: InputDecoration(
                        hintText: 'Qty',
                        hintStyle: const TextStyle(color: Color(0xFF3B4953)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.format_list_numbered, color: Color(0xFF90AB8B)),
                      ),
                      onChanged: (_) => _calculateHarga(),
                    ),
                    const SizedBox(height: 24),

                    // Harga
                    TextField(
                      controller: _hargaController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Color(0xFF3B4953)),
                      decoration: InputDecoration(
                        hintText: 'Harga',
                        hintStyle: const TextStyle(color: Color(0xFF3B4953)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF90AB8B)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Total Item Ini
                    TextField(
                      controller: _totalController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Color(0xFF3B4953), fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: 'Total Item Ini',
                        hintStyle: const TextStyle(color: Color(0xFF3B4953)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.calculate, color: Color(0xFF90AB8B)),
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Button Update
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateTransaksi,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF90AB8B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 10,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'UPDATE ITEM',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
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
    _qtyController.dispose();
    _hargaController.dispose();
    _totalController.dispose();
    super.dispose();
  }
}