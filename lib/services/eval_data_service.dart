import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/eval_result.dart';

class EvalDataService {
  // Dynamically load available models from models.json
  static Future<List<String>> _getAvailableModels() async {
    try {
      final contents = await rootBundle.loadString('assets/results/models.json');
      final List<dynamic> models = jsonDecode(contents);
      return models.cast<String>();
    } catch (e) {
      print('Error loading models.json: $e');
      // Fallback to empty list if models.json doesn't exist
      return [];
    }
  }

  // Dataset categories mapping
  static const Map<String, List<String>> datasetCategories = {
    'math': [
      'AIME2024',
      'AIME2025',
      'HMMTFeb2024',
      'HMMTFeb2025',
      'CMIMC2025',
      'BRUMO2025',
    ],
    'multimodal': [
      'MMMU',
      'MMMU-Pro',
      'CharXiv',
    ],
    'general': [
      'GPQA-Diamond',
      'HLE',
      'MMLU-Pro',
      'SimpleQA',
      'COLLIE',
    ],
    'coding': [
      'CodeContests',
    ],
  };

  static Future<List<EvalResult>> loadAllResults() async {
    final List<EvalResult> allResults = [];

    // Get available models dynamically from models.json
    final directories = await _getAvailableModels();

    for (final directory in directories) {
      try {
        final contents = await rootBundle
            .loadString('assets/results/$directory/final_results.json');
        final json = jsonDecode(contents) as Map<String, dynamic>;
        final evalResult = EvalResult.fromJson(json);

        // Try to load cost and latency data
        CostAndLatency? costAndLatency;
        try {
          final costContents = await rootBundle
              .loadString('assets/results/$directory/costs_and_latencies.json');
          final costJson = jsonDecode(costContents) as Map<String, dynamic>;
          costAndLatency = CostAndLatency.fromJson(costJson);
        } catch (e) {
          print('No cost/latency data for $directory (this is okay): $e');
        }

        // Create new EvalResult with cost/latency data and directory name
        allResults.add(EvalResult(
          model: evalResult.model,
          timestamp: evalResult.timestamp,
          numSamples: evalResult.numSamples,
          results: evalResult.results,
          costAndLatency: costAndLatency,
          directory: directory, // Store the directory name for lazy loading datasets
        ));
      } catch (e) {
        print('Error loading $directory/final_results.json: $e');
      }
    }

    return allResults;
  }

  static Future<List<dynamic>> loadDatasetSamples(
      String modelDirectory, String datasetName) async {
    try {
      final contents = await rootBundle
          .loadString('assets/results/$modelDirectory/$datasetName.json');
      final data = jsonDecode(contents);
      if (data is List) {
        return data;
      }
      return [];
    } catch (e) {
      print('Error loading $modelDirectory/$datasetName.json: $e');
      return [];
    }
  }

  static Map<String, Map<String, double>> organizeResultsForTable(
      List<EvalResult> results) {
    // Returns a map of model -> (dataset -> accuracy)
    final Map<String, Map<String, double>> organized = {};

    for (final result in results) {
      organized[result.model] = {};
      for (final datasetResult in result.results) {
        organized[result.model]![datasetResult.dataset] =
            datasetResult.accuracy;
      }
    }

    return organized;
  }

  static List<String> getAllDatasets(List<EvalResult> results) {
    final Set<String> datasets = {};
    for (final result in results) {
      for (final datasetResult in result.results) {
        datasets.add(datasetResult.dataset);
      }
    }
    return datasets.toList()..sort();
  }

  static double calculateAverageAccuracy(Map<String, double> scores) {
    if (scores.isEmpty) return 0.0;
    final sum = scores.values.fold(0.0, (a, b) => a + b);
    return sum / scores.length;
  }

  // Calculate category averages for all models
  // Returns: Map<category, Map<model, average_score>>
  static Map<String, Map<String, double>> calculateCategoryAverages(
      Map<String, Map<String, double>> tableData) {
    final Map<String, Map<String, double>> categoryAverages = {};

    for (final category in datasetCategories.keys) {
      categoryAverages[category] = {};
      final datasetsInCategory = datasetCategories[category]!;

      for (final modelEntry in tableData.entries) {
        final modelName = modelEntry.key;
        final modelScores = modelEntry.value;

        // Get scores for datasets in this category
        final categoryScores = <double>[];
        for (final dataset in datasetsInCategory) {
          if (modelScores.containsKey(dataset)) {
            categoryScores.add(modelScores[dataset]!);
          }
        }

        // Calculate average
        if (categoryScores.isNotEmpty) {
          final average =
              categoryScores.reduce((a, b) => a + b) / categoryScores.length;
          categoryAverages[category]![modelName] = average;
        }
      }
    }

    return categoryAverages;
  }
}
