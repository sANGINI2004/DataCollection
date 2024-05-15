import 'dart:async';
import 'dart:collection';

typedef Request = Future<void> Function();

class Sender {
  final Queue<Request> _queue;
  Timer? _timer;

  Sender(int intervalMs) : _queue = Queue() {
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), _run);
  }
  void push(Request request) {
    _queue.add(request);
  }

  void pushAll(Iterable<Request> iterable) {
    _queue.addAll(iterable);
  }

  void _run(Timer timer) {
    if (_queue.isNotEmpty) {
      (_queue.removeFirst())();
    }
  }
}
