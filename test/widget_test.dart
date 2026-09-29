import 'package:flutter_test/flutter_test.dart';

import 'package:pet_finance/main.dart';

void main() {
  testWidgets('FinnyPet запускается', (WidgetTester tester) async {
    await tester.pumpWidget(const FinnyPetApp());

    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(FinnyPetApp), findsOneWidget);
  });
}