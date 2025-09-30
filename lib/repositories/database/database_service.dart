import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sergey_sobyanin/repositories/database/models/history_tile.dart';
import 'package:sergey_sobyanin/repositories/database/models/user.dart';

abstract class DatabaseService<T> {
  Future<List<T>> getElements();

  Future<void> upsertElement(T user);

  Future<void> deleteElement(String id);
}

class UserDatabaseService implements DatabaseService<CustomUser> {
  final FirebaseFirestore _firestore;
  late final CollectionReference<CustomUser> _sessionsRef;
  final collectionPath = 'session';

  UserDatabaseService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance {
    _sessionsRef = _firestore.collection(collectionPath).withConverter<CustomUser>(
          fromFirestore: (snap, _) {
            final data = snap.data() ?? <String, dynamic>{};
            return CustomUser.fromJson({
              ...data,
              'id': snap.id,
            });
          },
          toFirestore: (user, _) => user.toJson(),
        );
  }

  @override
  Future<List<CustomUser>> getElements() async {
    final qs = await _sessionsRef.get();
    return qs.docs.map((d) => d.data()).toList();
  }

  @override
  Future<void> upsertElement(CustomUser user) async {
    await _sessionsRef.doc(user.id).set(user, SetOptions(merge: true));
  }

  @override
  Future<void> deleteElement(String id) async {
    await _sessionsRef.doc(id).delete();
  }

  Future<CustomUser> fetchOrCreateElementById(String id) async {
    final ref = _sessionsRef.doc(id);
    final snap = await ref.get();

    if (!snap.exists) {
      final user = CustomUser(
        pictureData: '',
        session: 0,
        result: <String, dynamic>{},
        id: id,
      );
      await ref.set(user);
      return user;
    }

    final map = (snap.data()!.toJson());
    map.putIfAbsent('id', () => id);
    return CustomUser.fromJson(map);
  }
}

class HistoryDatabaseService implements DatabaseService<HistoryTile> {
  final FirebaseFirestore _firestore;
  late final CollectionReference<HistoryTile> _sessionsRef;
  final collectionPath = 'history';

  HistoryDatabaseService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance {
    _sessionsRef = _firestore.collection(collectionPath).withConverter<HistoryTile>(
          fromFirestore: (snap, _) {
            final data = snap.data() ?? <String, dynamic>{};
            return HistoryTile.fromJson({
              ...data,
              'id': snap.id,
            });
          },
          toFirestore: (user, _) => user.toJson(),
        );
  }

  @override
  Future<List<HistoryTile>> getElements() async {
    final qs = await _sessionsRef.get();
    return qs.docs.map((d) => d.data()).toList();
  }

  @override
  Future<void> upsertElement(HistoryTile tile) async {
    await _sessionsRef.doc(tile.id).set(tile, SetOptions(merge: true));
  }

  @override
  Future<void> deleteElement(String id) async {
    await _sessionsRef.doc(id).delete();
  }
}
