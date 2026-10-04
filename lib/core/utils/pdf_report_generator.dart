import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/recommendation_response.dart';

class PdfReportGenerator {
  static const PdfColor primaryTeal = PdfColor(0.05, 0.58, 0.53); // #0D9488
  static const PdfColor darkTeal = PdfColor(0.06, 0.46, 0.43); // #0F766E
  static const PdfColor slateDark = PdfColor(0.12, 0.16, 0.23); // #1E293B
  static const PdfColor slateText = PdfColor(0.20, 0.25, 0.33); // #334155
  static const PdfColor slateMuted = PdfColor(0.39, 0.45, 0.55); // #64748B
  static const PdfColor slateBorder = PdfColor(0.89, 0.91, 0.94); // #E2E8F0
  static const PdfColor slateBg = PdfColor(0.95, 0.96, 0.97); // #F1F5F9
  static const PdfColor tealBg = PdfColor(0.94, 0.99, 0.98); // #F0FDFA
  static const PdfColor emeraldGreen = PdfColor(0.02, 0.59, 0.41); // #059669
  static const PdfColor roseRed = PdfColor(0.88, 0.11, 0.28); // #E11D48

  /// Generate a formal PDF document for an AI recommendation result
  static Future<Uint8List> generateRecommendationPdf({
    required RecommendationResponseDTO recommendation,
  }) async {
    final pdf = pw.Document();

    final topMatch = recommendation.topRecommendation;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return [
            // Header Section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'FoodPack AI',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryTeal,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Intelligent Packaging Recommendation Report',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: slateText,
                      ),
                    ),
                    pw.Text(
                      'Powered by XGBoost Machine Learning & SHAP Explainability',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: slateMuted,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Request ID: #${recommendation.requestId ?? 0}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Generated: ${recommendation.createdAt ?? DateTime.now().toIso8601String().substring(0, 10)}',
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: slateMuted,
                      ),
                    ),
                    pw.Text(
                      'Target Food: ${recommendation.foodCommodityName ?? "N/A"}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryTeal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.Divider(thickness: 1, color: slateBorder),
            pw.SizedBox(height: 12),

            // Top Recommendation Highlight
            if (topMatch != null) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  color: tealBg,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: primaryTeal, width: 1.5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'BEST MATCH #1: ${topMatch.materialName}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: darkTeal,
                              ),
                            ),
                            pw.Text(
                              'Code: ${topMatch.materialCode}',
                              style: const pw.TextStyle(fontSize: 10, color: slateMuted),
                            ),
                          ],
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: primaryTeal,
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Text(
                            '${topMatch.suitabilityScore.toStringAsFixed(1)}% Suitability',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      topMatch.explanation ?? 'Optimal barrier performance and shelf-life alignment.',
                      style: const pw.TextStyle(fontSize: 10, color: slateText),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetricBox('Overall Score', '${topMatch.overallScore?.toStringAsFixed(1) ?? "N/A"}%'),
                        _buildMetricBox('Cost Score', '${topMatch.costScore?.toStringAsFixed(1) ?? "N/A"}%'),
                        _buildMetricBox('Sustainability', '${topMatch.sustainabilityScore?.toStringAsFixed(1) ?? "N/A"}%'),
                        _buildMetricBox('Est. Cost', topMatch.materialProperties?.estimatedCostPerSqm != null
                            ? '\$${topMatch.materialProperties!.estimatedCostPerSqm!.toStringAsFixed(2)}/m²'
                            : 'N/A'),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
            ],

            // Top 3 Ranking Table
            pw.Text(
              'TOP 3 PACKAGING COMPARISON',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: slateDark,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: slateBorder),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: slateBg),
                  children: [
                    _buildTableCell('Rank', isHeader: true),
                    _buildTableCell('Material', isHeader: true),
                    _buildTableCell('Code', isHeader: true),
                    _buildTableCell('Suitability', isHeader: true),
                    _buildTableCell('Cost/m²', isHeader: true),
                    _buildTableCell('Sustainability', isHeader: true),
                  ],
                ),
                ...recommendation.results.map((res) {
                  return pw.TableRow(
                    children: [
                      _buildTableCell('#${res.rank}'),
                      _buildTableCell(res.materialName),
                      _buildTableCell(res.materialCode),
                      _buildTableCell('${res.suitabilityScore.toStringAsFixed(1)}%'),
                      _buildTableCell(res.materialProperties?.estimatedCostPerSqm != null
                          ? '\$${res.materialProperties!.estimatedCostPerSqm!.toStringAsFixed(2)}'
                          : '-'),
                      _buildTableCell(res.sustainabilityScore != null
                          ? '${res.sustainabilityScore!.toStringAsFixed(1)}%'
                          : '-'),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 16),

            // SHAP Explainability Section
            if (topMatch != null && topMatch.factors.isNotEmpty) ...[
              pw.Text(
                'AI DECISION FACTORS (SHAP EXPLAINABILITY)',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: slateDark,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'SHAP (SHapley Additive exPlanations) quantifies the positive or negative contribution of each feature to the predicted packaging suitability.',
                style: const pw.TextStyle(fontSize: 8, color: slateMuted),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(color: slateBorder),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: slateBg),
                    children: [
                      _buildTableCell('Feature', isHeader: true),
                      _buildTableCell('Impact Direction', isHeader: true),
                      _buildTableCell('Contribution', isHeader: true),
                      _buildTableCell('Raw Value', isHeader: true),
                    ],
                  ),
                  ...topMatch.factors.take(8).map((f) {
                    final isPos = f.isPositive;
                    return pw.TableRow(
                      children: [
                        _buildTableCell(f.factorName ?? 'Feature'),
                        _buildTableCell(
                          isPos ? '+ Increases Suitability' : '- Decreases Suitability',
                          textColor: isPos ? emeraldGreen : roseRed,
                        ),
                        _buildTableCell('${f.contributionPercentage?.toStringAsFixed(2) ?? "0.0"}%'),
                        _buildTableCell(f.factorValue?.toStringAsFixed(4) ?? '-'),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 16),
            ],

            // Packaging Barrier Properties
            if (topMatch?.materialProperties != null) ...[
              pw.Text(
                'BARRIER & MECHANICAL SPECIFICATIONS',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: slateDark,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildSpecCard('OTR (Oxygen Transmission)', '${topMatch!.materialProperties!.oxygenTransmissionRate ?? "-"} cc/m²/day'),
                  _buildSpecCard('WVTR (Water Vapor)', '${topMatch.materialProperties!.waterVaporTransmissionRate ?? "-"} g/m²/day'),
                  _buildSpecCard('Tensile Strength', '${topMatch.materialProperties!.tensileStrength ?? "-"} MPa'),
                  _buildSpecCard('Thickness', '${topMatch.materialProperties!.thicknessMicrons ?? "-"} µm'),
                ],
              ),
              pw.SizedBox(height: 16),
            ],

            // Disclaimer & System Footer
            pw.Divider(thickness: 0.5, color: slateBorder),
            pw.SizedBox(height: 4),
            pw.Text(
              'This recommendation was automatically generated by the FoodPack AI Recommendation Engine. Always confirm barrier properties against pilot scale shelf-life tests before full commercial packaging deployment.',
              style: const pw.TextStyle(fontSize: 7.5, color: slateMuted),
            ),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  static pw.Widget _buildMetricBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: slateBorder),
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7.5, color: slateMuted)),
          pw.SizedBox(height: 2),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkTeal)),
        ],
      ),
    );
  }

  static pw.Widget _buildSpecCard(String label, String value) {
    return pw.Container(
      width: 120,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        color: slateBg,
        border: pw.Border.all(color: slateBorder),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7, color: slateMuted)),
          pw.SizedBox(height: 2),
          pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: slateDark)),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    PdfColor? textColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8.5,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: textColor ?? (isHeader ? slateDark : slateText),
        ),
      ),
    );
  }
}
