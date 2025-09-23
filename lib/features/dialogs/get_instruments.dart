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
                          child: GestureDetector(
                            onTap: () async {
                              log('тык');
                              await pickOneImage();
                              if (imageFile != null) {
                                log(imageFile!.name);
                                bytes = imageFile?.bytes;
                                setState(() {});
                              }
                            },
                            child: Container(
                                width: 200,
                                height: 200,
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: Text('тык')),
                          ),
                        ),
                        bytes == null
                            ? const Text('Картинка не выбрана')
                            : ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 700, maxHeight: 700),
                                child: InteractiveViewer(
                                  // можно масштабировать колесиком/пальцами
                                  child: Image.memory(
                                    Uint8List.fromList(bytes as List<int>),
                                    fit: BoxFit.contain, // вписываем в экран
                                  ),
                                ),
                              ),
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
