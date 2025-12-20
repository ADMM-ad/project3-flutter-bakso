import 'package:flutter/material.dart';
import 'package:apk_bakso/screens/login_screen.dart';
import 'package:apk_bakso/screens/menu_list_screen.dart';
import 'package:apk_bakso/screens/paket_list_screen.dart';
import 'package:apk_bakso/screens/transaksi_list_screen.dart';
import 'package:apk_bakso/screens/transaksi_form_screen.dart';
import 'package:apk_bakso/screens/rekap_screen.dart';
import 'package:apk_bakso/services/auth_service.dart';
import 'package:apk_bakso/services/transaksi_service.dart';
import 'package:apk_bakso/services/menu_service.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _jumlahTransaksiBulanIni = 0;
  int _jumlahMenu = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);

    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0); // Hari terakhir bulan ini

      // Hitung transaksi bulan ini
      final transaksiList = await TransaksiService.getAllTransaksi();
      final transaksiBulanIni = transaksiList.where((t) {
        return t.tanggal.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
            t.tanggal.isBefore(endOfMonth.add(const Duration(days: 1)));
      }).length;

      // Hitung jumlah menu
      final menuList = await MenuService.getAllMenu();

      setState(() {
        _jumlahTransaksiBulanIni = transaksiBulanIni;
        _jumlahMenu = menuList.length;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      final token = await AuthService().getToken();
      if (token != null) {
        await http.post(
          Uri.parse('${AuthService.baseUrl}/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      // Ignore error server
    } finally {
      await AuthService().removeToken();
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
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
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hallo,',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Selamat datang di Aplikasi Bakso',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2 Card Statistik Sejajar
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.receipt_long,
                        title: 'Transaksi Bulan Ini',
                        value: _isLoadingStats ? '...' : _jumlahTransaksiBulanIni.toString(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.restaurant_menu,
                        title: 'Jumlah Menu',
                        value: _isLoadingStats ? '...' : _jumlahMenu.toString(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Grid 6 Button
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.65,
                  children: [
                    _buildMenuCard(
                      context,
                      icon: Icons.restaurant_menu,
                      title: 'Kelola Menu',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuListScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.location_on,
                      title: 'Kelola Alamat',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaketListScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.add_circle_outline,
                      title: 'Tambah Transaksi',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransaksiFormScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.receipt_long,
                      title: 'Lihat Transaksi',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransaksiListScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.analytics,
                      title: 'Big Data Rekap',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RekapScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
                      onTap: () => _logout(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String title, required String value}) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: const Color(0xFF90AB8B)),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B4953),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF3B4953),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: const Color(0xFF90AB8B),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,

                  color: Color(0xFF3B4953),
                ),
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}