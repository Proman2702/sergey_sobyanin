import 'dart:convert';
import 'dart:math' as math;
import 'dart:html' as html;
import 'package:sergey_sobyanin/etc/constants.dart';

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'package:sergey_sobyanin/etc/colors/gradients/background.dart';
import 'package:sergey_sobyanin/features/dialogs/change_confirmation.dart';
import 'package:sergey_sobyanin/features/error_screen.dart';
import 'package:sergey_sobyanin/features/ui_components/custom_button.dart';
import 'package:sergey_sobyanin/repositories/database/database_service.dart';
import 'package:sergey_sobyanin/repositories/database/models/history_tile.dart';

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
  bool visible1 = true;
  bool visible2 = true;

  bool boolResult = false;
  bool allowChangeResult = false;
  bool allowChangeResultButton = false;

  @override
  void initState() {
    boolResult = compareCountsEqual(widget.result1, widget.result2);
    allowChangeResult = !compareCountsEqual(widget.result1, widget.result2);
    super.initState();
  }

  void changeResultCallback() {
    allowChangeResultButton = true;
    setState(() {});
  }

  final database = UserDatabaseService();
  final historyDatabase = HistoryDatabaseService();

  Map<String, int> missingItems(Map<String, dynamic> dict1, Map<String, dynamic> dict2) {
    final result = <String, int>{};

    dict1.forEach((key, values) {
      final need = values.length;
      final have = dict2[key]?.length ?? 0;
      if (need > have) {
        result[key] = need - have;
      }
    });

    return result;
  }

  bool compareCountsEqual(Map<String, dynamic> dict1, Map<String, dynamic> dict2) {
    final allKeys = {...dict1.keys, ...dict2.keys};

    for (final key in allKeys) {
      final count1 = dict1[key]?.length ?? 0;
      final count2 = dict2[key]?.length ?? 0;

      if (count1 != count2) return false;
    }

    return true;
  }

  List<Map<String, dynamic>> convertToJsonList(Map<String, dynamic> input) {
    final List<Map<String, dynamic>> result = [];

    input.forEach((name, confList) {
      // ищем id по имени в INSTRUMENTS_INDEXED
      final entry =
          INSTRUMENTS_INDEXED.entries.firstWhere((e) => e.value == name, orElse: () => const MapEntry(-1, ''));

      if (entry.key == -1) return; // если имя не найдено — пропускаем

      for (final conf in confList) {
        result.add({
          "id": entry.key,
          "name": entry.value,
          "conf": double.parse(conf.toStringAsFixed(4)),
        });
      }
    });

    return result;
  }

  void downloadJsonResult(String filename, Map<String, dynamic> data1, Map<String, dynamic> data2) {
    final jsonList1 = convertToJsonList(data1);
    final jsonList2 = convertToJsonList(data2);

    final jsonListFinal = {'instruments_got': jsonList1, 'instruments_handed_over': jsonList2, 'result': boolResult};

    final encoder = const JsonEncoder.withIndent('  '); // pretty JSON
    final jsonStr = encoder.convert(jsonListFinal);

    final bytes = utf8.encode(jsonStr);
    final blob = html.Blob([bytes], 'application/json;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..download = filename
      ..style.display = 'none';

    html.document.body!.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final frameW = (size.width - 16 * 2).clamp(0.0, double.infinity);
    final frameH = (size.height - 16 * 2).clamp(0.0, double.infinity);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Container(
        width: math.min(1400, frameW),
        height: math.min(800, frameH),
        decoration: BoxDecoration(
          gradient: BackgroundGrad(),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            height: 800,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1400,
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
                            SizedBox(
                              height: 30,
                              width: 650,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Полученные инструменты',
                                    style: TextStyle(color: Color(CustomColors.main), fontSize: 18),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        visible1 = !visible1;
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        visible1 ? Icons.visibility : Icons.visibility_off,
                                        color: Color(CustomColors.main),
                                      ))
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: 650,
                              height: 500,
                              decoration: BoxDecoration(
                                  color: Color(CustomColors.shadow), borderRadius: BorderRadius.circular(15)),
                              child: visible1
                                  ? InteractiveViewer(
                                      child: Image.memory(Uint8List.fromList(widget.pic1 as List<int>),
                                          fit: BoxFit.contain))
                                  : SingleChildScrollView(
                                      child: Container(
                                        width: 200,
                                        height: 500,
                                        decoration: BoxDecoration(
                                          color: Color(CustomColors.main),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: ListView.builder(
                                            padding: const EdgeInsets.all(8),
                                            itemCount: widget.result1.keys.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              return Text(
                                                  "${INSTRUMENTS[widget.result1.keys.toList()[index]]} - ${widget.result1[widget.result1.keys.toList()[index]].length} шт.",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Color(CustomColors.bright),
                                                      fontWeight: FontWeight.w800));
                                            }),
                                      ),
                                    ),
                            )
                          ],
                        ),
                        SizedBox(width: 50),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 30,
                              width: 650,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Полученные инструменты',
                                    style: TextStyle(color: Color(CustomColors.main), fontSize: 18),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        visible2 = !visible2;
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        visible2 ? Icons.visibility : Icons.visibility_off,
                                        color: Color(CustomColors.main),
                                      ))
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: 650,
                              height: 500,
                              decoration: BoxDecoration(
                                  color: Color(CustomColors.shadow), borderRadius: BorderRadius.circular(15)),
                              child: visible2
                                  ? InteractiveViewer(
                                      child: Image.memory(Uint8List.fromList(widget.pic2 as List<int>),
                                          fit: BoxFit.contain))
                                  : SingleChildScrollView(
                                      child: Container(
                                        width: 200,
                                        height: 500,
                                        decoration: BoxDecoration(
                                          color: Color(CustomColors.main),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: ListView.builder(
                                            padding: const EdgeInsets.all(8),
                                            itemCount: widget.result2.keys.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              return Text(
                                                  "${INSTRUMENTS[widget.result2.keys.toList()[index]]} - ${widget.result2[widget.result2.keys.toList()[index]].length} шт.",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Color(CustomColors.bright),
                                                      fontWeight: FontWeight.w800));
                                            }),
                                      ),
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
                        'Нажмите на глазик сверху над картинкой, чтобы увидеть список инструментов',
                        style: TextStyle(color: Colors.black38, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(height: 20),
                    boolResult
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
                              ),
                              SizedBox(width: 15),
                              allowChangeResultButton
                                  ? IconButton(
                                      color: Colors.black26,
                                      onPressed: () {
                                        boolResult = !boolResult;
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.refresh,
                                        color: Color(CustomColors.main),
                                      ))
                                  : SizedBox()
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
                              ),
                              SizedBox(width: 15),
                              allowChangeResultButton
                                  ? IconButton(
                                      color: Colors.black26,
                                      onPressed: () {
                                        boolResult = !boolResult;
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.refresh,
                                        color: Color(CustomColors.main),
                                      ))
                                  : SizedBox()
                            ],
                          ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButtonModified(
                          width: 80,
                          height: 50,
                          color: Color(CustomColors.accent),
                          onTap: () async {
                            downloadJsonResult('exported_overall.json', widget.result1, widget.result2);
                          },
                          child: Row(
                            children: [
                              SizedBox(width: 5),
                              Icon(
                                Icons.save_outlined,
                                color: Color(CustomColors.main),
                                size: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Text(
                                  'JSON',
                                  style: TextStyle(
                                      color: Color(CustomColors.main), fontSize: 12, fontWeight: FontWeight.w800),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 30),
                        CustomButton(
                          onTap: () {
                            if (allowChangeResult) {
                              showDialog(
                                  context: context,
                                  builder: (context) => ChangeConfirmationDialog(callback: changeResultCallback));
                            } else {
                              ErrorNotifier.show('Инструменты и так совпадают!');
                            }
                          },
                          text: 'Недосдача',
                          width: 220,
                          height: 50,
                          color: allowChangeResult ? Color(CustomColors.accent) : Color(CustomColors.shadow),
                          fontSize: 25,
                        ),
                        SizedBox(width: 30),
                        CustomButton(
                          onTap: () async {
                            await database.deleteElement(widget.id);

                            final time = DateTime.now().toIso8601String();

                            await historyDatabase.upsertElement(HistoryTile(
                                id: widget.id,
                                personId: widget.id,
                                time: time,
                                result: boolResult.toString(),
                                missing: boolResult ? {} : missingItems(widget.result1, widget.result2)));

                            Navigator.pop(context);
                          },
                          text: 'Готово',
                          width: 220,
                          height: 50,
                          color: Color(CustomColors.accent),
                          fontSize: 25,
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
    );
  }
}
