import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Сжатие картинки до <= maxBytes с поэтапным подходом:
/// 1) сначала только качество (ранний выход, если удалось),
/// 2) если нет — пропорциональный даунскейл, и снова попытка по качеству.
/// Возвращает Base64 (JPEG). Работает и на Flutter Web (pure Dart).
class ImageService {
  static Future<String> compressToBase64(
    Uint8List inputBytes, {
    int maxBytes = 1024 * 1024, // 1 МБ
    int initialQuality = 85,
    int minQuality = 40,
    int qualityStep = 5,
    double downscaleStep = 0.9, // коэффициент для поэтапного уменьшения
    int minWidth = 700, // ниже этой ширины не даунскейлим
    bool withDataUriPrefix = false,
  }) async {
    // Если уже влезает — просто вернуть как есть
    if (inputBytes.lengthInBytes <= maxBytes) {
      final b64 = base64Encode(inputBytes);
      return withDataUriPrefix ? 'data:application/octet-stream;base64,$b64' : b64;
    }

    final decoded = img.decodeImage(inputBytes);
    if (decoded == null) {
      // Не смогли декодировать (битые данные и т.п.) — вернём исходник
      final b64 = base64Encode(inputBytes);
      return withDataUriPrefix ? 'data:application/octet-stream;base64,$b64' : b64;
    }

    img.Image current = decoded;

    Uint8List _encode(img.Image im, int q) => Uint8List.fromList(img.encodeJpg(im, quality: q));

    String _wrapB64(Uint8List bytes, {bool jpeg = true}) {
      final b64 = base64Encode(bytes);
      if (!withDataUriPrefix) return b64;
      return jpeg ? 'data:image/jpeg;base64,$b64' : 'data:application/octet-stream;base64,$b64';
    }

    // === ЭТАП 1: только качество (без изменения размеров) ===
    for (int q = initialQuality; q >= minQuality; q -= qualityStep) {
      final encoded = _encode(current, q);
      if (encoded.lengthInBytes <= maxBytes) {
        return _wrapB64(encoded); // ранний выход
      }
    }

    // === ЭТАП 2: даунскейл поэтапно + на каждом шаге снова пробуем качество ===
    while (true) {
      // Посчитаем следующие размеры пропорционально
      final nextWidth = (current.width * downscaleStep).round();
      final nextHeight = (current.height * downscaleStep).round();

      // Нельзя даунскейлить: ширина упадёт ниже minWidth (или невалидные размеры)
      final canDownscale = nextWidth >= minWidth && nextWidth > 0 && nextHeight > 0;

      if (!canDownscale) {
        // Больше уменьшать нельзя — вернём максимально сжатое по качеству
        final fallback = _encode(current, minQuality);
        return _wrapB64(fallback);
      }

      // Пропорционально уменьшаем обе стороны
      current = img.copyResize(
        current,
        width: nextWidth,
        height: nextHeight,
        interpolation: img.Interpolation.cubic,
      );

      // После очередного уменьшения размеров снова пытаемся качеством
      for (int q = initialQuality; q >= minQuality; q -= qualityStep) {
        final encoded = _encode(current, q);
        if (encoded.lengthInBytes <= maxBytes) {
          return _wrapB64(encoded); // ранний выход
        }
      }
      // Если всё ещё не влезли — цикл продолжится и ещё уменьшит изображение.
    }
  }
}
