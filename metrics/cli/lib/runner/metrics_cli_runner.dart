// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:cli/deploy/deploy_command.dart';
import 'package:cli/deploy/factory/deployer_factory.dart';
import 'package:cli/doctor/doctor_command.dart';

/// A [CommandRunner] implementation for the Metrics CLI.
class MetricsCliRunner extends CommandRunner<void> {
  /// Creates a new instance of the [MetricsCliRunner].
  ///
  /// Registers the [DeployCommand] and the [DoctorCommand] for this instance.
  MetricsCliRunner() : super('metrics', 'Metrics CLI.') {
    final deployerFactory = DeployerFactory();
    final deployCommand = DeployCommand(deployerFactory);
    final doctorCommand = DoctorCommand();

    addCommand(deployCommand);
    addCommand(doctorCommand);
  }
}
