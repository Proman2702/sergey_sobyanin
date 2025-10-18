import 'package:flutter/material.dart';

class HoverActionButton extends StatefulWidget {
  const HoverActionButton({super.key});

  @override
  State<HoverActionButton> createState() => _HoverActionButtonState();
}

class _HoverActionButtonState extends State<HoverActionButton> {
  bool _showWidget = false;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: GestureDetector(
            onTap: () => setState(() => _showWidget = !_showWidget),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: _isHovering ? Colors.blue[700] : Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (_isHovering)
                        const BoxShadow(
                          blurRadius: 8,
                          offset: Offset(0, 4),
                          color: Colors.black26,
                        )
                    ],
                  ),
                  child: const Text(
                    "Нажми меня",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),

                // Подсказка при наведении
                if (_isHovering)
                  Positioned(
                    top: -35,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Я всплываю при наведении 😎",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Виджет после нажатия
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showWidget
              ? Container(
                  key: const ValueKey(1),
                  width: 250,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueAccent, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Я появился после нажатия! 🚀",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
