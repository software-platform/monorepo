import 'package:args/command_runner.dart';

/// A [CommandRunner] for the coverage converter CLI.
class CoverageConverterRunner extends CommandRunner<void> {
  /// Creates a new instance of the [CoverageConverterRunner]
  /// and registers all available sub-commands.
  CoverageConverterRunner()
      : super(
          'coverage_converter',
          'A coverage converter tool.',
        );
}
