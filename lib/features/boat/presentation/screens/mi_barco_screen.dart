import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- IMPORTACIONES ABSOLUTAS CORREGIDAS ---
import 'package:tunapp/features/boat/providers/canas_provider.dart';
import 'package:tunapp/features/inventory/providers/inventory_providers.dart';

class MiBarcoScreen extends ConsumerStatefulWidget {
  const MiBarcoScreen({super.key});

  @override
  ConsumerState<MiBarcoScreen> createState() => _MiBarcoScreenState();
}

class _MiBarcoScreenState extends ConsumerState<MiBarcoScreen> {

  void _abrirAjustesCana(int index, List<Map<String, dynamic>> canasActuales) {
    String senueloSeleccionado = canasActuales[index]['senuelo'];
    TextEditingController brazasController = TextEditingController(text: canasActuales[index]['brazas'].toString());

    // Leemos el catálogo de señuelos directamente desde Riverpod
    final senuelosAsync = ref.read(senuelosStreamProvider);
    List<String> opcionesMuestras = ["Ninguno"];
    
    if (senuelosAsync.hasValue) {
      opcionesMuestras.addAll(senuelosAsync.value!.map((m) => m.nombre));
    }

    if (!opcionesMuestras.contains(senueloSeleccionado)) {
      senueloSeleccionado = "Ninguno";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajustar ${canasActuales[index]['id']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: senueloSeleccionado,
                decoration: const InputDecoration(labelText: 'Muestra'),
                isExpanded: true,
                items: opcionesMuestras.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (value) => senueloSeleccionado = value!,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: brazasController,
                decoration: const InputDecoration(labelText: 'Brazas de línea', suffixText: 'br'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
            ElevatedButton(
              onPressed: () {
                final nuevasBrazas = int.tryParse(brazasController.text) ?? 0;
                ref.read(canasProvider.notifier).actualizarCana(index, senueloSeleccionado, nuevasBrazas);
                Navigator.pop(context);
              },
              child: const Text('GUARDAR'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ESCUCHAMOS EL ESTADO GLOBAL DE LAS CAÑAS
    final canas = ref.watch(canasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Aparejos'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: canas.length,
        itemBuilder: (context, index) {
          final cana = canas[index];
          final bool isArmada = cana['senuelo'] != 'Ninguno';

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: isArmada ? Colors.green : Colors.grey.shade300, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isArmada ? Colors.green : Colors.grey.shade200,
                child: Text(cana['id'], style: TextStyle(color: isArmada ? Colors.white : Colors.black)),
              ),
              title: Text(cana['posicion'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${cana['senuelo']} • ${cana['brazas']} brazas'),
              trailing: IconButton(
                icon: const Icon(Icons.settings_suggest, color: Colors.blue),
                onPressed: () => _abrirAjustesCana(index, canas),
              ),
            ),
          );
        },
      ),
    );
  }
}
