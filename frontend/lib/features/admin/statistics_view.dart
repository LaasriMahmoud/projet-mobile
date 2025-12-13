import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/colors.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../services/api_service.dart';

class StatisticsView extends StatefulWidget {
  const StatisticsView({Key? key}) : super(key: key);

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  
  Map<String, int> studentsByDiploma = {};
  Map<String, double> averageByDiploma = {};
  int totalStudents = 0;
  int verifiedProfiles = 0;
  double globalAverage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final stats = await _apiService.getStatistics();
      
      setState(() {
        totalStudents = stats['total_students'] ?? 0;
        verifiedProfiles = stats['verified_profiles'] ?? 0;
        
        // Parse students by diploma
        final byDiploma = stats['students_by_diploma'] as Map<String, dynamic>?;
        if (byDiploma != null) {
          studentsByDiploma = byDiploma.map((key, value) => MapEntry(key, value as int));
        }
        
        // Parse average by diploma
        final avgByDiploma = stats['average_by_diploma'] as Map<String, dynamic>?;
        if (avgByDiploma != null) {
          averageByDiploma = avgByDiploma.map((key, value) => MapEntry(key, (value as num).toDouble()));
          
          // Calculate global average
          if (averageByDiploma.isNotEmpty) {
            globalAverage = averageByDiploma.values.reduce((a, b) => a + b) / averageByDiploma.length;
          }
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des statistiques: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStatistics,
              child: Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistiques',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadStatistics,
                tooltip: 'Actualiser',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Summary Cards
          isMobile
              ? Column(
                  children: [
                    _buildSummaryCard('Total Étudiants', totalStudents.toString(), Icons.people, UniversityColors.primaryBlue),
                    const SizedBox(height: 12),
                    _buildSummaryCard('Profils Vérifiés', verifiedProfiles.toString(), Icons.verified_user, UniversityColors.successGreen),
                    const SizedBox(height: 12),
                    _buildSummaryCard('Moyenne Globale', globalAverage > 0 ? '${globalAverage.toStringAsFixed(1)}/20' : 'N/A', Icons.grade, UniversityColors.accentCyan),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: _buildSummaryCard('Total Étudiants', totalStudents.toString(), Icons.people, UniversityColors.primaryBlue)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSummaryCard('Profils Vérifiés', verifiedProfiles.toString(), Icons.verified_user, UniversityColors.successGreen)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSummaryCard('Moyenne Globale', globalAverage > 0 ? '${globalAverage.toStringAsFixed(1)}/20' : 'N/A', Icons.grade, UniversityColors.accentCyan)),
                  ],
                ),

          const SizedBox(height: 32),

          // Charts (only show if we have data)
          if (studentsByDiploma.isNotEmpty || averageByDiploma.isNotEmpty)
            isMobile
                ? Column(
                    children: [
                      if (studentsByDiploma.isNotEmpty) _buildStudentDistributionChart(),
                      if (studentsByDiploma.isNotEmpty && averageByDiploma.isNotEmpty) const SizedBox(height: 24),
                      if (averageByDiploma.isNotEmpty) _buildAverageChart(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (studentsByDiploma.isNotEmpty) Expanded(child: _buildStudentDistributionChart()),
                      if (studentsByDiploma.isNotEmpty && averageByDiploma.isNotEmpty) const SizedBox(width: 24),
                      if (averageByDiploma.isNotEmpty) Expanded(child: _buildAverageChart()),
                    ],
                  )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Aucune donnée disponible pour le moment',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return ModernCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: UniversityColors.mediumGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentDistributionChart() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: UniversityColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Répartition par Diplôme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: UniversityColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxStudents(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final diploma = studentsByDiploma.keys.toList()[groupIndex];
                      return BarTooltipItem(
                        '$diploma\n${rod.toY.toInt()} étudiants',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                        final titles = studentsByDiploma.keys.toList();
                        if (value.toInt() >= 0 && value.toInt() < titles.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              titles[value.toInt()],
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxStudents() > 10 ? 10 : 5,
                ),
                borderData: FlBorderData(show: false),
                barGroups: _getBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAverageChart() {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: UniversityColors.successGreen),
              const SizedBox(width: 8),
              Text(
                'Moyennes par Diplôme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: UniversityColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final diploma = averageByDiploma.keys.toList()[groupIndex];
                      return BarTooltipItem(
                        '$diploma\n${rod.toY.toStringAsFixed(1)}/20',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                        final titles = averageByDiploma.keys.toList();
                        if (value.toInt() >= 0 && value.toInt() < titles.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              titles[value.toInt()],
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                ),
                borderData: FlBorderData(show: false),
                barGroups: _getAverageBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxStudents() {
    if (studentsByDiploma.isEmpty) return 100;
    final max = studentsByDiploma.values.reduce((a, b) => a > b ? a : b);
    return (max / 10).ceil() * 10.0 + 10; // Round up to nearest 10 and add 10
  }

  List<BarChartGroupData> _getBarGroups() {
    final colors = [
      UniversityColors.primaryBlue,
      UniversityColors.accentCyan,
      UniversityColors.successGreen,
      UniversityColors.warningOrange,
      UniversityColors.infoBlue,
    ];

    return studentsByDiploma.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.value.toDouble(),
            color: colors[index % colors.length],
            width: 30,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();
  }

  List<BarChartGroupData> _getAverageBarGroups() {
    final colors = [
      UniversityColors.successGreen,
      UniversityColors.primaryBlue,
      UniversityColors.warningOrange,
      UniversityColors.accentCyan,
      UniversityColors.infoBlue,
    ];

    return averageByDiploma.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.value,
            color: colors[index % colors.length],
            width: 30,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      );
    }).toList();
  }
}
