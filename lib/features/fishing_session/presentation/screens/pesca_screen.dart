import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- IMPORTACIONES ABSOLUTAS CORREGIDAS ---
import 'package:tunapp/features/fishing_session/domain/models/captura_model.dart';
import 'package:tunapp/features/fishing_session/providers/fishing_providers.dart';
import 'package:tunapp/features/boat/providers/canas_provider.dart';
import 'package:tunapp/core/utils/converters.dart';

class PescaScreen extends ConsumerStatefulWidget {
  const PescaScreen({super.key});

  @override
  ConsumerState<PescaScreen> createState() => _PescaScreenState();
}

class _PescaScreenState extends ConsumerState<PescaScreen> {
  bool isPaused = false;

  Future<void> registrarStrike(String canaId) async {
    if (isPaused) return;

    final estadoGlobalCanas = ref.read(canasProvider);
    final datosCana = estadoGlobalCanas.firstWhere((c) => c['id'] == canaId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡STRIKE en $canaId! Obteniendo GPS...'), 
        backgroundColor: Colors.orange,
        duration: const Duration(milliseconds: 800),
      ),
    );

    try {
      final locationService = ref.read(locationServiceProvider);
      final capturaRepo = ref.read(capturaRepositoryProvider);

      // CORRECCIÓN: Usamos el método real getCurrentPosition que devuelve un objeto Position
      final position = await locationService.getCurrentPosition();

      final nuevaCaptura = Captura(
        canaId: canaId,
        senueloId: "S1", // Lo pasaremos del ID real del señuelo más adelante
        senueloNombre: datosCana['senuelo'],
        brazas: (datosCana['brazas'] as num).toDouble(),
        especie: "Pendiente", 
        latitud: position.latitude,
        longitud: position.longitude,
        rumboBarco: position.heading,
        velocidadNudos: Converters.msToKnots(position.speed),
        fechaHora: DateTime.now(),
      );

      await capturaRepo.guardarCaptura(nuevaCaptura);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ ¡Picada guardada en la bitácora!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al obtener GPS: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        title: const Text('EN ACCIÓN DE PESCA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              alignment: Alignment.center, 
              children: [
                const Icon(Icons.sailing, size: 200, color: Colors.white10),
                
                _buildStrikeButton("C1", -140, 100),
                _buildStrikeButton("C2", -100, 160),
                _buildStrikeButton("C3", -60, 220),
                _buildStrikeButton("C4", 0, 250),
                _buildStrikeButton("C5", 60, 220),
                _buildStrikeButton("C6", 100, 160),
                _buildStrikeButton("C7", 140, 100),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            color: Colors.black87,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(Icons.stop, Colors.red, "STOP", () => Navigator.pop(context)),
                _buildControlButton(
                  isPaused ? Icons.play_arrow : Icons.pause, 
                  isPaused ? Colors.green : Colors.orange, 
                  isPaused ? "PLAY" : "PAUSE", 
                  () => setState(() => isPaused = !isPaused)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrikeButton(String id, double x, double y) {
    return Transform.translate(
      offset: Offset(x, y),
      child: GestureDetector(
        onTap: () => registrarStrike(id),
        child: CircleAvatar(
          radius: 28,
          backgroundColor: isPaused ? Colors.grey : Colors.red,
          child: Text(id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, Color color, String label, VoidCallback action) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(icon: Icon(icon, color: color, size: 40), onPressed: action),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
