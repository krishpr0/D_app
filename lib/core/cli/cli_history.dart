class CliHistory {
  static final List<String> _history = [];
  static int _index = -1;

  static void add(String cmd) {
    if (cmd.isNotEmpty) _history.add(cmd);
    _index = _history.length;
  }

  static String? previous() {
    if (_index > 0 ) _index--;
    return _index < _history.length ? _history[_index] : null;
  }

  static String? next() {
    if (_index < _history.length  - 1) _index++;
    return _index < _history.length ? _history[_index] : null;
  }
}
