import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTACIÓN ABSOLUTA CORREGIDA ---
import 'package:tunapp/features/fishing_session/domain/models/captura_model.dart';

class CapturaRepository {
  final FirebaseFirestore _firestore;
  final CollectionReference _db;

  CapturaRepository({required FirebaseFirestore firestore})
      : _firestore = firestore,
        _db = firestore.collection('capturas');

  /// Función para guardar una nueva picada para siempre
  Future<void> guardarCaptura(Captura captura) async {
    try {
      // Mandamos los datos convertidos a mapa (lo que hicimos en el modelo)
      await _db.add(captura.toMap());
      debugPrint("¡Picada guardada con éxito en la nube!");
    } catch (e) {
      // Si falla (por falta de cobertura, por ejemplo), nos avisa
      throw Exception("Error al guardar la captura: $e");
    }
  }

  /// Función para obtener todas tus capturas ordenadas por fecha
  Stream<List<Captura>> obtenerHistorial() {
    return _db.orderBy('fechaHora', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Aquí reconstruimos el objeto Captura usando el factory fromMap
        return Captura.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList(); 
    });
  }
}
