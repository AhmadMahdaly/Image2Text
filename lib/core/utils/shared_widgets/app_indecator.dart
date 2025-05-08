import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AppIndicator extends StatelessWidget {
  const AppIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitSpinningCircle(size: 50, color: Colors.brown.withAlpha(70)),
    );
  }
}
