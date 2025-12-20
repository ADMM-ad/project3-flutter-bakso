import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apk_bakso/models/menu.dart';
import 'package:apk_bakso/services/auth_service.dart';

class MenuService {
  static Future<List<Menu>> getAllMenu() async {
    final response = await http.get(
      Uri.parse('${AuthService.baseUrl}/menu'),
      headers: await AuthService.getAuthHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => Menu.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil daftar menu');
    }
  }

  static Future<Menu> createMenu(Menu menu) async {
    final response = await http.post(
      Uri.parse('${AuthService.baseUrl}/menu'),
      headers: await AuthService.getAuthHeaders(),
      body: jsonEncode(menu.toJson()),
    );

    if (response.statusCode == 201) {
      return Menu.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Gagal menambahkan menu: ${response.body}');
    }
  }

  static Future<Menu> updateMenu(int id, Menu menu) async {
    final response = await http.put(
      Uri.parse('${AuthService.baseUrl}/menu/$id'),
      headers: await AuthService.getAuthHeaders(),
      body: jsonEncode(menu.toJson()),
    );

    if (response.statusCode == 200) {
      return Menu.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Gagal update menu: ${response.body}');
    }
  }

  static Future<void> deleteMenu(int id) async {
    final response = await http.delete(
      Uri.parse('${AuthService.baseUrl}/menu/$id'),
      headers: await AuthService.getAuthHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus menu');
    }
  }
}