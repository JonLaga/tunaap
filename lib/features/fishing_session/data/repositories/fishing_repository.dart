import 'package:cloud_firestore/cloud_firestore.dart';

class FishingRepository {
  final FirebaseFirestore _firestore;

  FishingRepository(this._firestore);

  /// Verifica si la configuración en Firestore es válida para iniciar la pesca.
  /// Retorna `true` si el número de cañas está entre 4 y 7.
  Future<bool> isConfigurationValid() async {
    try {
      final doc = await _firestore.collection('active_session').doc('sesion_actual').get();
      
      if (!doc.exists || doc.data() == null) return false;
      
      final data = doc.data()!;
      final int rodCount = data['rodCount'] ?? 0;
      
      return rodCount >= 4 && rodCount <= 7;
    } catch (e) {
      // En caso de error de red o lectura, asumimos inválido por seguridad.
      return false;
    }
  }
}