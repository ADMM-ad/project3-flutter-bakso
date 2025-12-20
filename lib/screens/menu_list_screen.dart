import 'package:flutter/material.dart';
import 'package:apk_bakso/models/menu.dart';
import 'package:apk_bakso/services/menu_service.dart';
import 'package:apk_bakso/screens/menu_form_screen.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  late Future<List<Menu>> futureMenu;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  void _loadMenu() {
    setState(() {
      futureMenu = MenuService.getAllMenu();
    });
  }

  Future<void> _deleteMenu(int id) async {
    try {
      await MenuService.deleteMenu(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menu berhasil dihapus'),
          backgroundColor: Color(0xFF90AB8B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadMenu();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
        child: SafeArea(
          child: FutureBuilder<List<Menu>>(
            future: futureMenu,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final menus = snapshot.data!;
                if (menus.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada menu.\nTekan tombol + untuk menambahkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Color(0xFF3B4953)),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12), // Padding luar lebih kecil
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    final menu = menus[index];
                    return Card(
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), // Rounded lebih kecil
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6), // Jarak antar card lebih rapat
                      child: Padding(
                        padding: const EdgeInsets.all(14), // Padding dalam lebih kecil
                        child: Row(
                          children: [
                            // Informasi Menu
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menu.namaMenu,
                                    style: const TextStyle(
                                      fontSize: 16, // Dikecilkan dari 18
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3B4953),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Rp ${menu.hargaSatuan}',
                                    style: const TextStyle(
                                      fontSize: 14, // Dikecilkan dari 16
                                      color: Color(0xFF3B4953),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tombol Edit & Hapus - lebih kecil
                            Row(
                              children: [
                                // Edit
                                GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MenuFormScreen(menu: menu),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadMenu();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Menu berhasil diupdate'),
                                          backgroundColor: Color(0xFF90AB8B),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8), // Lebih kecil
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 20, // Lebih kecil
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Hapus
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Konfirmasi Hapus'),
                                        content: Text('Yakin hapus menu "${menu.namaMenu}"? Jika anda menghapus maka seluruh data transaksi menu ini akan terhapus'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              _deleteMenu(menu.id);
                                            },
                                            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
                        onPressed: _loadMenu,
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
            MaterialPageRoute(builder: (context) => const MenuFormScreen()),
          );
          if (result == true) {
            _loadMenu();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menu berhasil ditambahkan'),
                backgroundColor: Color(0xFF90AB8B),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Tambah Menu',
      ),
    );
  }
}