import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/offres_provider.dart';
import '../../models/offre.dart';
import 'offre_details_screen.dart';

class CandidatHomeScreen extends StatefulWidget {
  const CandidatHomeScreen({super.key});

  @override
  State<CandidatHomeScreen> createState() => _CandidatHomeScreenState();
}

class _CandidatHomeScreenState extends State<CandidatHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OffresProvider>().fetchOffres();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final offresProvider = context.watch<OffresProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offres disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Show profile dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Profil'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${authProvider.currentUser?.email}'),
                      Text('Nom: ${authProvider.currentUser?.username}'),
                      Text('Rôle: ${authProvider.currentUser?.role}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                    TextButton(
                      onPressed: () {
                        authProvider.logout();
                        Navigator.pop(context);
                      },
                      child: const Text('Déconnexion'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => offresProvider.fetchOffres(),
        child: offresProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : offresProvider.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(offresProvider.error!),
                        ElevatedButton(
                          onPressed: () => offresProvider.fetchOffres(),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : offresProvider.offres.isEmpty
                    ? const Center(
                        child: Text('Aucune offre disponible'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: offresProvider.offres.length,
                        itemBuilder: (context, index) {
                          final offre = offresProvider.offres[index];
                          return _OffreCard(offre: offre);
                        },
                      ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Offres',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Mes candidatures',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/candidatures');
          }
        },
      ),
    );
  }
}

class _OffreCard extends StatelessWidget {
  final Offre offre;

  const _OffreCard({required this.offre});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OffreDetailsScreen(offre: offre),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      offre.typeFormation ?? 'Formation',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (offre.duree != null)
                    Text(
                      offre.duree!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                offre.titre,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                offre.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    'Voir les détails',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
