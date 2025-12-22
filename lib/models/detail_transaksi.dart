class DetailTransaksi {
  final int? id; // nullable karena saat create baru belum ada id
  final int menuId;
  final String menuNama;
  final int qty;
  final int harga;

  DetailTransaksi({
    this.id,
    required this.menuId,
    required this.menuNama,
    required this.qty,
    required this.harga,
  });

  factory DetailTransaksi.fromJson(Map<String, dynamic> json) {
    return DetailTransaksi(
      id: json['id'],
      menuId: json['menu_id'] ?? json['menu']['id'],
      menuNama: json['menu_nama'] ?? json['menu']?['nama_menu'] ?? '',
      qty: json['qty'] ?? 0,
      harga: json['harga'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'qty': qty,
      'harga': harga,
    };
  }
}