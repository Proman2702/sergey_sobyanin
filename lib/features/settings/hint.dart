import 'package:flutter/material.dart';
import 'package:sergey_sobyanin/etc/colors/colors.dart';

class HintIcon extends StatefulWidget {
  final String text;
  const HintIcon(this.text, {super.key});

  @override
  State<HintIcon> createState() => _HintIconState();
}

class _HintIconState extends State<HintIcon> {
  final _link = LayerLink();
  OverlayEntry? _entry;

  void _close() {
    _entry?.remove();
    _entry = null;
  }

  void _toggle() {
    if (_entry != null) return _close();

    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // клик вне — закрыть
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            offset: const Offset(0, 24),
            child: Material(
              type: MaterialType.transparency,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.text,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context, debugRequiredFor: widget).insert(_entry!);
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: GestureDetector(
        onTap: _toggle,
        child: const CircleAvatar(
          radius: 10,
          backgroundColor: Color(CustomColors.accent),
          child: Text('?', style: TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ),
    );
  }
}
