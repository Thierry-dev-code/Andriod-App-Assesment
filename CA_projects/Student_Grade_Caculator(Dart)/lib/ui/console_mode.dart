import 'dart:io';
import '../calculators/calculator.dart';
import '../calculators/grade_calculator.dart';
import '../models/student.dart';
import '../services/excel_service.dart';

/// Console Mode for the Student Grade Calculator.
/// 
/// Provides a command-line interface for:
/// - Reading Excel files
/// - Calculating grades
/// - Displaying results
/// - Saving results to Excel
class ConsoleMode {
  final ExcelService _excelService = ExcelService();
  final GradeCalculator _gradeCalculator = GradeCalculator();

  /// Runs the console mode application.
  Future<void> run() async {
    _printHeader();
    
    // Get file path from user
    final filePath = _getFilePath();
    
    // Process the file
    await _processFile(filePath);
    
    _printFooter();
  }

  /// Prints the application header.
  void _printHeader() {
    print('');
    print('=' * 60);
    print('       STUDENT GRADE CALCULATOR - Console Mode');
    print('=' * 60);
    print('');
  }

  /// Prints the application footer.
  void _printFooter() {
    print('');
    print('=' * 60);
    print('       Thank you for using Student Grade Calculator');
    print('=' * 60);
    print('');
  }

  /// Gets the Excel file path from user input.
  String _getFilePath() {
    print('Enter the path to your Excel file:');
    print('(Example: /path/to/students.xlsx)');
    stdout.write('> ');
    
    final input = stdin.readLineSync()?.trim();
    
    if (input == null || input.isEmpty) {
      print('Error: No file path provided.');
      exit(1);
    }

    // Validate file extension
    if (!_excelService.isValidExcelFile(input)) {
      print('Error: File must have .xlsx or .xls extension.');
      exit(1);
    }

    return input;
  }

  /// Processes the Excel file and displays results.
  Future<void> _processFile(String filePath) async {
    print('');
    print('Processing file: $filePath');
    print('-' * 60);

    // Read students from Excel
    final readResult = await _excelService.readStudentsFromExcel(filePath);

    // Handle result using pattern matching (sealed class)
    switch (readResult) {
      case CalculationSuccess<List<Student>>(:final data, :final message):
        print('SUCCESS: $message');
        await _calculateAndDisplayGrades(data, filePath);
      
      case CalculationError<List<Student>>(:final errorMessage):
        print('ERROR: $errorMessage');
        exit(1);
      
      case CalculationLoading<List<Student>>():
        print('Loading...');
    }
  }

  /// Calculates grades and displays results.
  Future<void> _calculateAndDisplayGrades(
    List<Student> students,
    String inputPath,
  ) async {
    print('');
    print('Calculating grades for ${students.length} records...');
    print('-' * 60);

    // Calculate grades using the GradeCalculator
    final result = _gradeCalculator.processStudents(students);

    switch (result) {
      case CalculationSuccess<List<Student>>(:final data):
        // Display results in console
        _displayResults(data);
        
        // Display statistics
        _displayStatistics(data);
        
        // Save to Excel
        await _saveResults(data, inputPath);
      
      case CalculationError<List<Student>>(:final errorMessage):
        print('ERROR: $errorMessage');
        exit(1);
      
      case CalculationLoading<List<Student>>():
        print('Processing...');
    }
  }

  /// Displays student results in a formatted table.
  void _displayResults(List<Student> students) {
    print('');
    print('=' * 60);
    print('                    GRADE RESULTS');
    print('=' * 60);
    print('');

    // Print table header
    print(_formatTableRow('Name', 'Course', 'Mark', 'Grade'));
    print('-' * 60);

    // Print each student using forEach
    students.forEach((student) {
      print(_formatTableRow(
        student.name,
        student.course,
        student.examMark.toString(),
        student.grade ?? 'N/A',
      ));
    });

    print('-' * 60);
    print('Total Records: ${students.length}');
  }

  /// Formats a table row with proper spacing.
  String _formatTableRow(String col1, String col2, String col3, String col4) {
    return '${col1.padRight(20)} ${col2.padRight(15)} ${col3.padRight(8)} $col4';
  }

  /// Displays grade statistics.
  void _displayStatistics(List<Student> students) {
    print('');
    print('=' * 60);
    print('                  GRADE STATISTICS');
    print('=' * 60);
    print('');

    // Get grade distribution
    final distribution = _gradeCalculator.getGradeDistribution(students);
    
    // Display distribution
    distribution.forEach((grade, count) {
      final percentage = (count / students.length * 100).toStringAsFixed(1);
      final bar = '*' * (count * 2);
      print('Grade $grade: $count ($percentage%) $bar');
    });

    print('');

    // Group by student and show averages
    final groupedByStudent = _gradeCalculator.groupByStudentName(students);
    
    print('Student Averages:');
    print('-' * 40);
    
    groupedByStudent.forEach((name, records) {
      final average = _gradeCalculator.calculateStudentAverage(records);
      final avgGrade = _gradeCalculator.calculate(
        Student(name: name, course: '', examMark: average.round()),
      ).grade;
      print('$name: ${average.toStringAsFixed(1)} ($avgGrade)');
    });
  }

  /// Saves results to an Excel file.
  Future<void> _saveResults(List<Student> students, String inputPath) async {
    print('');
    print('=' * 60);
    print('                  SAVING RESULTS');
    print('=' * 60);
    print('');

    // Determine output path
    final outputPath = _excelService.getOutputPath(inputPath);
    
    print('Saving results to: $outputPath');

    final saveResult = await _excelService.writeResultsToExcel(
      students,
      outputPath: outputPath,
    );

    switch (saveResult) {
      case CalculationSuccess<String>(:final message):
        print('SUCCESS: $message');
      
      case CalculationError<String>(:final errorMessage):
        print('ERROR: $errorMessage');
      
      case CalculationLoading<String>():
        print('Saving...');
    }
  }
}

/// Extension methods for console output formatting.
extension ConsoleFormatting on Student {
  /// Formats the student for console display.
  String toConsoleString() {
    return '${name.padRight(20)} | ${course.padRight(15)} | '
        '${examMark.toString().padRight(5)} | ${grade ?? "N/A"}';
  }
}
