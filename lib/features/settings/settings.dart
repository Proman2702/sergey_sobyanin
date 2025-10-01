import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'package:sergey_sobyanin/etc/colors/gradients/background.dart';
import 'package:sergey_sobyanin/features/error_screen.dart';
import 'package:sergey_sobyanin/features/settings/hint.dart';
import 'package:sergey_sobyanin/features/ui_components/custom_button.dart';
import 'package:sergey_sobyanin/repositories/server/accuracy.dart';
import 'package:sergey_sobyanin/repositories/server/ip.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  String? accuracy;
  String? border;
  String? ip;

  @override
  void initState() {
    accuracy = Accuracy().getAcc.toString();
    border = Accuracy().getBorder.toString();
    ip = IP().getIp;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final frameW = (size.width - 16 * 2).clamp(0.0, double.infinity);
    final frameH = (size.height - 16 * 2).clamp(0.0, double.infinity);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: math.min(600, frameW),
          height: math.min(380, frameH),
          child: SingleChildScrollView(
            child: SizedBox(
              height: 380,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 600,
                  child: Container(
                    decoration: BoxDecoration(gradient: BackgroundGrad()),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Text('Настройки',
                            style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700)),
                        SizedBox(height: 20),
                        SizedBox(
                          width: 500,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('IP сервера',
                                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: HintIcon('IP модели, прописывать полностью (с http:// и т.д.)'),
                              ),
                              Spacer(),
                              Container(
                                width: 280,
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
                                      color: Colors.black26,
                                    )
                                  ],
                                ),
                                child: TextField(
                                  style:
                                      const TextStyle(fontWeight: FontWeight.w700, fontSize: 22, color: Colors.black87),
                                  maxLength: 50,
                                  onChanged: (value) => setState(() {
                                    ip = value;
                                  }),
                                  scrollPhysics: const BouncingScrollPhysics(), // горизонтальная прокрутка
                                  decoration: InputDecoration(
                                    isCollapsed: true, // убирает белые полосы
                                    contentPadding: const EdgeInsets.only(left: 10, bottom: 2),
                                    counterText: "",
                                    border: InputBorder.none,
                                    hintText: ip ?? "", // вместо labelText
                                    hintStyle: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                        SizedBox(
                          width: 500,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Точность модели в %',
                                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: HintIcon(
                                    'Изменяет порог уверенности модели\n(игнорирует инструменты, у которых значение уверенности ниже этого значения)'),
                              ),
                              Spacer(),
                              Container(
                                  width: 120,
                                  height: 40,
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                            offset: Offset(0, 4), blurRadius: 4, spreadRadius: 0, color: Colors.black26)
                                      ]),
                                  child: TextField(
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700, fontSize: 22, color: Colors.black87),
                                    maxLength: 20,
                                    onChanged: (value) => setState(() {
                                      accuracy = value;
                                    }),
                                    decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      contentPadding: EdgeInsets.only(left: 10, bottom: 15),
                                      counterText: "",
                                      border: InputBorder.none,
                                      labelText: accuracy ?? "",
                                      labelStyle:
                                          TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.w700),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: 500,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Допуск точности в %',
                                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600)),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: HintIcon(
                                    'Изменяет порог уверенности модели для редактирования\n(открывает возможность ручного редактирования списка инструментов, если уверенность ниже этого значения)'),
                              ),
                              Spacer(),
                              Container(
                                  width: 120,
                                  height: 40,
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                            offset: Offset(0, 4), blurRadius: 4, spreadRadius: 0, color: Colors.black26)
                                      ]),
                                  child: TextField(
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black87),
                                    maxLength: 20,
                                    onChanged: (value) => setState(() {
                                      border = value;
                                    }),
                                    decoration: InputDecoration(
                                      floatingLabelBehavior: FloatingLabelBehavior.never,
                                      contentPadding: EdgeInsets.only(left: 10, bottom: 15),
                                      counterText: "",
                                      border: InputBorder.none,
                                      labelText: border ?? "",
                                      labelStyle:
                                          TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w700),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                        CustomButton(
                            onTap: () {
                              try {
                                IP().setIp(ip!);
                                if ((0 < int.parse(accuracy!) && int.parse(accuracy!) < 100) &&
                                    (0 < int.parse(border!) && int.parse(border!) < 100)) {
                                  Accuracy().setAcc(int.parse(accuracy!));
                                  Accuracy().setBorder(int.parse(border!));
                                } else {
                                  throw ArgumentError('Значения не в диапазоне от 0 до 100');
                                }
                                Navigator.pop(context);
                              } catch (e) {
                                ErrorNotifier.show(e.toString());
                              }
                            },
                            text: 'Сохранить',
                            width: 200,
                            height: 45,
                            color: Color(CustomColors.accent))
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
