# Student Grade Calculator

A complete Dart/Flutter application for calculating student grades from Excel files.
Supports both **Console Mode** and **GUI Mode**, and runs on **mobile** and **desktop** platforms.

## Features

- Read student records from Excel files (.xlsx, .xls)
- Calculate grades based on exam marks
- Display results in console or graphical interface
- Export results to a new Excel file (results.xlsx)
- Full Object-Oriented Design with:
  - Abstract classes and inheritance
  - Data classes with proper equals, hashCode, toString, copyWith
  - Sealed classes for state management
  - Null safety throughout
  - Lambda expressions and collection processing

## Grading Scale

| Mark Range | Grade |
|------------|-------|
| 90 - 100   | A     |
| 80 - 89    | B     |
| 70 - 79    | C     |
| 60 - 69    | D     |
| Below 60   | F     |

## Excel File Format

Your input Excel file must have the following structure:

| Name       | Course      | Exam Mark |
|------------|-------------|-----------|
| John Doe   | Mathematics | 85        |
| John Doe   | Physics     | 92        |
| Mary Smith | Biology     | 74        |

**Note:** A student can appear multiple times (for different courses).

## Installation

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (3.0.0 or higher)

### Setup

1. Clone or download this project
2. Navigate to the project directory:

```bash
cd student_grade_calculator
```

3. Install dependencies:

```bash
flutter pub get
```

## Running the Application

### Option 1: Interactive Mode Selection

```bash
flutter run
```

This will prompt you to choose between Console Mode and GUI Mode.

### Option 2: Direct Console Mode

```bash
dart run lib/main.dart --console
# or
dart run lib/main.dart -c
```

### Option 3: Direct GUI Mode

```bash
flutter run
# Then select GUI mode, or:
dart run lib/main.dart --gui
```

### Option 4: Run on Desktop

```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

### Option 5: Run on Mobile

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

### Help

```bash
dart run lib/main.dart --help
```

## Project Structure

```
student_grade_calculator/
├── lib/
│   ├── main.dart                    # Entry point with mode selection
│   ├── models/
│   │   └── student.dart             # Student data class
│   ├── calculators/
│   │   ├── calculator.dart          # Abstract Calculator class
│   │   └── grade_calculator.dart    # GradeCalculator implementation
│   ├── services/
│   │   └── excel_service.dart       # Excel read/write service
│   ├── ui/
│   │   ├── console_mode.dart        # Console Mode implementation
│   │   └── gui_mode.dart            # GUI Mode (Flutter) implementation
│   └── demo/
│       └── oop_demonstration.dart   # OOP concepts demonstration
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

## OOP Concepts Demonstrated

This project demonstrates key OOP concepts from the course materials:

### 1. Abstract Classes and Inheritance

```dart
// Abstract class
abstract class Calculator<T, R> {
  R calculate(T input);           // Abstract method
  List<R> calculateAll(List<T> inputs); // Abstract method
  bool validateInput(T input) { ... }  // Concrete method
}

// Concrete subclass
class GradeCalculator extends Calculator<Student, Student> {
  @override
  Student calculate(Student input) { ... }
}
```

### 2. Data Classes

```dart
class Student {
  final String name;
  final String course;
  final int examMark;
  final String? grade;  // Nullable

  // Factory constructor
  factory Student.fromExcelRow(List<dynamic> row) { ... }
  
  // copyWith (like Kotlin's copy())
  Student copyWith({String? name, String? grade, ...}) { ... }
  
  // Auto-implemented: toString, ==, hashCode
}
```

### 3. Sealed Classes for State Management

```dart
sealed class CalculationResult<T> {
  const CalculationResult();
}

class CalculationSuccess<T> extends CalculationResult<T> { ... }
class CalculationError<T> extends CalculationResult<T> { ... }
class CalculationLoading<T> extends CalculationResult<T> { ... }

// Exhaustive pattern matching
switch (result) {
  case CalculationSuccess(:final data):
    // Handle success
  case CalculationError(:final errorMessage):
    // Handle error
  case CalculationLoading():
    // Handle loading
}
```

### 4. Lambda Expressions and Collection Processing

```dart
// map() - Transform collection
final names = students.map((s) => s.name).toSet();

// where() / filter() - Filter collection
final highScorers = students.where((s) => s.examMark >= 80).toList();

// forEach() - Iterate collection
students.forEach((s) => print(s));

// fold() - Reduce collection
final total = students.fold<int>(0, (sum, s) => sum + s.examMark);
```

### 5. Null Safety

```dart
final String? grade;  // Nullable type
grade?.length         // Safe call
grade ?? 'N/A'        // Elvis operator (default value)
```

## Run OOP Demonstration

To see all OOP concepts in action:

```bash
dart run lib/demo/oop_demonstration.dart
```

## Dependencies

- `excel: ^4.0.3` - Read/write Excel files
- `file_picker: ^6.1.1` - File selection dialog
- `path_provider: ^2.1.2` - Get file system paths
- `path: ^1.8.3` - Path manipulation

## License

This project is for educational purposes as part of SE 3242 Android App Development course.
