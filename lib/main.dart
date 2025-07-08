import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'SnakePainter.dart';

void main() {
  runApp(SnakeGameApp());
}

class SnakeGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SnakeGame(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SnakeGame extends StatefulWidget {
  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  List<Offset> _snake = [Offset(300, 300)];
  Offset _food = Offset.zero;
  Offset _direction = Offset(1, 0); // Default moving right
  double _snakeSpeed = 4.0;
  final double segmentDistance = 10.0;
  final int initialLength = 10;
  final Random _rand = Random();
  int _score = 0;

  // 🎯 Food emojis
  final List<String> _foodEmojis = [
    '🍎',
    '🍇',
    '🍌',
    '🍕',
    '🍔',
    '🥕',
    '🍓',
    '🍪',
    '🧁',
    '🍩'
  ];
  String _currentFoodEmoji = '🍎';

  late Size _screenSize;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < initialLength; i++) {
      _snake.add(_snake.last - Offset(segmentDistance, 0));
    }
    _ticker = Ticker(_update)..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
    _generateFood(); // ✅ Safe here
  }

void _generateFood() {
  _food = Offset(
    30 + _rand.nextDouble() * (_screenSize.width - 60),
    30 + _rand.nextDouble() * (_screenSize.height - 60),
  );
  _currentFoodEmoji = _foodEmojis[_rand.nextInt(_foodEmojis.length)];
}

  void _update(Duration _) {
    setState(() {
      final Size size = MediaQuery.of(context).size;
      Offset head = _snake.first;
      Offset dir = _direction * _snakeSpeed;
      Offset newHead = head + dir;
      _snake.insert(0, newHead);

      // Wall collision
      if (_isCollidingWithWall(newHead, size)) {
        _gameOver();
        return;
      }

      // Food collision
      if ((newHead - _food).distance < 20) {
        _score++;
        _snakeSpeed += 0.1;
        _generateFood();
      } else {
        _snake.removeLast();
      }
    });
  }

  bool _isCollidingWithWall(Offset head, Size size) {
    return head.dx < 0 ||
        head.dy < 0 ||
        head.dx > size.width ||
        head.dy > size.height;
  }

  void _gameOver() {
    _ticker.stop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _snake = [Offset(300, 300)];
      _direction = Offset(1, 0);
      _snakeSpeed = 4.0;
      _score = 0;
      for (int i = 0; i < initialLength; i++) {
        _snake.add(_snake.last - Offset(segmentDistance, 0));
      }
      _generateFood();
      _ticker.start();
    });
  }

  void _onHover(PointerHoverEvent event) {
    Offset target = event.localPosition;
    Offset head = _snake.first;
    Offset diff = target - head;

    if (diff.distance > 0) {
      _direction = diff / diff.distance;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MouseRegion(
        onHover: _onHover,
        child: Stack(
          children: [
            CustomPaint(
              painter: SnakePainter(_snake, _food, _currentFoodEmoji),
              child: Container(),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: Text(
                'Score: $_score',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
