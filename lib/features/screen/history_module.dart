import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'package:sergey_sobyanin/etc/constants.dart';
import 'package:sergey_sobyanin/features/settings/hint.dart';
import 'package:sergey_sobyanin/repositories/database/database_service.dart';
import 'package:sergey_sobyanin/repositories/database/models/history_tile.dart';

class HistoryModule extends StatefulWidget {
  const HistoryModule({
    super.key,
    required this.centerW,
    required this.h,
  });

  final double centerW;
  final double h;

  @override
  State<HistoryModule> createState() => _HistoryModuleState();
}

class _HistoryModuleState extends State<HistoryModule> {
  List<HistoryTile> filterByID(List<HistoryTile> list) {
    return list.where((e) => e.id.startsWith(filter)).toList();
  }

  List<HistoryTile> filterByDate(List<HistoryTile> list) {
    return list
        .where((e) => (DateTime.parse(e.time).isBefore(dateFinish) && DateTime.parse(e.time).isAfter(dateStart)))
        .toList();
  }

  Future<void> pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: dateStart,
        end: dateFinish,
      ),
      helpText: 'Выберите диапазон дат истории',
      cancelText: 'Отмена',
      confirmText: 'ОК',
      useRootNavigator: false,
      builder: (context, child) {
        return Center(
          child: SizedBox(
            width: 400,
            height: 500,
            child: child,
          ),
        );
      },
    );

    if (picked != null) {
      dateStart = picked.start;
      dateFinish = picked.end;
    }
  }

  String filter = '';
  DateTime dateStart = DateTime.now().subtract(const Duration(days: 30));
  DateTime dateFinish = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.centerW,
      height: widget.h,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Container(
                  width: 280,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(offset: Offset(0, 4), blurRadius: 4, color: Colors.black26)]),
                  child: TextField(
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black87),
                    maxLength: 16,
                    onChanged: (value) => setState(() {
                      filter = value;
                    }),
                    decoration: InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      contentPadding: EdgeInsets.only(left: 10, bottom: 20),
                      counterText: "",
                      border: InputBorder.none,
                      labelText: "Фильтр по id",
                      labelStyle: TextStyle(color: Colors.black12, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20),
              Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(offset: Offset(0, 4), blurRadius: 4, color: Colors.black26)]),
                  child: IconButton(
                    onPressed: () async {
                      await pickDateRange(context);
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.calendar_month,
                      color: Color(CustomColors.bright),
                    ),
                  )),
              SizedBox(width: 20),
              Text(
                'Показано с ${dateStart.toString().split(' ')[0]} до ${dateFinish.toString().split(' ')[0]}',
                style: TextStyle(color: Color(CustomColors.main), fontWeight: FontWeight.w600),
              )
            ],
          ),
          SizedBox(height: 16),
          SingleChildScrollView(
            child: SizedBox(
              height: widget.h - 100,
              width: widget.centerW,
              child: FutureBuilder(
                future: HistoryDatabaseService().getElements(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Ошибка: ${snapshot.error}'));
                  }

                  List<HistoryTile> elements = snapshot.data ?? [];
                  elements = filterByID(elements).reversed.toList();
                  elements = filterByDate(elements);

                  return ListView.builder(
                    itemCount: elements.length,
                    itemBuilder: (context, index) {
                      final element = elements[index];
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                            width: widget.centerW,
                            height: 90,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: BoxDecoration(
                                color: Color(CustomColors.main),
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [BoxShadow(offset: Offset(0, 4), blurRadius: 4, color: Colors.black26)]),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ID инженера',
                                        style: TextStyle(
                                            color: Color(CustomColors.accent),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        element.id,
                                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  width: 2,
                                  color: Color(CustomColors.shadow),
                                ),
                                SizedBox(width: 50),
                                SizedBox(
                                  width: 300,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Комментарий',
                                        style: TextStyle(
                                            color: Color(CustomColors.accent),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(height: 10),
                                      element.result == 'false'
                                          ? Row(
                                              children: [
                                                Text(
                                                  "Сдано с потерей: ",
                                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                                                ),
                                                HintIcon(element.missing.keys.map((e) => INSTRUMENTS[e]).join("\n"))
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Text(
                                                  "Сдано без потерь",
                                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                                                ),
                                                //HintIcon(
                                                //snapshot.data![index].missing.keys.map((e) => INSTRUMENTS[e]).join("\n"))
                                              ],
                                            ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    SizedBox(height: 5),
                                    element.result == 'true'
                                        ? Icon(Icons.check_circle_outline_outlined, color: Colors.lightGreen, size: 40)
                                        : Icon(Icons.cancel_outlined, color: Colors.red, size: 40),
                                    SizedBox(height: 10),
                                    Text(element.time.split("T").join(" "),
                                        style:
                                            TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54))
                                  ],
                                )
                              ],
                            )),
                      );
                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
