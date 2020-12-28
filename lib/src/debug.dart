class Debug {
  static final Debug _debug = Debug._internal();

  factory Debug() {
    return _debug;
  }

  Debug._internal();

  static var enabled = false;

  static String log(dynamic message) {
    if (enabled) {
      print('[ PAYME DEBUG ] $message');
    }
    return '$message';
  }
}
