import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sergey_sobyanin/repositories/database/models/user.dart';

const String collectionPath = 'sessions';

class DatabaseService {
  final FirebaseFirestore _firestore;
  late final CollectionReference<CustomUser> _sessionsRef;

  DatabaseService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance {
    _sessionsRef = _firestore.collection(collectionPath).withConverter<CustomUser>(
          fromFirestore: (snap, _) {
            final data = snap.data() ?? <String, dynamic>{};
            // если твой CustomUser.fromJson сам умеет работать с отсутствующими полями — ок
            // подстрахуемся, что id всегда попадёт в модель
            return CustomUser.fromJson({
              ...data,
              'id': snap.id,
            });
          },
          toFirestore: (user, _) => user.toJson(),
        );
  }

  /// Получить список всех пользователей (разово).
  Future<List<CustomUser>> getUsers() async {
    final qs = await _sessionsRef.get();
    return qs.docs.map((d) => d.data()).toList();
  }

  /// Создать или обновить пользователя (upsert).
  Future<void> upsertUser(CustomUser user) async {
    await _sessionsRef.doc(user.id).set(user, SetOptions(merge: true));
  }

  /// Удалить пользователя по id.
  Future<void> deleteUser(String id) async {
    await _sessionsRef.doc(id).delete();
  }
}
