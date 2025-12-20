import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apk_bakso/models/paket.dart';
import 'package:apk_bakso/services/auth_service.dart';

class PaketService {
  static Future<List<Paket>> getAllPaket() async {
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/paket'),
      headers: await AuthService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => Paket.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil daftar paket');
    }
  }

  static Future<Paket> createPaket(Paket paket) async {
    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/paket'),
      headers: await AuthService.getAuthHeaders(),
      body: jsonEncode(paket.toJson()),
    );

    if (response.statusCode == 201) {
      return Paket.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Gagal menambahkan paket');
    }
  }

  static Future<Paket> updatePaket(int id, Paket paket) async {
    final response = await http.put(
      Uri.parse('${AuthService.baseUrl}/paket/$id'),
      headers: await AuthService.getAuthHeaders(),
      body: jsonEncode(paket.toJson()),
    );

    if (response.statusCode == 200) {
      return Paket.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Gagal update paket');
    }
  }

  static Future<void> deletePaket(int id) async {
    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/paket/$id'),
      headers: await AuthService.getAuthHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus paket');
    }
  }
}