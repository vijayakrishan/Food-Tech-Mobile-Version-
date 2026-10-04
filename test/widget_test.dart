import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_packaging_mobile/widgets/stat_kpi_card.dart';
import 'package:food_packaging_mobile/widgets/property_pill.dart';

void main() {
  testWidgets('StatKpiCard renders title, value, and subtitle', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatKpiCard(
            title: 'Active Recommendations',
            value: '42',
            subtitle: '+12% this month',
            icon: Icons.analytics_outlined,
          ),
        ),
      ),
    );

    expect(find.text('Active Recommendations'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('+12% this month'), findsOneWidget);
  });

  testWidgets('PropertyPill renders label and value', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PropertyPill(
            label: 'OTR',
            value: '15.0 cc/m²/day',
          ),
        ),
      ),
    );

    expect(find.text('OTR'), findsOneWidget);
    expect(find.text('15.0 cc/m²/day'), findsOneWidget);
  });
}
