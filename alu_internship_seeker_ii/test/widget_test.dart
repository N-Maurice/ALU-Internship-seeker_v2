import 'package:flutter_test/flutter_test.dart';
import 'package:alu_internship_seeker_ii/main.dart';

void main() {
  testWidgets('shows the opportunities screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Explore Opportunities'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Mobile Development Intern'), findsOneWidget);
  });
}
