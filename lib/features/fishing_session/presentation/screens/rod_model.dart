class Rod {
  final String id;
  final String posicion;
  final int brazas;
  final String senuelo;

  Rod({
    required this.id,
    required this.posicion,
    required this.brazas,
    required this.senuelo,
  });

  Rod copyWith({
    String? id,
    String? posicion,
    int? brazas,
    String? senuelo,
  }) {
    return Rod(
      id: id ?? this.id,
      posicion: posicion ?? this.posicion,
      brazas: brazas ?? this.brazas,
      senuelo: senuelo ?? this.senuelo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'posicion': posicion,
      'brazas': brazas,
      'senuelo': senuelo,
    };
  }

  factory Rod.fromMap(Map<String, dynamic> map) {
    return Rod(
      id: map['id'] ?? '',
      posicion: map['posicion'] ?? 'Sin posición',
      brazas: map['brazas']?.toInt() ?? 0,
      senuelo: map['senuelo'] ?? 'Ninguno',
    );
  }
}