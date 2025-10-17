import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';

// ignore: must_be_immutable
class BackgroundGrad extends RadialGradient {
  BackgroundGrad()
      : super(
            colors: [
              Color(CustomColors().getBackgroundGrad[2]),
              Color(CustomColors().getBackgroundGrad[1]),
              Color(CustomColors().getBackgroundGrad[0])
            ],
            tileMode: TileMode.clamp,
            center: Alignment(0.8, 1),
            stops: <double>[0.0, 0.2, 0.4],
            radius: 2.5);
}
