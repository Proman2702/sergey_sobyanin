class IP {
  static final IP _instance = IP._internal();
  IP._internal();
  factory IP() => _instance;

  String _ip = "http://127.0.0.1:5000";

  String get getIp => _ip;

  void setIp(String newIp) {
    if (newIp.startsWith("http")) {
      _ip = newIp;
    } else {
      throw ArgumentError("IP должен начинаться с http");
    }
  }
}
