import 'package:flutter/material.dart';
import 'package:apk_bakso/models/paket.dart';
import 'package:apk_bakso/services/paket_service.dart';
import 'package:apk_bakso/screens/paket_form_screen.dart';

class PaketListScreen extends StatefulWidget {
  const PaketListScreen({super.key});

  @override
  State<PaketListScreen> createState() => _PaketListScreenState();
}

class _PaketListScreenState extends State<PaketListScreen> {
  late Future<List<Paket>> futurePaket;

  @override
  void initState() {
    super.initState();
    _loadPaket();
  }

  void _loadPaket() {
    setState(() {
      futurePaket = PaketService.getAllPaket();
    });
  }

  Future<void> _deletePaket(int id) async {
    try {
      await PaketService.deletePaket(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alamat berhasil dihapus'),
          backgroundColor: Color(0xFF90AB8B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadPaket();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(Paket paket) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Yakin ingin menghapus alamat "${paket.namaPaket}"?, Jika anda menghapus alamat maka seluruh data transaksi alamat ini akan terhapus'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deletePaket(paket.id);
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
        title: const Text('Data Alamat'), // <--- Header baru
        backgroundColor: const Color(0xFF5A7863),
        foregroundColor: Colors.white,
        // Tombol kembali otomatis muncul karena halaman ini dipush dari halaman lain
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
          child: FutureBuilder<List<Paket>>(
            future: futurePaket,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final pakets = snapshot.data!;
                if (pakets.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada alamat.\nTekan tombol + untuk menambahkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Color(0xFF3B4953)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: pakets.length,
                  itemBuilder: (context, index) {
                    final paket = pakets[index];
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
                          children: [
                            // Informasi Paket
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    paket.namaPaket,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3B4953),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    paket.keterangan,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF3B4953),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),

                            // Tombol Edit & Hapus
                            Row(
                              children: [
                                // Edit
                                GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PaketFormScreen(paket: paket),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadPaket();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Alamat berhasil diupdate'),
                                          backgroundColor: Color(0xFF90AB8B),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Hapus
                                GestureDetector(
                                  onTap: () => _confirmDelete(paket),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
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
                        onPressed: _loadPaket,
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
            MaterialPageRoute(builder: (_) => const PaketFormScreen()),
          );
          if (result == true) {
            _loadPaket();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Alamat berhasil ditambahkan'),
                backgroundColor: Color(0xFF90AB8B),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Tambah Alamat Baru',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}