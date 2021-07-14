// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/cli/updater/algorithm/update_algorithm.dart';
import 'package:cli/cli/updater/updater.dart';
import 'package:cli/common/model/paths/factory/paths_factory.dart';
import 'package:cli/common/model/services/factory/services_factory.dart';
import 'package:cli/prompter/prompter.dart';
import 'package:cli/prompter/writer/io_prompt_writer.dart';
import 'package:cli/util/file/file_helper.dart';

/// A class providing method for creating an [Updater] instance.
class UpdaterFactory {
  /// A [ServicesFactory] class this factory uses to create the services.
  final ServicesFactory _servicesFactory;

  /// Creates a new instance of the [UpdaterFactory]
  /// with the given [ServicesFactory].
  ///
  /// The services factory defaults to the [ServicesFactory] instance.
  ///
  /// Throws an [ArgumentError] if the given services factory is `null`.
  UpdaterFactory([this._servicesFactory = const ServicesFactory()]) {
    ArgumentError.checkNotNull(_servicesFactory, 'servicesFactory');
  }

  /// Creates a new instance of the [Updater].
  Updater create() {
    const fileHelper = FileHelper();

    final services = _servicesFactory.create();
    final algorithm = UpdateAlgorithm(
      services: services,
      fileHelper: fileHelper,
    );
    final promptWriter = IOPromptWriter();
    final prompter = Prompter(promptWriter);
    final pathsFactory = PathsFactory();

    return Updater(
      updateAlgorithm: algorithm,
      fileHelper: fileHelper,
      prompter: prompter,
      pathsFactory: pathsFactory,
    );
  }
}
