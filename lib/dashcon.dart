import 'package:flutter/material.dart';
import 'package:gestionticket/widgets/linechartwidget.dart';
import 'package:gestionticket/widgets/piechartwidget.dart';
import 'package:gestionticket/widgets/tickettablewidget.dart';

class DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Cartes de statistiques
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatCard(
                title: 'Total utilisateurs',
                value: '89,935',
                icon: Icons.people,
                color: Colors.orange),
            StatCard(
                title: 'Total Ticket Soumis',
                value: '23,283',
                icon: Icons.receipt,
                color: Colors.blue),
            StatCard(
                title: 'Total Ticket Résolu',
                value: '46,827',
                icon: Icons.check_circle,
                color: Colors.green),
            StatCard(
                title: 'Réalisation',
                value: '124,854',
                icon: Icons.show_chart,
                color: Colors.purple),
          ],
        ),
        const SizedBox(height: 16),
        // Graphiques
        LineChartWidget(), // Graphique linéaire pour l'analyse
        const SizedBox(height: 16),
        PieChartWidget(), // Graphique circulaire pour l'analyse
        const SizedBox(height: 16),
        // Tableau de reporting
        TicketTableWidget(),
      ],
    );
  }
}

// Widget StatCard amélioré avec icône et animation
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, color: color)),
                const SizedBox(height: 8),
                Text(value,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
