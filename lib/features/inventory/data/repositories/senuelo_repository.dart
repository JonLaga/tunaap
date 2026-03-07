
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// --- IMPORTACIÓN ABSOLUTA CORREGIDA ---
import 'package:tunapp/features/inventory/domain/models/senuelo_model.dart';

class SenueloRepository {
  final FirebaseFirestore _firestore; // Inyectado
  final FirebaseStorage _storage;     // Inyectado
  final CollectionReference _db;      // Inicializado con la instancia inyectada

  SenueloRepository({required FirebaseFirestore firestore, required FirebaseStorage storage})
      : _firestore = firestore,
        _storage = storage,
        _db = firestore.collection('senuelos');

  // --- ESCRITURA ---

  /// Sube la imagen y luego guarda el señuelo en una sola operación.
  /// Esto centraliza la lógica y facilita el manejo de errores en la UI.
  Future<void> guardarNuevoSenuelo(Senuelo senuelo, Uint8List imagenBytes) async {
    try {
      // 1. Subir imagen (usamos un nombre único basado en el tiempo para evitar sobrescrituras)
      final String nombreArchivo = '${DateTime.now().millisecondsSinceEpoch}';
      final String? urlImagen = await subirImagen(imagenBytes, nombreArchivo);

      if (urlImagen != null) {
        // 2. Crear copia del modelo con la URL de la imagen
        final nuevoSenuelo = senuelo.copyWith(fotoUrl: urlImagen);
        
        // 3. Guardar en Firestore
        await _db.add(nuevoSenuelo.toMap());
      } else {
        throw Exception("No se pudo obtener la URL de la imagen.");
      }
    } catch (e) {
      debugPrint("Error en guardarNuevoSenuelo: $e"); // Mensaje de error corregido
      rethrow; // Re-lanzamos para que la UI pueda mostrar un error al usuario
    }
  }

  Future<String?> subirImagen(Uint8List imagenBytes, String nombreArchivo) async {
    try {
      final ref = _storage.ref().child('muestras/$nombreArchivo.jpg'); // Corregido: Usar nombreArchivo
      final uploadTask = await ref.putData(
        imagenBytes,
        SettableMetadata(contentType: 'image/jpeg'), // Recomendado para que el navegador/app la lea bien
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error al subir imagen a Storage: $e"); // Mensaje de error corregido
      return null;
    }
  }

  // --- ACTUALIZACIÓN ---

  Future<void> actualizarSenuelo(Senuelo senuelo) async {
    try {
      if (senuelo.id == null) throw Exception("El ID del señuelo es necesario para actualizar.");
      await _db.doc(senuelo.id).update(senuelo.toMap());
    } catch (e) { // Mensaje de error corregido
      debugPrint("Error al actualizar: $e"); 
      rethrow;
    }
  }

  // --- ELIMINACIÓN ---

  /// Elimina el documento de Firestore y, opcionalmente, la imagen de Storage
  Future<void> eliminarSenuelo(String id, {String? imageUrl}) async {
    try {
      // 1. Eliminar de Firestore
      await _db.doc(id).delete();

      // 2. Si tiene imagen, eliminarla de Storage para no dejar archivos huérfanos
      if (imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(imageUrl);
          await ref.delete();
        } catch (e) {
          debugPrint("La imagen no se pudo borrar o no existe en Storage: $e");
        }
      }
    } catch (e) { // Mensaje de error corregido
      debugPrint("Error al eliminar señuelo: $e"); 
      rethrow;
    }
  }

  // --- LECTURA ---

  Stream<List<Senuelo>> obtenerSenuelos() {
    return _db.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Senuelo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<Senuelo?> obtenerSenueloPorId(String id) async {
    try {
      final doc = await _db.doc(id).get();
      if (doc.exists) {
        return Senuelo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint("Error al obtener señuelo: $e"); // Mensaje de error corregido
      return null;
    }
  }
}
