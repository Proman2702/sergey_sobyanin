class CustomUser {
  String id;
  String pictureData;
  Map<String, dynamic> result;
  int session;

  CustomUser({required this.id, required this.pictureData, required this.session, required this.result});

  factory CustomUser.fromJson(Map<String, Object?> json) {
    return CustomUser(
      id: (json['id'] as String?) ?? '', // если null → пустая строка
      pictureData: (json['picture'] as String?) ?? '', // дефолт: пустая строка
      session: (json['session'] as int?) ?? 0, // дефолт: 0
      result: (json['result'] as Map<String, dynamic>?) ?? <String, dynamic>{},
    );
  }

  CustomUser copyWith({String? id, String? pictureData, int? session, Map<String, dynamic>? result}) {
    return CustomUser(
        id: id ?? this.id,
        pictureData: pictureData ?? this.pictureData,
        session: session ?? this.session,
        result: result ?? this.result);
  }

  Map<String, Object?> toJson() {
    return {"id": id, "pictureData": pictureData, "session": session, "result": result};
  }
}
