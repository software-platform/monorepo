// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/util/file/file_helper.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../test_utils/matchers.dart';
import '../../test_utils/mock/directory_mock.dart';
import '../../test_utils/mock/file_mock.dart';

void main() {
  group("FileHelper", () {
    const prefix = 'prefix';
    const key1 = 'key1';
    const key2 = 'key2';
    const value1 = 'value1';
    const value2 = 'value2';
    const environment = <String, dynamic>{
      key1: value1,
      key2: value2,
    };
    const helper = FileHelper();

    final file = FileMock();
    final directory = DirectoryMock();

    tearDown(() {
      reset(file);
      reset(directory);
    });

    PostExpectation<bool> whenFileExists() {
      return when(file.existsSync());
    }

    test(
      ".getFile() returns the file with the given path",
      () {
        const path = 'testPath';

        final file = helper.getFile(path);

        expect(file.path, path);
      },
    );

    test(
      ".createTempDirectory() creates the temporary directory in the given directory",
      () {
        helper.createTempDirectory(directory, prefix);

        verify(directory.createTempSync(any)).called(once);
      },
    );

    test(
      ".createTempDirectory() creates the temporary directory with the given prefix",
      () {
        helper.createTempDirectory(directory, prefix);

        verify(directory.createTempSync(prefix)).called(once);
      },
    );

    test(
      ".createTempDirectory() throws an ArgumentError if the given directory is null",
      () {
        expect(
          () => helper.createTempDirectory(null, prefix),
          throwsArgumentError,
        );
      },
    );

    test(
      ".replaceEnvironmentVariables() throws an ArgumentError if the given file is null",
      () {
        expect(
          () => helper.replaceEnvironmentVariables(null, environment),
          throwsArgumentError,
        );
      },
    );

    test(
      ".replaceEnvironmentVariables() throws an ArgumentError if the given environment is null",
      () {
        expect(
          () => helper.replaceEnvironmentVariables(file, null),
          throwsArgumentError,
        );
      },
    );

    test(
      ".replaceEnvironmentVariables() does not read the content if the given environment is empty",
      () {
        whenFileExists().thenReturn(true);

        helper.replaceEnvironmentVariables(file, {});

        verifyNever(file.writeAsStringSync(any));
      },
    );

    test(
      ".replaceEnvironmentVariables() does not read the content if the given file does not exist",
      () async {
        whenFileExists().thenReturn(false);

        helper.replaceEnvironmentVariables(file, environment);

        verifyNever(file.writeAsStringSync(any));
      },
    );

    test(
      ".replaceEnvironmentVariables() replaces the environment variables in the given file by the values from the given environment",
      () async {
        const content = 'test=\$$key1; someField=\$$key2;';
        const expected = 'test=$value1; someField=$value2;';

        whenFileExists().thenReturn(true);
        when(file.readAsStringSync()).thenReturn(content);

        helper.replaceEnvironmentVariables(file, environment);

        verify(file.writeAsStringSync(expected)).called(once);
      },
    );
  });
}
