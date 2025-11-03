import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/eval_result.dart';
import '../services/eval_data_service.dart';

class CompareViewScreen extends StatefulWidget {
  final List<String> modelNames;
  final List<String>? initialSelectedDatasets;

  const CompareViewScreen({
    super.key,
    required this.modelNames,
    this.initialSelectedDatasets,
  });

  @override
  State<CompareViewScreen> createState() => _CompareViewScreenState();
}

class _CompareViewScreenState extends State<CompareViewScreen> {
  List<EvalResult> _results = [];
  List<String> _datasets = [];
  Set<String> _selectedDatasets = {};
  bool _isLoading = true;
  String? _selectedChartDataset;
  Map<String, Map<String, dynamic>> _sampleData = {};
  List<String> _sampleInputs = [];
  int _currentSampleIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await EvalDataService.loadAllResults();
      final datasets = EvalDataService.getAllDatasets(results);

      // Filter results to only include selected models
      final filteredResults =
          results.where((r) => widget.modelNames.contains(r.model)).toList();

      setState(() {
        _results = filteredResults;
        _datasets = datasets;
        // Use passed dataset selection if available, otherwise select all
        if (widget.initialSelectedDatasets != null && widget.initialSelectedDatasets!.isNotEmpty) {
          _selectedDatasets = Set.from(widget.initialSelectedDatasets!);
        } else {
          _selectedDatasets = Set.from(datasets); // Select all by default
        }
        _isLoading = false;
      });

      // Load first dataset by default
      if (datasets.isNotEmpty) {
        setState(() {
          _selectedChartDataset = datasets[0];
        });
        await _loadSampleData(datasets[0]);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Models'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Dataset selector buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDatasets = Set.from(_datasets);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7FB3FF),
                                foregroundColor: Colors.black,
                              ),
                              child: const Text('Select All'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedDatasets.clear();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16181D),
                                foregroundColor: Colors.white70,
                              ),
                              child: const Text('Select None'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _datasets
                              .map((dataset) => FilterChip(
                                    label: Text(dataset),
                                    selected: _selectedDatasets.contains(dataset),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedDatasets.add(dataset);
                                        } else {
                                          _selectedDatasets.remove(dataset);
                                        }
                                      });
                                    },
                                    selectedColor: const Color(0xFF7FB3FF),
                                    backgroundColor: const Color(0xFF16181D),
                                    labelStyle: TextStyle(
                                      color: _selectedDatasets.contains(dataset)
                                          ? Colors.black
                                          : Colors.white70,
                                      fontWeight:
                                          _selectedDatasets.contains(dataset)
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  // Results display - Bar charts
                  SizedBox(
                    height: 320,
                    child: _selectedDatasets.isEmpty
                        ? const Center(
                            child: Text(
                              'Select at least one dataset to compare',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : Listener(
                            onPointerSignal: (event) {
                              // Prevent horizontal scroll from triggering browser navigation
                            },
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(
                                dragDevices: {
                                  PointerDeviceKind.touch,
                                  PointerDeviceKind.mouse,
                                },
                                scrollbars: false,
                                overscroll: false,
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const ClampingScrollPhysics(),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _selectedDatasets.map((dataset) {
                                    return _buildDatasetChart(dataset);
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                  ),
                  // Sample viewer
                  _buildSampleViewer(),
                ],
              ),
            ),
    );
  }

  Widget _buildDatasetChart(String datasetName) {
    final modelColors = [
      const Color(0xFFFF9AA2),
      const Color(0xFFEEAEEE),
      const Color(0xFF7FB3FF),
      const Color(0xFFFFD97D),
      const Color(0xFFB4F8C8),
    ];

    final bars = <BarChartRodData>[];
    final modelNames = <String>[];

    for (var i = 0; i < _results.length; i++) {
      final result = _results[i];

      // Try to find the dataset result, skip if not found
      try {
        final datasetResult = result.results.firstWhere(
          (d) => d.dataset == datasetName,
        );

        bars.add(BarChartRodData(
          toY: datasetResult.accuracy,
          width: 40,
          color: modelColors[i % modelColors.length],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ));
        modelNames.add(result.model);
      } catch (e) {
        // Model doesn't have results for this dataset, skip it
        continue;
      }
    }

    final isSelected = _selectedChartDataset == datasetName;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        setState(() {
          _selectedChartDataset = datasetName;
          _currentSampleIndex = 0;
        });
        await _loadSampleData(datasetName);
      },
      child: Container(
        width: 280,
        height: 280,
        margin: const EdgeInsets.all(8),
        child: Card(
          elevation: 0,
          color: isSelected ? const Color(0xFF1E2027) : const Color(0xFF16181D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? const Color(0xFF7FB3FF) : Colors.transparent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  datasetName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      maxY: 1.0,
                      minY: 0,
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barsSpace: 8,
                          barRods: bars,
                        ),
                      ],
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: Colors.white12,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (v, meta) => Text(
                              '${(v * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${modelNames[rodIndex]}\n${(rod.toY * 100).toStringAsFixed(1)}%',
                              const TextStyle(color: Colors.white),
                            );
                          },
                        ),
                        handleBuiltInTouches: true,
                        touchCallback: (FlTouchEvent event, barTouchResponse) {
                          if (event is FlTapUpEvent) {
                            setState(() {
                              _selectedChartDataset = datasetName;
                              _currentSampleIndex = 0;
                            });
                            _loadSampleData(datasetName);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...modelNames.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: modelColors[entry.key % modelColors.length],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadSampleData(String datasetName) async {
    _sampleData.clear();
    _sampleInputs.clear();
    final Set<String> allInputs = {};

    for (final result in _results) {
      // Use the directory field which was populated when loading results
      final modelDirectory = result.directory;

      if (modelDirectory != null && modelDirectory.isNotEmpty) {
        try {
          final samples = await EvalDataService.loadDatasetSamples(
            modelDirectory,
            datasetName,
          );

          // Organize samples by input text
          _sampleData[result.model] = {};
          for (final sample in samples) {
            final input = sample['input']?.toString() ?? '';
            if (input.isNotEmpty) {
              _sampleData[result.model]![input] = sample;
              allInputs.add(input);
            }
          }
          // Successfully loaded samples
        } catch (e) {
          // Failed to load samples for this model
        }
      }
    }

    // Store all unique inputs as a sorted list
    _sampleInputs = allInputs.toList();

    setState(() {});
  }

  Widget _buildSampleViewer() {
    if (_selectedChartDataset == null || _sampleData.isEmpty || _sampleInputs.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_currentSampleIndex >= _sampleInputs.length) {
      return const SizedBox.shrink();
    }

    final models = _sampleData.keys.toList();
    final currentInput = _sampleInputs[_currentSampleIndex];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with sample number and navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sample ${_currentSampleIndex + 1} of ${_sampleInputs.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _currentSampleIndex > 0
                            ? () {
                                setState(() {
                                  _currentSampleIndex--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        onPressed: _currentSampleIndex < _sampleInputs.length - 1
                            ? () {
                                setState(() {
                                  _currentSampleIndex++;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Input section
              const Text(
                'Input:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),

              // Display base64 image if available
              Builder(
                builder: (context) {
                  // Try to get image_base64 from any model's sample for this input
                  String? imageBase64;
                  for (final model in models) {
                    final modelSamples = _sampleData[model] ?? {};
                    final modelSample = modelSamples[currentInput];
                    if (modelSample != null && modelSample['image_base64'] != null) {
                      imageBase64 = modelSample['image_base64'] as String;
                      break;
                    }
                  }

                  if (imageBase64 != null && imageBase64.isNotEmpty) {
                    try {
                      final imageBytes = base64Decode(imageBase64);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                              maxWidth: 600,
                              maxHeight: 400,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white24),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                imageBytes,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    } catch (e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Error loading image: $e',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),

              SelectableText(
                currentInput,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 16),

              // Ground Truth section (if available)
              Builder(
                builder: (context) {
                  // Try to get ground_truth from any model's sample for this input
                  String? groundTruth;
                  for (final model in models) {
                    final modelSamples = _sampleData[model] ?? {};
                    final modelSample = modelSamples[currentInput];
                    if (modelSample != null && modelSample['ground_truth'] != null) {
                      final gt = modelSample['ground_truth'].toString();
                      if (gt.isNotEmpty) {
                        groundTruth = gt;
                        break;
                      }
                    }
                  }

                  if (groundTruth != null && groundTruth.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ground Truth:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2027),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: SelectableText(
                            groundTruth,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // First divider
              Divider(
                color: Colors.white12,
                thickness: 1,
              ),
              const SizedBox(height: 16),

              // Response boxes side-by-side
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: models.map((model) {
                  final modelSamples = _sampleData[model] ?? {};
                  final modelSample = modelSamples[currentInput];

                  // Safely extract correctness value
                  bool? isCorrect;
                  if (modelSample != null) {
                    final score = modelSample['score'];
                    if (score is Map) {
                      isCorrect = score['correct'] as bool?;
                    } else if (score is bool) {
                      isCorrect = score;
                    }
                  }

                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2027),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  model,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Color(0xFFFF9AA2),
                                  ),
                                ),
                              ),
                              if (isCorrect != null)
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: isCorrect
                                      ? Colors.green
                                      : Colors.red,
                                  size: 18,
                                )
                              else
                                const Icon(
                                  Icons.help_outline,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Output:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 600),
                            child: SingleChildScrollView(
                              child: SelectableText(
                                modelSample?['output']?.toString() ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
