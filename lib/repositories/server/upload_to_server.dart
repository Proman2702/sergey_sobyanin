import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:dio/dio.dart';

// Апи к серверу на фласке, где хранится модель

class UploadAudio {
  final String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final math.Random _rnd = math.Random();

  String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<dynamic> uploadAudio(Uint8List file, String? name, String url) async {
    try {
      // Задается настройка запроса (айпи сервера, максимальное ожидание)

      final BaseOptions options = BaseOptions(
        baseUrl: url,
        validateStatus: (status) => true,
        connectTimeout: const Duration(seconds: 40),
        sendTimeout: const Duration(seconds: 40),
        receiveTimeout: const Duration(seconds: 40),
      );

      // импорт библиотеки с параметрами
      final dio = Dio(options);

      // Сборка картинки и его названия для отправки на сервер
      final formData =
          FormData.fromMap({"image": MultipartFile.fromBytes(file, filename: name ?? '${getRandomString(16)}.jpg')});
      log("<upload> после формирования даты");

      // Пост-запрос на сервер с отправкой файла
      var response = await dio.post(
        url,
        data: formData,
      );

      // Обработчик ошибок
      if (response.statusCode == 200) {
        log('<upload> Картинка успешно загружена');
        log("<upload> ${response.data}");
        return response.data;
      } else {
        log('<upload> Ошибка при загрузке: ${response.statusCode} ${response.statusMessage}');
        return '400';
      }

      // Что-то пошло не так в основном функционале
    } catch (e) {
      log('<upload> $e');
      return '400';
    }
  }
}
