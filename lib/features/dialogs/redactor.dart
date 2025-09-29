import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'dart:math' as math;

import 'package:sergey_sobyanin/etc/colors/gradients/background.dart';

const Map<String, String> INSTRUMENTS = {
  'screwdriver -': 'Отвертка "-"',
  'screwdriver +': 'Отвертка "+"',
  'screwdriver x': 'Отвертка на смещенный крест',
  'kolovorot': 'Коловорот',
  'passatizi kontro': 'Пассатижи контровочные',
  'passatizi': 'Пассатижи',
  'shernitsa': 'Шэрница',
  'razvodnoy kluch': 'Разводной ключ',
  'otkruvashka': 'Открывашка для банок с маслом',
  'kluch rozkov': 'Ключ рожковый/накидной ¾',
  'bokorezu': 'Бокорезы',
};

class RedactorDialog extends StatefulWidget {
  const RedactorDialog({super.key, required this.picture, required this.result, required this.updateCallback});

  final updateCallback;
  final Uint8List picture;
  final Map<String, dynamic> result;

  @override
  State<RedactorDialog> createState() => _RedactorDialogState();
}

class _RedactorDialogState extends State<RedactorDialog> {
  double targetWidth = 1100;
  double targetHeight = 600;
  double inset = 24;

  late Map<String, dynamic> newResult;

  List parseToDisplay(Map<String, dynamic> result) {
    List items = result.entries.toList();
    return items;
  }

  @override
  void initState() {
    newResult = widget.result;
    super.initState();
  }

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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 650,
                          height: 650,
                          decoration:
                              BoxDecoration(color: Color(CustomColors.shadow), borderRadius: BorderRadius.circular(15)),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 650, maxHeight: 600),
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                              child: InteractiveViewer(
                                  child: Image.memory(Uint8List.fromList(widget.picture as List<int>),
                                      fit: BoxFit.contain)),
                            ),
                          ),
                        ),
                        Container(
                          width: 450,
                          height: 600,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('Редактирование'),
                              Container(
                                  width: 450,
                                  height: 500,
                                  alignment: Alignment.topCenter,
                                  child: GridView.count(
                                    crossAxisCount: 1,
                                    crossAxisSpacing: 12, // меньше отступы между плитками
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 400 / 60, // ширина / высота (пример: 400х60)
                                    shrinkWrap: true,
                                    children: parseToDisplay(newResult).map((entry) {
                                      final name = INSTRUMENTS[entry.key]!;
                                      final count = entry.value.length;

                                      return Container(
                                        width: 400,
                                        height: 60,
                                        child: Row(
                                          children: [
                                            // минус
                                            SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  shape: const CircleBorder(),
                                                  backgroundColor: Color(CustomColors.accent),
                                                ),
                                                onPressed: () {
                                                  newResult[entry.key] = newResult[entry.key].removeLast();

                                                  //if (newResult[entry.key].isEmpty) {
                                                  //newResult.remove(entry.key);
                                                  //}
                                                  //;
                                                  setState(() {});
                                                },
                                                child: Icon(Icons.remove, size: 18, color: Color(CustomColors.main)),
                                              ),
                                            ),

                                            const SizedBox(width: 20),

                                            // центральный контейнер (300 px)
                                            Container(
                                              width: 300,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                color: Colors.white,
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      name,
                                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Color(CustomColors.darkAccent),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      "$count шт.",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 20),

                                            // плюс
                                            SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  shape: const CircleBorder(),
                                                  backgroundColor: Color(CustomColors.accent),
                                                ),
                                                onPressed: () {},
                                                child: Icon(Icons.add, size: 18, color: Color(CustomColors.main)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ))
                            ],
                          ),
                        )
                      ],
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
