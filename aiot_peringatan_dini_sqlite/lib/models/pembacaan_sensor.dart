class PembacaanSensor {
  final int? id;
  final String jenisSensor;
  final double nilai;
  final String satuan;
  final String status;
  final String lokasi;
  final double latitude;
  final double longitude;
  final String waktu;

  PembacaanSensor({
    this.id,
    required this.jenisSensor,
    required this.nilai,
    required this.satuan,
    required this.status,
    required this.lokasi,
    required this.latitude,
    required this.longitude,
    required this.waktu,
  });

  // Menentukan satuan berdasarkan jenis sensor
  static String tentukanSatuan(String jenis) {
    switch (jenis) {
      case 'Ketinggian Air':
        return 'cm';
      case 'Curah Hujan':
        return 'mm';
      case 'Pergerakan Tanah':
        return 'mm';
      default:
        return '';
    }
  }

  // Menentukan status berdasarkan nilai sensor
  static String tentukanStatus(String jenis, double nilai) {
    if (jenis == 'Ketinggian Air') {
      if (nilai >= 100) return 'Siaga';
      if (nilai >= 50) return 'Waspada';
      return 'Aman';
    }

    if (jenis == 'Curah Hujan') {
      if (nilai >= 50) return 'Siaga';
      if (nilai >= 20) return 'Waspada';
      return 'Aman';
    }

    if (jenis == 'Pergerakan Tanah') {
      if (nilai >= 5) return 'Siaga';
      if (nilai >= 2) return 'Waspada';
      return 'Aman';
    }

    return 'Aman';
  }

  // Mengubah objek menjadi Map untuk SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jenis_sensor': jenisSensor,
      'nilai': nilai,
      'satuan': satuan,
      'status': status,
      'lokasi': lokasi,
      'latitude': latitude,
      'longitude': longitude,
      'waktu': waktu,
    };
  }

  // Mengubah data SQLite menjadi objek
  factory PembacaanSensor.fromMap(Map<String, dynamic> map) {
    return PembacaanSensor(
      id: map['id'] as int?,
      jenisSensor: map['jenis_sensor'] as String,
      nilai: (map['nilai'] as num).toDouble(),
      satuan: map['satuan'] as String,
      status: map['status'] as String,
      lokasi: map['lokasi'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      waktu: map['waktu'] as String,
    );
  }
}
