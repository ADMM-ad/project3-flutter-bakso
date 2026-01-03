import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:apk_bakso/models/menu.dart';
import 'package:apk_bakso/models/paket.dart';
import 'package:apk_bakso/models/transaksi.dart';
import 'package:apk_bakso/models/detail_transaksi.dart';
import 'package:apk_bakso/services/menu_service.dart';
import 'package:apk_bakso/services/paket_service.dart';
import 'package:apk_bakso/services/transaksi_service.dart';
import 'package:intl/intl.dart';

class TransaksiEditScreen extends StatefulWidget {
  final Transaksi transaksi;

  const TransaksiEditScreen({super.key, required this.transaksi});

  @override
  State<TransaksiEditScreen> createState() => _TransaksiEditScreenState();
}

class _TransaksiEditScreenState extends State<TransaksiEditScreen> {
  late DateTime _tanggal;
  late TextEditingController _namaController;
  final TextEditingController _totalController = TextEditingController(text: '0');

  Paket? _selectedPaket;
  List<DetailTransaksi> _details = [];
  int _autoCalculatedTotal = 0;
  bool _isTotalManual = false; // Tandai jika user edit manual total

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tanggal = widget.transaksi.tanggal;
    _namaController = TextEditingController(text: widget.transaksi.nama);
    _details = List.from(widget.transaksi.details);

    // Total awal dari DB
    _autoCalculatedTotal = widget.transaksi.total;
    _totalController.text = _autoCalculatedTotal.toString();

    _selectedPaket = widget.transaksi.paketId != null
        ? Paket(id: widget.transaksi.paketId!, namaPaket: widget.transaksi.paketNama ?? '', keterangan: '')
        : null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialPaket();
    });
  }

  Future<void> _loadInitialPaket() async {
    if (widget.transaksi.paketId != null) {
      try {
        final pakets = await PaketService.getAllPaket();
        final paket = pakets.firstWhere((p) => p.id == widget.transaksi.paketId);
        setState(() => _selectedPaket = paket);
      } catch (e) {
        // ignore
      }
    }
    setState(() => _isLoading = false);
  }

  void _calculateAutoTotal() {
    int newTotal = 0;
    for (var detail in _details) {
      newTotal += detail.harga; // harga = total item (sudah × qty)
    }

    _autoCalculatedTotal = newTotal;

    // Update field total hanya jika belum diedit manual
    if (!_isTotalManual) {
      setState(() {
        _totalController.text = newTotal.toString();
      });
    }
  }

  void _addMenuItem() async {
    Menu? selectedMenu;
    final qtyController = TextEditingController(text: '1');
    final totalItemController = TextEditingController(); // Total item (bisa edit manual)

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
                        if (selectedMenu != null) {
                          controller.text = selectedMenu!.namaMenu;
                        }
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
                        final totalItem = menu.hargaSatuan * qty;
                        totalItemController.text = totalItem.toString();
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
                          final totalItem = selectedMenu!.hargaSatuan * qty;
                          totalItemController.text = totalItem.toString();
                          setDialogState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: totalItemController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Total Item (bisa edit manual)',
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
                  onPressed: selectedMenu == null || totalItemController.text.isEmpty ? null : () => Navigator.pop(ctx, true),
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
      final newDetail = DetailTransaksi(
        menuId: selectedMenu!.id,
        menuNama: selectedMenu!.namaMenu,
        qty: int.parse(qtyController.text),
        harga: int.parse(totalItemController.text), // Total item (bisa manual)
      );

      setState(() {
        _details.add(newDetail);
        _calculateAutoTotal();
      });
    } else {
      qtyController.dispose();
      totalItemController.dispose();
    }
  }

  Future<void> _updateTransaksi() async {
    if (_namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama pelanggan wajib diisi'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal ada 1 menu'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final finalTotal = int.tryParse(_totalController.text) ?? _autoCalculatedTotal;

      final updatedTransaksi = Transaksi(
        id: widget.transaksi.id,
        tanggal: _tanggal,
        nama: _namaController.text.trim(),
        paketId: _selectedPaket?.id,
        paketNama: _selectedPaket?.namaPaket,
        total: finalTotal,
        details: _details,
      );

      await TransaksiService.updateTransaksi(widget.transaksi.id, updatedTransaksi);

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

  String _formatRupiah(int amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount).replaceAll(',00', '');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF90AB8B))));
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  children: [
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
                    TextField(
                      controller: _namaController,
                      style: const TextStyle(color: Color(0xFF3B4953)),
                      decoration: InputDecoration(
                        hintText: 'Nama Pelanggan',
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
                    TypeAheadField<Paket>(
                      builder: (context, controller, focusNode) {
                        controller.text = _selectedPaket?.namaPaket ?? '';
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: const TextStyle(color: Color(0xFF3B4953)),
                          decoration: InputDecoration(
                            hintText: 'Pilih Alamat (opsional)',
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
                      suggestionsCallback: (pattern) async {
                        final pakets = await PaketService.getAllPaket();
                        if (pattern.isEmpty) return pakets;
                        return pakets.where((p) => p.namaPaket.toLowerCase().contains(pattern.toLowerCase())).toList();
                      },
                      itemBuilder: (context, paket) => ListTile(
                        title: Text(paket.namaPaket, style: const TextStyle(color: Color(0xFF3B4953))),
                        subtitle: Text(paket.keterangan, style: const TextStyle(color: Color(0xFF3B4953))),
                      ),
                      onSelected: (paket) => setState(() => _selectedPaket = paket),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
                      label: const Text(
                        'Tambah Item Menu',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
                    if (_details.isNotEmpty) ...[
                      const Text('Daftar Item Menu:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3B4953))),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _details.length,
                        itemBuilder: (context, index) {
                          final detail = _details[index];
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(detail.menuNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3B4953))),
                                  const SizedBox(height: 8),
                                  Text('Banyaknya: ${detail.qty}', style: const TextStyle(color: Color(0xFF3B4953))),
                                  const SizedBox(height: 8),
                                  Text('Total Item: ${_formatRupiah(detail.harga)}', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3B4953))),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _details.removeAt(index);
                                          _calculateAutoTotal();
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
                        setState(() {
                          _isTotalManual = true;
                        });
                      },
                    ),
                    const SizedBox(height: 60),
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
                          'UPDATE TRANSAKSI',
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
    _totalController.dispose();
    super.dispose();
  }
}