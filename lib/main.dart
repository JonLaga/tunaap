import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- El motor de estado
import 'firebase_options.dart'; // Importación corregida

import 'package:tunapp/features/home/presentation/screens/pantalla_principal_screen.dart';

void main() async {
  // 1. Asegurar los bindings antes de interactuar con el motor nativo (iOS/Android)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Ignición de la Arquitectura Reactiva
  // ProviderScope almacena el estado de todos los providers que creemos.
  runApp(
    const ProviderScope(
      child: TunappFishing(),
    ),
  );
}

class TunappFishing extends StatelessWidget {
  const TunappFishing({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tunapp Fishing',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
        useMaterial3: true,
      ),
      // Tu pantalla principal ahora vive en su propio módulo (feature)
      home: const PantallaPrincipalScreen(),
      debugShowCheckedModeBanner: false, 
    );
  }
}