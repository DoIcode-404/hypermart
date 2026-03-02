/// Order tracking map screen — live Google Maps view showing delivery progress.
/// Displays rider marker, route polyline, ETA.
library;

import 'package:flutter/material.dart';

class OrderTrackingMapScreen extends StatelessWidget {
  const OrderTrackingMapScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tracking Order $orderId')),
      body: Center(child: Text('Order Tracking Map: $orderId — TODO')),
    );
  }
}
