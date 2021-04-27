import 'package:firebase_functions_interop/firebase_functions_interop.dart';

/// A class that represents a single status field of the build day.
class BuildDayStatusField {
  /// A name of this field.
  final String name;

  /// A [value] of this field.
  final FieldValue value;

  /// Creates a new instance of the [BuildDayStatusField].
  BuildDayStatusField({
    this.name,
    this.value,
  });
}
