import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

class ImageService {
  /// Простой ресайз до Full HD (если нужно) + линейное снижение качества.
  /// Возвращает Base64 (JPEG).
  static Future<String> compressToBase64(
    Uint8List inputBytes, {
    int maxBytes = 1024 * 1024, // 1 МБ
    int boxW = 1920,
    int boxH = 1080,
    int startQuality = 90,
    int minQuality = 40,
    int qualityStep = 10, // уменьшай шаг, если хочется точнее (но медленнее)
  }) async {
    // Уже влезает — отдаем как есть.
    if (inputBytes.lengthInBytes <= maxBytes) {
      return base64Encode(inputBytes);
    }

    final src = img.decodeImage(inputBytes);
    if (src == null) {
      // не смогли декодировать — отдаем исходник
      return base64Encode(inputBytes);
    }

    img.Image work = src;

    // 1) Ужимаем в рамку 1920×1080 пропорционально (без апскейла).
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

    // 2) Линейно уменьшаем качество, пока не поместимся в maxBytes.
    for (int q = startQuality; q >= minQuality; q -= qualityStep) {
      final cand = Uint8List.fromList(img.encodeJpg(work, quality: q));
      if (cand.lengthInBytes <= maxBytes) {
        return base64Encode(cand);
      }
    }

    // Если даже на минимальном не влезли — вернем минимальное качество.
    final fallback = Uint8List.fromList(img.encodeJpg(work, quality: minQuality));
    return base64Encode(fallback);
  }

  // Коэффициент масштабирования, чтобы (w,h) поместить внутрь (boxW,boxH)
  static double _fitScale(int w, int h, int boxW, int boxH) {
    final sx = boxW / w;
    final sy = boxH / h;
    final s = sx < sy ? sx : sy;
    return s < 1.0 ? s : 1.0; // только уменьшение
  }
}
