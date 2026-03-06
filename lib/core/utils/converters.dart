class Converters {
  /// Convierte metros por segundo (m/s) a Nudos (knots)
  static double msToKnots(double speedInMs) {
    if (speedInMs < 0) return 0.0;
    return speedInMs * 1.94384;
  }

  /// Formatea las coordenadas para que tengan 5 decimales
  static double formatCoordinate(double coordinate) {
    return double.parse(coordinate.toStringAsFixed(5));
  }
}
