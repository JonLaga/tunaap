import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunapp/features/fishing_session/providers/fishing_session_provider.dart';
import 'package:tunapp/features/fishing_session/domain/models/rod_model.dart';
import 'package:tunapp/features/inventory/domain/models/senuelo_model.dart';
import 'package:tunapp/features/inventory/presentation/screens/mi_caja_screen.dart';
import 'package:tunapp/features/boat/presentation/screens/mi_barco_screen.dart';

/// Esta es la pantalla `pesca_screen.dart` (PS) de tu diagrama.
/// Es un `ConsumerWidget` para poder leer datos de los providers.
class PescaScreen extends ConsumerStatefulWidget {
  const PescaScreen({super.key});

  @override
  ConsumerState<PescaScreen> createState() => _PescaScreenState();
}

class _PescaScreenState extends ConsumerState<PescaScreen> {
  @override
  void initState() {
    super.initState();
    // Precarga de imágenes para evitar parpadeos al cambiar de configuración (4-7 cañas)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 4; i <= 7; i++) {
        precacheImage(AssetImage('assets/images/fishing/rod_$i.png'), context);
      }
    });
  }

  // Helper para obtener el asset dinámico basado en la configuración
  String _getRodAsset(int count) {
    return 'assets/images/fishing/rod_$count.png';
  }

  @override
  Widget build(BuildContext context) {
    // --- NAVIGATION GUARD ---
    // Escuchamos cambios en la validez de la configuración.
    // Si en algún momento se vuelve inválida (ej: se borra la sesión remotamente), sacamos al usuario.
    ref.listen(isFishingConfigValidProvider, (previous, isValid) {
      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Debes configurar entre 4 y 7 cañas para empezar a pescar"),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MiBarcoScreen()),
        );
      }
    });

    // 1. "Observamos" el provider. La UI se reconstruirá automáticamente
    //    cuando el estado de `fishingSessionProvider` cambie.
    final sessionAsyncValue = ref.watch(fishingSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesión de Pesca Activa'),
      ),
      // 2. `when` es la forma segura de manejar los 3 estados de un AsyncValue.
      body: sessionAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error al cargar la sesión: $err')),
        data: (session) {
          // Si la sesión aún no se ha creado en Firestore
          if (session == null) {
            return const Center(child: Text('Iniciando sesión en Firestore...'));
          }

          // Aseguramos que el contador esté entre 4 y 7 y obtenemos el asset
          final int safeRodCount = session.rodCount.clamp(4, 7);
          final String assetPath = _getRodAsset(safeRodCount);

          // La UI se divide en el visualizador y la lista de cañas.
          return Column(
            children: [
              // --- Visualizador de Configuración de Cañas ---
              _RodVisualizer(assetPath: assetPath, rodCount: safeRodCount),

              // --- Lista de Cañas ---
              Expanded(
                child: ListView.builder(
                  itemCount: session.canas.length,
                  itemBuilder: (context, index) {
                    final cana = session.canas[index];
                    return _RodDisplayCard(cana: cana, index: index);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Widget que representa una sola caña en la lista (RD en tu diagrama).
class _RodDisplayCard extends StatelessWidget {
  const _RodDisplayCard({
    super.key,
    required this.cana,
    required this.index,
  });

  final Rod cana;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        // Mostramos la imagen del señuelo si existe, o un icono por defecto
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          backgroundImage: (cana.senueloImage != null && cana.senueloImage!.isNotEmpty) ? NetworkImage(cana.senueloImage!) : null,
          child: (cana.senueloImage == null || cana.senueloImage!.isEmpty)
              ? const Icon(Icons.phishing, color: Colors.grey)
              : null,
        ),
        title: Text(cana.posicion),
        subtitle: Text(
          '${cana.senuelo}\n${cana.brazas} brazas', 
          style: TextStyle(color: Colors.grey.shade700),
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.edit),
        onTap: () {
          // Abrimos el modal de selección de señuelos
          _showSenueloSelectionModal(context, cana, index);
        },
      ),
    );
  }
}

/// Muestra un modal con la lista de señuelos del inventario ("Mi Caja").
void _showSenueloSelectionModal(BuildContext context, Rod cana, int rodIndex) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      // Usamos Consumer para escuchar el inventoryProvider dentro del modal
      return Consumer(
        builder: (context, ref, child) {
          final senuelosAsync = ref.watch(inventoryProvider);

          return Container(
            padding: const EdgeInsets.all(16),
            height: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Selecciona señuelo para: ${cana.posicion}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: senuelosAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                    data: (senuelos) {
                      if (senuelos.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.backpack_outlined, size: 50, color: Colors.grey),
                              const SizedBox(height: 10),
                              const Text("Tu caja de señuelos está vacía"),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // Cerrar modal
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const MiCajaScreen()),
                                  );
                                },
                                child: const Text("Ir a Mi Caja"),
                              )
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: senuelos.length,
                        itemBuilder: (context, index) {
                          final Senuelo senuelo = senuelos[index];
                          final bool isSelected = cana.selectedSenueloId == senuelo.id;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: (senuelo.fotoUrl != null && senuelo.fotoUrl!.isNotEmpty)
                                  ? NetworkImage(senuelo.fotoUrl!)
                                  : null,
                              child: (senuelo.fotoUrl == null || senuelo.fotoUrl!.isEmpty)
                                  ? const Icon(Icons.image_not_supported)
                                  : null,
                            ),
                            title: Text(senuelo.nombre),
                            subtitle: Text(senuelo.tipo),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                            onTap: () {
                              // Asignar señuelo y cerrar modal
                              if (senuelo.id != null) {
                                ref.read(fishingSessionProvider.notifier).setLureToRod(rodIndex, senuelo.id!);
                              }
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// Widget privado que muestra la imagen de la configuración de cañas.
class _RodVisualizer extends StatelessWidget {
  final String assetPath;
  final int rodCount;
  
  const _RodVisualizer({
    required this.assetPath, 
    required this.rodCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Image.asset(
        assetPath,
        key: ValueKey(rodCount), // Permite a Flutter identificar el cambio para animaciones
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('ERROR DE CARGA: No se encontró el asset en $assetPath');
          return const Icon(Icons.broken_image, size: 100, color: Colors.red);
        },
      ),
    );
  }
}