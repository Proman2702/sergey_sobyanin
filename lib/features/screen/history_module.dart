import 'package:flutter/material.dart';

class HistoryModule extends StatelessWidget {
  const HistoryModule({
    super.key,
    required this.centerW,
    required this.h,
  });

  final double centerW;
  final double h;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: centerW,
      height: h,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [Text('history')],
      ),
    );
  }
}
