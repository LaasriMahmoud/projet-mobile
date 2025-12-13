import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../core/theme/colors.dart';

class FillGradesScreen extends StatefulWidget {
  final Map<String, dynamic> candidature;

  const FillGradesScreen({Key? key, required this.candidature}) : super(key: key);

  @override
  State<FillGradesScreen> createState() => _FillGradesScreenState();
}

class _FillGradesScreenState extends State<FillGradesScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // List of grades (semester number, year, average)
  final List<Map<String, dynamic>> _grades = [];

  @override
  void initState() {
    super.initState();
    _loadExistingGrades();
  }

  void _loadExistingGrades() {
    final existingGrades = widget.candidature['grades'] as List<dynamic>? ?? [];
    for (var grade in existingGrades) {
      _grades.add({
        'id': grade['id'],
        'semester_number': grade['semester_number'],
        'academic_year': grade['academic_year'] ?? '',
        'average': grade['average']?.toDouble() ?? 0.0,
        'controller_year': TextEditingController(text: grade['academic_year'] ?? ''),
        'controller_average': TextEditingController(
          text: grade['average']?.toString() ?? '',
        ),
      });
    }
  }

  void _addNewSemester() {
    setState(() {
      _grades.add({
        'semester_number': _grades.length + 1,
        'academic_year': '',
        'average': 0.0,
        'controller_year': TextEditingController(),
        'controller_average': TextEditingController(),
      });
    });
  }

  void _removeSemester(int index) async {
    final grade = _grades[index];
    
    // If it's an existing grade (has ID), delete from backend
    if (grade['id'] != null) {
      try {
        await _apiService.deleteCandidatureGrade(grade['id']);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
          );
        }
        return;
      }
    }

    setState(() {
      _grades.removeAt(index);
      // Renumber semesters
      for (int i = 0; i < _grades.length; i++) {
        _grades[i]['semester_number'] = i + 1;
      }
    });
  }

  Future<void> _saveGrades() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final candidatureId = widget.candidature['id'] as int;

      // Save each grade
      for (var grade in _grades) {
        final year = grade['controller_year'].text;
        final averageText = grade['controller_average'].text;
        final average = double.tryParse(averageText) ?? 0.0;

        await _apiService.addCandidatureGrade(
          candidatureId: candidatureId,
          semesterNumber: grade['semester_number'] as int,
          diplomaType: 'licence', // You can make this dynamic if needed
          academicYear: year,
          average: average,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notes enregistrées'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitCandidature() async {
    if (_grades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une note'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Save grades first
    await _saveGrades();

    if (!mounted) return;

    // Then submit
    setState(() => _isLoading = true);

    try {
      final candidatureId = widget.candidature['id'] as int;
      await _apiService.submitCandidatureGrades(candidatureId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Candidature soumise avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remplir les notes'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: UniversityColors.primaryBlue.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.candidature['offre_titre'] ?? 'Offre',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.candidature['nom']} ${widget.candidature['prenom']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Grades list
            Expanded(
              child: _grades.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.grade, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Aucune note ajoutée',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _grades.length,
                      itemBuilder: (context, index) {
                        return _buildGradeCard(index);
                      },
                    ),
            ),

            // Bottom actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _addNewSemester,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un semestre'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveGrades,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Enregistrer'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _submitCandidature,
                      icon: const Icon(Icons.check),
                      label: const Text('Soumettre la candidature'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UniversityColors.successGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeCard(int index) {
    final grade = _grades[index];
    final yearController = grade['controller_year'] as TextEditingController;
    final averageController = grade['controller_average'] as TextEditingController;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Semestre ${grade['semester_number']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeSemester(index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: yearController,
              decoration: const InputDecoration(
                labelText: 'Année académique',
                hintText: '2023-2024',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: averageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Moyenne (/20)',
                border: OutlineInputBorder(),
                suffixText: '/20',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Requis';
                final avg = double.tryParse(value!);
                if (avg == null) return 'Nombre invalide';
                if (avg < 0 || avg > 20) return 'Entre 0 et 20';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var grade in _grades) {
      (grade['controller_year'] as TextEditingController).dispose();
      (grade['controller_average'] as TextEditingController).dispose();
    }
    super.dispose();
  }
}
