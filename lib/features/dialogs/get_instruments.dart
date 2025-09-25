import 'dart:developer';
import 'dart:math' as math;

import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'package:sergey_sobyanin/etc/colors/gradients/background.dart';
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
  const GetInstrumentsDialog({super.key, required this.id});

  final String id;
  @override
  State<GetInstrumentsDialog> createState() => _GetInstrumentsDialogState();
}

class _GetInstrumentsDialogState extends State<GetInstrumentsDialog> {
  double targetWidth = 1400;
  double targetHeight = 800;
  double inset = 24;

  PlatformFile? imageFile;
  Uint8List? bytes;
  bool sendingToServer = false;
  Map<String, dynamic>? data;
  final Map<String, List<double>> result = {};

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
    // items.sort(
    //   (a, b) => a.length.compareTo(b.length),
    // );

    // items = items.reversed.toList();

    // final (List<String>, List<String>) displayText =
    //     ([for (var i = 0; i < items.length; i += 2) items[i]], [for (var i = 1; i < items.length; i += 2) items[i]]);

    // return displayText;
  }

  void setImageWithSendingToServer() async {
    await pickOneImage();
    if (imageFile != null) {
      log(imageFile!.name);
      bytes = imageFile?.bytes;
      data = await UploadAudio().uploadAudio(bytes!, imageFile!.name, 'http://127.0.0.1:5000/upload')
          as Map<String, dynamic>;

      for (final item in data!["predictions"]) {
        final name = item["class_name"] as String;
        final conf = (item["confidence"] as num).toDouble();
        final rounded = double.parse(conf.toStringAsFixed(2));

        // если ключа ещё нет → создаём список
        result.putIfAbsent(name, () => []);
        // добавляем в список
        result[name]!.add(rounded);
      }

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
                                          child:
                                              Image.memory(Uint8List.fromList(bytes as List<int>), fit: BoxFit.contain),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    FloatingActionButton(
                                      backgroundColor: Color(CustomColors.accent),
                                      onPressed: setImageWithSendingToServer,
                                      child: Icon(
                                        Icons.refresh,
                                        color: Color(CustomColors.main),
                                        size: 40,
                                      ),
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
                                                      "$count",
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
                                        onTap: () {
                                          setState(() {});
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
