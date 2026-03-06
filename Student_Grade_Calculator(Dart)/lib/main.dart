import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'ui/console_mode.dart';
import 'ui/gui_mode.dart';

/// Main entry point for the Student Grade Calculator.
/// 
/// This application supports two modes:
/// 1. Console Mode - Command-line interface (run with: dart run lib/main.dart --console)
/// 2. GUI Mode - Graphical User Interface using Flutter (run with: flutter run)
/// 
/// When running with 'flutter run', GUI mode is launched automatically.
/// For console mode, use: dart run lib/main.dart --console
Future<void> main(List<String> arguments) async {
  // Check for command-line arguments
  if (arguments.isNotEmpty) {
    final mode = arguments.first.toLowerCase();
    
    if (mode == '--console' || mode == '-c') {
      await _runConsoleMode();
      return;
    } else if (mode == '--gui' || mode == '-g') {
      _runGuiMode();
      return;
    } else if (mode == '--help' || mode == '-h') {
      _printHelp();
      return;
    }
  }

  // When running with flutter run, stdin doesn't work properly
  // So we default to GUI mode and show instructions for console mode
  print('');
  print('=' * 50);
  print('     STUDENT GRADE CALCULATOR');
  print('=' * 50);
  print('');
  print('Starting GUI Mode...');
  print('');
  print('TIP: To run in Console Mode, use:');
  print('     dart run lib/main.dart --console');
  print('');
  print('=' * 50);
  
  _runGuiMode();
}

/// Runs the application in Console Mode.
Future<void> _runConsoleMode() async {
  print('');
  print('Starting Console Mode...');
  print('');
  
  final consoleMode = ConsoleMode();
  await consoleMode.run();
}

/// Runs the application in GUI Mode.
void _runGuiMode() {
  print('');
  print('Starting GUI Mode...');
  print('');
  
  runApp(const GuiMode());
}

/// Prints help information.
void _printHelp() {
  print('');
  print('=' * 50);
  print('     STUDENT GRADE CALCULATOR - HELP');
  print('=' * 50);
  print('');
  print('USAGE:');
  print('  flutter run                           Run GUI Mode (default)');
  print('  dart run lib/main.dart --console      Run Console Mode');
  print('  dart run lib/main.dart --help         Show this help');
  print('');
  print('OPTIONS:');
  print('  -c, --console    Run in Console Mode');
  print('  -g, --gui        Run in GUI Mode');
  print('  -h, --help       Show this help message');
  print('');
  print('DESCRIPTION:');
  print('  This application reads student records from an Excel file,');
  print('  calculates grades based on exam marks, and outputs results');
  print('  to a new Excel file (results.xlsx).');
  print('');
  print('GRADING SCALE:');
  print('  90 - 100  ->  A');
  print('  80 - 89   ->  B');
  print('  70 - 79   ->  C');
  print('  60 - 69   ->  D');
  print('  Below 60  ->  F');
  print('');
  print('EXCEL FILE FORMAT:');
  print('  The input Excel file must have the following columns:');
  print('  | Name | Course | Exam Mark |');
  print('');
  print('  Example:');
  print('  | John Doe | Mathematics | 85 |');
  print('  | John Doe | Physics     | 92 |');
  print('  | Mary Smith | Biology   | 74 |');
  print('');
  print('OUTPUT:');
  print('  A new file called "results.xlsx" will be created with:');
  print('  | Name | Course | Exam Mark | Grade |');
  print('');
  print('=' * 50);
  print('');
}


