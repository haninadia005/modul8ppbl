
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/sensor_cubit.dart';
import '../models/pembacaan_sensor.dart';

class FormSensor extends StatefulWidget {
  final PembacaanSensor? sensor;

  const FormSensor({super.key, this.sensor});

  @override
  State<FormSensor> createState() => _FormSensorState();
}

class _FormSensorState extends State<FormSensor> {
  final _formKey = GlobalKey<FormState>();

  final _nilaiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _latController = TextEditingController();
  final _longController = TextEditingController();

  String _jenisSensor = 'Ketinggian Air';
  bool _menyimpan = false;

  final List<String> _jenisSensorList = [
    'Ketinggian Air',
    'Curah Hujan',
    'Pergerakan Tanah',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.sensor != null) {
      final sensor = widget.sensor!;

      _jenisSensor = sensor.jenisSensor;
      _nilaiController.text = sensor.nilai.toString();
      _lokasiController.text = sensor.lokasi;
      _latController.text = sensor.latitude.toString();
      _longController.text = sensor.longitude.toString();
    }
  }

  @override
  void dispose() {
    _nilaiController.dispose();
    _lokasiController.dispose();
    _latController.dispose();
    _longController.dispose();
    super.dispose();
  }

  String? _validasiAngka(
    String? value, {
    double? minimum,
    double? maksimum,
  }) {
    final angka = double.tryParse(
      (value ?? '').trim().replaceAll(',', '.'),
    );

    if (angka == null || !angka.isFinite) {
      return 'Masukkan angka yang valid';
    }

    if (minimum != null && angka < minimum) {
      return 'Nilai minimal $minimum';
    }

    if (maksimum != null && angka > maksimum) {
      return 'Nilai maksimal $maksimum';
    }

    return null;
  }

  double _ambilAngka(TextEditingController controller) {
    return double.parse(
      controller.text.trim().replaceAll(',', '.'),
    );
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _menyimpan = true);

    final nilai = _ambilAngka(_nilaiController);

    final sensor = PembacaanSensor(
      id: widget.sensor?.id,
      jenisSensor: _jenisSensor,
      nilai: nilai,
      satuan: PembacaanSensor.tentukanSatuan(_jenisSensor),
      status: PembacaanSensor.tentukanStatus(
        _jenisSensor,
        nilai,
      ),
      lokasi: _lokasiController.text.trim(),
      latitude: _ambilAngka(_latController),
      longitude: _ambilAngka(_longController),
      waktu: widget.sensor?.waktu ??
          DateTime.now().toIso8601String(),
    );

    try {
      if (widget.sensor == null) {
        await context.read<SensorCubit>().tambah(sensor);
      } else {
        await context.read<SensorCubit>().ubah(sensor);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _menyimpan = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.sensor != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          edit ? 'Edit Pembacaan' : 'Tambah Pembacaan',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Data Pembacaan Sensor',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _jenisSensor,
              decoration: const InputDecoration(
                labelText: 'Jenis Sensor',
                border: OutlineInputBorder(),
              ),
              items: _jenisSensorList.map((jenis) {
                return DropdownMenuItem(
                  value: jenis,
                  child: Text(jenis),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _jenisSensor = value);
                }
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _nilaiController,
              decoration: InputDecoration(
                labelText: 'Nilai Pembacaan',
                helperText:
                    'Satuan: ${PembacaanSensor.tentukanSatuan(_jenisSensor)}',
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) => _validasiAngka(
                value,
                minimum: 0,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _lokasiController,
              decoration: const InputDecoration(
                labelText: 'Nama Lokasi',
                hintText: 'Contoh: Sungai Citarum',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Lokasi wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _latController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'Contoh: -6.973',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              validator: (value) => _validasiAngka(
                value,
                minimum: -90,
                maksimum: 90,
              ),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _longController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'Contoh: 107.630',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(
                signed: true,
                decimal: true,
              ),
              validator: (value) => _validasiAngka(
                value,
                minimum: -180,
                maksimum: 180,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Status siaga dihitung otomatis saat disimpan.',
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _menyimpan ? null : _simpan,
              icon: const Icon(Icons.save),
              label: Text(
                _menyimpan
                    ? 'Menyimpan...'
                    : 'Simpan Pembacaan',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
