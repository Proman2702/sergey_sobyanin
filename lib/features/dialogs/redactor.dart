import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:sergey_sobyanin/etc/colors/gradients/background.dart';

class RedactorDialog extends StatefulWidget {
  const RedactorDialog({super.key, required this.picture, required this.result});

  final Uint8List picture;
  final Map<String, dynamic> result;

  @override
  State<RedactorDialog> createState() => _RedactorDialogState();
}

class _RedactorDialogState extends State<RedactorDialog> {
  double targetWidth = 1000;
  double targetHeight = 700;
  double inset = 24;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Размер "вьюпорта" диалога (максимум — экран минус inset)
    final frameW = (size.width - inset * 2).clamp(0.0, double.infinity);
    final frameH = (size.height - inset * 2).clamp(0.0, double.infinity);

    // Собственно диалог
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(inset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          // Диалог как окно просмотра: не больше экрана, не больше target
          width: math.min(targetWidth, frameW),
          height: math.min(targetHeight, frameH),

          // 1) Вертикальный скролл (его ребёнку задаём фиксированную высоту!)
          child: SingleChildScrollView(
            child: SizedBox(
              height: targetHeight, // фикс! вместо SizedBox.expand
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: targetWidth, // фикс!

                  // Ваш «контент» фикс. размера с градиентом
                  child: Container(
                    decoration: BoxDecoration(gradient: BackgroundGrad()),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
