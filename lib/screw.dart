import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ScrewWidget extends StatelessWidget {
  final Color color;
  final Color wedgeColor;
  late final double rotationAngle;
  ScrewWidget(
      {this.color = Colors.white,
      this.wedgeColor = Colors.black,
      double? rotationAngle}) {
    this.rotationAngle = rotationAngle ?? (Random.secure().nextDouble() * 360);
  }

  Widget get _wedge {
    double angle = (rotationAngle * pi) / 180;
    return Align(
      alignment: Alignment.center,
      child: FractionallySizedBox(
          heightFactor: 0.15,
          child: Transform.rotate(
            angle: angle,
            child: Container(
                decoration: BoxDecoration(
                    border: Border.symmetric(
                        horizontal: BorderSide(color: wedgeColor)))),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
      _wedge
    ]);
  }
}
