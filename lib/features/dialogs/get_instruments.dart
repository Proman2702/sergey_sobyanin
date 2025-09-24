import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'package:sergey_sobyanin/etc/colors/gradients/background.dart';

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
                                  onTap: setImage,
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
                                              Icon(
                                                Icons.photo_size_select_actual_outlined,
                                                color: Colors.black54,
                                                size: 60,
                                              ),
                                              Icon(
                                                Icons.add,
                                                color: Colors.black54,
                                                size: 60,
                                              ),
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
                                          // можно масштабировать колесиком/пальцами
                                          child: Image.memory(
                                            Uint8List.fromList(bytes as List<int>),
                                            fit: BoxFit.contain, // вписываем в экран
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    FloatingActionButton(
                                      backgroundColor: Color(CustomColors.accent),
                                      onPressed: setImage,
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
                                color: Colors.black12,
                                child: Text('нейронка'),
                              ),
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
