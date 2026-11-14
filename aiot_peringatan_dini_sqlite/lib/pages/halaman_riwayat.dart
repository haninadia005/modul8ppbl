
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/sensor_cubit.dart';
import '../models/pembacaan_sensor.dart';
import 'form_sensor.dart';

class HalamanRiwayat extends StatelessWidget {
  const HalamanRiwayat({super.key});

  Color _warnaStatus(String status) {
    switch (status) {
      case 'Aman':
        return Colors.green;
      case 'Waspada':
        return Colors.orange;
      case 'Siaga':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatWaktu(String waktu) {
    final tanggal = DateTime.tryParse(waktu);

    if (tanggal == null) return waktu;

    String duaDigit(int angka) =>
        angka.toString().padLeft(2, '0');

    return '${duaDigit(tanggal.day)}/'
        '${duaDigit(tanggal.month)}/'
        '${tanggal.year} '
        '${duaDigit(tanggal.hour)}:'
        '${duaDigit(tanggal.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorCubit, SensorState>(
      builder: (context, state) {
        final daftar = state.daftarSensor;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Riwayat Sensor'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<SensorCubit>().muatData();
                },
              ),
            ],
          ),
          body: state.loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : state.error != null
                  ? Center(
                      child: Text(
                        'Gagal memuat data: ${state.error}',
                      ),
                    )
                  : daftar.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada pembacaan sensor',
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: daftar.length,
                          itemBuilder: (context, index) {
                            final sensor = daftar[index];
                            return _itemSensor(
                              context,
                              sensor,
                            );
                          },
                        ),
        );
      },
    );
  }

  Widget _itemSensor(
    BuildContext context,
    PembacaanSensor sensor,
  ) {
    final warna = _warnaStatus(sensor.status);

    return Dismissible(
      key: ValueKey(sensor.id),
      direction: DismissDirection.endToStart,

      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),

      // Konfirmasi sebelum data dihapus
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Hapus Pembacaan?'),
            content: const Text(
              'Data yang dihapus tidak dapat dikembalikan.',
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ?? false;
      },

      onDismissed: (direction) async {
        try {
          await context
              .read<SensorCubit>()
              .hapus(sensor.id!);
        } catch (e) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
            ),
          );

          await context.read<SensorCubit>().muatData();
        }
      },

      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      sensor.jenisSensor,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),

                  Chip(
                    label: Text(
                      sensor.status,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: warna,
                  ),
                ],
              ),

              Text(
                '${sensor.nilai} ${sensor.satuan}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text('Lokasi: ${sensor.lokasi}'),

              Text(
                'Koordinat: ${sensor.latitude}, '
                '${sensor.longitude}',
              ),

              Text(
                'Waktu: ${_formatWaktu(sensor.waktu)}',
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FormSensor(
                            sensor: sensor,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
