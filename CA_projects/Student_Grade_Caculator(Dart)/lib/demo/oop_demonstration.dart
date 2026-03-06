import '../models/student.dart';
import '../calculators/grade_calculator.dart';
import '../calculators/calculator.dart';

/// Demonstrates OOP concepts from the course materials.
/// 
/// This function showcases:
/// - Abstract class usage
/// - Inheritance
/// - Data classes
/// - Sealed classes for state management
/// - Lambda expressions
/// - Collection processing (map, filter, forEach)
void demonstrateOopConcepts() {
  print('');
  print('=' * 60);
  print('          OOP CONCEPTS DEMONSTRATION');
  print('=' * 60);
  print('');

  // Create sample students (demonstrates data class)
  final students = [
    const Student(name: 'John Doe', course: 'Mathematics', examMark: 85),
    const Student(name: 'John Doe', course: 'Physics', examMark: 92),
    const Student(name: 'Mary Smith', course: 'Biology', examMark: 74),
    const Student(name: 'Jane Brown', course: 'Chemistry', examMark: 58),
  ];

  // 1. DATA CLASS DEMONSTRATION
  print('1. DATA CLASS DEMONSTRATION (Kotlin data class equivalent):');
  print('-' * 60);
  print('   toString() auto-generated: ${students.first}');
  print('   copyWith() method: ${students.first.copyWith(grade: 'B')}');
  print('   Equality check: ${students[0] == students[0]} (same object)');
  print('   hashCode: ${students.first.hashCode}');
  print('');

  // 2. INHERITANCE DEMONSTRATION
  // GradeCalculator extends abstract Calculator class
  final calculator = GradeCalculator();
  
  print('2. INHERITANCE DEMONSTRATION (extends abstract class):');
  print('-' * 60);
  print('   GradeCalculator extends Calculator<Student, Student>');
  print('   Overridden calculatorType: "${calculator.calculatorType}"');
  print('   Inherited validateInput(): ${calculator.validateInput(students.first)}');
  print('   toString() from Calculator: $calculator');
  print('');

  // 3. ABSTRACT METHOD IMPLEMENTATION
  print('3. ABSTRACT METHOD IMPLEMENTATION:');
  print('-' * 60);
  print('   calculate(Student) -> Student with grade');
  print('   calculateAll(List<Student>) -> List<Student> with grades');
  print('');
  final gradedStudents = calculator.calculateAll(students);
  gradedStudents.forEach((s) => print('   -> $s'));
  print('');

  // 4. LAMBDA EXPRESSIONS AND COLLECTION PROCESSING
  print('4. LAMBDA EXPRESSIONS & COLLECTION PROCESSING:');
  print('-' * 60);
  
  // map() - transform collection
  final names = students.map((s) => s.name).toSet();
  print('   map((s) => s.name).toSet()');
  print('   Result: $names');
  print('');
  
  // filter/where() - filter collection  
  final highScorers = gradedStudents.where((s) => s.examMark >= 80).toList();
  print('   where((s) => s.examMark >= 80)');
  print('   High scorers: ${highScorers.length} students');
  highScorers.forEach((s) => print('   -> ${s.name}: ${s.examMark} (${s.grade})'));
  print('');
  
  // forEach() - iterate collection
  print('   forEach() - Iterating grade distribution:');
  final distribution = calculator.getGradeDistribution(gradedStudents);
  distribution.forEach((grade, count) {
    final bar = '*' * (count * 5);
    print('   Grade $grade: $count $bar');
  });
  print('');
  
  // fold() - reduction
  final totalMarks = gradedStudents.fold<int>(0, (sum, s) => sum + s.examMark);
  print('   fold() - Total marks: $totalMarks');
  print('   Average: ${(totalMarks / gradedStudents.length).toStringAsFixed(1)}');
  print('');

  // 5. SEALED CLASS FOR STATE MANAGEMENT
  print('5. SEALED CLASS (Exhaustive Pattern Matching):');
  print('-' * 60);
  print('   sealed class CalculationResult<T>');
  print('   Subclasses: CalculationSuccess, CalculationError, CalculationLoading');
  print('');
  
  final result = calculator.processStudents(students);
  print('   Pattern matching with switch:');
  switch (result) {
    case CalculationSuccess(:final data, :final message):
      print('   SUCCESS: $message');
      print('   Data contains ${data.length} students');
    case CalculationError(:final errorMessage):
      print('   ERROR: $errorMessage');
    case CalculationLoading(:final statusMessage):
      print('   LOADING: $statusMessage');
  }
  print('');

  // 6. NULL SAFETY DEMONSTRATION
  print('6. NULL SAFETY DEMONSTRATION:');
  print('-' * 60);
  print('   Student.grade is String? (nullable)');
  print('   Before calculation: ${students.first.grade ?? "null"}');
  print('   After calculation: ${gradedStudents.first.grade ?? "null"}');
  print('   Safe access with ?.: ${gradedStudents.first.grade?.length}');
  print('   Elvis operator ??: ${students.first.grade ?? "No grade yet"}');
  print('');

  // 7. GROUPING STUDENTS
  print('7. ADVANCED COLLECTION OPERATIONS:');
  print('-' * 60);
  final grouped = calculator.groupByStudentName(gradedStudents);
  print('   Grouped by student name:');
  grouped.forEach((name, records) {
    final avg = calculator.calculateStudentAverage(records);
    print('   $name: ${records.length} courses, avg: ${avg.toStringAsFixed(1)}');
  });
  print('');

  print('=' * 60);
  print('          DEMONSTRATION COMPLETE');
  print('=' * 60);
  print('');
}

/// Main function to run the demonstration independently.
void main() {
  demonstrateOopConcepts();
}
