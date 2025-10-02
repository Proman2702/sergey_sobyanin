class HistoryTile {
  String id;
  String personId;
  String result;
  String time;
  Map<String, dynamic> missing;

  HistoryTile(
      {required this.personId, required this.id, required this.time, required this.result, required this.missing});

  factory HistoryTile.fromJson(Map<String, Object?> json) {
    return HistoryTile(
        personId: (json['personId'] as String?) ?? '',
        id: (json['id'] as String?) ?? '',
        time: (json['time'] as String?) ?? '',
        result: (json['result'] as String?) ?? '',
        missing: (json['missing'] as Map<String, dynamic>?) ?? {});
  }

  HistoryTile copyWith({String? id, String? time, String? personId, String? result, Map<String, dynamic>? missing}) {
    return HistoryTile(
        id: id ?? this.id,
        time: time ?? this.time,
        result: result ?? this.result,
        missing: missing ?? this.missing,
        personId: personId ?? this.personId);
  }

  Map<String, Object?> toJson() {
    return {"id": id, "time": time, "result": result, "missing": missing, "personId": personId};
  }
}
