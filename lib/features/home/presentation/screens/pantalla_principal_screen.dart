import 'package:flutter/material.dart';

// Importamos las pantallas a las que queremos navegar
import 'package:tunapp/features/boat/presentation/screens/mi_barco_screen.dart';
import 'package:tunapp/features/inventory/presentation/screens/mi_caja_screen.dart';
import 'package:tunapp/features/fishing_session/presentation/screens/pesca_screen.dart';

/// Pantalla de bienvenida y navegación principal de la aplicación.
class PantallaPrincipalScreen extends StatelessWidget {
  const PantallaPrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tunapp Fishing', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MenuButton(
                icon: Icons.sailing,
                label: "MI BARCO",
                color: Colors.blue.shade700,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MiBarcoScreen())),
              ),
              const SizedBox(height: 20),
              _MenuButton(
                icon: Icons.backpack,
                label: "MI CAJA DE SEÑUELOS",
                color: Colors.orange.shade800,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MiCajaScreen())),
              ),
              const SizedBox(height: 40),
              _MenuButton(
                icon: Icons.bolt, // Icono de acción
                label: "¡A PESCAR!",
                color: Colors.red.shade700,
                isBig: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PescaScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isBig;

  const _MenuButton({required this.icon, required this.label, required this.color, required this.onTap, this.isBig = false});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: isBig ? 25 : 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: isBig ? 40 : 28),
      label: Text(label, style: TextStyle(fontSize: isBig ? 22 : 18, fontWeight: FontWeight.bold)),
    );
  }
}