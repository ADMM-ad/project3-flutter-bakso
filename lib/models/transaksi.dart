import 'package:apk_bakso/models/detail_transaksi.dart';

class Transaksi {
  final int id;
  final DateTime tanggal;
  final String nama;
  final int? paketId;
  final String? paketNama;
  final int total;
  final List<DetailTransaksi> details; // List detail menu

  Transaksi({
    required this.id,
    required this.tanggal,
    required this.nama,
    this.paketId,
    this.paketNama,
    required this.total,
    required this.details,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    // Parsing tanggal dengan aman
    final dateString = json['tanggal'];
    DateTime tanggal;

    try {
      if (dateString is String && dateString.contains('T')) {
        tanggal = DateTime.parse(dateString).toLocal();
      } else {
        tanggal = DateTime.parse('$dateString 00:00:00').toLocal();
      }
    } catch (e) {
      tanggal = DateTime.now();
    }

    // Parsing details
    List<DetailTransaksi> details = [];
    if (json['details'] != null && json['details'] is List) {
      details = (json['details'] as List)
          .map((detailJson) => DetailTransaksi.fromJson(detailJson))
          .toList();
    }

    return Transaksi(
      id: json['id'] ?? 0,
      tanggal: tanggal,
      nama: json['nama'] ?? '',
      paketId: json['paket_id'],
      paketNama: json['paket_nama'],
      total: json['total'] ?? 0,
      details: details,
    );
  }

  Map<String, dynamic> toJson() {
    final year = tanggal.year;
    final month = tanggal.month.toString().padLeft(2, '0');
    final day = tanggal.day.toString().padLeft(2, '0');

    return {
      'tanggal': '$year-$month-$day',
      'nama': nama,
      'paket_id': paketId,
      'total': total,
      'details': details.map((d) => d.toJson()).toList(), // Kirim array details
    };
  }
}