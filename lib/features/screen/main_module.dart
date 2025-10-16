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
import 'package:sergey_sobyanin/repositories/database/database_service.dart';
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

  @override
  void initState() {
    super.initState();
    _initCamera();
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
    debugPrint(data.toString());

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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            "Введите id инженера",
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w500),
          ),
          Container(
              width: 700,
              height: 70,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
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
                  labelText: "Ваш id",
                  labelStyle: TextStyle(color: Colors.black12, fontSize: 28, fontWeight: FontWeight.w700),
                ),
              )),
          Padding(
              padding: const EdgeInsets.only(left: 500, top: 5),
              child: CustomButton(
                onTap: id != ''
                    ? () async {
                        final close = showBlockingProgress(context, message: 'Обращаемся к базе данных...');

                        final user = await database.fetchOrCreateElementById(id);
                        await _captureFrame();

                        await sendToServer();

                        debugPrint(result.toString());

                        close();

                        log(user.id.toString());
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
                                    ));
                      }
                    : () {
                        ErrorNotifier.show('Введите ID');
                      },
                text: 'Готово',
                width: 200,
                height: 50,
                color: Color(CustomColors.accent),
                fontSize: 27,
              ))
        ],
      ),
    );
  }
}
