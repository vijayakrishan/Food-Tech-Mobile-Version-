import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_packaging_mobile/models/api_response.dart';
import 'package:food_packaging_mobile/models/auth_response.dart';
import 'package:food_packaging_mobile/models/food_commodity.dart';
import 'package:food_packaging_mobile/models/recommendation_history.dart';
import 'package:food_packaging_mobile/models/recommendation_request.dart';
import 'package:food_packaging_mobile/models/recommendation_response.dart';
import 'package:food_packaging_mobile/widgets/material_card.dart';
import 'package:food_packaging_mobile/widgets/score_radial_gauge.dart';
import 'package:food_packaging_mobile/widgets/shap_bar_chart.dart';

void main() {
  group('Backend DTO and Model Parsing Tests', () {
    test('AuthResponse parsing matches Spring Boot response', () {
      final json = {
        'token': 'mock.jwt.token',
        'type': 'Bearer',
        'id': 3,
        'username': 'producer',
        'email': 'producer@foodpack.ai',
        'role': 'ROLE_PRODUCER',
      };

      final auth = AuthResponse.fromJson(json);

      expect(auth.token, 'mock.jwt.token');
      expect(auth.username, 'producer');
      expect(auth.email, 'producer@foodpack.ai');
      expect(auth.role, 'ROLE_PRODUCER');
      expect(auth.isProducer, true);
      expect(auth.displayRole, 'Food Producer');
    });

    test('FoodCommodityDTO and FoodPropertiesDTO parsing', () {
      final json = {
        'id': 1,
        'name': 'Potato Chips',
        'categoryId': 4,
        'categoryName': 'Processed Foods',
        'description': 'Crisp snack',
        'properties': {
          'moistureContent': 2.0,
          'phLevel': 6.2,
          'fatContent': 35.0,
          'proteinContent': 6.0,
          'carbohydrateContent': 50.0,
          'respirationRate': 0.0,
          'oxygenSensitivity': 'High',
          'moistureSensitivity': 'High',
          'lightSensitivity': 'High',
          'isPerishable': false,
        }
      };

      final food = FoodCommodityDTO.fromJson(json);

      expect(food.id, 1);
      expect(food.name, 'Potato Chips');
      expect(food.properties?.moistureContent, 2.0);
      expect(food.properties?.oxygenSensitivity, 'High');
      expect(food.properties?.isPerishable, false);
    });

    test('RecommendationRequestDTO serializes accurately for Spring Boot', () {
      final req = RecommendationRequestDTO(
        foodCommodityId: 1,
        moistureContent: 2.0,
        phLevel: 6.2,
        storageTemperature: 25.0,
        requiredShelfLifeDays: 180,
        costPreference: 0.3,
        performancePreference: 0.4,
      );

      final map = req.toJson();

      expect(map['foodCommodityId'], 1);
      expect(map['moistureContent'], 2.0);
      expect(map['storageTemperature'], 25.0);
      expect(map['requiredShelfLifeDays'], 180);
      expect(map['performancePreference'], 0.4);
    });

    test('RecommendationResponseDTO with Top 3 and SHAP factors parsing', () {
      final json = {
        'requestId': 42,
        'foodCommodityName': 'Potato Chips',
        'status': 'COMPLETED',
        'results': [
          {
            'materialId': 5,
            'materialName': 'Metallized BOPP / PE',
            'materialCode': 'MBOPP-01',
            'rank': 1,
            'suitabilityScore': 94.5,
            'performanceScore': 94.5,
            'costScore': 80.0,
            'sustainabilityScore': 70.0,
            'overallScore': 88.5,
            'explanation': 'Optimal moisture and oxygen barrier.',
            'factors': [
              {
                'factorName': 'Water vapor transmission rate',
                'factorValue': 0.082,
                'contributionPercentage': 8.2,
                'direction': 'POSITIVE',
              },
              {
                'factorName': 'Storage temperature',
                'factorValue': -0.015,
                'contributionPercentage': 1.5,
                'direction': 'NEGATIVE',
              },
            ],
            'materialProperties': {
              'oxygenTransmissionRate': 15.0,
              'waterVaporTransmissionRate': 1.2,
              'estimatedCostPerSqm': 0.45,
              'sustainabilityScore': 7.0,
            }
          }
        ]
      };

      final response = RecommendationResponseDTO.fromJson(json);

      expect(response.requestId, 42);
      expect(response.foodCommodityName, 'Potato Chips');
      expect(response.results.length, 1);

      final top = response.topRecommendation;
      expect(top, isNotNull);
      expect(top!.materialName, 'Metallized BOPP / PE');
      expect(top.suitabilityScore, 94.5);
      expect(top.factors.length, 2);
      expect(top.factors.first.isPositive, true);
      expect(top.factors.last.isPositive, false);
      expect(top.materialProperties?.oxygenTransmissionRate, 15.0);
    });

    test('RecommendationHistoryDTO parsing', () {
      final json = {
        'id': 10,
        'foodCommodityName': 'Apple',
        'topMaterial': 'Macro-perforated LDPE',
        'topScore': 91.2,
        'status': 'COMPLETED',
        'createdAt': '2026-10-04T20:00:00',
      };

      final history = RecommendationHistoryDTO.fromJson(json);

      expect(history.id, 10);
      expect(history.foodCommodityName, 'Apple');
      expect(history.topMaterial, 'Macro-perforated LDPE');
      expect(history.topScore, 91.2);
    });

    test('ApiResponse envelope unwraps correctly', () {
      final json = {
        'success': true,
        'message': 'Data retrieved',
        'data': {'token': 'xyz', 'username': 'admin', 'email': 'admin@a.com', 'role': 'ROLE_ADMIN'},
      };

      final envelope = ApiResponse<AuthResponse>.fromJson(
        json,
        (data) => AuthResponse.fromJson(data as Map<String, dynamic>),
      );

      expect(envelope.success, true);
      expect(envelope.data?.username, 'admin');
      expect(envelope.data?.isAdmin, true);
    });
  });

  group('Widget Rendering Tests', () {
    testWidgets('ScoreRadialGauge renders score and percentage correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRadialGauge(
              score: 92.0,
              size: 100,
              label: 'SUITABILITY',
            ),
          ),
        ),
      );

      expect(find.text('92'), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
      expect(find.text('SUITABILITY'), findsOneWidget);
    });

    testWidgets('ShapBarChart renders positive and negative contribution bars', (tester) async {
      final factors = [
        RecommendationFactorDTO(
          factorName: 'Oxygen Transmission Rate',
          factorValue: 0.12,
          contributionPercentage: 12.0,
          direction: 'POSITIVE',
        ),
        RecommendationFactorDTO(
          factorName: 'Storage Temperature',
          factorValue: -0.05,
          contributionPercentage: 5.0,
          direction: 'NEGATIVE',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShapBarChart(factors: factors),
          ),
        ),
      );

      expect(find.text('Why did AI choose this?'), findsOneWidget);
      expect(find.text('Oxygen Transmission Rate'), findsOneWidget);
      expect(find.text('+12.0%'), findsOneWidget);
      expect(find.text('Storage Temperature'), findsOneWidget);
      expect(find.text('-5.0%'), findsOneWidget);
    });

    testWidgets('MaterialCard displays rank, code, and scores', (tester) async {
      final result = RecommendationResultDTO(
        materialId: 1,
        materialName: 'Coated Barrier Paperboard',
        materialCode: 'CBP-01',
        rank: 1,
        suitabilityScore: 88.0,
        explanation: 'Excellent eco-friendly barrier coating.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MaterialCard(
              result: result,
              isTopMatch: true,
            ),
          ),
        ),
      );

      expect(find.text('BEST MATCH'), findsOneWidget);
      expect(find.text('CBP-01'), findsOneWidget);
      expect(find.text('Coated Barrier Paperboard'), findsOneWidget);
      expect(find.text('Excellent eco-friendly barrier coating.'), findsOneWidget);
    });
  });
}
