import 'package:flutter/material.dart';

class PriceAlert extends StatefulWidget {
  final String routeId;
  final double currentPrice;

  const PriceAlert({Key? key, required this.routeId, required this.currentPrice}) : super(key: key);

  @override
  _PriceAlertState createState() => _PriceAlertState();
}

class _PriceAlertState extends State<PriceAlert> {
  double _alertPrice = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Price Alert for ${widget.routeId}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Current Price: \$${widget.currentPrice}'),
          Slider(
            value: _alertPrice,
            min: 0,
            max: widget.currentPrice,
            divisions: 20,
            label: '\$${_alertPrice.round()}',
            onChanged: (value) {
              setState(() {
                _alertPrice = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Set Alert'),
          onPressed: () {
            // TODO: Implement alert setting logic
            Navigator.of(context).pop(_alertPrice);
          },
        ),
      ],
    );
  }
}