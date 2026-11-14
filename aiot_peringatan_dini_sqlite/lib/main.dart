
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'cubit/sensor_cubit.dart';
import 'pages/halaman_dashboard.dart';
import 'pages/halaman_riwayat.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi SQLite untuk Windows dan Linux
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    sqfliteFfiInit();

    databaseFactory = databaseFactoryFfi;

    final directory =
        await getApplicationSupportDirectory();

    await databaseFactory.setDatabasesPath(
      join(directory.path, 'databases'),
    );
  }

  runApp(const AplikasiPeringatanDini());
}

class AplikasiPeringatanDini extends StatelessWidget {
  const AplikasiPeringatanDini({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SensorCubit()..muatData(),
      child: MaterialApp(
        title: 'Peringatan Dini Bencana',
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
          ),
        ),

        home: const KerangkaUtama(),
      ),
    );
  }
}

class KerangkaUtama extends StatefulWidget {
  const KerangkaUtama({super.key});

  @override
  State<KerangkaUtama> createState() =>
      _KerangkaUtamaState();
}

class _KerangkaUtamaState extends State<KerangkaUtama> {
  int _indeks = 0;

  final List<Widget> _halaman = const [
    HalamanDashboard(),
    HalamanRiwayat(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indeks,
        children: _halaman,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _indeks,
        onDestinationSelected: (index) {
          setState(() {
            _indeks = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Riwayat Sensor',
          ),
        ],
      ),
    );
  }
}
