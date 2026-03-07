class Rod {
  final String id;
  final String posicion;
  final int brazas;
  final String senuelo;
  final String? selectedSenueloId; // Referencia al ID del señuelo en el inventario
  final String? senueloImage; // URL de la imagen del señuelo para visualización rápida

  Rod({
    required this.id,
    required this.posicion,
    required this.brazas,
    required this.senuelo,
    this.selectedSenueloId,
    this.senueloImage,
  });

  Rod copyWith({
    String? id,
    String? posicion,
    int? brazas,
    String? senuelo,
    String? selectedSenueloId,
    String? senueloImage,
  }) {
    return Rod(
      id: id ?? this.id,
      posicion: posicion ?? this.posicion,
      brazas: brazas ?? this.brazas,
      senuelo: senuelo ?? this.senuelo,
      selectedSenueloId: selectedSenueloId ?? this.selectedSenueloId,
      senueloImage: senueloImage ?? this.senueloImage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'posicion': posicion,
      'brazas': brazas,
      'senuelo': senuelo,
      'selectedSenueloId': selectedSenueloId,
      'senueloImage': senueloImage,
    };
  }

  factory Rod.fromMap(Map<String, dynamic> map) {
    return Rod(
      id: map['id'] ?? '',
      posicion: map['posicion'] ?? 'Sin posición',
      brazas: map['brazas']?.toInt() ?? 0,
      senuelo: map['senuelo'] ?? 'Ninguno',
      selectedSenueloId: map['selectedSenueloId'],
      senueloImage: map['senueloImage'],
    );
  }
}