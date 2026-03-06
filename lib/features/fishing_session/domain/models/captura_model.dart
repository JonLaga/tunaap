import 'package:cloud_firestore/cloud_firestore.dart';

class Captura {
  final String? id;
  
  // CATEGORÍA A: Lo que configuramos en puerto
  final String canaId;          // Ej: "C1"
  final String senueloId;       // Ej: "S5"
  final String senueloNombre;   // Ej: "Pulpito Rosa"
  final double brazas;          // Longitud de línea
  final String especie;         // Ej: "Bonito"

  // CATEGORÍA B: Lo que dice el móvil en el mar
  final double latitud;
  final double longitud;
  final double rumboBarco;      
  final double velocidadNudos;  
  final DateTime fechaHora;

  // CATEGORÍA C: Lo que nos dice la Boya de Bilbao
  final double? tempAgua;       
  final double? presionAtmos;   
  final double? dirCorriente;   
  final double? velCorriente;   

  Captura({
    this.id,
    required this.canaId,
    required this.senueloId,
    required this.senueloNombre,
    required this.brazas,
    required this.especie,
    required this.latitud,
    required this.longitud,
    required this.rumboBarco,
    required this.velocidadNudos,
    required this.fechaHora,
    this.tempAgua,
    this.presionAtmos,
    this.dirCorriente,
    this.velCorriente,
  });

  // Esta función sirve para enviar los datos a Firebase fácilmente
  Map<String, dynamic> toMap() {
    return {
      'canaId': canaId,
      'senueloId': senueloId,
      'senueloNombre': senueloNombre,
      'brazas': brazas,
      'especie': especie,
      'latitud': latitud,
      'longitud': longitud,
      'rumboBarco': rumboBarco,
      'velocidadNudos': velocidadNudos,
      'fechaHora': Timestamp.fromDate(fechaHora),
      'tempAgua': tempAgua,
      'presionAtmos': presionAtmos,
      'dirCorriente': dirCorriente,
      'velCorriente': velCorriente,
    };
  }

  // Constructor factory para crear un objeto Captura desde un mapa de Firestore
  factory Captura.fromMap(Map<String, dynamic> map, String documentId) {
    return Captura(
      id: documentId,
      canaId: map['canaId'] ?? '',
      senueloId: map['senueloId'] ?? '',
      senueloNombre: map['senueloNombre'] ?? '',
      brazas: (map['brazas'] as num?)?.toDouble() ?? 0.0,
      especie: map['especie'] ?? '',
      latitud: (map['latitud'] as num?)?.toDouble() ?? 0.0,
      longitud: (map['longitud'] as num?)?.toDouble() ?? 0.0,
      rumboBarco: (map['rumboBarco'] as num?)?.toDouble() ?? 0.0,
      velocidadNudos: (map['velocidadNudos'] as num?)?.toDouble() ?? 0.0,
      fechaHora: (map['fechaHora'] as Timestamp).toDate(),
      tempAgua: (map['tempAgua'] as num?)?.toDouble(),
      presionAtmos: (map['presionAtmos'] as num?)?.toDouble(),
      dirCorriente: (map['dirCorriente'] as num?)?.toDouble(),
      velCorriente: (map['velCorriente'] as num?)?.toDouble(),
    );
  }
}
