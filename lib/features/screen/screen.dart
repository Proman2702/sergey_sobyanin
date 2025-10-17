import 'dart:developer';
import 'dart:math';

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

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: W),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: edge),

                        Container(
                          width: leftW,
                          height: h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Color(CustomColors.main).withOpacity(0.2),
                              border: Border.all(color: Color(CustomColors.mainDark).withOpacity(0.3), width: 3),
                              boxShadow: [
                                BoxShadow(offset: Offset(0, 3), blurRadius: 10, spreadRadius: 4, color: Colors.black26)
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 30),
                              Stack(
                                children: [
                                  Container(
                                    height: 140,
                                    width: 320,
                                    decoration: BoxDecoration(
                                        color: Color(CustomColors.darkAccent),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                              offset: Offset(0.0, 4.0),
                                              color: Colors.black26,
                                              blurRadius: 6,
                                              spreadRadius: 2)
                                        ]),
                                    padding: EdgeInsets.all(16),
                                    child: Image.asset(
                                      "images/logo.png",
                                      fit: BoxFit.contain,
                                      color: Color(CustomColors.main),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 30),
                              // Container(
                              //   height: 140,
                              //   width: 320,
                              //   alignment: Alignment.center,
                              //   decoration:
                              //       BoxDecoration(gradient: TileGrad1(), borderRadius: BorderRadius.circular(15)),
                              //   child: Stack(
                              //     children: [
                              //       Padding(
                              //         padding: EdgeInsets.only(top: 10, right: 30),
                              //         child: Icon(
                              //           Icons.settings_outlined,
                              //           color: Colors.white,
                              //           size: 90,
                              //         ),
                              //       ),
                              //       Padding(
                              //         padding: const EdgeInsets.only(bottom: 5, left: 60),
                              //         child: Icon(
                              //           Icons.settings_outlined,
                              //           color: Colors.white,
                              //           size: 60,
                              //         ),
                              //       )
                              //     ],
                              //   ),
                              // ),
                              // SizedBox(height: 30),
                              Container(
                                height: 560,
                                width: 320,
                                decoration: BoxDecoration(
                                    color: Color(CustomColors.mainLight).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Column(children: [
                                  SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Material(
                                        elevation: 0,
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.transparent,
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                chosen_module = 0;
                                              });
                                            },
                                            borderRadius: BorderRadius.circular(15),
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                color: chosen_module == 0
                                                    ? Color(CustomColors.accent)
                                                    : Color(CustomColors.background).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: SizedBox(
                                                height: 50,
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 20),
                                                    Icon(
                                                      Icons.home_rounded,
                                                      size: 30,
                                                      color: Color(CustomColors.main),
                                                    ),
                                                    SizedBox(width: 20),
                                                    Text(
                                                      'Главная',
                                                      style: TextStyle(
                                                          fontSize: 22,
                                                          color: chosen_module == 0
                                                              ? Color(CustomColors.main)
                                                              : Color(CustomColors.darkAccent),
                                                          fontWeight: FontWeight.w600),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ))),
                                  ),
                                  SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Material(
                                        elevation: 0,
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.transparent,
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                chosen_module = 1;
                                              });
                                            },
                                            borderRadius: BorderRadius.circular(15),
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                color: chosen_module == 1
                                                    ? Color(CustomColors.accent)
                                                    : Color(CustomColors.background).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: SizedBox(
                                                height: 50,
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 20),
                                                    Icon(
                                                      Icons.access_time,
                                                      size: 30,
                                                      color: Color(CustomColors.main),
                                                    ),
                                                    SizedBox(width: 20),
                                                    Text(
                                                      'История',
                                                      style: TextStyle(
                                                          fontSize: 22,
                                                          color: chosen_module == 1
                                                              ? Color(CustomColors.main)
                                                              : Color(CustomColors.darkAccent),
                                                          fontWeight: FontWeight.w600),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ))),
                                  ),
                                  SizedBox(
                                    height: 428,
                                    child: Stack(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      children: [
                                        Positioned.fill(
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(15),
                                              gradient: LinearGradient(colors: [
                                                Color(CustomColors.mainLight).withOpacity(0.0),
                                                Color(CustomColors.mainLight).withOpacity(0.3)
                                              ], begin: Alignment.center, end: Alignment.bottomRight),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: -70,
                                          bottom: -90,
                                          child: Transform.rotate(
                                            angle: 6 * pi / 4,
                                            child: Image.asset(
                                              "images/plane.png",
                                              color: Color(CustomColors.mainLight).withOpacity(0.1),
                                              width: 300,
                                              height: 300,
                                            ),
                                            // child: Icon(Icons.airplanemode_active,
                                            //     size: 300, color: Color(CustomColors.mainLight).withOpacity(0.1))
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ]),
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
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  showDialog(context: context, builder: (context) => SettingsDialog());
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: Color(CustomColors.main).withOpacity(0.4),
                                    border: Border.all(color: Color(CustomColors.mainDark).withOpacity(0.3), width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(0, 3), blurRadius: 10, spreadRadius: 4, color: Colors.black26)
                                    ],
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                      width: 80,
                                      height: 80,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.settings,
                                        color: Color(CustomColors.darkAccent),
                                        size: 50,
                                      )),
                                ),
                              ),
                            )),

                        SizedBox(width: edge), // 0..100 справа
                      ],
                    ),
                  ),
                ),
              );
            },
          ))),
    );
  }
}
