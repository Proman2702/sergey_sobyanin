import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'dart:math' as math;

import 'package:sergey_sobyanin/etc/colors/gradients/background.dart';
import 'package:sergey_sobyanin/features/error_screen.dart';

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

const Map<int, String> INSTRUMENTS_INDEXED = {
  0: 'screwdriver -',
  1: 'screwdriver +',
  2: 'screwdriver x',
  3: 'kolovorot',
  4: 'passatizi kontro',
  5: 'passatizi',
  6: 'shernitsa',
  7: 'razvodnoy kluch',
  8: 'otkruvashka',
  9: 'kluch rozkov',
  10: 'bokorezu'
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

  final _controller = TextEditingController();
  String filter = '';

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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, dynamic> filteredResult(String filter) => Map.fromEntries(
      newResult.entries.where((e) => INSTRUMENTS[e.key].toString().toLowerCase().startsWith(filter.toLowerCase())));

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
                              SizedBox(height: 15),
                              Text(
                                'Редактирование',
                                style: TextStyle(
                                    color: Color(CustomColors.main), fontSize: 28, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 15),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      width: 320,
                                      height: 40,
                                      alignment: Alignment.centerLeft,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                                offset: Offset(0, 4),
                                                blurRadius: 4,
                                                spreadRadius: 0,
                                                color: Colors.black26)
                                          ]),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 40,
                                            width: 40,
                                            alignment: Alignment.centerRight,
                                            child: Icon(
                                              Icons.search,
                                              color: Color(CustomColors.bright),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 280,
                                            height: 40,
                                            child: TextField(
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black87),
                                              maxLength: 16,
                                              onChanged: (value) => setState(() {
                                                filter = value;
                                              }),
                                              decoration: InputDecoration(
                                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                                contentPadding: EdgeInsets.only(left: 10, bottom: 20),
                                                counterText: "",
                                                border: InputBorder.none,
                                                labelText: "Фильтр",
                                                labelStyle: TextStyle(
                                                    color: Colors.black12, fontSize: 16, fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                  SizedBox(width: 20),
                                  SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: PopupMenuButton<String>(
                                          onSelected: (value) {
                                            if (newResult.keys.contains(value)) {
                                              ErrorNotifier.show('Такой инструмент уже существует');
                                            } else {
                                              newResult.addAll({
                                                value: [1.0]
                                              });
                                            }

                                            setState(() {});
                                          },
                                          itemBuilder: (context) => INSTRUMENTS_INDEXED.values
                                              .map((name) => PopupMenuItem(
                                                    value: name,
                                                    child: Text(INSTRUMENTS[name]!),
                                                  ))
                                              .toList(),
                                          child: FloatingActionButton(
                                            backgroundColor: Color(CustomColors.accent),
                                            onPressed: null,
                                            child: Icon(
                                              Icons.edit_document,
                                              color: Color(CustomColors.main),
                                            ), // кнопку сам PopupMenuButton обрабатывает
                                          )))
                                ],
                              ),
                              SizedBox(height: 15),
                              Container(
                                  width: 450,
                                  height: 400,
                                  alignment: Alignment.topCenter,
                                  child: GridView.count(
                                    crossAxisCount: 1,
                                    crossAxisSpacing: 2,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 400 / 60,
                                    shrinkWrap: true,
                                    children: parseToDisplay(filteredResult(filter)).map((entry) {
                                      final name = INSTRUMENTS[entry.key]!;
                                      final count = entry.value.length;

                                      return Container(
                                        width: 400,
                                        height: 45,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
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
                                                  newResult[entry.key].removeLast();

                                                  if (newResult[entry.key].isEmpty) {
                                                    newResult.remove(entry.key);
                                                  }

                                                  setState(() {});
                                                },
                                                child: Icon(Icons.remove, size: 20, color: Color(CustomColors.main)),
                                              ),
                                            ),

                                            const SizedBox(width: 15),

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
                                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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

                                            const SizedBox(width: 15),

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
                                                onPressed: () {
                                                  newResult[entry.key].add(1.0);

                                                  setState(() {});
                                                },
                                                child: Icon(Icons.add, size: 20, color: Color(CustomColors.main)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  )),
                              const SizedBox(height: 15),
                              Material(
                                elevation: 5,
                                borderRadius: BorderRadius.circular(15),

                                color: Colors.transparent, // нужен Material-предок для волны
                                child: InkWell(
                                  onTap: () {
                                    widget.updateCallback(newResult);
                                    Navigator.pop(context);
                                  },
                                  borderRadius: BorderRadius.circular(15),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: Color(CustomColors.accent),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Container(
                                        width: 200,
                                        height: 45,
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Сохранить',
                                          style:
                                              TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
                                        )),
                                  ),
                                ),
                              )
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
