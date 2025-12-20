import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:apk_bakso/models/menu.dart';
import 'package:apk_bakso/models/paket.dart';
import 'package:apk_bakso/models/transaksi.dart';
import 'package:apk_bakso/services/menu_service.dart';
import 'package:apk_bakso/services/paket_service.dart';
import 'package:apk_bakso/services/transaksi_service.dart';
import 'package:apk_bakso/screens/transaksi_list_screen.dart';

class TransaksiFormScreen extends StatefulWidget {
  const TransaksiFormScreen({super.key});

  @override
  State<TransaksiFormScreen> createState() => _TransaksiFormScreenState();
}

class _TransaksiFormScreenState extends State<TransaksiFormScreen> {
  DateTime _tanggal = DateTime.now();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _totalController = TextEditingController(text: '0');

  Paket? _selectedPaket;
  List<Map<String, dynamic>> _menuItems = [];
  int _total = 0;

  @override
  void dispose() {
    _namaController.dispose();
    _totalController.dispose();
    for (var item in _menuItems) {
      item['hargaController'].dispose();
    }
    super.dispose();
  }

  void _calculateTotal() {
    int newTotal = 0;
    for (var item in _menuItems) {
      final harga = int.tryParse(item['hargaController'].text) ?? 0;
      newTotal += harga;
    }

    setState(() {
      _total = newTotal;
      _totalController.text = newTotal.toString();
    });
  }

  void _addMenuItem() async {
    Menu? selectedMenu;
    final qtyController = TextEditingController(text: '1');
    final hargaController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Tambah Item Menu', style: TextStyle(color: Color(0xFF3B4953), fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TypeAheadField<Menu>(
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Cari Menu',
                            hintStyle: const TextStyle(color: Color(0xFF3B4953)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF90AB8B)),
                          ),
                        );
                      },
                      suggestionsCallback: (pattern) async {
                        final menus = await MenuService.getAllMenu();
                        return menus.where((menu) => menu.namaMenu.toLowerCase().contains(pattern.toLowerCase())).toList();
                      },
                      itemBuilder: (context, menu) {
                        return ListTile(
                          title: Text(menu.namaMenu, style: const TextStyle(color: Color(0xFF3B4953))),
                          subtitle: Text('Rp ${menu.hargaSatuan}', style: const TextStyle(color: Color(0xFF90AB8B))),
                        );
                      },
                      onSelected: (menu) {
                        selectedMenu = menu;
                        final qty = int.tryParse(qtyController.text) ?? 1;
                        final harga = menu.hargaSatuan * qty;
                        hargaController.text = harga.toString();
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Qty',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.format_list_numbered, color: Color(0xFF90AB8B)),
                      ),
                      onChanged: (value) {
                        if (selectedMenu != null) {
                          final qty = int.tryParse(value) ?? 1;
                          final harga = selectedMenu!.hargaSatuan * qty;
                          hargaController.text = harga.toString();
                          setDialogState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: hargaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Harga satuan',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.attach_money, color: Color(0xFF90AB8B)),
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal', style: TextStyle(color: Color(0xFF3B4953))),
                ),
                ElevatedButton(
                  onPressed: selectedMenu == null || hargaController.text.isEmpty ? null : () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF90AB8B)),
                  child: const Text('Tambah', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && selectedMenu != null) {
      setState(() {
        _menuItems.add({
          'menu': selectedMenu,
          'qty': int.parse(qtyController.text),
          'hargaController': hargaController,
        });
        _calculateTotal();
      });
    } else {
      qtyController.dispose();
      hargaController.dispose();
    }
  }

  Future<void> _saveTransaksi() async {
    if (_namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama pelanggan wajib diisi')),
      );
      return;
    }

    if (_menuItems.isNotEmpty && _selectedPaket == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jika ada menu tambahan, harus pilih alamat terlebih dahulu')),
      );
      return;
    }

    if (_selectedPaket != null && _menuItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal tambahkan 1 menu untuk alamat')),
      );
      return;
    }

    if (_selectedPaket == null && _menuItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih alamat dan tambahkan minimal 1 menu')),
      );
      return;
    }

    try {
      for (var item in _menuItems) {
        final transaksi = Transaksi(
          id: 0,
          tanggal: _tanggal,
          nama: _namaController.text.trim(),
          paketId: _selectedPaket!.id,
          menuId: item['menu'].id,
          qty: item['qty'],
          harga: int.parse(item['hargaController'].text),
          total: _total,
        );
        await TransaksiService.createTransaksi(transaksi);
      }

      if (!mounted) return;

      // Tampilkan SnackBar dulu di form ini
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil disimpan!'),
          backgroundColor: Color(0xFF90AB8B),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Delay sedikit agar SnackBar terlihat, lalu pop dengan true
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TransaksiListScreen()),
              (route) => false, // false = hapus SEMUA halaman sebelumnya
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal simpan transaksi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Tambah Transaksi',
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
                        title: const Text('Tanggal Transaksi', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B4953))),
                        subtitle: Text(_tanggal.toLocal().toString().split(' ')[0], style: const TextStyle(color: Color(0xFF3B4953))),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today, color: Color(0xFF90AB8B)),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _tanggal,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) setState(() => _tanggal = picked);
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

                    // Pilih Paket - Nama paket tetap tampil di field
                    TypeAheadField<Paket>(
                      builder: (context, controller, focusNode) {
                        // Selalu set teks dengan nama paket yang dipilih
                        if (_selectedPaket != null) {
                          controller.text = _selectedPaket!.namaPaket;
                        } else {
                          controller.text = '';
                        }
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: const TextStyle(color: Color(0xFF3B4953)),
                          decoration: InputDecoration(
                            hintText: _selectedPaket == null ? 'Pilih Alamat' : 'Alamat sudah dipilih',
                            hintStyle: TextStyle(
                              color: _selectedPaket == null ? const Color(0xFF3B4953) : Colors.grey,
                            ),
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
                      onSelected: (paket) {
                        setState(() {
                          _selectedPaket = paket;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Tombol Tambah Menu
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
                      label: const Text(
                        'Tambah Item Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF90AB8B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.3),
                      ),
                      onPressed: _addMenuItem,
                    ),
                    const SizedBox(height: 24),

                    // Daftar Item Menu
                    if (_menuItems.isNotEmpty) ...[
                      const Text('Daftar Item Menu:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B4953))),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _menuItems.length,
                        itemBuilder: (context, index) {
                          final item = _menuItems[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['menu'].namaMenu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B4953))),
                                  const SizedBox(height: 8),
                                  Text('Qty: ${item['qty']}', style: const TextStyle(color: Color(0xFF3B4953))),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: item['hargaController'],
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Color(0xFF3B4953)),
                                    decoration: InputDecoration(
                                      hintText: 'Harga (edit manual)',
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (value) => _calculateTotal(),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          item['hargaController'].dispose();
                                          _menuItems.removeAt(index);
                                          _calculateTotal();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 40),

                    TextField(
                      controller: _totalController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF3B4953)),
                      decoration: InputDecoration(
                        labelText: 'Total Keseluruhan',
                        prefixText: 'Rp ',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        _total = int.tryParse(value) ?? 0;
                      },
                    ),
                    const SizedBox(height: 50),

                    // Button Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveTransaksi,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF90AB8B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 10,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: const Text(
                          'SIMPAN TRANSAKSI',
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
}