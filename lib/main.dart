import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: GameWidget(
          game: MyGame(),
        ),
      ),
    );
  }
}

class MyGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  late final Paddle leftPaddle;
  late final Paddle rightPaddle;
  late final Ball ball;
  final Random random = Random();
  @override
  void update(double dt) {
    if (leftPaddle.movement != PaddleMovement.idle) {
      final dy = dt *
          Paddle.speed *
          (leftPaddle.movement == PaddleMovement.up ? -1 : 1);
      leftPaddle.slideUpOrDown(dy);
    }
    if (rightPaddle.movement != PaddleMovement.idle) {
      final dy = dt *
          Paddle.speed *
          (rightPaddle.movement == PaddleMovement.up ? -1 : 1);
      rightPaddle.slideUpOrDown(dy);
    }

    ball.position += Vector2(
      ball.movement.x * dt * ball.speed,
      ball.movement.y * dt * ball.speed,
    );

    ball.position = Vector2(
      ball.position.x.clamp(
        maxValue,
        minValue(size.x),
      ),
      ball.position.y.clamp(
        maxValue,
        minValue(size.y),
      ),
    );

    if (ball.position.x == minValue(size.x) || ball.position.x == maxValue) {
      ball.movement = Vector2(-ball.movement.x, ball.movement.y);
    }
    if (ball.position.y == minValue(size.y) || ball.position.y == maxValue) {
      ball.movement = Vector2(ball.movement.x, -ball.movement.y);
    }

    super.update(dt);
  }

  double minValue(double coordinate) => coordinate - ball.radius;
  double get maxValue => 0 + ball.radius;

  @override
  Future<void> onLoad() async {
    leftPaddle = Paddle(
      size: Vector2(20, 100),
      position: Vector2(size.x * 0.05, size.y * 0.5),
    );
    rightPaddle = Paddle(
      size: Vector2(20, 100),
      position: Vector2(
        size.x * 0.95,
        size.y * 0.5,
      ),
    );
    ball = Ball(
      radius: 20,
      position: Vector2(size.x * 0.5, size.y * 0.5),
    );
    ball.movement = randomVector();

    addAll([leftPaddle, rightPaddle, ball]);
  }

  Vector2 randomVector() => Vector2(random.nextDouble().clamp(0.2, 1), random.nextDouble(),);

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final keyDown = event is RawKeyDownEvent;

    if (event.logicalKey == LogicalKeyboardKey.keyW) {
      leftPaddle.movement = keyDown ? PaddleMovement.up : PaddleMovement.idle;
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyS) {
      leftPaddle.movement = keyDown ? PaddleMovement.down : PaddleMovement.idle;
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      rightPaddle.movement = keyDown ? PaddleMovement.up : PaddleMovement.idle;
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      rightPaddle.movement =
          keyDown ? PaddleMovement.down : PaddleMovement.idle;
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

class Paddle extends RectangleComponent with CollisionCallbacks, HasGameReference<MyGame> {
  Paddle({super.size, super.position}) : super(anchor: Anchor.center);

  PaddleMovement movement = PaddleMovement.idle;


  static const double speed = 300;
  void slideUpOrDown(double dy) =>
      position = Vector2(position.x, position.y + dy);

  @override
  onLoad() {
    add(RectangleHitbox(),);
    super.onLoad();
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if(other is Ball) {
      other.flipX();
      final intersection = intersectionPoints.first;
      final centerY = game.ball.size.y - position.y;
      final collisionDistanceFromCenter = intersection.y - centerY;

      other.increaseSpeed();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}

class Ball extends CircleComponent with CollisionCallbacks{
  Ball({
    super.radius,
    super.position,
  }) : super(anchor: Anchor.center);


  late Vector2 movement;
  double speed = 700;

  void flipX() {
    movement = Vector2(-movement.x, movement.y);
  }

  void increaseSpeed() {
    speed = speed * 1.05;
  }

  @override
  Future<void> onLoad() async{
    add(CircleHitbox());
    super.onLoad();
  }
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollisionStart
    super.onCollisionStart(intersectionPoints, other);
  }
}

enum PaddleMovement { up, down, idle }
