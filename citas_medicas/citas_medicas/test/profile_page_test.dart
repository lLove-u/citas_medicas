import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:citas_medicas/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('permite editar nombre, correo y teléfono en el perfil', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: ProfilePage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Carlos Pérez');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'carlos@email.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), '5551234567');

    await tester.tap(find.text('Guardar cambios'));
    await tester.pump();

    expect(find.text('Perfil actualizado'), findsOneWidget);
  });
}
