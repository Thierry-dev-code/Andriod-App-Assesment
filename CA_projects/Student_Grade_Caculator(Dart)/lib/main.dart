import 'dart:io';
import 'package:flutter/material.dart';
import 'ui/console_mode.dart';
import 'ui/gui_mode.dart';

/// Main entry point for the Student Grade Calculator.
/// 
/// This application supports two modes:
/// 1. Console Mode - Command-line interface
/// 2. GUI Mode - Graphical User Interface using Flutter
/// 
/// The user selects the mode at startup.
void main(List<String> arguments) {
  // Check for command-line arguments
  if (arguments.isNotEmpty) {
    final mode = arguments.first.toLowerCase();
    
    if (mode == '--console' || mode == '-c') {
      _runConsoleMode();
      return;
    } else if (mode == '--gui' || mode == '-g') {
      _runGuiMode();
      return;
    } else if (mode == '--help' || mode == '-h') {
      _printHelp();
      return;
    }
  }

  // No arguments or invalid arguments - prompt user
  _promptModeSelection();
}

/// Prompts the user to select a mode.
void _promptModeSelection() {
  print('');
  print('=' * 50);
  print('     STUDENT GRADE CALCULATOR');
  print('=' * 50);
  print('');
  print('Please select a mode:');
  print('');
  print('  1. Console Mode (Command-line Interface)');
  print('  2. GUI Mode (Graphical User Interface)');
  print('');
  print('  Type "help" for usage instructions');
  print('');
  stdout.write('Enter your choice (1 or 2): ');

  final input = stdin.readLineSync()?.trim().toLowerCase();

  switch (input) {
    case '1':
    case 'console':
    case 'c':
      _runConsoleMode();
    case '2':
    case 'gui':
    case 'g':
      _runGuiMode();
    case 'help':
    case 'h':
      _printHelp();
      _promptModeSelection();
    default:
      print('');
      print('Invalid choice. Please enter 1 or 2.');
      _promptModeSelection();
  }
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
  print('  dart run [options]');
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


