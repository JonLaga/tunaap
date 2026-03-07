import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// --- IMPORTACIÓN DE MODELOS ---
import 'package:tunapp/features/fishing_session/domain/models/fishing_session_model.dart';
import 'package:tunapp/features/fishing_session/domain/models/rod_model.dart';
import 'package:tunapp/features/fishing_session/data/repositories/fishing_repository.dart';
import 'package:tunapp/features/inventory/data/repositories/senuelo_repository.dart';
import 'package:tunapp/features/inventory/domain/models/senuelo_model.dart';

// Provider simple para obtener la instancia de Firestore.
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final firebaseStorageProvider = Provider((ref) => FirebaseStorage.instance);

// --- INVENTARIO ---
final senueloRepositoryProvider = Provider<SenueloRepository>((ref) {
  return SenueloRepository(
    firestore: ref.read(firestoreProvider),
    storage: ref.read(firebaseStorageProvider),
  );
});

/// Selector que combina el estado: Obtiene la lista de señuelos disponibles en tiempo real.
final inventoryProvider = StreamProvider<List<Senuelo>>((ref) {
  return ref.read(senueloRepositoryProvider).obtenerSenuelos();
});

// --- REPOSITORIOS ---
final fishingRepositoryProvider = Provider<FishingRepository>((ref) {
  return FishingRepository(ref.read(firestoreProvider));
});

// --- LOGIC GUARDS ---
/// Provider reactivo que indica si la configuración actual es válida.
/// Retorna `true` por defecto mientras carga para evitar redirecciones prematuras.
final isFishingConfigValidProvider = Provider<bool>((ref) {
  final sessionAsync = ref.watch(fishingSessionProvider);
  
  return sessionAsync.maybeWhen(
    data: (session) => session == null || (session.rodCount >= 4 && session.rodCount <= 7),
    orElse: () => true, // Asumimos válido mientras carga o si hay error (la UI de error se encargará)
  );
});

/// Este es el Provider principal para la sesión de pesca (FP en tu diagrama).
/// Usamos StreamNotifierProvider para escuchar cambios en tiempo real de forma segura.
final fishingSessionProvider = StreamNotifierProvider<FishingSessionNotifier, FishingSession?>(FishingSessionNotifier.new);

class FishingSessionNotifier extends StreamNotifier<FishingSession?> {
  
  /// Referencia al documento específico que guarda nuestra sesión activa en Firestore.
  DocumentReference get _sessionDoc => ref.read(firestoreProvider).collection('active_session').doc('sesion_actual');

  @override
  Stream<FishingSession?> build() {
    // Escuchamos el stream directamente. Riverpod maneja la suscripción y cancelación.
    return _sessionDoc.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data() as Map<String, dynamic>;
        return FishingSession.fromMap(data);
      } else {
        // Si el documento no existe, lo creamos con el estado inicial.
        // Esto se ejecuta en segundo plano.
        _inicializarSesion();
        return null;
      }
    });
  }

  Future<void> _inicializarSesion() async {
    // Creamos un objeto de sesión inicial con 7 cañas.
    final sesionInicial = FishingSession(
      rodCount: 7,
      canas: [
        Rod(id: "C1", posicion: "Tangón Ext. Babor", brazas: 0, senuelo: "Ninguno"),
        Rod(id: "C2", posicion: "Tangón Int. Babor", brazas: 0, senuelo: "Ninguno"),
        Rod(id: "C3", posicion: "Popa Babor", brazas: 0, senuelo: "Ninguno"),
        Rod(id: "C4", posicion: "Popa Centro", brazas: 0, senuelo: "Ninguno"),
        Rod(id: "C5", posicion: "Popa Estribor", brazas: 0, senuelo: "Ninguno"),
        Rod(id: "C6", posicion: "Tangón Int. Estribor", brazas: 0, senuelo: "Ninguno"),
        Rod(id: "C7", posicion: "Tangón Ext. Estribor", brazas: 0, senuelo: "Ninguno"),
      ],
    );
    await _sessionDoc.set(sesionInicial.toMap());
  }

  /// Esta es la lógica de configuración de la caña (RC en tu diagrama).
  Future<void> actualizarCana(String canaId, String nuevoSenuelo, int nuevasBrazas) async {
    final session = state.value;
    if (session == null) return; // No hacer nada si no hay datos

    final canasActualizadas = session.canas.map((cana) {
      if (cana.id == canaId) {
        return cana.copyWith(senuelo: nuevoSenuelo, brazas: nuevasBrazas);
      }
      return cana;
    }).toList();

    // Actualizamos el documento en Firestore con la lista completa.
    await _sessionDoc.update({'canas': canasActualizadas.map((c) => c.toMap()).toList()});
  }

  /// Asigna un señuelo del inventario a una caña específica.
  Future<void> assignSenueloToRod(String canaId, String senueloId, String senueloNombre) async {
    final session = state.value;
    if (session == null) return;

    final canasActualizadas = session.canas.map((cana) {
      if (cana.id == canaId) {
        // Actualizamos tanto el nombre (para visualización rápida) como el ID (para referencia)
        return cana.copyWith(senuelo: senueloNombre, selectedSenueloId: senueloId);
      }
      return cana;
    }).toList();

    // Persistencia optimizada: Guardamos el objeto completo actualizado
    await _sessionDoc.update({'canas': canasActualizadas.map((c) => c.toMap()).toList()});
  }

  /// Configura un señuelo en una caña específica por índice.
  /// Actualiza la lista de cañas y persiste el mapa de configuración 'rods_configuration'.
  Future<void> setLureToRod(int rodIndex, String lureId) async {
    final session = state.value;
    if (session == null) return;

    // 1. Obtener detalles del señuelo desde el repositorio para tener la imagen y nombre actualizados
    final senuelo = await ref.read(senueloRepositoryProvider).obtenerSenueloPorId(lureId);
    if (senuelo == null) return; // Si no existe el señuelo, no hacemos nada

    // 2. Actualizar la caña específica en la lista
    final List<Rod> currentRods = List.from(session.canas);
    if (rodIndex < 0 || rodIndex >= currentRods.length) return;

    final oldRod = currentRods[rodIndex];
    currentRods[rodIndex] = oldRod.copyWith(
      senuelo: senuelo.nombre,
      selectedSenueloId: lureId,
      senueloImage: senuelo.fotoUrl,
    );

    // 3. Construir el mapa de configuración solicitado (Índice -> ID Señuelo)
    final Map<String, String> rodsConfiguration = {};
    for (int i = 0; i < currentRods.length; i++) {
      if (currentRods[i].selectedSenueloId != null) {
        rodsConfiguration[i.toString()] = currentRods[i].selectedSenueloId!;
      }
    }

    // 4. Persistir en Firestore: actualizamos la lista visual y el mapa de configuración
    await _sessionDoc.update({
      'canas': currentRods.map((c) => c.toMap()).toList(),
      'rods_configuration': rodsConfiguration,
    });
  }

  /// Actualiza el número de cañas en la configuración de la sesión.
  Future<void> updateRodCount(int newCount) async {
    // Validación de lógica de negocio (cumple con el modelo RodConfig implícito)
    if (newCount < 4 || newCount > 7) {
      throw ArgumentError('El número de cañas debe estar entre 4 y 7.');
    }

    // Persiste el cambio en Firestore.
    // El stream del método `build` se encargará de actualizar el estado de la app.
    try {
      await _sessionDoc.update({'rodCount': newCount});
    } catch (e) {
      // Manejar el caso donde el documento no existe todavía.
      // En este flujo, `_inicializarSesion` debería haberlo creado.
    }
  }
}