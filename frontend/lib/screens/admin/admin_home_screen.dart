import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/colors.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/modern_card.dart';
import '../../features/admin/students_view.dart';
import '../../features/admin/offers_view.dart';
import '../../features/admin/statistics_view.dart';
import '../../features/admin/candidatures_view.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    const StudentsView(),
    const OffersView(),
    const AdminCandidaturesView(),
    const StatisticsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Administration'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthProvider>().logout();
                  },
                ),
              ],
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: Container(
                color: UniversityColors.darkNavy,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(
                        color: UniversityColors.primaryBlue,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.school,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Université',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) => Text(
                              auth.currentUser?.username ?? 'Admin',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildDrawerItem(Icons.dashboard, 'Dashboard', 0),
                    _buildDrawerItem(Icons.people, 'Étudiants', 1),
                    _buildDrawerItem(Icons.school, 'Offres', 2),
                    _buildDrawerItem(Icons.assignment, 'Candidatures', 3),
                    _buildDrawerItem(Icons.analytics, 'Statistiques', 4),
                  ],
                ),
              ),
            )
          : null,
      body: Row(
        children: [
          // Sidebar Navigation - Desktop only
          if (!isMobile)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              backgroundColor: UniversityColors.darkNavy,
              selectedIconTheme: const IconThemeData(
                color: UniversityColors.accentCyan,
                size: 28,
              ),
              unselectedIconTheme: IconThemeData(
                color: Colors.white.withOpacity(0.6),
                size: 24,
              ),
              selectedLabelTextStyle: const TextStyle(
                color: UniversityColors.accentCyan,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: Colors.white.withOpacity(0.6),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Étudiants'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.school),
                  selectedIcon: Icon(Icons.school),
                  label: Text('Offres'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment),
                  selectedIcon: Icon(Icons.assignment),
                  label: Text('Candidatures'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics),
                  selectedIcon: Icon(Icons.analytics),
                  label: Text('Statistiques'),
                ),
              ],
            ),

          // Main Content
          Expanded(
            child: Container(
              color: UniversityColors.backgroundLight,
              child: Column(
                children: [
                  // Top App Bar - Desktop only
                  if (!isMobile)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Université - Administration',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: UniversityColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) => Text(
                                  'Bienvenue, ${auth.currentUser?.username ?? "Admin"}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined),
                                onPressed: () {},
                                color: UniversityColors.darkGray,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.settings_outlined),
                                onPressed: () {},
                                color: UniversityColors.darkGray,
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.read<AuthProvider>().logout();
                                },
                                icon: const Icon(Icons.logout, size: 18),
                                label: const Text('Déconnexion'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: UniversityColors.errorRed,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Page Content
                  Expanded(
                    child: _pages[_selectedIndex],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? UniversityColors.accentCyan : Colors.white70,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? UniversityColors.accentCyan : Colors.white70,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: UniversityColors.primaryBlue.withOpacity(0.3),
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context); // Close drawer
      },
    );
  }
}

// Dashboard View with Statistics
class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vue d\'ensemble',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Stats Grid - Responsive
          isMobile
              ? Column(
                  children: [
                    _buildStatCard(
                      context,
                      'Total Étudiants',
                      '150',
                      Icons.people,
                      UniversityColors.primaryBlue,
                      '+12 ce mois',
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      context,
                      'Profils Vérifiés',
                      '120',
                      Icons.verified_user,
                      UniversityColors.successGreen,
                      '80% du total',
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      context,
                      'En Attente',
                      '30',
                      Icons.hourglass_empty,
                      UniversityColors.warningOrange,
                      'À valider',
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      context,
                      'Moyenne Générale',
                      '14.2',
                      Icons.grade,
                      UniversityColors.accentCyan,
                      'Sur 20',
                    ),
                  ],
                )
              : GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.5,
                  children: [
                    StatCard(
                      title: 'Total Étudiants',
                      value: '150',
                      icon: Icons.people,
                      color: UniversityColors.primaryBlue,
                      subtitle: '+12 ce mois',
                    ),
                    StatCard(
                      title: 'Profils Vérifiés',
                      value: '120',
                      icon: Icons.verified_user,
                      color: UniversityColors.successGreen,
                      subtitle: '80% du total',
                    ),
                    StatCard(
                      title: 'En Attente',
                      value: '30',
                      icon: Icons.hourglass_empty,
                      color: UniversityColors.warningOrange,
                      subtitle: 'À valider',
                    ),
                    StatCard(
                      title: 'Moyenne Générale',
                      value: '14.2',
                      icon: Icons.grade,
                      color: UniversityColors.accentCyan,
                      subtitle: 'Sur 20',
                    ),
                  ],
                ),

          const SizedBox(height: 32),

          // Recent Activity
          Text(
            'Activité récente',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dernières inscriptions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: UniversityColors.primaryBlue.withOpacity(0.1),
                        child: const Icon(Icons.person, color: UniversityColors.primaryBlue),
                      ),
                      title: Text(
                        'Étudiant ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text('Inscrit il y a ${index + 1} jour(s)'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: UniversityColors.warningOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'En attente',
                          style: TextStyle(
                            color: UniversityColors.warningOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
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
                    color: UniversityColors.darkGray,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: UniversityColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


