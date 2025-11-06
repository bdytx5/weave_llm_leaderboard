import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../models/eval_result.dart';
import '../services/eval_data_service.dart';
import '../widgets/category_charts.dart';
import 'compare_view_screen.dart';

class BenchmarksTableScreen extends StatefulWidget {
  const BenchmarksTableScreen({super.key});

  @override
  State<BenchmarksTableScreen> createState() => _BenchmarksTableScreenState();
}

class _BenchmarksTableScreenState extends State<BenchmarksTableScreen> {
  List<EvalResult> _results = [];
  List<String> _datasets = [];
  Map<String, Map<String, double>> _tableData = {};
  Map<String, Map<String, double>> _categoryAverages = {};
  bool _isLoading = true;
  String? _sortColumn; // null means sort by average
  bool _sortAscending = false; // false = descending (best first)
  Set<String> _selectedModels = {};
  List<String> _selectedDatasets = []; // List to maintain selection order

  // Filter thresholds
  double _minToksPerS = 0;
  double _maxToksPerS = 100000;
  double _minInputCost = 0;
  double _maxInputCost = 50;
  double _minOutputCost = 0;
  double _maxOutputCost = 50;

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
      final tableData = EvalDataService.organizeResultsForTable(results);
      final categoryAverages = EvalDataService.calculateCategoryAverages(tableData);

      setState(() {
        _results = results;
        _datasets = datasets;
        _tableData = tableData;
        _categoryAverages = categoryAverages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assessment_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'No evaluation results found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Make sure result files are in assets/results/',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Category performance charts or individual dataset charts
          CategoryCharts(
            categoryAverages: _getFilteredCategoryAverages(),
            selectedModels: _selectedModels,
            selectedDatasets: _selectedDatasets,
            tableData: _getFilteredTableData(),
          ),
          // Filter button and Compare button row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filters'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
                if (_hasActiveFilters()) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Reset'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF9AA2),
                      side: const BorderSide(color: Color(0xFFFF9AA2)),
                    ),
                  ),
                ],
                if (_selectedModels.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _navigateToCompare,
                    icon: const Icon(Icons.visibility),
                    label: Text(_selectedModels.length > 1 ? 'Compare' : 'View'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7FB3FF),
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Listener(
            onPointerSignal: (event) {
              // Prevent horizontal scroll from triggering browser navigation
            },
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
                scrollbars: true,
                overscroll: false,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildTable(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, Map<String, double>>> _getSortedEntries() {
    var entries = _tableData.entries.toList();

    // Apply filters
    entries = entries.where((entry) {
      final modelName = entry.key;
      final modelResult = _results.firstWhere(
        (r) => r.model == modelName,
        orElse: () => _results.first,
      );
      final costLatency = modelResult.costAndLatency;

      // Filter by tok/s
      final toksPerS = costLatency?.e2eToksPerS ?? 0;
      if (toksPerS < _minToksPerS || toksPerS > _maxToksPerS) {
        return false;
      }

      // Filter by input cost
      final inputCost = costLatency?.promptCostPer1M ?? 0;
      if (inputCost < _minInputCost || inputCost > _maxInputCost) {
        return false;
      }

      // Filter by output cost
      final outputCost = costLatency?.completionCostPer1M ?? 0;
      if (outputCost < _minOutputCost || outputCost > _maxOutputCost) {
        return false;
      }

      return true;
    }).toList();

    entries.sort((a, b) {
      double aValue, bValue;

      if (_sortColumn == null) {
        // Sort by average
        aValue = EvalDataService.calculateAverageAccuracy(a.value);
        bValue = EvalDataService.calculateAverageAccuracy(b.value);
      } else {
        // Sort by specific dataset
        aValue = a.value[_sortColumn] ?? 0.0;
        bValue = b.value[_sortColumn] ?? 0.0;
      }

      final comparison = aValue.compareTo(bValue);
      return _sortAscending ? comparison : -comparison;
    });

    return entries;
  }


  void _onSort(String? column) {
    setState(() {
      if (_sortColumn == column) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumn = column;
        _sortAscending = false;
      }
    });
  }

  bool _hasActiveFilters() {
    return _minToksPerS != 0 ||
        _maxToksPerS != 100000 ||
        _minInputCost != 0 ||
        _maxInputCost != 50 ||
        _minOutputCost != 0 ||
        _maxOutputCost != 50;
  }

  bool _modelPassesFilters(String modelName) {
    final modelResult = _results.firstWhere(
      (r) => r.model == modelName,
      orElse: () => _results.first,
    );
    final costLatency = modelResult.costAndLatency;

    // Filter by tok/s
    final toksPerS = costLatency?.e2eToksPerS ?? 0;
    if (toksPerS < _minToksPerS || toksPerS > _maxToksPerS) {
      return false;
    }

    // Filter by input cost
    final inputCost = costLatency?.promptCostPer1M ?? 0;
    if (inputCost < _minInputCost || inputCost > _maxInputCost) {
      return false;
    }

    // Filter by output cost
    final outputCost = costLatency?.completionCostPer1M ?? 0;
    if (outputCost < _minOutputCost || outputCost > _maxOutputCost) {
      return false;
    }

    return true;
  }

  Map<String, Map<String, double>> _getFilteredCategoryAverages() {
    final Map<String, Map<String, double>> filtered = {};

    for (final categoryEntry in _categoryAverages.entries) {
      final category = categoryEntry.key;
      final modelScores = categoryEntry.value;

      // Filter out models that don't pass the filters
      final filteredModelScores = Map<String, double>.fromEntries(
        modelScores.entries.where((entry) => _modelPassesFilters(entry.key))
      );

      if (filteredModelScores.isNotEmpty) {
        filtered[category] = filteredModelScores;
      }
    }

    return filtered;
  }

  Map<String, Map<String, double>> _getFilteredTableData() {
    final Map<String, Map<String, double>> filtered = {};

    for (final entry in _tableData.entries) {
      if (_modelPassesFilters(entry.key)) {
        filtered[entry.key] = entry.value;
      }
    }

    return filtered;
  }

  void _resetFilters() {
    setState(() {
      _minToksPerS = 0;
      _maxToksPerS = 100000;
      _minInputCost = 0;
      _maxInputCost = 50;
      _minOutputCost = 0;
      _maxOutputCost = 50;
    });
  }

  void _navigateToCompare() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompareViewScreen(
          modelNames: _selectedModels.toList(),
          initialSelectedDatasets: _selectedDatasets.isNotEmpty ? _selectedDatasets : null,
        ),
      ),
    );
  }

  void _showFilterDialog() {
    final minToksController = TextEditingController(text: _minToksPerS.round().toString());
    final maxToksController = TextEditingController(text: _maxToksPerS.round().toString());
    final minInputCostController = TextEditingController(text: _minInputCost.toStringAsFixed(2));
    final maxInputCostController = TextEditingController(text: _maxInputCost.toStringAsFixed(2));
    final minOutputCostController = TextEditingController(text: _minOutputCost.toStringAsFixed(2));
    final maxOutputCostController = TextEditingController(text: _maxOutputCost.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF16181D),
          title: const Text(
            'Filter Models',
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tokens per second filter
                  const Text(
                    'Tokens/Second',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minToksController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Min',
                            labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null && parsed >= 0 && parsed <= 100000) {
                              setDialogState(() => _minToksPerS = parsed);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('-', style: TextStyle(color: Colors.white54)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: maxToksController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Max',
                            labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null && parsed >= 0 && parsed <= 100000) {
                              setDialogState(() => _maxToksPerS = parsed);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: RangeValues(
                      _minToksPerS.clamp(0, 2000),
                      _maxToksPerS.clamp(0, 2000)
                    ),
                    min: 0,
                    max: 2000,
                    divisions: 2000,
                    activeColor: const Color(0xFF7FB3FF),
                    onChanged: (values) {
                      setDialogState(() {
                        _minToksPerS = values.start;
                        _maxToksPerS = values.end;
                        minToksController.text = values.start.round().toString();
                        maxToksController.text = values.end.round().toString();
                      });
                    },
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Slider range: 0-2000. Use text inputs for higher values.',
                    style: TextStyle(color: Colors.white38, fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),

                  // Input cost filter
                  const Text(
                    'Input Cost per 1M Tokens',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minInputCostController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Min \$',
                            labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null && parsed >= 0 && parsed <= 50) {
                              setDialogState(() => _minInputCost = parsed);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('-', style: TextStyle(color: Colors.white54)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: maxInputCostController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Max \$',
                            labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null && parsed >= 0 && parsed <= 50) {
                              setDialogState(() => _maxInputCost = parsed);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: RangeValues(_minInputCost, _maxInputCost),
                    min: 0,
                    max: 50,
                    divisions: 1000,
                    activeColor: const Color(0xFF7FB3FF),
                    onChanged: (values) {
                      setDialogState(() {
                        _minInputCost = values.start;
                        _maxInputCost = values.end;
                        minInputCostController.text = values.start.toStringAsFixed(2);
                        maxInputCostController.text = values.end.toStringAsFixed(2);
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Output cost filter
                  const Text(
                    'Output Cost per 1M Tokens',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minOutputCostController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Min \$',
                            labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null && parsed >= 0 && parsed <= 50) {
                              setDialogState(() => _minOutputCost = parsed);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('-', style: TextStyle(color: Colors.white54)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: maxOutputCostController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Max \$',
                            labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null && parsed >= 0 && parsed <= 50) {
                              setDialogState(() => _maxOutputCost = parsed);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RangeSlider(
                    values: RangeValues(_minOutputCost, _maxOutputCost),
                    min: 0,
                    max: 50,
                    divisions: 1000,
                    activeColor: const Color(0xFF7FB3FF),
                    onChanged: (values) {
                      setDialogState(() {
                        _minOutputCost = values.start;
                        _maxOutputCost = values.end;
                        minOutputCostController.text = values.start.toStringAsFixed(2);
                        maxOutputCostController.text = values.end.toStringAsFixed(2);
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _minToksPerS = 0;
                  _maxToksPerS = 100000;
                  _minInputCost = 0;
                  _maxInputCost = 50;
                  _minOutputCost = 0;
                  _maxOutputCost = 50;
                });
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {}); // Apply filters
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7FB3FF),
                foregroundColor: Colors.black,
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Dispose controllers
      minToksController.dispose();
      maxToksController.dispose();
      minInputCostController.dispose();
      maxInputCostController.dispose();
      minOutputCostController.dispose();
      maxOutputCostController.dispose();
    });
  }

  Widget _buildTable() {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(
        const Color(0xFF1E2027),
      ),
      dataRowColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) {
          return const Color(0xFF1E2027);
        }
        return null;
      }),
      columns: [
        const DataColumn(
          label: SizedBox(width: 20),
        ),
        DataColumn(
          label: InkWell(
            onTap: () => _onSort(null),
            child: Row(
              children: [
                const Text(
                  'Model',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(width: 4),
                Icon(
                  _sortColumn == null
                      ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                      : Icons.unfold_more,
                  size: 16,
                  color: _sortColumn == null ? Colors.white70 : Colors.white24,
                ),
              ],
            ),
          ),
        ),
        const DataColumn(
          label: Text(
            'Cost/1M In',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const DataColumn(
          label: Text(
            'Cost/1M Out',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const DataColumn(
          label: Text(
            'tok/s (estimated)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        ..._datasets.map((dataset) => DataColumn(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        if (_selectedDatasets.contains(dataset)) {
                          _selectedDatasets.remove(dataset);
                        } else {
                          if (!_selectedDatasets.contains(dataset)) {
                            _selectedDatasets.insert(0, dataset); // Insert at beginning (left)
                          }
                        }
                      });
                    },
                    child: Checkbox(
                      value: _selectedDatasets.contains(dataset),
                      onChanged: null, // Disable default behavior
                    ),
                  ),
                  Text(
                    dataset,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onSort(dataset),
                    child: Icon(
                      _sortColumn == dataset
                          ? (_sortAscending ? Icons.arrow_upward : Icons.arrow_downward)
                          : Icons.unfold_more,
                      size: 16,
                      color: _sortColumn == dataset ? Colors.white70 : Colors.white24,
                    ),
                  ),
                ],
              ),
            )),
      ],
      rows: _getSortedEntries().map((entry) {
        final modelName = entry.key;
        final scores = entry.value;

        // Find the cost and latency data for this model
        final modelResult = _results.firstWhere(
          (r) => r.model == modelName,
          orElse: () => _results.first,
        );
        final costLatency = modelResult.costAndLatency;

        return DataRow(
          cells: [
            DataCell(
              Checkbox(
                value: _selectedModels.contains(modelName),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedModels.add(modelName);
                    } else {
                      _selectedModels.remove(modelName);
                    }
                  });
                },
              ),
            ),
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Text(
                  modelName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF9AA2),
                  ),
                ),
              ),
            ),
            // Cost per 1M input tokens
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Text(
                  costLatency?.promptCostPer1M != null
                      ? '\$${costLatency!.promptCostPer1M!.toStringAsFixed(2)}'
                      : '-',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Cost per 1M output tokens
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Text(
                  costLatency?.completionCostPer1M != null
                      ? '\$${costLatency!.completionCostPer1M!.toStringAsFixed(2)}'
                      : '-',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // Latency (tokens per second, end-to-end)
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Text(
                  costLatency?.e2eToksPerS != null
                      ? costLatency!.e2eToksPerS!.round().toString()
                      : '-',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            ..._datasets.map((dataset) {
              final score = scores[dataset];
              return DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text(
                    score != null
                        ? '${(score * 100).toStringAsFixed(1)}%'
                        : '-',
                    style: TextStyle(
                      color: score != null ? _getScoreColor(score) : Colors.white38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.9) return const Color(0xFF7FB3FF); // blue - excellent
    if (score >= 0.7) return const Color(0xFFEEAEEE); // lilac - good
    if (score >= 0.5) return Colors.white70; // white - okay
    return Colors.white38; // dim - poor
  }
}
