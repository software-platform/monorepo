// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli/cli/updater/algorithm/update_algorithm.dart';
import 'package:cli/cli/updater/strings/update_strings.dart';
import 'package:cli/cli/updater/updater.dart';
import 'package:cli/common/constants/deploy_constants.dart';
import 'package:cli/common/model/config/update_config.dart';
import 'package:cli/common/model/paths/factory/paths_factory.dart';
import 'package:cli/common/model/paths/paths.dart';
import 'package:cli/common/strings/common_strings.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../test_utils/extension/error_answer.dart';
import '../../test_utils/matchers.dart';
import '../../test_utils/mock/directory_mock.dart';
import '../../test_utils/mock/file_helper_mock.dart';
import '../../test_utils/mock/path_factory_mock.dart';
import '../../test_utils/mock/prompter_mock.dart';

// ignore_for_file: avoid_redundant_argument_values, avoid_implementing_value_types, must_be_immutable

void main() {
  group("Updater", () {
    const tempDirectoryPath = 'tempDirectoryPath';
    const prefix = DeployConstants.tempDirectoryPrefix;

    final stateError = StateError('stateError');
    final paths = Paths(tempDirectoryPath);
    final updateAlgorithm = _UpdateAlgorithmMock();
    final fileHelper = FileHelperMock();
    final prompter = PrompterMock();
    final pathsFactory = PathsFactory();
    final pathsFactoryMock = PathsFactoryMock();
    final directory = DirectoryMock();
    final updater = Updater(
      updateAlgorithm: updateAlgorithm,
      fileHelper: fileHelper,
      pathsFactory: pathsFactory,
      prompter: prompter,
    );
    final config = _UpdateConfigMock();

    PostExpectation<Directory> whenCreateTempDirectory() {
      return when(fileHelper.createTempDirectory(any, any));
    }

    PostExpectation<bool> whenDirectoryExist({
      Directory withDirectory,
      String withPath,
    }) {
      final currentDirectory = withDirectory ?? directory;
      whenCreateTempDirectory().thenReturn(currentDirectory);

      final currentPath = withPath ?? tempDirectoryPath;
      when(currentDirectory.path).thenReturn(currentPath);

      return when(currentDirectory.existsSync());
    }

    tearDown(() {
      reset(updateAlgorithm);
      reset(fileHelper);
      reset(prompter);
      reset(pathsFactoryMock);
      reset(directory);
    });

    test(
      "throws an ArgumentError if the given update algorithm is null",
      () {
        expect(
          () => Updater(
            updateAlgorithm: null,
            fileHelper: fileHelper,
            prompter: prompter,
            pathsFactory: pathsFactory,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given FileHelper is null",
      () {
        expect(
          () => Updater(
            updateAlgorithm: updateAlgorithm,
            fileHelper: null,
            prompter: prompter,
            pathsFactory: pathsFactory,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given Prompter is null",
      () {
        expect(
          () => Updater(
            updateAlgorithm: updateAlgorithm,
            fileHelper: fileHelper,
            prompter: null,
            pathsFactory: pathsFactory,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given PathsFactory is null",
      () {
        expect(
          () => Updater(
            updateAlgorithm: updateAlgorithm,
            fileHelper: fileHelper,
            prompter: prompter,
            pathsFactory: null,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      ".update() creates a temporary directory",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(config);

        verify(fileHelper.createTempDirectory(any, prefix)).called(once);
      },
    );

    test(
      ".update() creates a temporary directory before creating the Paths instance",
      () async {
        final updater = Updater(
          updateAlgorithm: updateAlgorithm,
          fileHelper: fileHelper,
          pathsFactory: pathsFactoryMock,
          prompter: prompter,
        );

        whenDirectoryExist().thenReturn(true);
        when(pathsFactoryMock.create(tempDirectoryPath)).thenReturn(paths);

        await updater.update(config);

        verifyInOrder([
          fileHelper.createTempDirectory(any, any),
          pathsFactoryMock.create(tempDirectoryPath),
        ]);
      },
    );

    test(
      ".update() creates a Paths instance using the given factory",
      () async {
        final updater = Updater(
          updateAlgorithm: updateAlgorithm,
          fileHelper: fileHelper,
          pathsFactory: pathsFactoryMock,
          prompter: prompter,
        );

        whenDirectoryExist().thenReturn(true);
        when(pathsFactoryMock.create(tempDirectoryPath)).thenReturn(paths);

        await updater.update(config);

        verify(pathsFactoryMock.create(tempDirectoryPath)).called(once);
      },
    );

    test(
      ".update() creates a Paths instance before starting the update algorithm",
      () async {
        final updater = Updater(
          updateAlgorithm: updateAlgorithm,
          fileHelper: fileHelper,
          pathsFactory: pathsFactoryMock,
          prompter: prompter,
        );

        whenDirectoryExist().thenReturn(true);
        when(pathsFactoryMock.create(tempDirectoryPath)).thenReturn(paths);

        await updater.update(config);

        verifyInOrder([
          pathsFactoryMock.create(tempDirectoryPath),
          updateAlgorithm.start(config, paths),
        ]);
      },
    );

    test(
      ".update() starts the update algorithm",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(config);

        verify(updateAlgorithm.start(config, paths)).called(once);
      },
    );

    test(
      ".update() informs the user about the failed updating if the update algorithm throws",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(updateAlgorithm.start(config, paths)).thenAnswerError(
          stateError,
        );

        await updater.update(config);

        verify(prompter.error(
          UpdateStrings.failedUpdating(stateError),
        )).called(once);
      },
    );

    test(
      ".update() informs about deleting the temporary directory if the update algorithm throws",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(updateAlgorithm.start(config, paths)).thenAnswerError(stateError);

        await updater.update(config);

        verify(prompter.info(CommonStrings.deletingTempDirectory)).called(once);
      },
    );

    test(
      ".update() deletes the temporary directory if the update algorithm throws",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(updateAlgorithm.start(config, paths)).thenAnswerError(stateError);

        await updater.update(config);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".update() deletes the temporary directory if it exists",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(config);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".update() does not delete the temporary directory if it does not exist",
      () async {
        whenDirectoryExist().thenReturn(false);

        await updater.update(config);

        verifyNever(directory.deleteSync(recursive: true));
      },
    );

    test(
      ".update() informs about deleting the temporary directory",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(config);

        verify(prompter.info(CommonStrings.deletingTempDirectory)).called(once);
      },
    );

    test(
      ".update() informs about the successful deployment if deployment succeeds",
      () async {
        whenDirectoryExist().thenReturn(false);

        await updater.update(config);

        verify(prompter.info(UpdateStrings.successfulUpdating)).called(once);
      },
    );
  });
}

class _UpdateAlgorithmMock extends Mock implements UpdateAlgorithm {}

class _UpdateConfigMock extends Mock implements UpdateConfig {}
