import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:html' as html;
import 'package:dotted_border/dotted_border.dart';
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
  const GetInstrumentsDialog(
      {super.key,
      required this.user,
      required this.bytes,
      required this.allowRedacting,
      required this.bytesFromServer,
      required this.updater,
      required this.result});
  final Uint8List? bytes;
  final dynamic updater;
  final bool allowRedacting;
  final Map<String, dynamic> result;
  final Uint8List? bytesFromServer;

  final CustomUser user;
  @override
  State<GetInstrumentsDialog> createState() => _GetInstrumentsDialogState();
}

class _GetInstrumentsDialogState extends State<GetInstrumentsDialog> {
  final database = UserDatabaseService();
  Uint8List? bytesFromServer;
  bool sendingToServer = false;
  Map<String, dynamic>? data;
  Map<String, dynamic> result = {};
  bool showBoxes = false;
  bool allowRedacting = false;
  html.VideoElement? _video;
  html.CanvasElement? _canvas;
  Uint8List? _photoBytes;
  html.MediaStream? _stream;

  @override
  void initState() {
    super.initState();
    _initCamera();
    result = widget.result;
    allowRedacting = widget.allowRedacting;
    bytesFromServer = widget.bytesFromServer;
  }

  @override
  void dispose() {
    // Останавливаем все треки камеры, если поток есть
    _stream?.getTracks().forEach((track) => track.stop());

    // Отвязываем видео от потока
    if (_video != null) {
      _video!.srcObject = null;
    }

    super.dispose();
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

  Future<void> _initCamera() async {
    final video = html.VideoElement()
      ..autoplay = true
      ..muted = true
      ..style.width = '100%'
      ..style.height = '100%';

    try {
      final stream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': {'facingMode': 'user'}, // 'environment' для задней камеры
      });

      video.srcObject = stream;
      await video.play();

      setState(() {
        _video = video;
        _stream = stream;
      });
    } catch (e) {
      debugPrint('Ошибка доступа к камере: $e');
    }
  }

  Future<void> _captureFrame() async {
    if (_video == null) return;

    final width = _video!.videoWidth;
    final height = _video!.videoHeight;

    _canvas = html.CanvasElement(width: width, height: height);
    final ctx = _canvas!.context2D;
    ctx.drawImage(_video!, 0, 0);

    final blob = await _canvas!.toBlob('image/png');
    final reader = html.FileReader();
    reader.readAsArrayBuffer(blob!);
    await reader.onLoad.first;

    _photoBytes = reader.result as Uint8List?;
  }

  // открыть картинку и отправить ее на сервер
  Future<void> sendToServer() async {
    data = await UploadImage().uploadImage(_photoBytes!, 'burda.jpg', '${IP().getIp}/upload', note: Accuracy().getAcc)
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
                      width: 850,
                      height: 800,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Color(CustomColors.background),
                        // border: Border.all(color: Color(CustomColors.mainDark), width: 5)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 30),
                          Container(
                            width: 790,
                            height: 600,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Color(CustomColors.backgroundDark).withOpacity(0.1)),
                            child: widget.bytes != null
                                ? Center(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(maxWidth: 820, maxHeight: 600),
                                      child: Container(
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), boxShadow: [
                                          BoxShadow(offset: Offset(0, 4), color: Colors.black38, blurRadius: 3)
                                        ]),
                                        clipBehavior: Clip.hardEdge,
                                        child: InteractiveViewer(
                                            clipBehavior: Clip.hardEdge,
                                            child: Image.memory(
                                                Uint8List.fromList(!showBoxes
                                                    ? _photoBytes ?? widget.bytes!
                                                    : bytesFromServer ?? widget.bytes as List<int>),
                                                fit: BoxFit.contain)),
                                      ),
                                    ),
                                  )
                                : Center(child: Text('Что-то пошло не так')),
                          ),
                          SizedBox(height: 30),
                          Container(
                            width: 790,
                            height: 100,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Color(CustomColors.backgroundDark).withOpacity(0.1)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomButtonModified(
                                  color: Color(CustomColors.bright),
                                  onTap: () async {
                                    final close = showBlockingProgress(context,
                                        message: 'Фотографируем и обращаемся к серверу...');

                                    await _captureFrame();

                                    await sendToServer();

                                    close();
                                    setState(() {});
                                  },
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.refresh,
                                    color: Color(CustomColors.main),
                                    size: 35,
                                  ),
                                ),
                                SizedBox(width: 20),
                                CustomButtonModified(
                                  color: Color(CustomColors.bright),
                                  onTap: () {
                                    showBoxes = !showBoxes;
                                    setState(() {});
                                  },
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.check_box_outlined,
                                    color: Color(CustomColors.main),
                                    size: 35,
                                  ),
                                ),
                                SizedBox(width: 20),
                                CustomButton(
                                  onTap: allowRedacting
                                      ? () {
                                          if (_photoBytes == null && widget.bytes == null) {
                                            ErrorNotifier.show('Картинка не загружена!');
                                          } else if (result.isEmpty) {
                                            ErrorNotifier.show('Инструменты еще не определены или их нет!');
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (context) => RedactorDialog(
                                                    picture: _photoBytes ?? widget.bytes!,
                                                    result: result,
                                                    updateCallback: updateCallback));
                                            setState(() {});
                                          }
                                        }
                                      : () {
                                          ErrorNotifier.show('Редактирование недоступно');
                                        },
                                  text: 'Редактировать',
                                  width: 200,
                                  height: 50,
                                  color: allowRedacting ? Color(CustomColors.bright) : Color(CustomColors.shadow),
                                  fontSize: 22,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: 550,
                      height: 800,
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20),
                          SizedBox(
                            height: 140,
                            width: 500,
                            child: Text(
                              'Список полученных инструментов',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 40),
                            ),
                          ),
                          Container(
                              width: 480,
                              height: 520,
                              alignment: Alignment.topCenter,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Color(CustomColors.mainLight).withOpacity(0.1)),
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                              child: result.isEmpty
                                  ? widget.bytes == null && _photoBytes == null
                                      ? ConstrainedBox(
                                          constraints: BoxConstraints(maxWidth: 50, maxHeight: 50),
                                          child: CircularProgressIndicator())
                                      : Center(
                                          child: Text(
                                            "Инструменты не найдены!",
                                            style: const TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w600,
                                                height: 1.2,
                                                color: Color(CustomColors.mainLight)),
                                          ),
                                        )
                                  : GridView.count(
                                      crossAxisCount: 1, // две колонки
                                      crossAxisSpacing: 24,
                                      mainAxisSpacing: 1,
                                      childAspectRatio: 8,

                                      shrinkWrap: true,
                                      children: result.entries.toList().map((entry) {
                                        final name = INSTRUMENTS[entry.key];
                                        final count = entry.value.length;

                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  name!,
                                                  style: const TextStyle(
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.w600,
                                                      height: 1.2,
                                                      color: Colors.white),
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
                          SizedBox(height: 40),
                          SizedBox(
                            width: 500,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomButtonModified(
                                  width: 90,
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
                                  onTap: () async {
                                    if (_photoBytes == null && widget.bytes == null) {
                                      ErrorNotifier.show('Картинка не загружена!');
                                    } else if (result.isEmpty) {
                                      ErrorNotifier.show('Инструменты еще не определены или их нет!');
                                    } else {
                                      final close = showBlockingProgress(context, message: 'Сохраняем…');

                                      await Future.delayed(Duration(milliseconds: 200));

                                      final base64pic =
                                          await ImageService.compressToBase64(_photoBytes ?? widget.bytes!);
                                      await database.upsertElement(
                                          widget.user.copyWith(session: 1, pictureData: base64pic, result: result));
                                      widget.updater();

                                      close();

                                      Navigator.pop(context);
                                    }
                                  },
                                  text: 'Сохранить',
                                  width: 220,
                                  height: 50,
                                  color: Color(CustomColors.accent),
                                  fontSize: 26,
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
