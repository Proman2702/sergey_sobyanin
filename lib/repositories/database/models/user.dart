class CustomUser {
  String id;
  String pictureData;
  int session;

  CustomUser({required this.id, required this.pictureData, required this.session});

  CustomUser.fromJson(Map<String, Object?> json)
      : this(id: json['id']! as String, pictureData: json['picture']! as String, session: json['session']! as int);

  CustomUser copyWith({String? id, String? pictureData, int? session}) {
    return CustomUser(
        id: id ?? this.id, pictureData: pictureData ?? this.pictureData, session: session ?? this.session);
  }

  Map<String, Object?> toJson() {
    return {"id": id, "pictureData": pictureData, "session": session};
  }
}
