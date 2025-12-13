import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../core/theme/colors.dart';
import 'fill_grades_screen.dart';

class MyCandidaturesScreen extends StatefulWidget {
  const MyCandidaturesScreen({Key? key}) : super(key: key);

  @override
  State<MyCandidaturesScreen> createState() => _MyCandidaturesScreenState();
}

class _MyCandidaturesScreenState extends State<MyCandidaturesScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _candidatures = [];

  @override
  void initState() {
    super.initState();
    _loadCandidatures();
  }

  Future<void> _loadCandidatures() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final candidatures = await _apiService.getMyCandidaturesWithGrades();

      setState(() {
        _candidatures = candidatures;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'incomplete':
        return UniversityColors.warningOrange;
      case 'submitted':
        return UniversityColors.infoBlue;
      case 'in_review':
        return UniversityColors.accentCyan;
      case 'accepted':
        return UniversityColors.successGreen;
      case 'rejected':
        return UniversityColors.errorRed;
      default:
        return UniversityColors.mediumGray;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'incomplete':
        return 'Incomplète';
      case 'submitted':
        return 'En cours de traitement';
      case 'in_review':
        return 'En révision';
      case 'accepted':
        return '✅ ADMIS';  // Changed to make it more visible
      case 'rejected':
        return '❌ Refusée';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Candidatures'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCandidatures,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _candidatures.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Aucune candidature',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCandidatures,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _candidatures.length,
                        itemBuilder: (context, index) {
                          final candidature = _candidatures[index];
                          return _buildCandidatureCard(candidature);
                        },
                      ),
                    ),
    );
  }

  Widget _buildCandidatureCard(Map<String, dynamic> candidature) {
    final status = candidature['status'] as String? ?? 'unknown';
    final gradesCount = candidature['grades_count'] as int? ?? 0;
    final offreTitre = candidature['offre_titre'] as String? ?? 'Offre inconnue';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offreTitre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${candidature['nom']} ${candidature['prenom']}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.grade, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '$gradesCount semestre(s) rempli(s)',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            if (candidature['commentaire'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.comment, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        candidature['commentaire'],
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (status.toLowerCase() == 'incomplete')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToFillGrades(candidature),
                  icon: const Icon(Icons.edit),
                  label: const Text('Remplir les notes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: UniversityColors.primaryBlue,
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showDetails(candidature),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Voir détails'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToFillGrades(Map<String, dynamic> candidature) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FillGradesScreen(candidature: candidature),
      ),
    );

    if (result == true) {
      _loadCandidatures(); // Refresh
    }
  }

  void _showDetails(Map<String, dynamic> candidature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la candidature'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Offre', candidature['offre_titre'] ?? 'N/A'),
              _buildDetailRow('Statut', _getStatusLabel(candidature['status'] ?? '')),
              _buildDetailRow('Notes', '${candidature['grades_count'] ?? 0} semestre(s)'),
              if (candidature['commentaire'] != null)
                _buildDetailRow('Commentaire', candidature['commentaire']),
              const SizedBox(height: 16),
              const Text('Notes par semestre:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(candidature['grades'] as List? ?? []).map((grade) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('S${grade['semester_number']}: ${grade['average']}/20'),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
