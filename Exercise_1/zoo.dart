abstract class Animal {
  final String name;
  int get legs;

  Animal(this.name);

  void makeSound();
}

class Dog extends Animal {
  Dog(String name) : super(name);

  @override
  int get legs => 4;

  @override
  void makeSound() {
    print('$name says Woof!');
  }
}

class Cat extends Animal {
  Cat(String name) : super(name);

  @override
  int get legs => 4;

  @override
  void makeSound() {
    print('$name says Meow!');
  }
}

void main() {
  List<Animal> animals = [
    Dog('Buddy'),
    Cat('Whiskers'),
  ];

  for (var animal in animals) {
    animal.makeSound();
  }
}