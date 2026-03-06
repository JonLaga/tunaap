class Senuelo {
  final String? id;
  final String nombre;
  final String tipo;   // Reemplaza a 'marca' para coincidir con la UI
  final String color;  // Nuevo campo añadido en la UI
  final String? fotoUrl;

  Senuelo({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.color,
    this.fotoUrl,
  });

  // Método para clonar el objeto modificando solo algunos campos (como la URL o el ID)
  Senuelo copyWith({
    String? id,
    String? nombre,
    String? tipo,
    String? color,
    String? fotoUrl,
  }) {
    return Senuelo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      tipo: tipo ?? this.tipo,
      color: color ?? this.color,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }

  // Convierte el objeto a un Map para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'tipo': tipo,
      'color': color,
      'fotoUrl': fotoUrl,
    };
  }

  // Crea un objeto Senuelo a partir de los datos leídos de Firestore
  factory Senuelo.fromMap(Map<String, dynamic> map, String documentId) {
    return Senuelo(
      id: documentId,
      nombre: map['nombre'] ?? '',
      tipo: map['tipo'] ?? 'Desconocido', // Valor por defecto seguro por si hay datos antiguos
      color: map['color'] ?? 'Sin color', // Valor por defecto seguro
      fotoUrl: map['fotoUrl'],
    );
  }
}
