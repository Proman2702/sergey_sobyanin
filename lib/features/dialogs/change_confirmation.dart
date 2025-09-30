import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';
import 'package:sergey_sobyanin/etc/colors/gradients/background.dart';
import 'package:sergey_sobyanin/features/ui_components/custom_button.dart';

class ChangeConfirmationDialog extends StatelessWidget {
  const ChangeConfirmationDialog({super.key, required this.callback});
  final dynamic callback;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(16),
      child: Container(
        width: 400,
        height: 270,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), gradient: BackgroundGrad()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 10),
            Text(
              'Внимание!',
              style: TextStyle(color: Color(CustomColors.main), fontWeight: FontWeight.w800, fontSize: 20),
            ),
            SizedBox(height: 10),
            Icon(Icons.warning_amber_rounded, size: 50, color: Color(CustomColors.main)),
            SizedBox(height: 10),
            SizedBox(
              height: 100,
              width: 350,
              child: Text(
                textAlign: TextAlign.center,
                'Изменять результат работы алгоритма может только специалист после проверки! (нажать на значок ⟳)',
                style: TextStyle(color: Color(CustomColors.main), fontWeight: FontWeight.w600, fontSize: 17),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  text: 'Выйти',
                  width: 150,
                  height: 40,
                  color: Color(CustomColors.accent),
                  textColor: Color(CustomColors.main),
                  fontSize: 16,
                ),
                SizedBox(width: 30),
                CustomButton(
                  onTap: () {
                    callback();
                    Navigator.pop(context);
                  },
                  text: 'Уведомлен',
                  width: 150,
                  height: 40,
                  color: Color(CustomColors.darkAccent),
                  fontSize: 16,
                  textColor: Color(CustomColors.main),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
