import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/pdf_report_generator.dart';
import '../../models/recommendation_response.dart';

class ReportPreviewScreen extends StatelessWidget {
  final RecommendationResponseDTO recommendation;

  const ReportPreviewScreen({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final foodName = recommendation.foodCommodityName ?? 'Commodity';

    return Scaffold(
      appBar: AppBar(
        title: Text('Report: $foodName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Report',
            onPressed: () async {
              final bytes = await PdfReportGenerator.generateRecommendationPdf(
                recommendation: recommendation,
              );
              await Printing.layoutPdf(
                onLayout: (_) => bytes,
                name: 'FoodPack_AI_Report_${recommendation.requestId}.pdf',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Report PDF',
            onPressed: () async {
              final bytes = await PdfReportGenerator.generateRecommendationPdf(
                recommendation: recommendation,
              );
              await Printing.sharePdf(
                bytes: bytes,
                filename: 'FoodPack_AI_Report_${recommendation.requestId}.pdf',
              );
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => PdfReportGenerator.generateRecommendationPdf(
          recommendation: recommendation,
        ),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        dynamicLayout: false,
        loadingWidget: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        pdfFileName: 'FoodPack_AI_Report_${recommendation.requestId}.pdf',
      ),
    );
  }
}
