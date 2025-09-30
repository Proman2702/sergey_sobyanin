import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'package:sergey_sobyanin/etc/colors/gradients/background.dart';
import 'package:sergey_sobyanin/etc/colors/gradients/tiles.dart';
import 'package:sergey_sobyanin/features/screen/history_module.dart';
import 'package:sergey_sobyanin/features/screen/main_module.dart';
import 'package:sergey_sobyanin/features/settings/settings.dart';
import 'package:sergey_sobyanin/features/ui_components/custom_button.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  int chosen_module = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: BackgroundGrad()),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: LayoutBuilder(
            builder: (context, constraints) {
              const double maxEdge = 100;
              const double h = 800;

              const double leftW = 400;
              const double centerW = 800;
              const double rightW = 100;

              final double W = constraints.maxWidth;
              final double content = leftW + centerW + rightW;
              final double free = (W - content).clamp(0.0, double.infinity);

              double edge, gap;
              if (free <= 2 * maxEdge) {
                edge = free / 2;
                gap = 0;
              } else {
                edge = maxEdge;
                gap = (free - 2 * maxEdge) / 2;
              }

              final row = Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: edge),

                  Container(
                    width: leftW,
                    height: h,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white, boxShadow: [
                      BoxShadow(offset: Offset(0, 3), blurRadius: 10, spreadRadius: 4, color: Colors.black26)
                    ]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Text('ТОиР | Аэрофлот',
                            style: TextStyle(
                                color: Color(CustomColors.bright), fontWeight: FontWeight.w800, fontSize: 36)),
                        SizedBox(height: 20),
                        Container(
                          height: 140,
                          width: 320,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(gradient: TileGrad1(), borderRadius: BorderRadius.circular(15)),
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 10, right: 30),
                                child: Icon(
                                  Icons.settings_outlined,
                                  color: Colors.white,
                                  size: 90,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5, left: 60),
                                child: Icon(
                                  Icons.settings_outlined,
                                  color: Colors.white,
                                  size: 60,
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        CustomButtonModified(
                            onTap: () {
                              setState(() {
                                chosen_module = 0;
                              });
                            },
                            width: 320,
                            height: 60,
                            color: chosen_module == 0 ? Color(CustomColors.accent) : Color(CustomColors.main),
                            child: Row(
                              children: [
                                SizedBox(width: 20),
                                Icon(
                                  Icons.home_rounded,
                                  size: 35,
                                  color: Color(CustomColors.mainDark),
                                ),
                                SizedBox(width: 15),
                                Container(
                                  height: 40,
                                  width: 3,
                                  color: Color(CustomColors.shadow),
                                ),
                                SizedBox(width: 20),
                                Text(
                                  'Главная',
                                  style: TextStyle(
                                      fontSize: 25,
                                      color: chosen_module == 0
                                          ? Color(CustomColors.main)
                                          : Color(CustomColors.darkAccent),
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            )),
                        SizedBox(height: 20),
                        CustomButtonModified(
                          onTap: () {
                            setState(() {
                              chosen_module = 1;
                            });
                          },
                          width: 320,
                          height: 60,
                          color: chosen_module == 1 ? Color(CustomColors.accent) : Color(CustomColors.main),
                          child: Row(
                            children: [
                              SizedBox(width: 20),
                              Icon(
                                Icons.access_time,
                                size: 35,
                                color: Color(CustomColors.mainDark),
                              ),
                              SizedBox(width: 15),
                              Container(
                                height: 40,
                                width: 3,
                                color: Color(CustomColors.shadow),
                              ),
                              SizedBox(width: 20),
                              Text(
                                'История',
                                style: TextStyle(
                                    fontSize: 25,
                                    color:
                                        chosen_module == 1 ? Color(CustomColors.main) : Color(CustomColors.darkAccent),
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: gap),

                  switch (chosen_module) {
                    1 => HistoryModule(centerW: centerW, h: h),
                    _ => MainModule(centerW: centerW, h: h)
                  },

                  SizedBox(width: gap),

                  Container(
                      width: rightW,
                      height: h,
                      alignment: Alignment.topCenter,
                      child: Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(10),

                        color: Colors.transparent, // нужен Material-предок для волны
                        child: InkWell(
                          onTap: () {
                            log("настройки");
                            showDialog(context: context, builder: (context) => SettingsDialog());
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                                width: 80,
                                height: 80,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.settings,
                                  color: Color(CustomColors.bright),
                                  size: 50,
                                )),
                          ),
                        ),
                      )),

                  SizedBox(width: edge), // 0..100 справа
                ],
              );

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: W), // тянем минимум на ширину экрана
                    child: row,
                  ),
                ),
              );
            },
          ))),
    );
  }
}
