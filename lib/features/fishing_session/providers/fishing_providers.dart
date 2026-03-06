import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- IMPORTACIONES ABSOLUTAS CORREGIDAS ---
import 'package:tunapp/core/services/location_service.dart';
import 'package:tunapp/features/fishing_session/data/repositories/captura_repository.dart';
import 'package:tunapp/core/providers/firebase_providers.dart'; // Importación corregida

// Proveedor del servicio GPS
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Proveedor del repositorio de capturas en Firebase
final capturaRepositoryProvider = Provider<CapturaRepository>((ref) {
  return CapturaRepository(firestore: ref.watch(firestoreProvider));
});
