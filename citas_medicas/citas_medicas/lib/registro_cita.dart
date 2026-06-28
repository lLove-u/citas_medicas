// ============================================================
// ARCHIVO COMPLETAMENTE CORREGIDO: lib/pages/registro_cita.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cita.dart';
import '../providers/citas_provider.dart';

class RegistroCitaPage extends StatefulWidget {
  const RegistroCitaPage({super.key});

  @override
  State<RegistroCitaPage> createState() => _RegistroCitaPageState();
}

class _RegistroCitaPageState extends State<RegistroCitaPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para capturar lo que el usuario escribe
  final _pacienteCtrl     = TextEditingController();
  final _especialidadCtrl = TextEditingController();
  final _profesionalCtrl  = TextEditingController();
  final _motivoCtrl       = TextEditingController();

  DateTime?  _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  String _estadoSeleccionado = 'Programada';

  @override
  void dispose() {
    // Liberar memoria al cerrar la pantalla
    _pacienteCtrl.dispose();
    _especialidadCtrl.dispose();
    _profesionalCtrl.dispose();
    _motivoCtrl.dispose();
    super.dispose();
  }

  // Abre el selector de fecha y luego el de hora consecutivamente
  Future<void> _seleccionarFechaHora() async {
    final ahora = DateTime.now();
    
    final fecha = await showDatePicker(
      context: context,
      initialDate: ahora,
      firstDate: DateTime(ahora.year, ahora.month, ahora.day), // Evita días pasados
      lastDate: ahora.add(const Duration(days: 365)),
      helpText: 'Seleccionar fecha de la cita',
    );
    if (fecha == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Seleccionar hora de la cita',
    );
    if (hora == null || !mounted) return;

    // Validación para que no pongan una hora que ya pasó el día de hoy
    final fechaHoraCombinada = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
    if (fechaHoraCombinada.isBefore(ahora)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora seleccionada ya ha pasado. Elige una hora futura.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _fechaSeleccionada = fecha;
      _horaSeleccionada  = hora;
    });
  }

  // Da formato de texto amigable a la fecha elegida
  String get _fechaTexto {
    if (_fechaSeleccionada == null || _horaSeleccionada == null) {
      return 'Seleccionar fecha y hora';
    }
    final d = _fechaSeleccionada!;
    final h = _horaSeleccionada!;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}  '
        '${h.hour.toString().padLeft(2, '0')}:'
        '${h.minute.toString().padLeft(2, '0')}';
  }

  void _guardarCita() {
    // Valida que ningún campo de texto esté vacío
    if (!_formKey.currentState!.validate()) return;

    // Valida que se haya seleccionado fecha y hora
    if (_fechaSeleccionada == null || _horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona fecha y hora de la cita.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final fechaHora = DateTime(
      _fechaSeleccionada!.year,
      _fechaSeleccionada!.month,
      _fechaSeleccionada!.day,
      _horaSeleccionada!.hour,
      _horaSeleccionada!.minute,
    );

    final provider = context.read<CitasProvider>();
    
    // Mapeo e inserción con los campos correctos unificados en español
    provider.agregarCita(Cita(
      id:           provider.generarId(),
      paciente:     _pacienteCtrl.text.trim(),
      especialidad: _especialidadCtrl.text.trim(), // <- CORREGIDO AL ESPAÑOL
      profesional:  _profesionalCtrl.text.trim(),
      fechaHora:    fechaHora,
      motivo:       _motivoCtrl.text.trim(),
      estado:       _estadoSeleccionado,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Cita registrada correctamente"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context); // Regresa a la pantalla de inicio tras guardar
  }

  @override
  Widget build(BuildContext context) {
    final esModoOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Cita"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Campo Paciente
                TextFormField(
                  controller: _pacienteCtrl,
                  decoration: const InputDecoration(
                    labelText: "Paciente",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa el nombre del paciente'
                      : null,
                ),
                const SizedBox(height: 15),

                // Campo Especialidad
                TextFormField(
                  controller: _especialidadCtrl,
                  decoration: const InputDecoration(
                    labelText: "Especialidad",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.medical_services),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa la especialidad'
                      : null,
                ),
                const SizedBox(height: 15),

                // Campo Profesional / Médico
                TextFormField(
                  controller: _profesionalCtrl,
                  decoration: const InputDecoration(
                    labelText: "Profesional",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa el nombre del profesional'
                      : null,
                ),
                const SizedBox(height: 15),

                // Botón selector de fecha y hora interactivo
                GestureDetector(
                  onTap: _seleccionarFechaHora,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: esModoOscuro ? Colors.grey.shade900 : Colors.grey.shade50,
                      border: Border.all(
                        color: _fechaSeleccionada == null ? Colors.grey.shade400 : const Color(0xFF1565C0),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: _fechaSeleccionada == null ? Colors.grey : const Color(0xFF1565C0),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _fechaTexto,
                          style: TextStyle(
                            fontSize: 16,
                            color: _fechaSeleccionada == null 
                                ? Colors.grey.shade600 
                                : (esModoOscuro ? Colors.white : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Campo Motivo
                TextFormField(
                  controller: _motivoCtrl,
                  decoration: const InputDecoration(
                    labelText: "Motivo de la cita",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Describe el motivo de la cita'
                      : null,
                ),
                const SizedBox(height: 20),

                // Selector desplegable para el Estado inicial de la cita
                DropdownButtonFormField<String>(
                  value: _estadoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: "Estado",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Programada", child: Text("Programada")),
                    DropdownMenuItem(value: "Atendida", child: Text("Atendida")),
                    DropdownMenuItem(value: "Cancelada", child: Text("Cancelada")),
                    DropdownMenuItem(value: "Reprogramada", child: Text("Reprogramada")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _estadoSeleccionado = value);
                    }
                  },
                ),
                const SizedBox(height: 25),

                // Botón Principal Guardar
                ElevatedButton(
                  onPressed: _guardarCita,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Guardar Cita", style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 10),

                // Botón Secundario Cancelar
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}