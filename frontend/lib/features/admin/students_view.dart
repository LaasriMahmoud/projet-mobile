import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../shared/widgets/modern_card.dart';
import '../../../services/api_service.dart';

class StudentsView extends StatefulWidget {
  const StudentsView({Key? key}) : super(key: key);

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  final ApiService _apiService = ApiService();
  String? _selectedDiploma;
  String? _selectedStatus;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final students = await _apiService.getStudents(
        diploma: _selectedDiploma,
        profileStatus: _selectedStatus,
      );

      setState(() {
        _students = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des étudiants: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredStudents {
    return _students.where((student) {
      if (_selectedDiploma != null && student['current_diploma'] != _selectedDiploma) {
        return false;
      }
      if (_selectedStatus != null && student['profile_status'] != _selectedStatus) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestion des Étudiants',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadStudents,
                tooltip: 'Actualiser',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtres',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: _selectedDiploma,
                        decoration: const InputDecoration(
                          labelText: 'Diplôme',
                          prefixIcon: Icon(Icons.school),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tous')),
                          DropdownMenuItem(value: 'Licence', child: Text('Licence')),
                          DropdownMenuItem(value: 'Master', child: Text('Master')),
                          DropdownMenuItem(value: 'DEUST', child: Text('DEUST')),
                          DropdownMenuItem(value: 'DUT', child: Text('DUT')),
                          DropdownMenuItem(value: 'Doctorat', child: Text('Doctorat')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedDiploma = value);
                          _loadStudents();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Statut',
                          prefixIcon: Icon(Icons.check_circle),
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tous')),
                          DropdownMenuItem(value: 'verified', child: Text('Vérifié')),
                          DropdownMenuItem(value: 'pending', child: Text('En attente')),
                          DropdownMenuItem(value: 'rejected', child: Text('Rejeté')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedStatus = value);
                          _loadStudents();
                        },
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedDiploma = null;
                          _selectedStatus = null;
                        });
                        _loadStudents();
                      },
                      icon: const Icon(Icons.clear),
                      label: const Text('Réinitialiser'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Students Table
          ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isLoading 
                          ? 'Chargement...' 
                          : '${_filteredStudents.length} étudiant(s)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 8),
                        Text(_error!, style: TextStyle(color: Colors.red)),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadStudents,
                          child: Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                else if (_filteredStudents.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Aucun étudiant trouvé',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Nom')),
                        DataColumn(label: Text('Prénom')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Diplôme')),
                        DataColumn(label: Text('Moyenne')),
                        DataColumn(label: Text('Semestres')),
                        DataColumn(label: Text('Statut')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _filteredStudents.map((student) {
                        return DataRow(cells: [
                          DataCell(Text(student['nom'] ?? 'N/A')),
                          DataCell(Text(student['prenom'] ?? 'N/A')),
                          DataCell(Text(student['email'] ?? 'N/A')),
                          DataCell(
                            Chip(
                              label: Text(student['current_diploma'] ?? 'N/A'),
                              backgroundColor: UniversityColors.primaryBlue.withOpacity(0.1),
                              labelStyle: const TextStyle(
                                color: UniversityColors.primaryBlue,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                const Icon(Icons.grade, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  student['global_average'] != null
                                      ? student['global_average'].toStringAsFixed(2)
                                      : 'N/A',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(student['total_semesters']?.toString() ?? '0'),
                          ),
                          DataCell(_buildStatusChip(student['profile_status'] ?? 'unknown')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility, size: 20),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Détails de ${student['nom']} ${student['prenom']}'),
                                      ),
                                    );
                                  },
                                  tooltip: 'Voir détails',
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status.toLowerCase()) {
      case 'verified':
        color = UniversityColors.successGreen;
        label = 'Vérifié';
        break;
      case 'pending':
        color = UniversityColors.warningOrange;
        label = 'En attente';
        break;
      case 'rejected':
        color = UniversityColors.errorRed;
        label = 'Rejeté';
        break;
      default:
        color = UniversityColors.mediumGray;
        label = 'Inconnu';
    }

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
