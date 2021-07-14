// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/cli/updater/config/factory/update_config_factory.dart';
import 'package:cli/cli/updater/config/parser/update_config_parser.dart';
import 'package:cli/common/model/config/firebase_config.dart';
import 'package:cli/common/model/config/sentry_config.dart';
import 'package:cli/common/model/config/update_config.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../../test_utils/matchers.dart';
import '../../../../test_utils/mock/file_helper_mock.dart';
import '../../../../test_utils/mock/file_mock.dart';

// ignore_for_file: avoid_redundant_argument_values

void main() {
  group("UpdateConfigFactory", () {
    const configPath = 'configPath';
    const content = 'content';

    final fileHelper = FileHelperMock();
    final configParser = _UpdateConfigParserMock();
    final file = FileMock();
    final configFactory = UpdateConfigFactory(
      fileHelper: fileHelper,
      configParser: configParser,
    );

    PostExpectation<String> whenReadAsString({String withConfigPath}) {
      final path = withConfigPath ?? configPath;

      when(fileHelper.getFile(path)).thenReturn(file);
      return when(file.readAsStringSync());
    }

    tearDown(() {
      reset(fileHelper);
      reset(configParser);
      reset(file);
    });

    test(
      "creates an instance with the given parameters",
      () {
        final configFactory = UpdateConfigFactory(
          fileHelper: fileHelper,
          configParser: configParser,
        );

        expect(configFactory.fileHelper, equals(fileHelper));
        expect(configFactory.configParser, equals(configParser));
      },
    );

    test(
      "creates an instance with the default file helper, if the given one is null",
      () {
        final updateConfigFactory = UpdateConfigFactory(
          fileHelper: null,
          configParser: configParser,
        );

        expect(updateConfigFactory.fileHelper, isNotNull);
      },
    );

    test(
      "creates an instance with the default update config parser, if the given one is null",
      () {
        final updateConfigFactory = UpdateConfigFactory(
          fileHelper: fileHelper,
          configParser: null,
        );

        expect(updateConfigFactory.configParser, isNotNull);
      },
    );

    test(
      ".create() throws an ArgumentError if the given config path is null",
      () {
        expect(() => configFactory.create(null), throwsArgumentError);
      },
    );

    test(
      ".create() gets the configuration file using the given file helper",
      () {
        whenReadAsString().thenReturn(content);

        configFactory.create(configPath);

        verify(fileHelper.getFile(configPath)).called(once);
      },
    );

    test(
      ".create() reads the content of the configuration file as string",
      () {
        whenReadAsString().thenReturn(content);

        configFactory.create(configPath);

        verify(file.readAsStringSync()).called(once);
      },
    );

    test(
      ".create() parses the config file content using the given config parser",
      () {
        whenReadAsString().thenReturn(content);

        configFactory.create(configPath);

        verify(configParser.parse(content)).called(once);
      },
    );

    test(
      ".create() returns the config parsed by the update config parser",
      () {
        final firebaseConfig = FirebaseConfig(
          authToken: 'token',
          projectId: 'projectId',
          googleSignInClientId: 'google_sign_in_client_id',
        );
        final sentryConfig = SentryConfig(
          authToken: 'token',
          organizationSlug: 'organizationSlug',
          projectSlug: 'projectSlug',
          projectDsn: 'projectDsn',
          releaseName: 'releaseName',
        );
        final expectedConfig = UpdateConfig(
          firebaseConfig: firebaseConfig,
          sentryConfig: sentryConfig,
        );

        whenReadAsString().thenReturn(content);
        when(configParser.parse(content)).thenReturn(expectedConfig);

        final config = configFactory.create(configPath);

        expect(config, equals(expectedConfig));
      },
    );
  });
}

class _UpdateConfigParserMock extends Mock implements UpdateConfigParser {}
