import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';

class ErrorNotifier {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final List<OverlayEntry> _entries = [];

  static void show(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final lateOverlay = navigatorKey.currentState?.overlay;
        if (lateOverlay != null) {
          _insertToast(lateOverlay, message, duration);
        }
      });
      return;
    }
    _insertToast(overlay, message, duration);
  }

  static void _insertToast(OverlayState overlay, String message, Duration duration) {
    final index = _entries.length;
    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: 40.0 + index * 64.0,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: _ToastCard(message: message),
          ),
        );
      },
    );

    _entries.add(entry);
    overlay.insert(entry);

    Future.delayed(duration, () {
      if (_entries.contains(entry)) {
        entry.remove();
        _entries.remove(entry);
        for (final e in _entries) {
          e.markNeedsBuild();
        }
      }
    });
  }
}

class _ToastCard extends StatelessWidget {
  final String message;
  const _ToastCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 200),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(CustomColors.darkAccent),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Flexible(child: Text(message, style: TextStyle(fontFamily: "Jura"))),
            ],
          ),
        ),
      ),
    );
  }
}
