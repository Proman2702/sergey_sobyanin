import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'package:sergey_sobyanin/etc/colors/gradients/background.dart';
import 'package:sergey_sobyanin/etc/colors/gradients/tiles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: BackgroundGrad()),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: LayoutBuilder(
            builder: (context, constraints) {
              const double maxEdge = 100;
              const double h = 900;

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
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              log("Мы тут");
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: Color(CustomColors.accent),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                width: 320,
                                height: 60,
                                alignment: Alignment.center,
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
                                      style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              log("В историю");
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: Color(CustomColors.main),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                width: 320,
                                height: 60,
                                alignment: Alignment.center,
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
                                          color: Color(CustomColors.darkAccent),
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(15),

                          color: Colors.transparent, // нужен Material-предок для волны
                          child: InkWell(
                            onTap: () {
                              log("JSON");
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: Ink(
                              decoration: BoxDecoration(
                                color: Color(CustomColors.main),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Container(
                                width: 320,
                                height: 60,
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    SizedBox(width: 20),
                                    Icon(
                                      Icons.code,
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
                                      'Экспорт в json',
                                      style: TextStyle(
                                          fontSize: 25,
                                          color: Color(CustomColors.darkAccent),
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: gap),

                  Container(
                    width: centerW,
                    height: h,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10,
                      children: [
                        Text(
                          "Введите id",
                          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w500),
                        ),
                        Container(
                          width: 700,
                          height: 70,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(offset: Offset(0, 4), blurRadius: 4, spreadRadius: 0, color: Colors.black26)
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 500, top: 5),
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),

                            color: Colors.transparent, // нужен Material-предок для волны
                            child: InkWell(
                              onTap: () {
                                log("введен id");
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Color(CustomColors.accent),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                    width: 200,
                                    height: 60,
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Готово',
                                      style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w500),
                                    )),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
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
