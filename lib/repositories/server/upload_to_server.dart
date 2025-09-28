import 'dart:developer';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:dio/dio.dart';

class UploadImage {
  final String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final math.Random _rnd = math.Random();

  String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<dynamic> uploadImage(
    Uint8List file,
    String? name,
    String url, {
    int? note, // <-- текстовое поле
  }) async {
    try {
      final BaseOptions options = BaseOptions(
        baseUrl: url,
        validateStatus: (status) => true,
        connectTimeout: const Duration(seconds: 40),
        sendTimeout: const Duration(seconds: 40),
        receiveTimeout: const Duration(seconds: 40),
      );

      final dio = Dio(options);

      // Сборка формы: файл + текст
      final formData = FormData.fromMap({
        "image": MultipartFile.fromBytes(
          file,
          filename: name ?? '${getRandomString(16)}.jpg',
        ),
        "note": note ?? 0, // <-- добавили текст
      });

      log("<upload> после формирования даты");

      var response = await dio.post(
        url,
        data: formData,
      );

      if (response.statusCode == 200) {
        log('<upload> Картинка + текст успешно загружены');
        log("<upload> ${response.data}");
        return response.data;
      } else {
        log('<upload> Ошибка при загрузке: ${response.statusCode} ${response.statusMessage}');
        return '400';
      }
    } catch (e) {
      log('<upload> $e');
      return '400';
    }
  }
}
