import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// --- IMPORTACIONES ABSOLUTAS CORREGIDAS ---
import 'package:tunapp/features/inventory/domain/models/senuelo_model.dart';
import 'package:tunapp/features/inventory/providers/inventory_providers.dart';

class MiCajaScreen extends ConsumerStatefulWidget {
  const MiCajaScreen({super.key});

  @override
  ConsumerState<MiCajaScreen> createState() => _MiCajaScreenState();
}

class _MiCajaScreenState extends ConsumerState<MiCajaScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _estaGuardando = false; 

  void _mostrarFormularioNuevo() {
    String nombre = '';
    String tipo = 'Pulpito';
    String color = '';
    Uint8List? imagenBytes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('NUEVA MUESTRA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 15),
              
              GestureDetector(
                onTap: () async {
                  final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
                  if (photo != null) {
                    final bytes = await photo.readAsBytes();
                    setModalState(() => imagenBytes = bytes);
                  }
                },
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.shade900, width: 2)
                  ),
                  child: imagenBytes == null 
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.add_photo_alternate, size: 40), Text('Añadir Foto', style: TextStyle(fontSize: 10))],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.memory(imagenBytes!, fit: BoxFit.cover)
                      ),
                ),
              ),

              TextField(
                decoration: const InputDecoration(labelText: 'Nombre'),
                onChanged: (val) => nombre = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Color'),
                onChanged: (val) => color = val,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  minimumSize: const Size(double.infinity, 50)
                ),
                onPressed: _estaGuardando ? null : () async {
                  if (nombre.isNotEmpty && imagenBytes != null) {
                    setModalState(() => _estaGuardando = true);

                    try {
                      final nuevoSenuelo = Senuelo(
                        nombre: nombre,
                        tipo: tipo,
                        color: color,
                      );

                      final repo = ref.read(senueloRepositoryProvider);
                      await repo.guardarNuevoSenuelo(nuevoSenuelo, imagenBytes!);
                      
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error al guardar: $e")),
                      );
                    } finally {
                      if (mounted) setModalState(() => _estaGuardando = false);
                    }
                  } else if (imagenBytes == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Por favor, selecciona una imagen")),
                    );
                  }
                },
                child: _estaGuardando 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Text('GUARDAR EN LA CAJA', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final senuelosAsync = ref.watch(senuelosStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Caja de Muestras'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: senuelosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
        data: (senuelos) {
          if (senuelos.isEmpty) {
            return const Center(child: Text('Caja vacía. Pulsa + para añadir.', style: TextStyle(color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: senuelos.length,
            itemBuilder: (context, index) {
              final s = senuelos[index];
              return Card(
                elevation: 3,
                child: ListTile(
                  leading: s.fotoUrl != null && s.fotoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          s.fotoUrl!, 
                          width: 50, 
                          height: 50, 
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                        )
                      )
                    : const Icon(Icons.image_not_supported, size: 40),
                  title: Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${s.tipo} - ${s.color}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmarEliminacion(s),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioNuevo,
        backgroundColor: Colors.blue.shade900,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _confirmarEliminacion(Senuelo s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar muestra?'),
        content: Text('Se borrará "${s.nombre}" permanentemente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(
            onPressed: () async {
              await ref.read(senueloRepositoryProvider).eliminarSenuelo(s.id!, imageUrl: s.fotoUrl);
              if (mounted) Navigator.pop(context);
            }, 
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}
