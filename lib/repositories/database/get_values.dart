import 'package:sergey_sobyanin/repositories/database/models/user.dart';

// Класс для обработки сырых данных потока и вывода информации для конкретного пользователя (user)
class GetValues {
  final List _users;
  final String _id;

  GetValues({required List<dynamic> users, required String id})
      : _id = id,
        _users = users;

  CustomUser? getUser() {
    for (var i in _users) {
      if (i.id == _id) {
        return i.data();
      }
    }
    return null;
  }
}
