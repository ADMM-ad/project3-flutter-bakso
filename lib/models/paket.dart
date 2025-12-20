class Paket {
  final int id;
  final String namaPaket;
  final String keterangan;

  Paket({
    required this.id,
    required this.namaPaket,
    required this.keterangan,
  });

  factory Paket.fromJson(Map<String, dynamic> json) {
    return Paket(
      id: json['id'],
      namaPaket: json['nama_paket'],
      keterangan: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_paket': namaPaket,
      'keterangan': keterangan,
    };
  }
}