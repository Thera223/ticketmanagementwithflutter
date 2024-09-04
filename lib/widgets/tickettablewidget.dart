import 'package:flutter/material.dart';

class TicketTableWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('No')),
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Username')),
        DataColumn(label: Text('Location')),
        DataColumn(label: Text('Categorie')),
        DataColumn(label: Text('Status Ticket')),
        DataColumn(label: Text('Action')),
      ],
      rows: const [
        DataRow(cells: [
          DataCell(Text('1')),
          DataCell(Text('#2564')),
          DataCell(Text('Dec 1, 2021')),
          DataCell(Text('Frank Murlo')),
          DataCell(Text('372 S Winset Ave')),
          DataCell(Text('Pédagogique')),
          DataCell(Text('Résolu')),
          DataCell(Text('...')),
        ]),
        // Ajoutez plus de lignes dynamiquement
      ],
    );
  }
}
