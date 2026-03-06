/// Student data class that stores student information.
/// 
/// This follows the data class pattern from Kotlin, implementing:
/// - Named constructor
/// - toString() override
/// - Equality (== operator) override
/// - hashCode override
/// - copyWith method (equivalent to Kotlin's copy())
class Student {
  final String name;
  final String course;
  final int examMark;
  final String? grade; // Nullable - grade is calculated later

  /// Primary constructor with required parameters
  const Student({
    required this.name,
    required this.course,
    required this.examMark,
    this.grade,
  });

  /// Factory constructor to create Student from Excel row data
  /// Uses null safety - returns null if data is invalid
  factory Student.fromExcelRow(List<dynamic> row) {
    // Skip empty rows or rows with insufficient data
    if (row.length < 3) {
      throw ArgumentError('Row must have at least 3 columns: Name, Course, Exam Mark');
    }

    final name = row[0]?.toString().trim();
    final course = row[1]?.toString().trim();
    final markValue = row[2];

    // Null safety checks
    if (name == null || name.isEmpty) {
      throw ArgumentError('Student name cannot be empty');
    }
    if (course == null || course.isEmpty) {
      throw ArgumentError('Course name cannot be empty');
    }

    // Parse exam mark - handle both int and double from Excel
    int examMark;
    if (markValue is int) {
      examMark = markValue;
    } else if (markValue is double) {
      examMark = markValue.toInt();
    } else if (markValue is String) {
      examMark = int.tryParse(markValue) ?? 0;
    } else {
      throw ArgumentError('Exam mark must be a number');
    }

    return Student(
      name: name,
      course: course,
      examMark: examMark,
    );
  }

  /// Creates a copy of this Student with updated fields (Kotlin's copy() equivalent)
  Student copyWith({
    String? name,
    String? course,
    int? examMark,
    String? grade,
  }) {
    return Student(
      name: name ?? this.name,
      course: course ?? this.course,
      examMark: examMark ?? this.examMark,
      grade: grade ?? this.grade,
    );
  }

  /// Converts Student to a list for Excel output
  List<dynamic> toExcelRow() {
    return [name, course, examMark, grade ?? 'N/A'];
  }

  /// Override toString for readable output (Kotlin data class behavior)
  @override
  String toString() {
    return 'Student(name: $name, course: $course, examMark: $examMark, grade: ${grade ?? "Not calculated"})';
  }

  /// Override equality operator (Kotlin data class behavior)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Student &&
        other.name == name &&
        other.course == course &&
        other.examMark == examMark &&
        other.grade == grade;
  }

  /// Override hashCode (Kotlin data class behavior)
  @override
  int get hashCode {
    return Object.hash(name, course, examMark, grade);
  }
}
