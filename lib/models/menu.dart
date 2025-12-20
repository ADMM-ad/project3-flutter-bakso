class Menu {
  final int id;
  final String namaMenu;
  final int hargaSatuan;

  Menu({
    required this.id,
    required this.namaMenu,
    required this.hargaSatuan,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      namaMenu: json['nama_menu'],
      hargaSatuan: json['harga_satuan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_menu': namaMenu,
      'harga_satuan': hargaSatuan,
    };
  }
}