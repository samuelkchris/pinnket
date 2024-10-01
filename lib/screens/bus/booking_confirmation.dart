import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String busCompany;
  final String from;
  final String to;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final double price;
  final List<int> selectedSeats;

  const BookingConfirmationScreen({
    Key? key,
    required this.busCompany,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.selectedSeats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Confirmation'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking Details', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 16),
            _buildDetailItem('Bus Company', busCompany),
            _buildDetailItem('From', from),
            _buildDetailItem('To', to),
            _buildDetailItem('Departure', departureTime.toString()),
            _buildDetailItem('Arrival', arrivalTime.toString()),
            _buildDetailItem('Seats', selectedSeats.join(', ')),
            _buildDetailItem('Total Price', '\$${price * selectedSeats.length}'),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Implement booking logic here
                // Then navigate back to the home screen
                context.go('/');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('Confirm Booking'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}