
import 'package:flutter_bloc/flutter_bloc.dart';
import '../db/database_helper.dart';
import '../models/pembacaan_sensor.dart';

class SensorState {
  final List<PembacaanSensor> daftarSensor;
  final bool loading;
  final String? error;

  const SensorState({
    this.daftarSensor = const [],
    this.loading = false,
    this.error,
  });
}

class SensorCubit extends Cubit<SensorState> {
  SensorCubit() : super(const SensorState());

  // Membaca data sensor dari SQLite
  Future<void> muatData() async {
    emit(SensorState(
      daftarSensor: state.daftarSensor,
      loading: true,
    ));

    try {
      final data =
          await DatabaseHelper.instance.ambilSemuaPembacaan();

      emit(SensorState(daftarSensor: data));
    } catch (e) {
      emit(SensorState(
        daftarSensor: state.daftarSensor,
        error: e.toString(),
      ));
    }
  }

  // Menambah data
  Future<void> tambah(PembacaanSensor sensor) async {
    await DatabaseHelper.instance.tambahPembacaan(sensor);
    await muatData();
  }

  // Mengubah data
  Future<void> ubah(PembacaanSensor sensor) async {
    await DatabaseHelper.instance.ubahPembacaan(sensor);
    await muatData();
  }

  // Menghapus data
  Future<void> hapus(int id) async {
    await DatabaseHelper.instance.hapusPembacaan(id);
    await muatData();
  }
}
