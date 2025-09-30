import 'dart:typed_data';
import 'package:sergey_sobyanin/etc/constants.dart';

import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'dart:math' as math;

import 'package:sergey_sobyanin/etc/colors/gradients/background.dart';
import 'package:sergey_sobyanin/features/error_screen.dart';
import 'package:sergey_sobyanin/features/ui_components/custom_button.dart';

class RedactorDialog extends StatefulWidget {
  const RedactorDialog({super.key, required this.picture, required this.result, required this.updateCallback});
  final updateCallback;
  final Uint8List picture;
  final Map<String, dynamic> result;

  @override
  State<RedactorDialog> createState() => _RedactorDialogState();
}

class _RedactorDialogState extends State<RedactorDialog> {
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

    final frameW = (size.width - 16 * 2).clamp(0.0, double.infinity);
    final frameH = (size.height - 16 * 2).clamp(0.0, double.infinity);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Container(
        width: math.min(1100, frameW),
        height: math.min(600, frameH),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: BackgroundGrad()),
        child: SingleChildScrollView(
          child: SizedBox(
            height: 600,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1100,
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
                              child:
                                  Image.memory(Uint8List.fromList(widget.picture as List<int>), fit: BoxFit.contain)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 450,
                      height: 600,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 15),
                          Text(
                            'Редактирование',
                            style:
                                TextStyle(color: Color(CustomColors.main), fontSize: 28, fontWeight: FontWeight.w600),
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
                                            offset: Offset(0, 4), blurRadius: 4, spreadRadius: 0, color: Colors.black26)
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
                                        ),
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
                                  return SizedBox(
                                    width: 400,
                                    height: 45,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
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
                          CustomButton(
                              onTap: () {
                                widget.updateCallback(newResult);
                                Navigator.pop(context);
                              },
                              text: 'Сохранить',
                              width: 200,
                              height: 45,
                              color: Color(CustomColors.accent))
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
    );
  }
}
