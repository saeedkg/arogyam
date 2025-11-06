import 'package:flutter/material.dart';

class DyteMeetingPage extends StatelessWidget {
  final Widget uiKit; // Store the passed UI Kit widget

  const DyteMeetingPage(this.uiKit, {super.key});

  @override
  Widget build(BuildContext context) {
    // Just return the uiKit directly (no .loadUI() needed anymore)
    return Scaffold(
      body: uiKit,
    );
  }
}
