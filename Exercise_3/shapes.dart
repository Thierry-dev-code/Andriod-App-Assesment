abstract interface class Drawable {
  void draw();
}

class Circle implements Drawable {
  final int radius;
  Circle(this.radius);

  @override
  void draw() {
    print('Circle with radius $radius:');
    print('  ***  ');
    print(' *   * ');
    print('  ***  ');
  }
}

class Square implements Drawable {
  final int side;
  Square(this.side);

  @override
  void draw() {
    print('Square with side $side:');
    print('*****');
    print('*   *');
    print('*   *');
    print('*****');
  }
}

void main() {
  List<Drawable> shapes = [
    Circle(5),
    Square(4),
  ];

  for (var shape in shapes) {
    shape.draw();
    print('');
  }
}