import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../core/theme/colors.dart';

class AdminCandidaturesView extends StatefulWidget {
  const AdminCandidaturesView({Key? key}) : super(key: key);

  @override
  State<AdminCandidaturesView> createState() => _AdminCandidaturesViewState();
}

class _AdminCandidaturesViewState extends State<AdminCandidaturesView> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _candidatures = [];
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadCandidatures();
  }

  Future<void> _loadCandidatures({String? statusFilter}) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
        _selectedFilter = statusFilter;
      });

      final candidatures = await _apiService.getAdminCandidatures(
        statusFilter: statusFilter,
      );

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
        return 'Soumise';
      case 'in_review':
        return 'En révision';
      case 'accepted':
        return 'Acceptée';
      case 'rejected':
        return 'Refusée';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Toutes'),
                selected: _selectedFilter == null,
                 onSelected: (selected) {
                  if (selected) _loadCandidatures();
                },
              ),
              FilterChip(
                label: const Text('Incomplètes'),
                selected: _selectedFilter == 'incomplete',
                onSelected: (selected) {
                  if (selected) _loadCandidatures(statusFilter: 'incomplete');
                },
              ),
              FilterChip(
                label: const Text('Soumises'),
                selected: _selectedFilter == 'submitted',
                onSelected: (selected) {
                  if (selected) _loadCandidatures(statusFilter: 'submitted');
                },
              ),
              FilterChip(
                label: const Text('En révision'),
                selected: _selectedFilter == 'in_review',
                onSelected: (selected) {
                  if (selected) _loadCandidatures(statusFilter: 'in_review');
                },
              ),
              FilterChip(
                label: const Text('Acceptées'),
                selected: _selectedFilter == 'accepted',
                onSelected: (selected) {
                  if (selected) _loadCandidatures(statusFilter: 'accepted');
                },
              ),
              FilterChip(
                label: const Text('Refusées'),
                selected: _selectedFilter == 'rejected',
                onSelected: (selected) {
                  if (selected) _loadCandidatures(statusFilter: 'rejected');
                },
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text('Erreur: $_error'))
                  : _candidatures.isEmpty
                      ? const Center(child: Text('Aucune candidature'))
                      : RefreshIndicator(
                          onRefresh: () => _loadCandidatures(statusFilter: _selectedFilter),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _candidatures.length,
                            itemBuilder: (context, index) {
                              return _buildCandidatureCard(_candidatures[index]);
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildCandidatureCard(Map<String, dynamic> candidature) {
    final status = candidature['status'] as String? ?? 'unknown';
    final nom = candidature['candidat_nom'] ?? '';
    final prenom = candidature['candidat_prenom'] ?? '';
    final offre = candidature['offre_titre'] ?? 'Offre';
    final average = candidature['average_total'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                        '$nom $prenom',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offre,
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
            if (average != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.grade, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Moyenne: ${average.toStringAsFixed(2)}/20',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDetails(candidature),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('Détails'),
                  ),
                ),
                if (status.toLowerCase() == 'submitted' || status.toLowerCase() == 'in_review') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _acceptCandidature(candidature),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Accepter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UniversityColors.successGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectCandidature(candidature),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Refuser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UniversityColors.errorRed,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(Map<String, dynamic> candidature) async {
    try {
      final details = await _apiService.getAdminCandidatureDetails(candidature['id']);
      
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Détails de la candidature'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailSection('Candidat', [
                  _buildDetailRow('Nom', details['candidat']['nom']),
                  _buildDetailRow('Prénom', details['candidat']['prenom']),
                  _buildDetailRow('Email', details['candidat']['email']),
                  if (details['candidat']['telephone'] != null)
                    _buildDetailRow('Téléphone', details['candidat']['telephone']),
                ]),
                const Divider(),
                _buildDetailSection('Offre', [
                  _buildDetailRow('Titre', details['offre']['titre']),
                  _buildDetailRow('Type', details['offre']['type_formation']),
                ]),
                const Divider(),
                _buildDetailSection('Notes', [
                  ...(details['grades'] as List).map((grade) => Text(
                    'S${grade['semester_number']}: ${grade['average']}/20 (${grade['academic_year']})',
                    style: const TextStyle(fontSize: 14),
                  )),
                ]),
                if (details['commentaire'] != null) ...[
                  const Divider(),
                  _buildDetailSection('Commentaire', [
                    Text(details['commentaire']),
                  ]),
                ],
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$label: ${value ?? 'N/A'}'),
    );
  }

  void _acceptCandidature(Map<String, dynamic> candidature) {
    showDialog(
      context: context,
      builder: (context) {
        final commentController = TextEditingController();
        return AlertDialog(
          title: const Text('Accepter la candidature'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Voulez-vous accepter la candidature de ${candidature['candidat_nom']} ?'),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Commentaire (optionnel)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateStatus(
                  candidature['id'],
                  'accepted',
                  commentController.text.isEmpty ? null : commentController.text,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: UniversityColors.successGreen),
              child: const Text('Accepter'),
            ),
          ],
        );
      },
    );
  }

  void _rejectCandidature(Map<String, dynamic> candidature) {
    showDialog(
      context: context,
      builder: (context) {
        final commentController = TextEditingController();
        return AlertDialog(
          title: const Text('Refuser la candidature'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Voulez-vous refuser la candidature de ${candidature['candidat_nom']} ?'),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Raison du refus (recommandé)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateStatus(
                  candidature['id'],
                  'rejected',
                  commentController.text.isEmpty ? null : commentController.text,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: UniversityColors.errorRed),
              child: const Text('Refuser'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStatus(int candidatureId, String newStatus, String? commentaire) async {
    try {
      await _apiService.updateCandidatureStatus(
        candidatureId: candidatureId,
        newStatus: newStatus,
        commentaire: commentaire,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Candidature ${newStatus == 'accepted' ? 'acceptée' : 'refusée'}'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCandidatures(statusFilter: _selectedFilter); // Refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
