import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:html' as html;
import 'package:sergey_sobyanin/etc/constants.dart';

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'package:sergey_sobyanin/etc/colors/gradients/background.dart';
import 'package:sergey_sobyanin/features/blocking_progress.dart';
import 'package:sergey_sobyanin/features/dialogs/redactor.dart';
import 'package:sergey_sobyanin/features/error_screen.dart';
import 'package:sergey_sobyanin/features/ui_components/custom_button.dart';
import 'package:sergey_sobyanin/repositories/database/database_service.dart';
import 'package:sergey_sobyanin/repositories/database/models/user.dart';
import 'package:sergey_sobyanin/repositories/image/image_service.dart';
import 'package:sergey_sobyanin/repositories/server/accuracy.dart';
import 'package:sergey_sobyanin/repositories/server/ip.dart';
import 'package:sergey_sobyanin/repositories/server/upload_to_server.dart';

class GetInstrumentsDialog extends StatefulWidget {
  const GetInstrumentsDialog({super.key, required this.user});

  final CustomUser user;
  @override
  State<GetInstrumentsDialog> createState() => _GetInstrumentsDialogState();
}

class _GetInstrumentsDialogState extends State<GetInstrumentsDialog> {
  final database = UserDatabaseService();
  PlatformFile? imageFile;
  Uint8List? bytes;
  Uint8List? bytesFromServer;
  bool sendingToServer = false;
  Map<String, dynamic>? data;
  Map<String, dynamic> result = {};
  bool showBoxes = false;
  bool allowRedacting = false;

  Future<void> pickOneImage() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.image,
    );
    if (result == null) return;
    setState(() => imageFile = result.files.single);
  }

  void updateCallback(Map<String, dynamic> newResult) {
    result = newResult;
    setState(() {});
  }

  List<Map<String, dynamic>> convertToJsonList(Map<String, dynamic> input) {
    final List<Map<String, dynamic>> result = [];

    input.forEach((name, confList) {
      final entry =
          INSTRUMENTS_INDEXED.entries.firstWhere((e) => e.value == name, orElse: () => const MapEntry(-1, ''));

      if (entry.key == -1) return;

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

  void downloadJson(String filename, Map<String, dynamic> data) {
    final jsonList = convertToJsonList(data);

    final encoder = const JsonEncoder.withIndent('  '); // pretty JSON
    final jsonStr = encoder.convert(jsonList);

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

  void setImage() async {
    await pickOneImage();
    if (imageFile != null) {
      log(imageFile!.name);
      bytes = imageFile?.bytes;
      setState(() {});
    }
  }

  // открыть картинку и отправить ее на сервер
  void setImageWithSendingToServer() async {
    await pickOneImage();
    if (imageFile != null) {
      log(imageFile!.name);
      bytes = imageFile?.bytes;
      data = await UploadImage().uploadImage(bytes!, imageFile!.name, '${IP().getIp}/upload', note: Accuracy().getAcc)
          as Map<String, dynamic>;

      bytesFromServer = base64Decode(data!['img']);
      result = {};
      for (final item in data!["predictions"]) {
        final name = item["class_name"] as String;
        final conf = (item["confidence"] as num).toDouble();
        final rounded = double.parse(conf.toStringAsFixed(2));

        result.putIfAbsent(name, () => []);
        result[name]!.add(rounded);
      }

      if (!result.isEmpty) {
        if (result.values.expand((list) => list).reduce((a, b) => a < b ? a : b) < Accuracy().getBorder / 100) {
          allowRedacting = true;
          ErrorNotifier.show('Доступно редактирование');
        } else {
          allowRedacting = false;
        }
      }
      setState(() {});
    }
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
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: BackgroundGrad()),
        child: SingleChildScrollView(
          child: SizedBox(
            height: 800,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1400,
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
                                        style:
                                            TextStyle(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 22),
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
                                                !showBoxes ? bytes! : bytesFromServer ?? bytes as List<int>),
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
                                      children: result.entries.toList().map((entry) {
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
                            width: 600,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomButtonModified(
                                  width: 80,
                                  height: 50,
                                  color: Color(CustomColors.accent),
                                  onTap: () async {
                                    downloadJson('exported_get.json', result);
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
                                              color: Color(CustomColors.main),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(width: 30),
                                CustomButton(
                                  onTap: allowRedacting
                                      ? () {
                                          if (imageFile == null) {
                                            ErrorNotifier.show('Картинка не загружена!');
                                          } else if (result.isEmpty) {
                                            ErrorNotifier.show('Инструменты еще не определены или их нет!');
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (context) => RedactorDialog(
                                                    picture: bytes!, result: result, updateCallback: updateCallback));
                                            setState(() {});
                                          }
                                        }
                                      : () {
                                          ErrorNotifier.show('Редактирование недоступно');
                                        },
                                  text: 'Редактировать',
                                  width: 220,
                                  height: 50,
                                  color: allowRedacting ? Color(CustomColors.accent) : Color(CustomColors.shadow),
                                  fontSize: 25,
                                ),
                                SizedBox(width: 30),
                                CustomButton(
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
                                      await database.upsertElement(
                                          widget.user.copyWith(session: 1, pictureData: base64pic, result: result));

                                      close();

                                      Navigator.pop(context);
                                    }
                                  },
                                  text: 'Сохранить',
                                  width: 220,
                                  height: 50,
                                  color: Color(CustomColors.accent),
                                  fontSize: 25,
                                ),
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
    );
  }
}
