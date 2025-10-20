import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

class ImageService {
  // ресайз до Full HD + линейное снижение качества
  // Возвращает Base64
  static Future<String> compressToBase64(
    Uint8List inputBytes, {
    int maxBytes = 1000 * 1000, // 1 МБ
    int boxW = 1920,
    int boxH = 1080,
    int startQuality = 90,
    int minQuality = 40,
    int qualityStep = 10,
  }) async {
    if (inputBytes.lengthInBytes <= maxBytes) {
      return base64Encode(inputBytes);
    }

    final src = img.decodeImage(inputBytes);
    if (src == null) {
      return base64Encode(inputBytes);
    }

    img.Image work = src;

    if (work.width > boxW || work.height > boxH) {
      final s = _fitScale(work.width, work.height, boxW, boxH);
      if (s < 1.0) {
        final newW = (work.width * s).round();
        final newH = (work.height * s).round();
        work = img.copyResize(
          work,
          width: newW,
          height: newH,
          interpolation: img.Interpolation.average,
        );
      }
    }

    for (int q = startQuality; q >= minQuality; q -= qualityStep) {
      final cand = Uint8List.fromList(img.encodeJpg(work, quality: q));
      if (cand.lengthInBytes <= maxBytes) {
        return base64Encode(cand);
      }
    }

    final fallback = Uint8List.fromList(img.encodeJpg(work, quality: minQuality));
    return base64Encode(fallback);
  }

  static double _fitScale(int w, int h, int boxW, int boxH) {
    final sx = boxW / w;
    final sy = boxH / h;
    final s = sx < sy ? sx : sy;
    return s < 1.0 ? s : 1.0;
  }
}
