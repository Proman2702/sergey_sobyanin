import 'dart:developer';
import 'dart:math' as math;

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'package:sergey_sobyanin/etc/colors/gradients/background.dart';
import 'package:sergey_sobyanin/features/blocking_progress.dart';
import 'package:sergey_sobyanin/features/error_screen.dart';
import 'package:sergey_sobyanin/repositories/database/database_service.dart';
import 'package:sergey_sobyanin/repositories/database/models/user.dart';
import 'package:sergey_sobyanin/repositories/image/image_service.dart';
import 'package:sergey_sobyanin/repositories/server/upload_to_server.dart';

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

class ComparePicsDialog extends StatefulWidget {
  const ComparePicsDialog(
      {super.key,
      required this.id,
      required this.pic1,
      required this.pic2,
      required this.result1,
      required this.result2});

  final String id;
  final Uint8List pic1;
  final Uint8List pic2;
  final Map<String, dynamic> result1;
  final Map<String, dynamic> result2;

  @override
  State<ComparePicsDialog> createState() => _ComparePicsDialogState();
}

class _ComparePicsDialogState extends State<ComparePicsDialog> {
  double targetWidth = 1400;
  double targetHeight = 800;
  double inset = 24;

  final database = DatabaseService();

  bool compareCountsEqual(Map<String, dynamic> dict1, Map<String, dynamic> dict2) {
    final allKeys = {...dict1.keys, ...dict2.keys};

    for (final key in allKeys) {
      final count1 = dict1[key]?.length ?? 0;
      final count2 = dict2[key]?.length ?? 0;

      if (count1 != count2) return false;
    }

    return true;
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Завершение сессии',
                          style: TextStyle(color: Color(CustomColors.main), fontSize: 40, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Полученные инструменты',
                                  style: TextStyle(color: Color(CustomColors.main), fontSize: 18),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  width: 650,
                                  height: 500,
                                  decoration: BoxDecoration(
                                      color: Color(CustomColors.shadow), borderRadius: BorderRadius.circular(15)),
                                  child: InteractiveViewer(
                                    child:
                                        Image.memory(Uint8List.fromList(widget.pic1 as List<int>), fit: BoxFit.contain),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(width: 50),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Сданные инструменты',
                                  style: TextStyle(color: Color(CustomColors.main), fontSize: 18),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  width: 650,
                                  height: 500,
                                  decoration: BoxDecoration(
                                      color: Color(CustomColors.shadow), borderRadius: BorderRadius.circular(15)),
                                  child: InteractiveViewer(
                                    child:
                                        Image.memory(Uint8List.fromList(widget.pic2 as List<int>), fit: BoxFit.contain),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        SizedBox(
                          width: 1350,
                          child: Text(
                            'Нажмите на картинки, чтобы увидеть список инструментов',
                            style: TextStyle(color: Colors.black38, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(height: 20),
                        compareCountsEqual(widget.result1, widget.result2)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Color(CustomColors.main),
                                    size: 25,
                                  ),
                                  SizedBox(width: 20),
                                  Text(
                                    'Выданные инструменты совпадают со сданными',
                                    style: TextStyle(color: Color(CustomColors.main), fontSize: 24),
                                  )
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cancel_outlined,
                                    color: Color(CustomColors.main),
                                    size: 25,
                                  ),
                                  SizedBox(width: 20),
                                  Text(
                                    'Инструменты не совпадают!',
                                    style: TextStyle(color: Color(CustomColors.main), fontSize: 24),
                                  )
                                ],
                              ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.transparent,
                              child: //InkWell(
                                  GestureDetector(
                                onTap: () {
                                  setState(() {});
                                },
                                //borderRadius: BorderRadius.circular(15),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: Color(CustomColors.shadow),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                      width: 220,
                                      height: 50,
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Недосдача',
                                        style: TextStyle(
                                            fontSize: 25, color: Color(CustomColors.main), fontWeight: FontWeight.w600),
                                      )),
                                ),
                              ),
                            ),
                            SizedBox(width: 50),
                            Material(
                              elevation: 5,
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(15),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: Color(CustomColors.accent),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                      width: 220,
                                      height: 50,
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Готово',
                                        style: TextStyle(
                                            fontSize: 25, color: Color(CustomColors.main), fontWeight: FontWeight.w600),
                                      )),
                                ),
                              ),
                            )
                          ],
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
