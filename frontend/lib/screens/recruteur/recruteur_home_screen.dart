import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/offres_provider.dart';

class RecruteurHomeScreen extends StatefulWidget {
  const RecruteurHomeScreen({super.key});

  @override
  State<RecruteurHomeScreen> createState() => _RecruteurHomeScreenState();
}

class _RecruteurHomeScreenState extends State<RecruteurHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OffresProvider>().fetchOffres();
    });
  }

  void _showCreateOffreDialog() {
    final titreController = TextEditingController();
    final descriptionController = TextEditingController();
    final typeFormationController = TextEditingController();
    final dureeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer une offre'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titreController,
                decoration: const InputDecoration(labelText: 'Titre'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: typeFormationController,
                decoration: const InputDecoration(labelText: 'Type de formation'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dureeController,
                decoration: const InputDecoration(labelText: 'Durée'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final offresProvider = context.read<OffresProvider>();
              final success = await offresProvider.createOffre({
                'titre': titreController.text,
                'description': descriptionController.text,
                'type_formation': typeFormationController.text,
                'duree': dureeController.text,
              });
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Offre créée avec succès!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final offresProvider = context.watch<OffresProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Offres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: offresProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : offresProvider.offres.isEmpty
              ? const Center(child: Text('Aucune offre'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: offresProvider.offres.length,
                  itemBuilder: (context, index) {
                    final offre = offresProvider.offres[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(offre.titre),
                        subtitle: Text(offre.status),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                offresProvider.deleteOffre(offre.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateOffreDialog,
        icon: const Icon(Icons.add),
        label: const Text('Créer une offre'),
      ),
    );
  }
}
