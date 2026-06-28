// ============================================================
// ARCHIVO COMPLETAMENTE CORREGIDO: lib/pages/listas_citas.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cita.dart';
import '../providers/citas_provider.dart';
class RegistroCitaPage extends StatefulWidget {
  const ListasCitasPage({super.key});

  // Devuelve un color característico para la tarjeta según el estado de la cita
  Color _obtenerColorEstado(String estado) {
    switch (estado) {
      case 'Programada':
        return Colors.blue;
      case 'Atendida':
        return Colors.green;
      case 'Cancelada':
        return Colors.red;
      case 'Reprogramada':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Muestra un menú inferior interactivo para cambiar el estado de una cita específica
  void _mostrarOpcionesEstado(BuildContext context, Cita cita) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final provider = context.read<CitasProvider>();
        final estados = ['Programada', 'Atendida', 'Reprogramada', 'Cancelada'];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cambiar Estado de Cita',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
              ),
              const SizedBox(height: 15),
              ...estados.map((estado) {
                final esSeleccionado = cita.estado == estado;
                return ListTile(
                  leading: Icon(
                    Icons.flag,
                    color: _obtenerColorEstado(estado),
                  ),
                  title: Text(
                    estado,
                    style: TextStyle(
                      fontWeight: esSeleccionado ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: esSeleccionado ? const Icon(Icons.check_circle, color: Colors.green) : null,
                  onTap: () {
                    provider.cambiarEstado(cita.id, estado);
                    Navigator.pop(context); // Cierra el menú inferior
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Estado actualizado a "$estado"'),
                        backgroundColor: _obtenerColorEstado(estado),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escucha la lista de citas global del Provider en tiempo real
    final listaCitas = context.watch<CitasProvider>().citas;
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Citas"),
      ),
      body: listaCitas.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 70, color: Colors.grey),
                  SizedBox(height: 15),
                  Text(
                    "No hay citas registradas",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: listaCitas.length,
              itemBuilder: (context, index) {
                final cita = listaCitas[index];
                final colorEstado = _obtenerColorEstado(cita.estado);

                // Permite eliminar la cita deslizando la tarjeta horizontalmente
                return Dismissible(
                  key: Key(cita.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white, size: 30),
                  ),
                  onDismissed: (direction) {
                    context.read<CitasProvider>().eliminarCita(cita.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cita de ${cita.paciente} eliminada'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Barra lateral de color según el estado
                          Container(
                            width: 6,
                            decoration: BoxDecoration(
                              color: colorEstado,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        cita.paciente,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      // Indicador visual superior del estado de la cita
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: colorEstado.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          cita.estado,
                                          style: TextStyle(
                                            color: colorEstado,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  
                                  // Especialidad médica (CORREGIDO AL ESPAÑOL)
                                  Row(
                                    children: [
                                      const Icon(Icons.medical_services, size: 16, color: Colors.blue),
                                      const SizedBox(width: 6),
                                      Text(
                                        cita.especialidad, // <- CAMPO EN ESPAÑOL
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  // Profesional asignado
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Prof: ${cita.profesional}',
                                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  // Fecha y Hora formateadas de manera legible
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${cita.fechaHora.day.toString().padLeft(2, '0')}/'
                                        '${cita.fechaHora.month.toString().padLeft(2, '0')}/'
                                        '${cita.fechaHora.year}  '
                                        '${cita.fechaHora.hour.toString().padLeft(2, '0')}:'
                                        '${cita.fechaHora.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  const Divider(),

                                  // Motivo detallado de la consulta médica
                                  Text(
                                    'Motivo: ${cita.motivo}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: esModoOscuro ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Botón inferior para reaccionar o cambiar de estado
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () => _mostrarOpcionesEstado(context, cita),
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: const Text('Gestionar Estado'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: colorEstado,
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}