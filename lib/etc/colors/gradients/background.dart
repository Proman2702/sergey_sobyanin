import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';

// ignore: must_be_immutable
class BackgroundGrad extends LinearGradient {
  BackgroundGrad()
      : super(
            colors: [Color(CustomColors().getBackgroundGrad[0]), Color(CustomColors().getBackgroundGrad[1])],
            tileMode: TileMode.clamp,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter);
}
