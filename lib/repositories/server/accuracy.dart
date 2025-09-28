class Accuracy {
  static final Accuracy _instance = Accuracy._internal();
  Accuracy._internal();
  factory Accuracy() => _instance;

  int _acc = 80;
  int _border = 80;

  int get getAcc => _acc;
  int get getBorder => _border;

  void setAcc(int newAcc) {
    _acc = newAcc;
  }

  void setBorder(int newBorder) {
    _border = newBorder;
  }
}
