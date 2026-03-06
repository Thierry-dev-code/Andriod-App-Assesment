/// Abstract class representing a general calculator.
/// 
/// This follows the OOP principles from the course material:
/// - Abstract class with abstract method (must be overridden)
/// - Defines a contract for subclasses
/// - Cannot be instantiated directly
/// 
/// Equivalent to Kotlin's:
/// ```kotlin
/// abstract class Calculator {
///     abstract fun calculate()
/// }
/// ```
abstract class Calculator<T, R> {
  /// Abstract method that must be implemented by subclasses.
  /// 
  /// [input] - The input data to calculate
  /// Returns the calculated result
  R calculate(T input);

  /// Abstract method to process a collection of inputs.
  /// 
  /// [inputs] - List of input data
  /// Returns a list of calculated results
  List<R> calculateAll(List<T> inputs);

  /// Template method pattern - provides default implementation
  /// that can be overridden by subclasses.
  /// 
  /// Validates input before calculation
  bool validateInput(T input) {
    return input != null;
  }

  /// Describes the calculator type - can be overridden
  String get calculatorType => 'Generic Calculator';

  @override
  String toString() {
    return calculatorType;
  }
}

/// Mixin for printable results (similar to Kotlin interface with default implementation)
/// 
/// Demonstrates interface-like behavior in Dart
mixin PrintableResult {
  /// Formats result for console output
  String formatForConsole();
  
  /// Formats result for file output
  String formatForFile();
}

/// Sealed class pattern for calculation results (Dart 3 feature)
/// 
/// Similar to Kotlin sealed classes - represents exhaustive states:
/// - Success: calculation completed successfully
/// - Error: calculation failed with message
/// 
/// This enables pattern matching with switch expressions
sealed class CalculationResult<T> {
  const CalculationResult();
}

/// Successful calculation result
class CalculationSuccess<T> extends CalculationResult<T> {
  final T data;
  final String message;

  const CalculationSuccess({
    required this.data,
    this.message = 'Calculation successful',
  });

  @override
  String toString() => 'Success: $message';
}

/// Failed calculation result
class CalculationError<T> extends CalculationResult<T> {
  final String errorMessage;
  final Exception? exception;

  const CalculationError({
    required this.errorMessage,
    this.exception,
  });

  @override
  String toString() => 'Error: $errorMessage';
}

/// Loading state for async calculations
class CalculationLoading<T> extends CalculationResult<T> {
  final String? statusMessage;

  const CalculationLoading({this.statusMessage});

  @override
  String toString() => 'Loading: ${statusMessage ?? "Processing..."}';
}
