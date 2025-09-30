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
            return CustomUser.fromJson({
              ...data,
              'id': snap.id,
            });
          },
          toFirestore: (user, _) => user.toJson(),
        );
  }

  Future<List<CustomUser>> getUsers() async {
    final qs = await _sessionsRef.get();
    return qs.docs.map((d) => d.data()).toList();
  }

  Future<void> upsertUser(CustomUser user) async {
    await _sessionsRef.doc(user.id).set(user, SetOptions(merge: true));
  }

  Future<void> deleteUser(String id) async {
    await _sessionsRef.doc(id).delete();
  }
}
