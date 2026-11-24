import 'package:flutter_test/flutter_test.dart';
import 'package:quesgen/main.dart';

void main() {
  testWidgets('shows bottom navigation tabs', (tester) async {
    await tester.pumpWidget(const QuesGenApp());

    expect(find.text('New Paper'), findsWidgets);
    expect(find.text('Scan from Image'), findsOneWidget);
    expect(find.text('Create Manually'), findsOneWidget);
    expect(find.text('Saved Papers'), findsOneWidget);

    await tester.tap(find.text('Saved Papers'));
    await tester.pumpAndSettle();

    expect(find.text('No saved papers yet.'), findsOneWidget);
  });

  testWidgets('opens manual question editor', (tester) async {
    await tester.pumpWidget(const QuesGenApp());

    await tester.tap(find.text('Create Manually'));
    await tester.pumpAndSettle();

    expect(find.text('Untitled paper'), findsOneWidget);
    expect(find.text('1 question'), findsOneWidget);
    expect(find.text('Add question'), findsOneWidget);
  });
}
