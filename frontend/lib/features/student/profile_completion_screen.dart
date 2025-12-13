import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/colors.dart';
import '../../shared/widgets/modern_card.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controllers
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  
  String? _selectedDiploma;
  DateTime? _dateNaissance;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compléter votre profil'),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              UniversityColors.primaryBlue.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ModernCard(
                child: Form(
                  key: _formKey,
                  child: Stepper(
                    currentStep: _currentStep,
                    onStepContinue: () {
                      if (_currentStep < 3) {
                        if (_validateCurrentStep()) {
                          setState(() => _currentStep++);
                        }
                      } else {
                        _submitProfile();
                      }
                    },
                    onStepCancel: () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                      }
                    },
                    steps: [
                      Step(
                        title: const Text('Informations personnelles'),
                        isActive: _currentStep >= 0,
                        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                        content: Column(
                          children: [
                            TextFormField(
                              controller: _nomController,
                              decoration: const InputDecoration(
                                labelText: 'Nom',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre nom';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _prenomController,
                              decoration: const InputDecoration(
                                labelText: 'Prénom',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Veuillez entrer votre prénom';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2000),
                                  firstDate: DateTime(1950),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() => _dateNaissance = date);
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date de naissance',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _dateNaissance != null
                                      ? '${_dateNaissance!.day}/${_dateNaissance!.month}/${_dateNaissance!.year}'
                                      : 'Sélectionner une date',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _telephoneController,
                              decoration: const InputDecoration(
                                labelText: 'Téléphone',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                            ),
                          ],
                        ),
                      ),
                      Step(
                        title: const Text('Diplôme'),
                        isActive: _currentStep >= 1,
                        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                        content: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _selectedDiploma,
                              decoration: const InputDecoration(
                                labelText: 'Diplôme visé',
                                prefixIcon: Icon(Icons.school),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'licence', child: Text('Licence')),
                                DropdownMenuItem(value: 'master', child: Text('Master')),
                                DropdownMenuItem(value: 'deust', child: Text('DEUST')),
                                DropdownMenuItem(value: 'dut', child: Text('DUT')),
                                DropdownMenuItem(value: 'doctorat', child: Text('Doctorat')),
                              ],
                              onChanged: (value) {
                                setState(() => _selectedDiploma = value);
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Veuillez sélectionner un diplôme';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _adresseController,
                              decoration: const InputDecoration(
                                labelText: 'Adresse',
                                prefixIcon: Icon(Icons.home),
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      Step(
                        title: const Text('Upload Documents'),
                        isActive: _currentStep >= 2,
                        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                        content: Column(
                          children: [
                            _buildUploadButton(
                              'CIN / Carte d\'identité',
                              Icons.badge,
                              () {
                                // TODO: Upload CIN
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Upload CIN - À implémenter')),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildUploadButton(
                              'Baccalauréat',
                              Icons.workspace_premium,
                              () {
                                // TODO: Upload BAC
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Upload BAC - À implémenter')),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildUploadButton(
                              'Relevé de notes',
                              Icons.description,
                              () {
                                // TODO: Upload relevé
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Upload Relevé - À implémenter')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Step(
                        title: const Text('Confirmation'),
                        isActive: _currentStep >= 3,
                        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Résumé de votre profil',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryItem('Nom', _nomController.text),
                            _buildSummaryItem('Prénom', _prenomController.text),
                            _buildSummaryItem('Diplôme', _selectedDiploma ?? 'N/A'),
                            _buildSummaryItem('Téléphone', _telephoneController.text),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: UniversityColors.infoBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info, color: UniversityColors.infoBlue),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Votre profil sera vérifié par l\'administration avant validation.',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton(String label, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          const Icon(Icons.upload_file, size: 20),
        ],
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        minimumSize: const Size(double.infinity, 60),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'Non renseigné' : value),
          ),
        ],
      ),
    );
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (_nomController.text.isEmpty || _prenomController.text.isEmpty || _dateNaissance == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
        );
        return false;
      }
    } else if (_currentStep == 1) {
      if (_selectedDiploma == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un diplôme')),
        );
        return false;
      }
    }
    return true;
  }

  void _submitProfile() {
    // TODO: Implement API call to complete profile
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil soumis ! En attente de vérification...'),
        backgroundColor: UniversityColors.successGreen,
      ),
    );

    // Navigate to home after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }
}
