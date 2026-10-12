import 'package:flutter_test/flutter_test.dart';
import 'package:lab8_file_notification/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Bài 08: NOTIFICATION & FILE'), findsOneWidget);
  });
}
