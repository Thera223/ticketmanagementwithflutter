import 'package:flutter/material.dart';
import 'package:gestionticket/widgets/linechartwidget.dart';
import 'package:gestionticket/widgets/piechartwidget.dart';
import 'package:gestionticket/widgets/tickettablewidget.dart';
import 'user.dart';
import 'performance.dart';
import 'rapport.dart';
import 'adhesion.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardContent(),
    UserManagementPage(),
    PerformanceTrackingPage(),
    ReportGenerationPage(),
    MembershipRequestsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Administratif'),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Utilisateurs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                label: Text('Performances'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.description),
                label: Text('Rapports'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.group_add),
                label: Text('Adhésions'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatCard(title: 'Total utilisateurs', value: '89,935'),
            StatCard(title: 'Total Ticket Soumis', value: '23,283.5'),
            StatCard(title: 'Total Ticket Résolu', value: '46,827'),
            StatCard(title: 'Réalisation', value: '124,854'),
          ],
        ),
        const SizedBox(height: 16),
        LineChartWidget(),
        const SizedBox(height: 16),
        PieChartWidget(),
        const SizedBox(height: 16),
        TicketTableWidget(),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
