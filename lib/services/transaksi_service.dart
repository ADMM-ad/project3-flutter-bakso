import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apk_bakso/models/transaksi.dart';
import 'package:apk_bakso/services/auth_service.dart';

class TransaksiService {
  // Get semua transaksi dengan detail menu
  static Future<List<Transaksi>> getAllTransaksi() async {
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/transaksi'),
      headers: await AuthService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];

      return data.map((json) => Transaksi.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil daftar transaksi: ${response.body}');
    }
  }

  // Create transaksi baru + multiple detail menu
  static Future<void> createTransaksi(Transaksi transaksi) async {
    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/transaksi'),
      headers: await AuthService.getAuthHeaders(),
      body: jsonEncode(transaksi.toJson()),
    );

    if (response.statusCode != 201) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Gagal menyimpan transaksi: ${errorBody['message'] ?? response.body}');
    }
  }

  // Update transaksi + detail (kirim seluruh data baru)
  static Future<void> updateTransaksi(int id, Transaksi transaksi) async {
    final response = await http.put(
      Uri.parse('${AuthService.baseUrl}/transaksi/$id'),
      headers: await AuthService.getAuthHeaders(),
      body: jsonEncode(transaksi.toJson()),
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Gagal update transaksi: ${errorBody['message'] ?? response.body}');
    }
  }

  // Delete tetap sama (detail otomatis terhapus karena cascade)
  static Future<void> deleteTransaksi(int id) async {
    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/transaksi/$id'),
      headers: await AuthService.getAuthHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus transaksi: ${response.body}');
    }
  }
}