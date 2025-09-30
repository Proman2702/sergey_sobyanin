import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'package:sergey_sobyanin/etc/constants.dart';
import 'package:sergey_sobyanin/features/settings/hint.dart';
import 'package:sergey_sobyanin/repositories/database/database_service.dart';
import 'package:sergey_sobyanin/repositories/database/models/history_tile.dart';

class HistoryModule extends StatelessWidget {
  const HistoryModule({
    super.key,
    required this.centerW,
    required this.h,
  });

  final double centerW;
  final double h;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: centerW,
      height: h,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          SingleChildScrollView(
            child: SizedBox(
              height: h - 100,
              width: centerW,
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
                  elements = elements.reversed.toList();

                  return ListView.builder(
                    itemCount: elements.length,
                    itemBuilder: (context, index) {
                      final element = elements[index];
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                            width: centerW,
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
                                        snapshot.data![index].id,
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
