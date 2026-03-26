// portfolio_ai_insight_service.dart
// Generates AI-powered portfolio insights using the Gemini Pro model.

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../../core/app_config.dart';
import '../../../core/services/exception_handler.dart';
import '../../../core/services/portfolio_service.dart';
import 'portfolio_analysis_service.dart';
import 'portfolio_document_parser.dart';

class AiInsightResult {
  final String performanceSummary;
  final String riskSummary;
  final String diversificationAnalysis;
  final List<String> suggestions;
  final bool isLoading;
  final String? error;

  const AiInsightResult({
    required this.performanceSummary,
    required this.riskSummary,
    required this.diversificationAnalysis,
    required this.suggestions,
    this.isLoading = false,
    this.error,
  });

  factory AiInsightResult.loading() => const AiInsightResult(
    performanceSummary: '',
    riskSummary: '',
    diversificationAnalysis: '',
    suggestions: [],
    isLoading: true,
  );

  factory AiInsightResult.error(String message) => AiInsightResult(
    performanceSummary: '',
    riskSummary: '',
    diversificationAnalysis: '',
    suggestions: [],
    error: message,
  );

  factory AiInsightResult.fromJson(Map<String, dynamic> json) {
    return AiInsightResult(
      performanceSummary: json['performanceSummary'] ?? '',
      riskSummary: json['riskSummary'] ?? '',
      diversificationAnalysis: json['diversificationAnalysis'] ?? '',
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }
}

class PortfolioAiInsightService {
  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            extra: {'withCredentials': true},
          ),
        )
        ..interceptors.add(
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: false,
            compact: false,
          ),
        );

  /// Generates real portfolio insights using Gemini.
  static Future<AiInsightResult> generateInsights(
    List<PortfolioInvestment> investments,
    PortfolioAnalysis analysis,
  ) async {
    final Map<String, dynamic> portfolioData = {
      'totalInvested': analysis.totalInvested,
      'currentValue': analysis.currentValue,
      'totalReturns': analysis.totalReturns,
      'returnPercentage': analysis.returnPercentage,
      'allocation': analysis.allocation
          .map(
            (a) => {
              'category': a.category,
              'amount': a.amount,
              'percentage': a.percentage,
            },
          )
          .toList(),
      'investments': investments
          .map(
            (i) => PortfolioService.investmentToMap(i, '', forFirestore: false),
          )
          .toList(),
    };

    final String prompt =
        '''
      You are an expert financial portfolio advisor. Analyze the following portfolio data and provide personalized, professional insights.
      Use relevant, professional emojis in all summaries and suggestions to make the insights more engaging and to highlight key points.
      The output must be a single valid JSON object with EXACTLY these four keys:
      1. performanceSummary (String): A detailed assessment of historical growth and recent performance, highlighted with relevant emojis.
      2. riskSummary (String): Analysis of the risk profile based on asset allocation, highlighted with relevant emojis.
      3. diversificationAnalysis (String): Evaluation of how well-diversified the portfolio is across asset classes and specific holdings, highlighted with relevant emojis.
      4. suggestions (List of strings): At least 3 specific, actionable recommendations for optimization, each starting with a unique, relevant emoji.

      PORTFOLIO DATA:
      ${jsonEncode(portfolioData)}

      IMPORTANT: Return ONLY the raw JSON object. Do not include any introductory text, markdown code blocks (like ```json), or explanations.
    ''';

    try {
      final response = await _dio.post(
        '/models/gemini-2.5-flash:generateContent?key=${AppConfig.geminiApiKey}',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        },
      );

      if (response.statusCode == 200) {
        final candidates = response.data['candidates'] as List;
        if (candidates.isNotEmpty) {
          final text = candidates[0]['content']['parts'][0]['text'] as String;

          // Clean the response text by removing potential markdown code blocks
          String cleanedText = text.trim();
          if (cleanedText.startsWith('```')) {
            final lines = cleanedText.split('\n');
            if (lines.first.startsWith('```')) {
              lines.removeAt(0);
            }
            if (lines.isNotEmpty && lines.last.startsWith('```')) {
              lines.removeLast();
            }
            cleanedText = lines.join('\n').trim();
          }

          final decoded = jsonDecode(cleanedText);
          return AiInsightResult.fromJson(decoded);
        }
      }

      return AiInsightResult.error('Failed to generate insights from Gemini.');
    } catch (e) {
      return AiInsightResult.error(ExceptionUtils.handleException(e));
    }
  }
}
