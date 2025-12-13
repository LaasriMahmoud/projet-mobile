import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/offres_provider.dart';
import '../../models/offre.dart';
import '../../core/theme/colors.dart';
import '../../shared/widgets/modern_card.dart';

class OffersView extends StatefulWidget {
  const OffersView({Key? key}) : super(key: key);

  @override
  State<OffersView> createState() => _OffersViewState();
}

class _OffersViewState extends State<OffersView> {
  @override
  void initState() {
    super.initState();
    // Charger les offres au démarrage
    Future.microtask(() => 
      context.read<OffresProvider>().fetchOffres()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<OffresProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: UniversityColors.errorRed),
                  const SizedBox(height: 16),
                  Text('Erreur: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchOffres(),
                    child: const Text('Réessayer'),
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
                      'Gestion des Offres',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddOfferDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter Offre'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: UniversityColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                if (provider.offres.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Icon(
                          Icons.school_outlined,
                          size: 80,
                          color: UniversityColors.mediumGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune offre disponible',
                          style: TextStyle(
                            fontSize: 18,
                            color: UniversityColors.darkGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cliquez sur "Ajouter Offre" pour créer une nouvelle offre',
                          style: TextStyle(
                            color: UniversityColors.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.offres.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final offer = provider.offres[index];
                      return _buildOfferCard(offer);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOfferCard(Offre offer) {
    return ModernCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.titre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: UniversityColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: UniversityColors.accentCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        offer.typeFormation ?? 'Formation',
                        style: const TextStyle(
                          fontSize: 12,
                          color: UniversityColors.accentCyan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: UniversityColors.primaryBlue),
                    onPressed: () => _showEditOfferDialog(context, offer),
                    tooltip: 'Modifier',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: UniversityColors.errorRed),
                    onPressed: () => _confirmDelete(context, offer),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (offer.description != null) ...[
            _buildInfoRow(Icons.description, 'Description', offer.description!),
            const SizedBox(height: 8),
          ],
          if (offer.conditions != null) ...[
            _buildInfoRow(Icons.check_circle, 'Conditions', offer.conditions!),
            const SizedBox(height: 8),
          ],
          if (offer.duree != null)
            _buildInfoRow(Icons.timer, 'Durée', offer.duree!),
          
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: UniversityColors.darkGray),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: UniversityColors.darkGray,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: UniversityColors.darkGray,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddOfferDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const OfferFormDialog(),
    ).then((_) {
      // Recharger la liste après fermeture du dialogue
      context.read<OffresProvider>().fetchOffres();
    });
  }

  void _showEditOfferDialog(BuildContext context, Offre offer) {
    showDialog(
      context: context,
      builder: (context) => OfferFormDialog(existingOffer: offer),
    ).then((_) {
      context.read<OffresProvider>().fetchOffres();
    });
  }

  void _confirmDelete(BuildContext context, Offre offer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer l\'offre "${offer.titre}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<OffresProvider>().deleteOffre(offer.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Offre supprimée'),
                      backgroundColor: UniversityColors.errorRed,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: UniversityColors.errorRed,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: UniversityColors.errorRed,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// Dialog Form needs to be updated too... but let's keep it simple for now
// Just need to update it to use API instead of mocks
class OfferFormDialog extends StatefulWidget {
  final Offre? existingOffer;

  const OfferFormDialog({Key? key, this.existingOffer}) : super(key: key);

  @override
  State<OfferFormDialog> createState() => _OfferFormDialogState();
}

class _OfferFormDialogState extends State<OfferFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titreController;
  late TextEditingController _descriptionController;
  late TextEditingController _conditionsController;
  late TextEditingController _dureeController;
  String _selectedDiplome = 'Licence';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titreController = TextEditingController(text: widget.existingOffer?.titre ?? '');
    _descriptionController = TextEditingController(text: widget.existingOffer?.description ?? '');
    _conditionsController = TextEditingController(text: widget.existingOffer?.conditions ?? '');
    _dureeController = TextEditingController(text: widget.existingOffer?.duree ?? '');
    if (widget.existingOffer?.typeFormation != null) {
      // Simple check to ensure value exists in dropdown items
      final type = widget.existingOffer!.typeFormation!;
      if (['Licence', 'Master', 'DEUST', 'DUT', 'Doctorat'].contains(type)) {
        _selectedDiplome = type;
      }
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _conditionsController.dispose();
    _dureeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingOffer != null;

    return AlertDialog(
      title: Text(isEdit ? 'Modifier l\'offre' : 'Nouvelle offre'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading) const LinearProgressIndicator(),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _titreController,
                  decoration: const InputDecoration(
                    labelText: 'Titre de l\'offre *',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _selectedDiplome,
                  decoration: const InputDecoration(
                    labelText: 'Diplôme *',
                    prefixIcon: Icon(Icons.school),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Licence', child: Text('Licence')),
                    DropdownMenuItem(value: 'Master', child: Text('Master')),
                    DropdownMenuItem(value: 'DEUST', child: Text('DEUST')),
                    DropdownMenuItem(value: 'DUT', child: Text('DUT')),
                    DropdownMenuItem(value: 'Doctorat', child: Text('Doctorat')),
                  ],
                  onChanged: (value) => setState(() => _selectedDiplome = value!),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _conditionsController,
                  decoration: const InputDecoration(
                    labelText: 'Prérequis/Conditions',
                    prefixIcon: Icon(Icons.check_circle),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _dureeController,
                  decoration: const InputDecoration(
                    labelText: 'Durée (ex: 2 ans)',
                    prefixIcon: Icon(Icons.timer),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveOffer,
          style: ElevatedButton.styleFrom(
            backgroundColor: UniversityColors.primaryBlue,
          ),
          child: Text(isEdit ? 'Modifier' : 'Ajouter'),
        ),
      ],
    );
  }

  Future<void> _saveOffer() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final data = {
        'titre': _titreController.text,
        'type_formation': _selectedDiplome,
        'description': _descriptionController.text,
        'conditions': _conditionsController.text,
        'duree': _dureeController.text,
      };

      try {
        if (widget.existingOffer != null) {
          await context.read<OffresProvider>().updateOffre(widget.existingOffer!.id, data);
        } else {
          await context.read<OffresProvider>().createOffre(data);
        }
        
        // Refresh the list immediately after creation
        await context.read<OffresProvider>().fetchOffres();
        
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.existingOffer != null ? 'Offre modifiée avec succès' : 'Offre ajoutée avec succès'),
              backgroundColor: UniversityColors.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e'), backgroundColor: UniversityColors.errorRed),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}
