import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bucket Ball Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double bucketX = 0.0;
  double ballY = -1.0;
  double ballX = 0.0;
  double speed = 5.0;
  int score = 0;
  bool gameOver = false;
  bool isPaused = false;
  Random random = Random();
  late Future<void> ballMovement;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    ballY = -1.0;
    score = 0;
    gameOver = false;
    isPaused = false;
    ballMovement = _moveBall();
  }

  Future<void> _moveBall() async {
    const duration = Duration(milliseconds: 20);
    while (!gameOver && !isPaused) {
      setState(() {
        ballY += 0.02; // Make the ball fall down
      });

      // If the ball hits the bucket
      if (ballY >= 0.8 && (ballX - bucketX).abs() < 0.1) {
        score += 1;
        ballY = -1.0; // Reset ball position
        ballX = random.nextDouble() * 2 - 1; // Randomize ball X position
      }

      // If the ball falls beyond the screen
      if (ballY > 1.0) {
        gameOver = true;
      }

      await Future.delayed(duration);
    }
  }

  void _moveBucket(double newPosition) {
    setState(() {
      bucketX = newPosition;
    });
  }

  void _pauseGame() {
    setState(() {
      isPaused = !isPaused;
    });
    if (isPaused) {
      // Pause the ball movement by stopping the Future
      ballMovement = Future.value();
    } else {
      // Resume the ball movement
      ballMovement = _moveBall();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bucket Ball Game'),
        actions: [
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _pauseGame,
          ),
          IconButton(
            icon: Icon(Icons.replay),
            onPressed: _startGame,
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          double newPosition = details.localPosition.dx /
              MediaQuery.of(context).size.width *
              2 -
              1;
          if (newPosition >= -1 && newPosition <= 1) {
            _moveBucket(newPosition);
          }
        },
        child: Stack(
          children: [
            // Use an image for the bucket instead of a container
            Positioned(
              left: (MediaQuery.of(context).size.width / 2 - 50) *
                  (bucketX + 1),
              bottom: 20,
              child: Image.asset(
                'assets/images/bucket.png', // Path to your bucket image
                width: 50,  // Set both width and height to make it square
                height: 50, // Set both width and height to make it square
                fit: BoxFit.fill,
              ),
            ),
            // Ball
            Positioned(
              left: (MediaQuery.of(context).size.width / 2 - 10) *
                  (ballX + 1),
              top: MediaQuery.of(context).size.height * ballY,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Game Over screen
            if (gameOver)
              Center(
                child: Text(
                  'Game Over\nScore: $score',
                  style: TextStyle(fontSize: 30, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            // Score display
            Positioned(
              bottom: 20,
              left: 20,
              child: Text(
                'Score: $score',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
