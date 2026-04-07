/// Base class for all typed application errors.
sealed class AppError implements Exception {
  const AppError(this.message);
  final String message;
}

/// An error originating from a domain rule violation.
final class DomainError extends AppError {
  const DomainError(super.message);
}

/// An error from the infrastructure layer (I/O, network, DB).
final class InfrastructureError extends AppError {
  const InfrastructureError(super.message, {this.cause});
  final Object? cause;
}

/// An unexpected / unclassified runtime error.
final class UnexpectedError extends AppError {
  const UnexpectedError(
    super.message, {
    this.cause,
    this.stackTrace,
  });
  final Object? cause;
  final StackTrace? stackTrace;
}
