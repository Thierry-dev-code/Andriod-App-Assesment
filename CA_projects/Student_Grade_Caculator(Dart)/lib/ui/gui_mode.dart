import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../calculators/calculator.dart';
import '../calculators/grade_calculator.dart';
import '../models/student.dart';
import '../services/excel_service.dart';

/// GUI Mode for the Student Grade Calculator.
/// 
/// Provides a graphical user interface with:
/// - File selection button
/// - Process grades button
/// - Results display
/// - Status messages
class GuiMode extends StatelessWidget {
  const GuiMode({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Grade Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Blue primary
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      home: const GradeCalculatorScreen(),
    );
  }
}

/// Main screen for the Grade Calculator GUI.
class GradeCalculatorScreen extends StatefulWidget {
  const GradeCalculatorScreen({super.key});

  @override
  State<GradeCalculatorScreen> createState() => _GradeCalculatorScreenState();
}

class _GradeCalculatorScreenState extends State<GradeCalculatorScreen> {
  final ExcelService _excelService = ExcelService();
  final GradeCalculator _gradeCalculator = GradeCalculator();

  String? _selectedFilePath;
  List<Student>? _students;
  List<Student>? _gradedStudents;
  String _statusMessage = 'Select an Excel file to begin';
  bool _isProcessing = false;
  String? _outputPath;

  /// Handles file selection using file_picker.
  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        dialogTitle: 'Select Excel File',
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        
        if (filePath != null) {
          setState(() {
            _selectedFilePath = filePath;
            _students = null;
            _gradedStudents = null;
            _outputPath = null;
            _statusMessage = 'File selected: ${result.files.first.name}';
          });

          // Automatically read the file
          await _readExcelFile(filePath);
        }
      }
    } on Exception catch (e) {
      setState(() {
        _statusMessage = 'Error selecting file: $e';
      });
    }
  }

  /// Reads students from the selected Excel file.
  Future<void> _readExcelFile(String filePath) async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Reading Excel file...';
    });

    final result = await _excelService.readStudentsFromExcel(filePath);

    setState(() {
      _isProcessing = false;
      
      switch (result) {
        case CalculationSuccess<List<Student>>(:final data, :final message):
          _students = data;
          _statusMessage = message;
        
        case CalculationError<List<Student>>(:final errorMessage):
          _students = null;
          _statusMessage = 'Error: $errorMessage';
        
        case CalculationLoading<List<Student>>():
          _statusMessage = 'Loading...';
      }
    });
  }

  /// Processes grades for all students.
  Future<void> _processGrades() async {
    if (_students == null || _students!.isEmpty) {
      setState(() {
        _statusMessage = 'No students to process. Please select a file first.';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Calculating grades...';
    });

    // Simulate processing delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    final result = _gradeCalculator.processStudents(_students!);

    switch (result) {
      case CalculationSuccess<List<Student>>(:final data):
        // Save to Excel
        final outputPath = _excelService.getOutputPath(_selectedFilePath!);
        final saveResult = await _excelService.writeResultsToExcel(
          data,
          outputPath: outputPath,
        );

        setState(() {
          _isProcessing = false;
          _gradedStudents = data;
          
          switch (saveResult) {
            case CalculationSuccess<String>(:final data):
              _outputPath = data;
              _statusMessage = 'Grades calculated and saved to: $data';
            
            case CalculationError<String>(:final errorMessage):
              _statusMessage = 'Grades calculated but save failed: $errorMessage';
            
            case CalculationLoading<String>():
              _statusMessage = 'Saving...';
          }
        });
      
      case CalculationError<List<Student>>(:final errorMessage):
        setState(() {
          _isProcessing = false;
          _statusMessage = 'Error: $errorMessage';
        });
      
      case CalculationLoading<List<Student>>():
        setState(() {
          _statusMessage = 'Processing...';
        });
    }
  }

  /// Resets the application state.
  void _reset() {
    setState(() {
      _selectedFilePath = null;
      _students = null;
      _gradedStudents = null;
      _outputPath = null;
      _statusMessage = 'Select an Excel file to begin';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Grade Calculator'),
        centerTitle: true,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        actions: [
          if (_selectedFilePath != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              _buildStatusCard(colorScheme),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              _buildActionButtons(colorScheme),
              
              const SizedBox(height: 16),
              
              // Results Section
              Expanded(
                child: _buildResultsSection(colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the status card widget.
  Widget _buildStatusCard(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isProcessing
                      ? Icons.hourglass_top
                      : _gradedStudents != null
                          ? Icons.check_circle
                          : Icons.info_outline,
                  color: _gradedStudents != null
                      ? Colors.green
                      : colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_selectedFilePath != null) ...[
              const SizedBox(height: 8),
              Text(
                'File: ${_selectedFilePath!.split('/').last}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
              ),
            ],
            if (_outputPath != null) ...[
              const SizedBox(height: 4),
              Text(
                'Output: ${_outputPath!.split('/').last}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the action buttons row.
  Widget _buildActionButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _selectFile,
            icon: const Icon(Icons.file_upload),
            label: const Text('Select Excel File'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isProcessing || _students == null
                ? null
                : _processGrades,
            icon: _isProcessing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.calculate),
            label: Text(_isProcessing ? 'Processing...' : 'Process Grades'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the results section with student table.
  Widget _buildResultsSection(ColorScheme colorScheme) {
    final displayStudents = _gradedStudents ?? _students;

    if (displayStudents == null || displayStudents.isEmpty) {
      return Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_chart_outlined,
                size: 64,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No data to display',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select an Excel file to view student records',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Course',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Mark',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                if (_gradedStudents != null)
                  Expanded(
                    child: Text(
                      'Grade',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Table Body
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: displayStudents.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final student = displayStudents[index];
                return _buildStudentRow(student, colorScheme);
              },
            ),
          ),
          
          // Statistics Footer
          if (_gradedStudents != null) _buildStatisticsFooter(colorScheme),
        ],
      ),
    );
  }

  /// Builds a single student row.
  Widget _buildStudentRow(Student student, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(student.name),
          ),
          Expanded(
            flex: 2,
            child: Text(student.course),
          ),
          Expanded(
            child: Text(
              student.examMark.toString(),
              textAlign: TextAlign.center,
            ),
          ),
          if (student.grade != null)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getGradeColor(student.grade!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  student.grade!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the statistics footer.
  Widget _buildStatisticsFooter(ColorScheme colorScheme) {
    final distribution = _gradeCalculator.getGradeDistribution(_gradedStudents!);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: distribution.entries.map((entry) {
          return Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getGradeColor(entry.key),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.value}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Returns color based on grade.
  Color _getGradeColor(String grade) {
    return switch (grade) {
      'A' => const Color(0xFF16A34A), // Green
      'B' => const Color(0xFF65A30D), // Lime
      'C' => const Color(0xFFCA8A04), // Yellow
      'D' => const Color(0xFFEA580C), // Orange
      'F' => const Color(0xFFDC2626), // Red
      _ => Colors.grey,
    };
  }
}
