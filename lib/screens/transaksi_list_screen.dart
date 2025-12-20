import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tambahkan package intl untuk format tanggal
import 'package:apk_bakso/models/transaksi.dart';
import 'package:apk_bakso/services/transaksi_service.dart';
import 'package:apk_bakso/screens/transaksi_form_screen.dart';
import 'package:apk_bakso/screens/transaksi_edit_screen.dart';

class TransaksiListScreen extends StatefulWidget {
  const TransaksiListScreen({super.key});

  @override
  State<TransaksiListScreen> createState() => _TransaksiListScreenState();
}

class _TransaksiListScreenState extends State<TransaksiListScreen> {
  late Future<List<Transaksi>> futureTransaksi;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1), // Awal bulan ini
    end: DateTime(
      DateTime.now().year,
      DateTime.now().month + 1,
      0, // tanggal terakhir bulan ini
    ),
  );

  @override
  void initState() {
    super.initState();
    _loadTransaksi();
  }

  void _loadTransaksi() {
    setState(() {
      futureTransaksi = TransaksiService.getAllTransaksi();
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF90AB8B),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      _loadTransaksi(); // Reload data
    }
  }

  // Filter data berdasarkan date range
  List<Transaksi> _filterTransaksi(List<Transaksi> allTransaksi) {
    return allTransaksi.where((t) {
      final tanggal = t.tanggal;
      return tanggal.isAfter(_dateRange.start.subtract(const Duration(days: 1))) &&
          tanggal.isBefore(_dateRange.end.add(const Duration(days: 1)));
    }).toList();
  }

  Future<void> _deleteTransaksi(int id) async {
    try {
      await TransaksiService.deleteTransaksi(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil dihapus'),
          backgroundColor: Color(0xFF90AB8B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadTransaksi();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal hapus: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(Transaksi transaksi) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin hapus transaksi "${transaksi.nama}" pada ${transaksi.tanggal.toLocal().toString().split(' ')[0]}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteTransaksi(transaksi.id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Transaksi'),
        backgroundColor: const Color(0xFF5A7863),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Filter Tanggal',
            onPressed: _pickDateRange,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              'Periode: ${DateFormat('dd/MM/yyyy').format(_dateRange.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange.end)}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
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
        child: SafeArea(
          child: FutureBuilder<List<Transaksi>>(
            future: futureTransaksi,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final allTransaksi = snapshot.data!;
                final filteredTransaksi = _filterTransaksi(allTransaksi);

                if (filteredTransaksi.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada transaksi pada periode ini.',
                      style: TextStyle(fontSize: 18, color: Color(0xFF3B4953)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredTransaksi.length,
                  itemBuilder: (context, index) {
                    final t = filteredTransaksi[index];
                    return Card(
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.nama,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3B4953),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${t.tanggal.toLocal().toString().split(' ')[0]}',
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF3B4953)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Paket: ${t.paketNama ?? '-'}',
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF3B4953)),
                                  ),
                                  Text(
                                    'Menu: ${t.menuNama ?? '-'}',
                                    style: const TextStyle(fontSize: 14, color: Color(0xFF3B4953)),
                                  ),
                                  Text(
                                    'Qty: ${t.qty} | Harga: Rp ${t.harga} | Total: Rp ${t.total}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3B4953),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TransaksiEditScreen(transaksi: t),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadTransaksi();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () => _confirmDelete(t),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 80, color: Colors.red),
                      const SizedBox(height: 20),
                      Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(fontSize: 16, color: Color(0xFF3B4953)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadTransaksi,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF90AB8B)),
                        child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator(color: Color(0xFF90AB8B)));
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF90AB8B),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TransaksiFormScreen()),
          );
          if (result == true) {
            _loadTransaksi();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Tambah Transaksi Baru',
      ),
    );
  }
}