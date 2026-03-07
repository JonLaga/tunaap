import 'package:tunapp/features/fishing_session/domain/models/rod_model.dart';

class FishingSession {
  final int rodCount;
  final List<Rod> canas;

  FishingSession({required this.rodCount, required this.canas}) {
    // Validación requerida por la tarea.
    if (rodCount < 4 || rodCount > 7) {
      throw Exception('El número de cañas debe estar entre 4 y 7.');
    }
  }

  FishingSession copyWith({
    int? rodCount,
    List<Rod>? canas,
  }) {
    return FishingSession(
      rodCount: rodCount ?? this.rodCount,
      canas: canas ?? this.canas,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rodCount': rodCount,
      'canas': canas.map((x) => x.toMap()).toList(),
    };
  }

  factory FishingSession.fromMap(Map<String, dynamic> map) {
    return FishingSession(
      rodCount: map['rodCount']?.toInt() ?? 7, // Default a 7 si no existe.
      canas: List<Rod>.from(
        (map['canas'] as List<dynamic>? ?? []).map((x) => Rod.fromMap(x)),
      ),
    );
  }
}