import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tunapp/core/providers/firebase_providers.dart';
import 'package:tunapp/features/inventory/data/repositories/senuelo_repository.dart';
import 'package:tunapp/features/inventory/domain/models/senuelo_model.dart';

/// Provider para el Repositorio de Señuelos.
///
/// Este provider se encarga de instanciar el `SenueloRepository`, inyectándole
/// las dependencias de Firestore y Storage que obtiene de otros providers.
final senueloRepositoryProvider = Provider<SenueloRepository>((ref) {
  return SenueloRepository(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(storageProvider), // Asume que storageProvider existe en firebase_providers.dart
  );
});

/// Provider que expone el Stream de la lista de señuelos desde Firestore.
final senuelosStreamProvider = StreamProvider.autoDispose<List<Senuelo>>((ref) {
  return ref.watch(senueloRepositoryProvider).obtenerSenuelos();
});