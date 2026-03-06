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
  /// Reads student records from an Excel file.
  /// 
  /// [filePath] - Path to the Excel file
  /// Returns a CalculationResult with list of students or error
  /// 
  /// Expected Excel format:
  /// | Name | Course | Exam Mark |
  /// | John Doe | Mathematics | 85 |
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

      final students = <Student>[];
      var skippedRows = 0;
      var isFirstRow = true;

      // Process each row using forEach
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
          // Convert cells to values
          final rowData = row.map((cell) => cell?.value).toList();
          final student = Student.fromExcelRow(rowData);
          students.add(student);
        } on ArgumentError catch (e) {
          // Log error but continue processing other rows
          print('Warning: Skipping invalid row - ${e.message}');
          skippedRows++;
        }
      }

      if (students.isEmpty) {
        return CalculationError(
          errorMessage: 'No valid student records found in the file',
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
      
      // Remove default sheet and create 'Results' sheet
      excel.delete('Sheet1');
      final sheet = excel['Results'];

      // Add header row with styling
      final headers = ['Name', 'Course', 'Exam Mark', 'Grade'];
      final headerStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      // Write headers
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // Write student data using forEach
      var rowIndex = 1;
      for (final student in students) {
        final rowData = student.toExcelRow();
        for (var colIndex = 0; colIndex < rowData.length; colIndex++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: colIndex, rowIndex: rowIndex),
          );
          
          // Handle different value types
          final value = rowData[colIndex];
          if (value is int) {
            cell.value = IntCellValue(value);
          } else {
            cell.value = TextCellValue(value.toString());
          }

          // Style grade column based on value
          if (colIndex == 3) {
            cell.cellStyle = _getGradeStyle(student.grade);
          }
        }
        rowIndex++;
      }

      // Set column widths for better readability
      sheet.setColumnWidth(0, 20); // Name
      sheet.setColumnWidth(1, 15); // Course
      sheet.setColumnWidth(2, 12); // Exam Mark
      sheet.setColumnWidth(3, 8);  // Grade

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

  /// Checks if a row is empty (all cells are null or empty).
  bool _isEmptyRow(List<Data?> row) {
    return row.every((cell) {
      if (cell == null) return true;
      final value = cell.value;
      if (value == null) return true;
      if (value is String && value.trim().isEmpty) return true;
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
