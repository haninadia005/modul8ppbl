
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/sensor_cubit.dart';
import 'form_sensor.dart';

class HalamanDashboard extends StatelessWidget {
  const HalamanDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorCubit, SensorState>(
      builder: (context, state) {
        final daftar = state.daftarSensor;

        final aman = daftar
            .where((sensor) => sensor.status == 'Aman')
            .length;

        final waspada = daftar
            .where((sensor) => sensor.status == 'Waspada')
            .length;

        final siaga = daftar
            .where((sensor) => sensor.status == 'Siaga')
            .length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard Sensor'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Peringatan Dini Bencana',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Monitoring pembacaan sensor BPBD',
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Total Pembacaan Sensor'),
                      const SizedBox(height: 8),
                      Text(
                        '${daftar.length}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _kartuStatus(
                'Aman',
                aman,
                Colors.green,
                Icons.check_circle,
              ),

              _kartuStatus(
                'Waspada',
                waspada,
                Colors.orange,
                Icons.warning_amber,
              ),

              _kartuStatus(
                'Siaga',
                siaga,
                Colors.red,
                Icons.crisis_alert,
              ),

              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: () async {
                  final berhasil =
                      await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FormSensor(),
                    ),
                  );

                  if (berhasil == true && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Pembacaan berhasil disimpan',
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah Pembacaan Sensor'),
              ),

              if (state.loading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),

              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Gagal memuat data: ${state.error}',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _kartuStatus(
    String nama,
    int jumlah,
    Color warna,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: warna),
        title: Text(nama),
        trailing: Text(
          '$jumlah',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: warna,
          ),
        ),
      ),
    );
  }
}
