// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'screens/benchmarks_table_screen.dart';

void main() => runApp(const EvalChartsApp());

class EvalChartsApp extends StatelessWidget {
  const EvalChartsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eval Charts',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0E0F12),
        cardTheme: const CardTheme(color: Color(0xFF16181D)),
      ),
      home: const ChartsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  // bool _showBenchmarks = false;

  @override
  Widget build(BuildContext context) {
    // final brandA = const Color(0xFFFF9AA2); // pink
    // final brandB = const Color(0xFFEEAEEE); // lilac
    // final brandC = const Color(0xFF7FB3FF); // blue

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        // Prevent browser back navigation from swipe gestures
      },
      child: Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            'assets/images/logo.jpg',
            fit: BoxFit.contain,
          ),
        ),
        title: const Text(
          'W&B Weave LLM Leaderboard',
          style: TextStyle(
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16),
        //     child: SegmentedButton<bool>(
        //       segments: const [
        //         ButtonSegment(
        //           value: false,
        //           label: Text('Charts'),
        //           icon: Icon(Icons.bar_chart),
        //         ),
        //         ButtonSegment(
        //           value: true,
        //           label: Text('Benchmarks'),
        //           icon: Icon(Icons.table_chart),
        //         ),
        //       ],
        //       selected: {_showBenchmarks},
        //       onSelectionChanged: (Set<bool> selection) {
        //         setState(() {
        //           _showBenchmarks = selection.first;
        //         });
        //       },
        //     ),
        //   ),
        // ],
      ),
      body: const BenchmarksTableScreen(),
      // body: _showBenchmarks
      //     ? const BenchmarksTableScreen()
      //     : ListView(
      //         padding: const EdgeInsets.all(16),
      //         children: [
      //           ChartCard(
      //             title: 'correctness',
      //             yLabel: '',
      //             maxY: 0.55,
      //             groups: _groups(
      //               ['o4', 'sonnet', 'gemini'],
      //               [
      //                 0.500,
      //                 0.367,
      //                 0.333,
      //               ],
      //               [brandA, brandB, brandC],
      //             ),
      //             valueFormat: (v) => v.toStringAsFixed(3),
      //           ),
      //           const SizedBox(height: 16),
      //           ChartCard(
      //             title: 'avg_code_latency',
      //             yLabel: 's',
      //             maxY: 0.22,
      //             groups: _groups(
      //               ['o4', 'sonnet', 'gemini'],
      //               [
      //                 0.081,
      //                 0.198,
      //                 0.164,
      //               ],
      //               [brandA, brandB, brandC],
      //             ),
      //             valueFormat: (v) => v.toStringAsFixed(3),
      //           ),
      //           const SizedBox(height: 16),
      //           ChartCard(
      //             title: 'Total Tokens',
      //             yLabel: '',
      //             maxY: 800000,
      //             groups: _groups(
      //               ['o4', 'sonnet', 'gemini'],
      //               [
      //                 122486,
      //                 41828,
      //                 751486,
      //               ],
      //               [brandA, brandB, brandC],
      //             ),
      //             valueFormat: (v) => v >= 1000
      //                 ? '${(v / 1000).toStringAsFixed(0)}k'
      //                 : v.toStringAsFixed(0),
      //           ),
      //         ],
      //       ),
      ),
    );
  }

  // List<BarChartGroupData> _groups(
  //   List<String> labels,
  //   List<double> values,
  //   List<Color> colors,
  // ) {
  //   // three bars, one per model, shown as one group at x = 0
  //   return [
  //     BarChartGroupData(
  //       x: 0,
  //       barsSpace: 16,
  //       barRods: [
  //         _rod(values[0], colors[0]),
  //         _rod(values[1], colors[1]),
  //         _rod(values[2], colors[2]),
  //       ],
  //       showingTooltipIndicators: const [0, 1, 2],
  //     ),
  //   ];
  // }

  // BarChartRodData _rod(double y, Color c) {
  //   return BarChartRodData(
  //     toY: y,
  //     width: 28,
  //     color: c,
  //     borderRadius: const BorderRadius.only(
  //       topLeft: Radius.circular(6),
  //       topRight: Radius.circular(6),
  //     ),
  //   );
  // }
}

// class ChartCard extends StatelessWidget {
//   const ChartCard({
//     super.key,
//     required this.title,
//     required this.groups,
//     required this.maxY,
//     required this.valueFormat,
//     required this.yLabel,
//   });

//   final String title;
//   final List<BarChartGroupData> groups;
//   final double maxY;
//   final String Function(double) valueFormat;
//   final String yLabel;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 0,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: SizedBox(
//           height: 260,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: Theme.of(context).textTheme.titleMedium),
//               const SizedBox(height: 12),
//               Expanded(
//                 child: BarChart(
//                   BarChartData(
//                     maxY: maxY,
//                     minY: 0,
//                     barGroups: groups,
//                     gridData: FlGridData(
//                       show: true,
//                       getDrawingHorizontalLine: (v) => FlLine(
//                         color: Colors.white12,
//                         strokeWidth: 1,
//                       ),
//                     ),
//                     titlesData: FlTitlesData(
//                       leftTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           reservedSize: 44,
//                           getTitlesWidget: (v, meta) => Text(
//                             yLabel.isEmpty
//                                 ? valueFormat(v)
//                                 : '${valueFormat(v)} $yLabel',
//                             style: const TextStyle(
//                                 color: Colors.white54, fontSize: 11),
//                           ),
//                         ),
//                       ),
//                       rightTitles: const AxisTitles(
//                           sideTitles: SideTitles(showTitles: false)),
//                       topTitles: const AxisTitles(
//                           sideTitles: SideTitles(showTitles: false)),
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           getTitlesWidget: (v, meta) {
//                             // three bars laid out horizontally; label each under its rod
//                             final labels = ['o4', 'sonnet', 'gemini'];
//                             // place labels under the approximate x positions of rods
//                             final idx = {0.0: 0, 1.0: 1, 2.0: 2}[v];
//                             if (idx == null) return const SizedBox.shrink();
//                             return Padding(
//                               padding: const EdgeInsets.only(top: 6),
//                               child: Text(labels[idx],
//                                   style:
//                                       const TextStyle(color: Colors.white70)),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     barTouchData: BarTouchData(
//                       enabled: true,
//                       touchTooltipData: BarTouchTooltipData(
//                         // tooltipBgColor: const Color(0xFF242833),
//                         getTooltipItem: (group, groupIndex, rod, rodIndex) {
//                           final names = ['o4', 'sonnet', 'gemini'];
//                           return BarTooltipItem(
//                             '${names[rodIndex]}\n${valueFormat(rod.toY)}',
//                             const TextStyle(color: Colors.white),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
