import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as path;
import '../models/student.dart';
import '../calculators/calculator.dart';

/// Service class for reading and writing Excel files.
/// 
/// Follows Single Responsibility Principle - handles only Excel operations.
/// Uses null safety throughout.
class ExcelService {
  // Flexible column name mappings - supports multiple variations
  static final List<String> _nameVariations = [
    'name', 'student name', 'student_name', 'studentname', 'full name', 
    'fullname', 'full_name', 'student', 'nama', 'nom', 'nombre',
    'learner', 'pupil', 'candidate', 'participant'
  ];
  
  static final List<String> _courseVariations = [
    'course', 'subject', 'course name', 'course_name', 'coursename',
    'class', 'module', 'subject name', 'subject_name', 'mata pelajaran',
    'unit', 'paper', 'topic', 'lesson', 'discipline'
  ];
  
  static final List<String> _markVariations = [
    'exam mark', 'exammark', 'exam_mark', 'mark', 'marks', 'score', 
    'grade', 'exam score', 'exam_score', 'examscore', 'result',
    'exam', 'test score', 'test_score', 'testscore', 'nilai', 'points',
    'percentage', 'percent', '%', 'total', 'final mark', 'final_mark',
    'obtained', 'obtained marks', 'final', 'assessment', 'value'
  ];

  /// Reads student records from an Excel file.
  /// 
  /// [filePath] - Path to the Excel file
  /// Returns a CalculationResult with list of students or error
  /// 
  /// Flexible Excel format - supports various column names and orders:
  /// | Name/Student | Course/Subject | Mark/Score/Exam Mark |
  Future<CalculationResult<List<Student>>> readStudentsFromExcel(String filePath) async {
    try {
      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        return CalculationError(
          errorMessage: 'File not found: $filePath',
        );
      }

      // Read the Excel file
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      // Get the first sheet
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName];

      if (sheet == null || sheet.rows.isEmpty) {
        return CalculationError(
          errorMessage: 'Excel file is empty or has no valid sheet',
        );
      }

      // Find column indices from header row
      final columnMapping = _detectColumnMapping(sheet.rows.first);
      
      if (columnMapping == null) {
        // Try without header - assume standard order (Name, Course, Mark)
        return _readWithoutHeader(sheet);
      }

      final students = <Student>[];
      var skippedRows = 0;
      var isFirstRow = true;

      // Process each row
      for (final row in sheet.rows) {
        // Skip header row
        if (isFirstRow) {
          isFirstRow = false;
          continue;
        }

        // Skip empty rows
        if (_isEmptyRow(row)) {
          skippedRows++;
          continue;
        }

        try {
          final student = _parseStudentRow(row, columnMapping);
          if (student != null) {
            students.add(student);
          } else {
            skippedRows++;
          }
        } on ArgumentError catch (e) {
          print('Warning: Skipping invalid row - ${e.message}');
          skippedRows++;
        }
      }

      if (students.isEmpty) {
        return CalculationError(
          errorMessage: 'No valid student records found. Please ensure your Excel file has columns for: Name, Course/Subject, and Mark/Score',
        );
      }

      return CalculationSuccess(
        data: students,
        message: 'Loaded ${students.length} records (skipped $skippedRows rows)',
      );
    } on Exception catch (e) {
      return CalculationError(
        errorMessage: 'Failed to read Excel file: ${e.toString()}',
        exception: e,
      );
    }
  }

  /// Detects column mapping from header row.
  /// Returns a map of column type to column index, or null if no valid header found.
  Map<String, int>? _detectColumnMapping(List<Data?> headerRow) {
    int? nameIndex;
    int? courseIndex;
    int? markIndex;

    for (var i = 0; i < headerRow.length; i++) {
      final cellValue = headerRow[i]?.value?.toString().toLowerCase().trim() ?? '';
      
      // Skip empty cells
      if (cellValue.isEmpty) continue;
      
      // Check for name column
      if (nameIndex == null && _matchesVariation(cellValue, _nameVariations)) {
        nameIndex = i;
      } 
      // Check for course column
      else if (courseIndex == null && _matchesVariation(cellValue, _courseVariations)) {
        courseIndex = i;
      } 
      // Check for mark column
      else if (markIndex == null && _matchesVariation(cellValue, _markVariations)) {
        markIndex = i;
      }
    }

    // If we found at least name and mark columns, we can proceed
    if (nameIndex != null && markIndex != null) {
      return {
        'name': nameIndex,
        'course': courseIndex ?? -1, // -1 means not found, will use default
        'mark': markIndex,
      };
    }
    
    // Fallback: try positional detection based on column count
    final nonEmptyCols = headerRow.where((c) => 
      c?.value != null && c!.value.toString().trim().isNotEmpty
    ).length;
    
    if (nonEmptyCols >= 3) {
      // Assume: Name (0), Course (1), Mark (2)
      return {'name': 0, 'course': 1, 'mark': 2};
    } else if (nonEmptyCols == 2) {
      // Assume: Name (0), Mark (1)
      return {'name': 0, 'course': -1, 'mark': 1};
    }

    return null;
  }
  
  /// Checks if a cell value matches any of the variations
  bool _matchesVariation(String cellValue, List<String> variations) {
    final lower = cellValue.toLowerCase().trim();
    
    // Exact match
    if (variations.contains(lower)) return true;
    
    // Partial match - check if cell contains any variation or vice versa
    for (final variation in variations) {
      if (lower.contains(variation) || variation.contains(lower)) {
        return true;
      }
      // Also check without spaces/underscores
      final normalizedCell = lower.replaceAll(RegExp(r'[\s_-]'), '');
      final normalizedVar = variation.replaceAll(RegExp(r'[\s_-]'), '');
      if (normalizedCell.contains(normalizedVar) || normalizedVar.contains(normalizedCell)) {
        return true;
      }
    }
    return false;
  }

  /// Reads Excel without header - assumes columns are in order: Name, Course, Mark
  /// Or just Name, Mark if only 2 columns
  Future<CalculationResult<List<Student>>> _readWithoutHeader(Sheet sheet) async {
    final students = <Student>[];
    var skippedRows = 0;

    for (final row in sheet.rows) {
      if (_isEmptyRow(row)) {
        skippedRows++;
        continue;
      }

      try {
        final rowData = row.map((cell) => cell?.value).toList();
        
        // Try to parse - handle 2 or 3+ column formats
        String? name;
        String course = 'General';
        int? mark;

        if (rowData.length >= 3) {
          // Standard format: Name, Course, Mark
          name = rowData[0]?.toString().trim();
          course = rowData[1]?.toString().trim() ?? 'General';
          mark = _parseMarkValue(rowData[2]);
        } else if (rowData.length == 2) {
          // Minimal format: Name, Mark
          name = rowData[0]?.toString().trim();
          mark = _parseMarkValue(rowData[1]);
        }

        // Skip if name looks like a header
        if (name != null && !_isLikelyHeader(name) && mark != null) {
          students.add(Student(name: name, course: course, examMark: mark));
        } else {
          skippedRows++;
        }
      } catch (e) {
        skippedRows++;
      }
    }

    if (students.isEmpty) {
      return CalculationError(
        errorMessage: 'No valid student records found. Please ensure your Excel file has at least Name and Mark/Score columns.',
      );
    }

    return CalculationSuccess(
      data: students,
      message: 'Loaded ${students.length} records (skipped $skippedRows rows)',
    );
  }

  /// Parses a student from a row using the detected column mapping.
  Student? _parseStudentRow(List<Data?> row, Map<String, int> columnMapping) {
    final nameIndex = columnMapping['name']!;
    final courseIndex = columnMapping['course']!;
    final markIndex = columnMapping['mark']!;

    // Get name
    final name = row.length > nameIndex ? row[nameIndex]?.value?.toString().trim() : null;
    if (name == null || name.isEmpty) return null;

    // Get course (use default if not found)
    String course = 'General';
    if (courseIndex >= 0 && row.length > courseIndex) {
      course = row[courseIndex]?.value?.toString().trim() ?? 'General';
    }

    // Get mark
    final markValue = row.length > markIndex ? row[markIndex]?.value : null;
    final mark = _parseMarkValue(markValue);
    if (mark == null) return null;

    return Student(name: name, course: course, examMark: mark);
  }

  /// Parses a mark value from various formats.
  int? _parseMarkValue(dynamic value) {
    if (value == null) return null;
    
    if (value is int) return value;
    if (value is double) return value.toInt();
    
    final stringValue = value.toString().trim();
    if (stringValue.isEmpty) return null;
    
    // Remove common suffixes like % or "marks"
    final cleanValue = stringValue
        .replaceAll('%', '')
        .replaceAll('marks', '')
        .replaceAll('mark', '')
        .replaceAll('points', '')
        .trim();
    
    return int.tryParse(cleanValue) ?? double.tryParse(cleanValue)?.toInt();
  }

  /// Checks if a value looks like a header (not actual data).
  bool _isLikelyHeader(String value) {
    final lower = value.toLowerCase();
    return _nameVariations.contains(lower) ||
           _courseVariations.contains(lower) ||
           _markVariations.contains(lower) ||
           lower == 'no' || lower == 'no.' || lower == '#' ||
           lower == 'id' || lower == 'sno' || lower == 's.no';
  }

  /// Writes student results to an Excel file.
  /// 
  /// [students] - List of students with grades
  /// [outputPath] - Path for the output file (defaults to 'results.xlsx')
  /// Returns a CalculationResult indicating success or failure
  Future<CalculationResult<String>> writeResultsToExcel(
    List<Student> students, {
    String? outputPath,
  }) async {
    try {
      // Create a new Excel workbook
      final excel = Excel.createExcel();
      
      // Use 'Sheet1' as the default first sheet for results
      final detailsSheet = excel['Sheet1'];
      final summarySheet = excel['Summary by Student'];

      // Styles
      final headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      // === DETAILS SHEET ===
      // Add header row
      final detailHeaders = ['Name', 'Course', 'Exam Mark', 'Grade'];
      for (var i = 0; i < detailHeaders.length; i++) {
        final cell = detailsSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(detailHeaders[i]);
        cell.cellStyle = headerStyle;
      }

      // Write student data
      var rowIndex = 1;
      for (final student in students) {
        final rowData = student.toExcelRow();
        for (var colIndex = 0; colIndex < rowData.length; colIndex++) {
          final cell = detailsSheet.cell(
            CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex),
          );
          
          final value = rowData[colIndex];
          if (value is int) {
            cell.value = IntCellValue(value);
          } else {
            cell.value = TextCellValue(value.toString());
          }

          if (colIndex == 3) {
            cell.cellStyle = _getGradeStyle(student.grade);
          }
        }
        rowIndex++;
      }

      // Set column widths
      detailsSheet.setColumnWidth(0, 20);
      detailsSheet.setColumnWidth(1, 15);
      detailsSheet.setColumnWidth(2, 12);
      detailsSheet.setColumnWidth(3, 8);

      // === SUMMARY SHEET (Grouped by Student) ===
      // Group students by name
      final studentGroups = <String, List<Student>>{};
      for (final student in students) {
        studentGroups.putIfAbsent(student.name, () => []).add(student);
      }

      // Summary headers
      final summaryHeaders = ['Student Name', 'Total Courses', 'Average Mark', 'Overall Grade', 'Courses & Grades'];
      for (var i = 0; i < summaryHeaders.length; i++) {
        final cell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(summaryHeaders[i]);
        cell.cellStyle = headerStyle;
      }

      // Write summary data
      var summaryRow = 1;
      for (final entry in studentGroups.entries) {
        final studentName = entry.key;
        final studentRecords = entry.value;
        
        final totalCourses = studentRecords.length;
        final avgMark = studentRecords.map((s) => s.examMark).reduce((a, b) => a + b) / totalCourses;
        final overallGrade = _calculateOverallGrade(avgMark);
        final coursesDetails = studentRecords.map((s) => '${s.course}: ${s.examMark} (${s.grade})').join(', ');

        // Name
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: summaryRow))
          .value = TextCellValue(studentName);
        
        // Total Courses
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: summaryRow))
          .value = IntCellValue(totalCourses);
        
        // Average Mark
        final avgCell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: summaryRow));
        avgCell.value = DoubleCellValue(double.parse(avgMark.toStringAsFixed(1)));
        
        // Overall Grade
        final gradeCell = summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: summaryRow));
        gradeCell.value = TextCellValue(overallGrade);
        gradeCell.cellStyle = _getGradeStyle(overallGrade);
        
        // Courses & Grades
        summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: summaryRow))
          .value = TextCellValue(coursesDetails);

        summaryRow++;
      }

      // Set summary column widths
      summarySheet.setColumnWidth(0, 20);
      summarySheet.setColumnWidth(1, 14);
      summarySheet.setColumnWidth(2, 14);
      summarySheet.setColumnWidth(3, 14);
      summarySheet.setColumnWidth(4, 60);

      // Determine output path
      final finalPath = outputPath ?? 'results.xlsx';
      
      // Encode and save the file
      final encodedBytes = excel.encode();
      if (encodedBytes == null) {
        return CalculationError(
          errorMessage: 'Failed to encode Excel file',
        );
      }

      final outputFile = File(finalPath);
      await outputFile.writeAsBytes(encodedBytes);

      return CalculationSuccess(
        data: finalPath,
        message: 'Results saved to: $finalPath',
      );
    } on Exception catch (e) {
      return CalculationError(
        errorMessage: 'Failed to write Excel file: ${e.toString()}',
        exception: e,
      );
    }
  }
  
  /// Calculates overall grade based on average mark
  String _calculateOverallGrade(double avgMark) {
    if (avgMark >= 70) return 'A';
    if (avgMark >= 60) return 'B';
    if (avgMark >= 50) return 'C';
    if (avgMark >= 40) return 'D';
    return 'F';
  }

  /// Checks if a row is empty (all cells are null or empty).
  bool _isEmptyRow(List<Data?> row) {
    return row.every((cell) {
      if (cell == null) return true;
      final value = cell.value;
      if (value == null) return true;
      // Convert CellValue to string before checking if empty
      final stringValue = value.toString();
      if (stringValue.trim().isEmpty) return true;
      return false;
    });
  }

  /// Returns cell style based on grade value.
  CellStyle _getGradeStyle(String? grade) {
    final color = switch (grade) {
      'A' => '#00B050', // Green
      'B' => '#92D050', // Light Green
      'C' => '#FFEB9C', // Yellow
      'D' => '#FFC000', // Orange
      'F' => '#FF0000', // Red
      _ => '#FFFFFF',   // White
    };

    return CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString(color),
    );
  }

  /// Gets the output file path in the same directory as input file.
  String getOutputPath(String inputPath) {
    final directory = path.dirname(inputPath);
    return path.join(directory, 'results.xlsx');
  }

  /// Validates that the file has a valid Excel extension.
  bool isValidExcelFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return extension == '.xlsx' || extension == '.xls';
  }
}
