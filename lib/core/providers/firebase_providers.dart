import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para acceder a la base de datos Firestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Provider para acceder al almacenamiento de archivos (imágenes de señuelos, etc.)
final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});