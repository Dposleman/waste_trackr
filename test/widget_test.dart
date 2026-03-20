import 'package:flutter_test/flutter_test.dart';
import 'package:waste_trackr/main.dart';

void main() {
  testWidgets('WasteTrackr app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const WasteTrackrApp());
    await tester.pumpAndSettle();

    expect(find.text('WasteTrackr'), findsWidgets);
  });
}