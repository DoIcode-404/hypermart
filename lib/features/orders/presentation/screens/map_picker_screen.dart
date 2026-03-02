/// Map picker screen — Google Maps widget for selecting delivery address.
/// User places pin → reverse geocode → confirm address.
library;

import 'package:flutter/material.dart';

class MapPickerScreen extends StatelessWidget {
  const MapPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Location')),
      body: const Center(child: Text('Map Picker Screen — TODO')),
    );
  }
}
