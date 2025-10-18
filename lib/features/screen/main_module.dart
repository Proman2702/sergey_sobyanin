import 'dart:convert';
import 'dart:developer';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'package:sergey_sobyanin/features/blocking_progress.dart';
import 'package:sergey_sobyanin/features/dialogs/get_instruments.dart';
import 'package:sergey_sobyanin/features/dialogs/hand_over_instruments.dart';
import 'package:sergey_sobyanin/features/error_screen.dart';
import 'package:sergey_sobyanin/features/ui_components/custom_button.dart';
import 'package:sergey_sobyanin/features/ui_components/hover_button.dart';
import 'package:sergey_sobyanin/repositories/database/database_service.dart';
import 'package:sergey_sobyanin/repositories/database/models/user.dart';
import 'package:sergey_sobyanin/repositories/server/accuracy.dart';
import 'package:sergey_sobyanin/repositories/server/ip.dart';
import 'package:sergey_sobyanin/repositories/server/upload_to_server.dart';

class MainModule extends StatefulWidget {
  const MainModule({
    super.key,
    required this.centerW,
    required this.h,
  });

  final double centerW;
  final double h;

  @override
  State<MainModule> createState() => _MainModuleState();
}

class _MainModuleState extends State<MainModule> {
  final database = UserDatabaseService();
  String id = "";
  html.VideoElement? _video;
  html.CanvasElement? _canvas;
  Uint8List? _photoBytes;
  Map<String, dynamic>? data;
  Map<String, dynamic> result = {};
  Uint8List? bytesFromServer;
  bool allowRedacting = false;
  html.MediaStream? _stream;

  bool _isHovering = false;
  bool _isShowingWidget = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
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

    setState(() {
      _photoBytes = reader.result as Uint8List?;
    });
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
    return Container(
      width: widget.centerW,
      height: widget.h,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 10,
        children: [
          SizedBox(height: 300),
          Container(
              width: 700,
              height: 70,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                      color: Color(CustomColors.mainLight).withOpacity(0.4),
                      width: 6,
                      strokeAlign: BorderSide.strokeAlignOutside),
                  boxShadow: [BoxShadow(offset: Offset(0, 4), blurRadius: 4, spreadRadius: 0, color: Colors.black26)]),
              child: TextField(
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 28, color: Colors.black87),
                maxLength: 20,
                onChanged: (value) => setState(() {
                  id = value;
                }),
                decoration: InputDecoration(
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  contentPadding: EdgeInsets.only(left: 10, bottom: 30),
                  counterText: "",
                  border: InputBorder.none,
                  labelText: "Ввод ID инженера",
                  labelStyle: TextStyle(color: Colors.black26, fontSize: 28, fontWeight: FontWeight.w800),
                ),
              )),
          SizedBox(
            width: 700,
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 50,
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isShowingWidget = !_isShowingWidget;
                            _isHovering = !_isHovering;
                          });
                        },
                        icon: Icon(Icons.search),
                        iconSize: 30,
                        color: Color(CustomColors.mainLight),
                        onHover: (value) {
                          if (!_isShowingWidget) {
                            setState(() {
                              _isHovering = !_isHovering;
                            });
                          }
                        },
                      ),
                      _isHovering
                          ? Positioned(
                              bottom: 45,
                              left: 30,
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Color(CustomColors.backgroundDark).withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Text(
                                  "Показать активные сессии",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                ),
                SizedBox(width: 400),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: CustomButton(
                      onTap: id != ''
                          ? () async {
                              final close =
                                  showBlockingProgress(context, message: 'Фотографируем и обращаемся к серверу...');

                              final user = await database.fetchOrCreateElementById(id);
                              await _captureFrame();

                              await sendToServer();

                              close();

                              _isShowingWidget = false;

                              // _stream?.getTracks().forEach((track) => track.stop());

                              // // Отвязываем видео от потока
                              // if (_video != null) {
                              //   _video!.srcObject = null;
                              // }

                              user.session == 0
                                  ? showDialog(
                                      context: context,
                                      builder: (context) => GetInstrumentsDialog(
                                          user: user,
                                          bytes: _photoBytes,
                                          allowRedacting: allowRedacting,
                                          bytesFromServer: bytesFromServer,
                                          result: result))
                                  : showDialog(
                                      context: context,
                                      builder: (context) => HandOverInstrumentsDialog(
                                          user: user,
                                          bytes: _photoBytes,
                                          allowRedacting: allowRedacting,
                                          bytesFromServer: bytesFromServer,
                                          result: result));
                            }
                          : () {
                              ErrorNotifier.show('Введите ID');
                            },
                      text: 'Готово',
                      width: 200,
                      height: 50,
                      color: Color(CustomColors.accent),
                      fontSize: 27,
                    )),
              ],
            ),
          ),
          if (_isShowingWidget)
            Container(
              width: 700,
              alignment: Alignment.topLeft,
              child: Container(
                  padding: EdgeInsets.all(8),
                  width: 400,
                  decoration: BoxDecoration(
                    color: Color(CustomColors.background).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Активные сессии",
                        style:
                            TextStyle(color: Color(CustomColors.darkAccent), fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      FutureBuilder(
                          future: UserDatabaseService().getElements(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(child: Text('Ошибка: ${snapshot.error}'));
                            }

                            List<CustomUser> elements = snapshot.data ?? [];

                            return elements.isNotEmpty
                                ? Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: elements
                                        .where((e) => e.session == 1)
                                        .map((s) => GestureDetector(
                                              onTap: () async {
                                                final close = showBlockingProgress(context,
                                                    message: 'Фотографируем и обращаемся к серверу...');

                                                final user = await database.fetchOrCreateElementById(s.id);
                                                await _captureFrame();

                                                await sendToServer();

                                                close();
                                                _isShowingWidget = false;

                                                // _stream?.getTracks().forEach((track) => track.stop());

                                                // // Отвязываем видео от потока
                                                // if (_video != null) {
                                                //   _video!.srcObject = null;
                                                // }

                                                showDialog(
                                                    context: context,
                                                    builder: (context) => HandOverInstrumentsDialog(
                                                        user: user,
                                                        bytes: _photoBytes,
                                                        allowRedacting: allowRedacting,
                                                        bytesFromServer: bytesFromServer,
                                                        result: result));
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Color(CustomColors.accent),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(s.id,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(CustomColors.main))),
                                              ),
                                            ))
                                        .toList())
                                : Text("Активных сессий нет");
                          }),
                    ],
                  )),
            )
        ],
      ),
    );
  }
}
