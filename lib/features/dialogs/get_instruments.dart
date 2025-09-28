import 'dart:convert';
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
import 'package:sergey_sobyanin/repositories/server/accuracy.dart';
import 'package:sergey_sobyanin/repositories/server/ip.dart';
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

class GetInstrumentsDialog extends StatefulWidget {
  const GetInstrumentsDialog({super.key, required this.user});

  final CustomUser user;
  @override
  State<GetInstrumentsDialog> createState() => _GetInstrumentsDialogState();
}

class _GetInstrumentsDialogState extends State<GetInstrumentsDialog> {
  double targetWidth = 1400;
  double targetHeight = 800;
  double inset = 24;

  final database = DatabaseService();
  PlatformFile? imageFile;
  Uint8List? bytes;
  Uint8List? bytes_from_server;
  bool sendingToServer = false;
  Map<String, dynamic>? data;
  Map<String, List<double>> result = {};
  bool showBoxes = false;

  Future<void> pickOneImage() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true, // важно для Web — нужны bytes
      type: FileType.image, // только картинки
    );
    if (result == null) return;
    setState(() => imageFile = result.files.single);
  }

  void setImage() async {
    log('тык');
    await pickOneImage();
    if (imageFile != null) {
      log(imageFile!.name);
      bytes = imageFile?.bytes;
      setState(() {});
    }
  }

  List parseToDisplay(Map<String, List<double>> result) {
    List items = result.entries.toList();
    return items;
  }

  void setImageWithSendingToServer() async {
    await pickOneImage();
    if (imageFile != null) {
      log(imageFile!.name);
      bytes = imageFile?.bytes;
      data = await UploadImage().uploadImage(bytes!, imageFile!.name, '${IP().getIp}/upload', note: Accuracy().getAcc)
          as Map<String, dynamic>;

      bytes_from_server = base64Decode(data!['img']);
      result = {};
      for (final item in data!["predictions"]) {
        final name = item["class_name"] as String;
        final conf = (item["confidence"] as num).toDouble();
        final rounded = double.parse(conf.toStringAsFixed(2));

        // если ключа ещё нет → создаём список
        result.putIfAbsent(name, () => []);
        // добавляем в список
        result[name]!.add(rounded);
      }
      log(result.toString());
      log(parseToDisplay(result).toString());
      setState(() {});
    }
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
                    child: Row(
                      children: [
                        Container(
                          width: 700,
                          height: 800,
                          alignment: Alignment.center,
                          decoration:
                              BoxDecoration(borderRadius: BorderRadius.circular(16), color: Color(CustomColors.shadow)),
                          child: bytes == null
                              ? GestureDetector(
                                  onTap: setImageWithSendingToServer,
                                  child: Container(
                                      width: 300,
                                      height: 300,
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        spacing: 10,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            spacing: 10,
                                            children: [
                                              Icon(Icons.photo_size_select_actual_outlined,
                                                  color: Colors.black54, size: 60),
                                              Icon(Icons.add, color: Colors.black54, size: 60),
                                            ],
                                          ),
                                          Text(
                                            'Нажмите, чтобы добавить фото',
                                            style: TextStyle(
                                                color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 22),
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      )),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 700, maxHeight: 700),
                                      child: Container(
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
                                        child: InteractiveViewer(
                                            child: Image.memory(
                                                Uint8List.fromList(
                                                    !showBoxes ? bytes! : bytes_from_server ?? bytes as List<int>),
                                                fit: BoxFit.contain)),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        FloatingActionButton(
                                          backgroundColor: Color(CustomColors.accent),
                                          onPressed: setImageWithSendingToServer,
                                          child: Icon(
                                            Icons.refresh,
                                            color: Color(CustomColors.main),
                                            size: 40,
                                          ),
                                        ),
                                        SizedBox(width: 20),
                                        FloatingActionButton(
                                          backgroundColor: Color(CustomColors.accent),
                                          onPressed: () {
                                            showBoxes = !showBoxes;
                                            setState(() {});
                                          },
                                          child: Icon(
                                            Icons.check_box_outlined,
                                            color: Color(CustomColors.main),
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                        ),
                        Container(
                          width: 700,
                          height: 800,
                          alignment: Alignment.center,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 20),
                              SizedBox(
                                height: 160,
                                width: 600,
                                child: Text(
                                  'Список полученных инструментов',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 50),
                                ),
                              ),
                              SizedBox(height: 30),
                              Container(
                                  width: 600,
                                  height: 450,
                                  alignment: Alignment.topCenter,
                                  child: result.isEmpty
                                      ? ConstrainedBox(
                                          constraints: BoxConstraints(maxWidth: 50, maxHeight: 50),
                                          child: CircularProgressIndicator())
                                      : GridView.count(
                                          crossAxisCount: 2, // две колонки
                                          crossAxisSpacing: 16,
                                          mainAxisSpacing: 12,
                                          childAspectRatio: 3.5,

                                          shrinkWrap: true,
                                          children: parseToDisplay(result).map((entry) {
                                            final name = INSTRUMENTS[entry.key];
                                            final count = entry.value.length;

                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                color: Colors.white,
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      name!,
                                                      style: const TextStyle(
                                                          fontSize: 22, fontWeight: FontWeight.w500, height: 1.2),
                                                      softWrap: true,
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Color(CustomColors.darkAccent),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      "$count шт.",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        )),
                              SizedBox(height: 60),
                              SizedBox(
                                width: 500,
                                child: Row(
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
                                                'Редактировать',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    color: Color(CustomColors.main),
                                                    fontWeight: FontWeight.w600),
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
                                        onTap: () async {
                                          if (imageFile == null) {
                                            ErrorNotifier.show('Картинка не загружена!');
                                          } else if (result.isEmpty) {
                                            ErrorNotifier.show('Инструменты еще не определены или их нет!');
                                          } else {
                                            final close = showBlockingProgress(context, message: 'Сохраняем…');

                                            await Future.delayed(Duration(milliseconds: 200));

                                            final base64pic = await ImageService.compressToBase64(bytes!);
                                            log('задаунскейлили');
                                            await database.upsertUser(widget.user
                                                .copyWith(session: 1, pictureData: base64pic, result: result));

                                            close();

                                            Navigator.pop(context);
                                          }
                                        },
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
                                                'Сохранить',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    color: Color(CustomColors.main),
                                                    fontWeight: FontWeight.w600),
                                              )),
                                        ),
                                      ),
                                    )
                                  ],
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
