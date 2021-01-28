import 'package:ci_integration/integration/error/config_validation_error.dart';
import 'package:test/test.dart';

// ignore_for_file: avoid_redundant_argument_values

void main() {
  group("ConfigValidationError", () {
    const message = 'message';

    const defaultError = 'An error occurred during config validation: ';

    test(
      "creates an instance with the given message",
      () {
        final error = ConfigValidationError(message: message);

        expect(error.message, equals(message));
      },
    );

    test(
      ".toString() returns the error's message if the message is not null",
      () {
        const expectedError = '$defaultError$message';
        final error = ConfigValidationError(message: message);

        expect(error.toString(), equals(expectedError));
      },
    );

    test(
      ".toString() returns an empty string if the error's message is null",
      () {
        final error = ConfigValidationError(message: null);

        expect(error.toString(), equals(defaultError));
      },
    );
  });
}
