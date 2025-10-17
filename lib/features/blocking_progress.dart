import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';

class BlockingProgressDialog extends StatelessWidget {
  final String? message;

  const BlockingProgressDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Color(CustomColors.main),
        elevation: 8,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(CustomColors.darkAccent),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  message ?? 'Загрузка...',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(CustomColors.darkAccent), fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef CloseProgress = void Function();

CloseProgress showBlockingProgress(
  BuildContext context, {
  String? message,
}) {
  final navigator = Navigator.of(context, rootNavigator: true);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black38,
    useRootNavigator: true,
    builder: (_) => BlockingProgressDialog(message: message),
  );

  var closed = false;
  return () {
    if (!closed && navigator.mounted && navigator.canPop()) {
      navigator.pop();
      closed = true;
    }
  };
}
