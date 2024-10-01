import 'package:flutter/material.dart';

class CompareFeature extends StatelessWidget {
  final List<Map<String, dynamic>> busesToCompare;

  const CompareFeature({Key? key, required this.busesToCompare}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Feature')),
          DataColumn(label: Text('Bus 1')),
          DataColumn(label: Text('Bus 2')),
          DataColumn(label: Text('Bus 3')),
        ],
        rows: [
          _buildDataRow('Company', (bus) => bus['company']),
          _buildDataRow('Departure', (bus) => bus['departureTime']),
          _buildDataRow('Arrival', (bus) => bus['arrivalTime']),
          _buildDataRow('Price', (bus) => '\$${bus['price']}'),
          _buildDataRow('Amenities', (bus) => bus['amenities'].join(', ')),
        ],
      ),
    );
  }

  DataRow _buildDataRow(String feature, String Function(Map<String, dynamic>) getValue) {
    return DataRow(
      cells: [
        DataCell(Text(feature)),
        ...busesToCompare.map((bus) => DataCell(Text(getValue(bus)))),
        if (busesToCompare.length < 3)
          ...List.generate(3 - busesToCompare.length, (_) => const DataCell(Text('-'))),
      ],
    );
  }
}