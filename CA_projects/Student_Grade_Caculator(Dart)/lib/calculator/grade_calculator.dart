import '../models/student.dart';
import 'calculator.dart';

/// GradeCalculator extends the abstract Calculator class.
/// 
/// Demonstrates:
/// - Inheritance (extends Calculator)
/// - Override of abstract methods
/// - Lambda expressions and collection processing
/// - Null safety
/// 
/// Grading Scale:
/// 90 - 100 -> A
/// 80 - 89  -> B
/// 70 - 79  -> C
/// 60 - 69  -> D
/// Below 60 -> F
class GradeCalculator extends Calculator<Student, Student> {
  /// Grade boundaries configuration
  /// Can be modified to support different grading scales
  final Map<String, int> _gradeBoundaries = {
    'A': 90,
    'B': 80,
    'C': 70,
    'D': 60,
    'F': 0,
  };

  @override
  String get calculatorType => 'Student Grade Calculator';

  /// Calculates the grade for a single student.
  /// 
  /// Uses pattern matching with when-like switch expression.
  /// Returns a new Student with the grade field populated.
  @override
  Student calculate(Student input) {
    final grade = _calculateGrade(input.examMark);
    return input.copyWith(grade: grade);
  }

  /// Calculates grades for all students in the list.
  /// 
  /// Uses collection processing with map() - demonstrates functional programming.
  /// [inputs] - List of students without grades
  /// Returns list of students with calculated grades
  @override
  List<Student> calculateAll(List<Student> inputs) {
    // Using map() lambda expression for collection processing
    return inputs.map((student) => calculate(student)).toList();
  }

  /// Private method to determine grade letter from exam mark.
  /// 
  /// Uses Dart's switch expression (similar to Kotlin's when).
  String _calculateGrade(int mark) {
    return switch (mark) {
      >= 90 && <= 100 => 'A',
      >= 80 && < 90 => 'B',
      >= 70 && < 80 => 'C',
      >= 60 && < 70 => 'D',
      _ => 'F',
    };
  }

  /// Alternative grade calculation using if expressions.
  /// Kept for demonstration purposes.
  String calculateGradeWithIf(int mark) {
    if (mark >= 90 && mark <= 100) {
      return 'A';
    } else if (mark >= 80) {
      return 'B';
    } else if (mark >= 70) {
      return 'C';
    } else if (mark >= 60) {
      return 'D';
    } else {
      return 'F';
    }
  }

  /// Validates that the student has valid exam mark.
  @override
  bool validateInput(Student input) {
    return input.examMark >= 0 && input.examMark <= 100;
  }

  /// Filters students by grade using lambda expression.
  /// 
  /// [students] - List of students with grades
  /// [targetGrade] - Grade to filter by (A, B, C, D, F)
  /// Returns filtered list of students
  List<Student> filterByGrade(List<Student> students, String targetGrade) {
    // Using filter() with lambda
    return students.where((student) => student.grade == targetGrade).toList();
  }

  /// Gets unique student names from the list.
  /// 
  /// Uses map() and toSet() for collection processing.
  Set<String> getUniqueStudentNames(List<Student> students) {
    return students.map((student) => student.name).toSet();
  }

  /// Groups students by their name.
  /// 
  /// A student can have multiple courses, so this groups all records.
  Map<String, List<Student>> groupByStudentName(List<Student> students) {
    final Map<String, List<Student>> grouped = {};
    
    // Using forEach for iteration
    students.forEach((student) {
      if (grouped.containsKey(student.name)) {
        grouped[student.name]!.add(student);
      } else {
        grouped[student.name] = [student];
      }
    });
    
    return grouped;
  }

  /// Calculates average mark for a specific student across all courses.
  /// 
  /// Uses fold() for reduction operation.
  double calculateStudentAverage(List<Student> studentRecords) {
    if (studentRecords.isEmpty) return 0.0;
    
    final totalMarks = studentRecords.fold<int>(
      0,
      (sum, student) => sum + student.examMark,
    );
    
    return totalMarks / studentRecords.length;
  }

  /// Gets grade distribution statistics.
  /// 
  /// Returns a map with grade counts.
  Map<String, int> getGradeDistribution(List<Student> students) {
    final distribution = <String, int>{
      'A': 0,
      'B': 0,
      'C': 0,
      'D': 0,
      'F': 0,
    };

    for (final student in students) {
      final grade = student.grade;
      if (grade != null && distribution.containsKey(grade)) {
        distribution[grade] = distribution[grade]! + 1;
      }
    }

    return distribution;
  }

  /// Processes students and returns a CalculationResult (sealed class usage).
  /// 
  /// Demonstrates sealed class pattern for state management.
  CalculationResult<List<Student>> processStudents(List<Student> students) {
    try {
      // Validate all inputs
      final invalidStudents = students.where((s) => !validateInput(s)).toList();
      
      if (invalidStudents.isNotEmpty) {
        return CalculationError(
          errorMessage: 'Found ${invalidStudents.length} students with invalid marks',
        );
      }

      // Calculate grades for all students
      final gradedStudents = calculateAll(students);
      
      return CalculationSuccess(
        data: gradedStudents,
        message: 'Successfully calculated grades for ${gradedStudents.length} records',
      );
    } on Exception catch (e) {
      return CalculationError(
        errorMessage: 'Failed to process students',
        exception: e,
      );
    }
  }

  @override
  String toString() {
    return 'GradeCalculator(boundaries: $_gradeBoundaries)';
  }
}
