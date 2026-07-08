import 'package:flutter_test/flutter_test.dart';
import 'package:citas_medicas/main.dart';

void main() {
  testWidgets(
    'muestra el mensaje de bienvenida y navega a la pantalla principal',
    (tester) async {
      await tester.pumpWidget(const CitasMedicasApp());

      expect(find.text('Bienvenido al sistema de citas'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Citas Médicas'), findsOneWidget);
    },
  );
}
