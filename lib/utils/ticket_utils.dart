// Simple Ticker for recording time (not using flutter's TickerProvider)
class Ticker {
  final void Function(Duration) onTick;
  bool _running = false;
  late final Stopwatch _sw;

  Ticker(this.onTick) {
    _sw = Stopwatch();
  }

  void start() {
    if (_running) return;
    _running = true;
    _sw.reset();
    _sw.start();
    _loop();
  }

  void _loop() async {
    while (_running) {
      await Future.delayed(const Duration(milliseconds: 250));
      onTick(_sw.elapsed);
    }
  }

  void stop() {
    _running = false;
    _sw.stop();
  }

  void dispose() {
    _running = false;
  }
}
