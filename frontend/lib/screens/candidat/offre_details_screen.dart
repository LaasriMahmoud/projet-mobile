import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/offre.dart';
import '../../providers/candidatures_provider.dart';

class OffreDetailsScreen extends StatefulWidget {
  final Offre offre;

  const OffreDetailsScreen({super.key, required this.offre});

  @override
  State<OffreDetailsScreen> createState() => _OffreDetailsScreenState();
}

class _OffreDetailsScreenState extends State<OffreDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _cneController = TextEditingController();
  String _selectedMention = 'Passable';

  File? _cinImage;
  File? _bacImage;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _dateNaissanceController.dispose();
    _telephoneController.dispose();
    _cneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isCin) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isCin) {
          _cinImage = File(pickedFile.path);
        } else {
          _bacImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _submitCandidature() async {
    if (!_formKey.currentState!.validate()) return;

    if (_cinImage == null || _bacImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez uploader les documents CIN et Baccalauréat'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final candidaturesProvider = context.read<CandidaturesProvider>();
    final success = await candidaturesProvider.submitCandidature(
      offreId: widget.offre.id,
      nom: _nomController.text.trim(),
      prenom: _prenomController.text.trim(),
      dateNaissance: _dateNaissanceController.text.trim(),
      telephone: _telephoneController.text.trim(),
      cne: _cneController.text.trim(),
      mention: _selectedMention,
      cinImagePath: _cinImage!.path,
      bacImagePath: _bacImage!.path,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Candidature soumise avec succès!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(candidaturesProvider.error ?? 'Erreur'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'offre'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.offre.titre,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.school, widget.offre.typeFormation ?? 'N/A'),
                    _buildInfoRow(Icons.schedule, widget.offre.duree ?? 'N/A'),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.offre.description),
                    if (widget.offre.conditions != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Conditions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.offre.conditions!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Postuler à cette offre',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _prenomController,
                    decoration: const InputDecoration(
                      labelText: 'Prénom',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateNaissanceController,
                    decoration: const InputDecoration(
                      labelText: 'Date de naissance',
                      border: OutlineInputBorder(),
                      hintText: 'JJ/MM/AAAA',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telephoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cneController,
                    decoration: const InputDecoration(
                      labelText: 'CNE (Code National de l\'Étudiant)',
                      border: OutlineInputBorder(),
                      hintText: 'Ex: K123456789',
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedMention,
                    decoration: const InputDecoration(
                      labelText: 'Mention du Baccalauréat',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Passable', child: Text('Passable')),
                      DropdownMenuItem(value: 'Assez bien', child: Text('Assez bien')),
                      DropdownMenuItem(value: 'Bien', child: Text('Bien')),
                      DropdownMenuItem(value: 'Très bien', child: Text('Très bien')),
                    ],
                    onChanged: (value) => setState(() => _selectedMention = value!),
                    validator: (v) => v == null ? 'Requis' : null,
                  ),
                  const SizedBox(height: 24),
                  _buildImagePicker('CIN', _cinImage, () => _pickImage(true)),
                  const SizedBox(height: 16),
                  _buildImagePicker('Baccalauréat', _bacImage, () => _pickImage(false)),
                  const SizedBox(height: 24),
                  Consumer<CandidaturesProvider>(
                    builder: (context, provider, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _submitCandidature,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: provider.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Soumettre la candidature'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildImagePicker(String label, File? image, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                image != null ? Icons.check_circle : Icons.upload_file,
                color: image != null ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload $label',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      image != null ? 'Fichier sélectionné' : 'Aucun fichier',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
