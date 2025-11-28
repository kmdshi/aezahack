import 'dart:async';

class GlobalStreamController {
  static final StreamController<bool> _controller = StreamController<bool>.broadcast();

  static Stream<bool> get stream => _controller.stream;

  static void notify() {
    _controller.add(true);
  }

  static void dispose() {
    _controller.close();
  }
}
