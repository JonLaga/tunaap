import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Definimos el estado inicial de cubierta (Single Source of Truth)
const _estadoInicial = [
  {"id": "C1", "posicion": "Tangón Ext. Babor", "brazas": 0, "senuelo": "Ninguno"},
  {"id": "C2", "posicion": "Tangón Int. Babor", "brazas": 0, "senuelo": "Ninguno"},
  {"id": "C3", "posicion": "Popa Babor", "brazas": 0, "senuelo": "Ninguno"},
  {"id": "C4", "posicion": "Popa Centro", "brazas": 0, "senuelo": "Ninguno"},
  {"id": "C5", "posicion": "Popa Estribor", "brazas": 0, "senuelo": "Ninguno"},
  {"id": "C6", "posicion": "Tangón Int. Estribor", "brazas": 0, "senuelo": "Ninguno"},
  {"id": "C7", "posicion": "Tangón Ext. Estribor", "brazas": 0, "senuelo": "Ninguno"},
];

// 2. Creamos un Notifier. Este objeto gestiona la memoria de las cañas.
class CanasNotifier extends Notifier<List<Map<String, dynamic>>> {
  @override
  List<Map<String, dynamic>> build() {
    // Retornamos una copia para no mutar la constante original
    return List.from(_estadoInicial);
  }

  // 3. Método expuesto para que la UI modifique el estado de forma segura
  void actualizarCana(int index, String nuevoSenuelo, int nuevasBrazas) {
    // En Riverpod el estado es inmutable. Copiamos la lista actual:
    final nuevoEstado = [...state];
    
    // Modificamos solo la caña afectada:
    nuevoEstado[index] = {
      ...nuevoEstado[index],
      "senuelo": nuevoSenuelo,
      "brazas": nuevasBrazas,
    };
    
    // Actualizamos el estado global (Esto redibuja automáticamente la UI)
    state = nuevoEstado;
  }
}

// 4. Exponemos el Provider al resto de la app
// CORRECCIÓN: NotifierProvider no recibe 'ref' en su constructor
final canasProvider = NotifierProvider<CanasNotifier, List<Map<String, dynamic>>>(CanasNotifier.new);
