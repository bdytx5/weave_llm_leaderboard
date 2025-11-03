import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryCharts extends StatelessWidget {
  final Map<String, Map<String, double>> categoryAverages;
  final Set<String> selectedModels;
  final List<String> selectedDatasets;
  final Map<String, Map<String, double>> tableData;

  const CategoryCharts({
    super.key,
    required this.categoryAverages,
    this.selectedModels = const {},
    this.selectedDatasets = const [],
    required this.tableData,
  });

  static const List<Color> modelColors = [
    Color(0xFFFF9AA2), // pink
    Color(0xFFEEAEEE), // lilac
    Color(0xFF7FB3FF), // blue
    Color(0xFFFFD97D), // yellow
    Color(0xFFB4F8C8), // mint
  ];

  @override
  Widget build(BuildContext context) {
    // If specific datasets are selected, show individual dataset charts
    if (selectedDatasets.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 16, 8),
            child: Text(
              'Dataset Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
          ),
          SizedBox(
            height: 320,
            child: Listener(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: selectedDatasets.map((dataset) {
                      return _buildDatasetChart(dataset);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Otherwise show category averages
    if (categoryAverages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   'Category Performance Overview',
              //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
              //         fontWeight: FontWeight.bold,
              //         color: Colors.white,
              //       ),
              // ),
              // const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: categoryAverages.entries.map((entry) {
                  return _buildCategoryChart(
                    entry.key,
                    entry.value,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChart(String category, Map<String, double> modelScores) {
    if (modelScores.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get sorted model entries for consistent coloring
    var sortedEntries = modelScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Filter based on selected models or show top 5
    if (selectedModels.isNotEmpty) {
      sortedEntries = sortedEntries
          .where((entry) => selectedModels.contains(entry.key))
          .toList();
    } else {
      sortedEntries = sortedEntries.take(5).toList();
    }

    return SizedBox(
      width: 300,
      height: 280,
      child: Card(
        color: const Color(0xFF1E2027),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getCategoryDisplayName(category),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1.0,
                    minY: 0.0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Colors.black87,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final modelName = sortedEntries[group.x.toInt()].key;
                          final score = rod.toY;
                          return BarTooltipItem(
                            '$modelName\n${(score * 100).toStringAsFixed(1)}%',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= sortedEntries.length) {
                              return const SizedBox.shrink();
                            }
                            final modelName = sortedEntries[value.toInt()].key;
                            // Show abbreviated model name
                            final displayName = modelName.length > 12
                                ? '${modelName.substring(0, 10)}...'
                                : modelName;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${(value * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 0.2,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white12,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        left: BorderSide(color: Colors.white24),
                        bottom: BorderSide(color: Colors.white24),
                      ),
                    ),
                    barGroups: sortedEntries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final modelEntry = entry.value;
                      final score = modelEntry.value;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: score,
                            color: modelColors[index % modelColors.length],
                            width: 40,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatasetChart(String dataset) {
    // Get scores for this dataset from all models
    Map<String, double> modelScores = {};
    for (final modelEntry in tableData.entries) {
      final modelName = modelEntry.key;
      final scores = modelEntry.value;
      if (scores.containsKey(dataset)) {
        modelScores[modelName] = scores[dataset]!;
      }
    }

    if (modelScores.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get sorted model entries for consistent coloring
    var sortedEntries = modelScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Filter based on selected models or show top 5
    if (selectedModels.isNotEmpty) {
      sortedEntries = sortedEntries
          .where((entry) => selectedModels.contains(entry.key))
          .toList();
    } else {
      sortedEntries = sortedEntries.take(5).toList();
    }

    if (sortedEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 280,
      height: 280,
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 0,
        color: const Color(0xFF1E2027),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dataset,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 1.0,
                    minY: 0.0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Colors.black87,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final modelName = sortedEntries[group.x.toInt()].key;
                          final score = rod.toY;
                          return BarTooltipItem(
                            '$modelName\n${(score * 100).toStringAsFixed(1)}%',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= sortedEntries.length) {
                              return const SizedBox.shrink();
                            }
                            final modelName = sortedEntries[value.toInt()].key;
                            // Show abbreviated model name
                            final displayName = modelName.length > 12
                                ? '${modelName.substring(0, 10)}...'
                                : modelName;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                displayName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${(value * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 0.2,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white12,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        left: BorderSide(color: Colors.white24),
                        bottom: BorderSide(color: Colors.white24),
                      ),
                    ),
                    barGroups: sortedEntries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final modelEntry = entry.value;
                      final score = modelEntry.value;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: score,
                            color: modelColors[index % modelColors.length],
                            width: 40,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(6),
                              topRight: Radius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'math':
        return 'Mathematics';
      case 'multimodal':
        return 'Multimodal';
      case 'general':
        return 'General Knowledge';
      case 'coding':
        return 'Coding';
      default:
        return category[0].toUpperCase() + category.substring(1);
    }
  }
}
