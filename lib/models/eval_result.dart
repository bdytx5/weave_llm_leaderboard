class EvalResult {
  final String model;
  final String timestamp;
  final int numSamples;
  final List<DatasetResult> results;
  final CostAndLatency? costAndLatency;

  EvalResult({
    required this.model,
    required this.timestamp,
    required this.numSamples,
    required this.results,
    this.costAndLatency,
  });

  factory EvalResult.fromJson(Map<String, dynamic> json) {
    return EvalResult(
      model: json['model'] as String,
      timestamp: json['timestamp'] as String,
      numSamples: json['num_samples'] as int,
      results: (json['results'] as List)
          .map((e) => DatasetResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DatasetResult {
  final String dataset;
  final int totalSamples;
  final int correct;
  final double accuracy;

  DatasetResult({
    required this.dataset,
    required this.totalSamples,
    required this.correct,
    required this.accuracy,
  });

  factory DatasetResult.fromJson(Map<String, dynamic> json) {
    return DatasetResult(
      dataset: json['dataset'] as String,
      totalSamples: json['total_samples'] as int,
      correct: json['correct'] as int,
      accuracy: json['accuracy'] as double,
    );
  }
}

class CostAndLatency {
  final double? promptCostPer1M;
  final double? completionCostPer1M;
  final double? streamToksPerS;
  final double? e2eToksPerS;
  final double? ttftS;

  CostAndLatency({
    this.promptCostPer1M,
    this.completionCostPer1M,
    this.streamToksPerS,
    this.e2eToksPerS,
    this.ttftS,
  });

  factory CostAndLatency.fromJson(Map<String, dynamic> json) {
    return CostAndLatency(
      promptCostPer1M: json['prompt_cost_per_1m'] as double?,
      completionCostPer1M: json['completion_cost_per_1m'] as double?,
      streamToksPerS: json['stream_toks_per_s'] as double?,
      e2eToksPerS: json['e2e_toks_per_s'] as double?,
      ttftS: json['ttft_s'] as double?,
    );
  }
}
