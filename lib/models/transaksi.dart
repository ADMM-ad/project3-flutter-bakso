class Transaksi {
  final int id;
  final DateTime tanggal;
  final String nama;
  final int? paketId;
  final String? paketNama;
  final int? menuId;
  final String? menuNama;
  final int qty;
  final int harga;
  final int total;

  Transaksi({
    required this.id,
    required this.tanggal,
    required this.nama,
    this.paketId,
    this.paketNama,
    this.menuId,
    this.menuNama,
    required this.qty,
    required this.harga,
    required this.total,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) {
    // FIX: Tanggal parsing dengan handling timezone
    final dateString = json['tanggal'];
    DateTime tanggal;

    try {
      // Coba parse sebagai DateTime lengkap
      if (dateString is String && dateString.contains('T')) {
        tanggal = DateTime.parse(dateString).toLocal();
      } else {
        // Jika hanya date tanpa time, tambahkan waktu 00:00:00
        tanggal = DateTime.parse('$dateString 00:00:00').toLocal();
      }
    } catch (e) {
      // Fallback ke tanggal sekarang jika parsing gagal
      tanggal = DateTime.now();
    }

    return Transaksi(
      id: json['id'],
      tanggal: tanggal,
      nama: json['nama'],
      paketId: json['paket_id'],
      paketNama: json['paket']?['nama_paket'],
      menuId: json['menu_id'],
      menuNama: json['menu']?['nama_menu'],
      qty: json['qty'],
      harga: json['harga'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    // FIX: Selalu simpan tanggal dalam format YYYY-MM-DD
    final year = tanggal.year;
    final month = tanggal.month.toString().padLeft(2, '0');
    final day = tanggal.day.toString().padLeft(2, '0');

    return {
      'tanggal': '$year-$month-$day', // Format konsisten tanpa timezone
      'nama': nama,
      'paket_id': paketId,
      'menu_id': menuId,
      'qty': qty,
      'harga': harga,
      'total': total,
    };
  }
}