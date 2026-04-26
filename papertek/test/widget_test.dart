import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papertek/ui/app.dart';

void main() {
  testWidgets('Start screen shows New Show and Open Show buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PaperTekApp()));
    await tester.pumpAndSettle();

    expect(find.text('New Show'), findsOneWidget);
    expect(find.text('Open Show'), findsOneWidget);
  });
}
