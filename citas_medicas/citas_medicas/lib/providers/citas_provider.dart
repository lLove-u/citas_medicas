// ============================================================
// ARCHIVO NUEVO: lib/providers/citas_provider.dart
// MOTIVO: El proyecto no tenía estado compartido entre páginas.
// Registrar una cita en RegistroCitaPage nunca se reflejaba
// en ListaCitasPage. Este provider usa ChangeNotifier (patrón
// oficial de Flutter) como fuente de verdad de las citas.
// ============================================================

// ============================================================
// ARCHIVO: lib/providers/citas_provider.dart
// ============================================================

import 'package:flutter/material.dart';
import '../models/cita.dart';

class CitasProvider extends ChangeNotifier {
  final List<Cita> _citas = [
    Cita(
      id: '1',
      paciente: 'Juan Pérez',
      especialidad: 'Odontología',
      profesional: 'Dr. Ramírez',
      fechaHora: DateTime(2026, 6, 20, 10, 0),
      motivo: 'Limpieza dental',
      estado: 'Programada',
    ),
    Cita(
      id: '2',
      paciente: 'María López',
      especialidad: 'Medicina General',
      profesional: 'Dra. Soto',
      fechaHora: DateTime(2026, 6, 18, 9, 30),
      motivo: 'Control de rutina',
      estado: 'Atendida',
    ),
  ];

  List<Cita> get citas => List.unmodifiable(_citas);

  void agregarCita(Cita cita) {
    _citas.add(cita);
    notifyListeners();
  }

  void cambiarEstado(String id, String nuevoEstado) {
    final index = _citas.indexWhere((c) => c.id == id);
    if (index != -1) {
      _citas[index] = _citas[index].copyWith(estado: nuevoEstado);
      notifyListeners();
    }
  }

  void eliminarCita(String id) {
    _citas.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  String generarId() => DateTime.now().millisecondsSinceEpoch.toString();
}