import 'package:metrics_core/src/domain/entities/password_validation_error_code.dart';
import 'package:metrics_core/src/domain/entities/validation_exception.dart';

/// Represents the password validation exception.
class PasswordValidationException
    extends ValidationException<PasswordValidationErrorCode> {
  @override
  final PasswordValidationErrorCode code;


  /// Creates the [PasswordValidationException] with the given [code].
  ///
  /// [code] is the code of this error that specifies the concrete reason for the exception occurrence.
  /// Throws an [ArgumentError] if the [code] is null.
  PasswordValidationException(this.code);
}
