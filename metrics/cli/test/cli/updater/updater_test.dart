// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli/cli/updater/strings/updater_strings.dart';
import 'package:cli/cli/updater/updater.dart';
import 'package:cli/common/constants/deploy_constants.dart';
import 'package:cli/common/model/config/firebase_config.dart';
import 'package:cli/common/model/config/sentry_config.dart';
import 'package:cli/common/model/config/sentry_web_config.dart';
import 'package:cli/common/model/config/update_config.dart';
import 'package:cli/common/model/config/web_metrics_config.dart';
import 'package:cli/common/model/paths/factory/paths_factory.dart';
import 'package:cli/common/model/paths/paths.dart';
import 'package:cli/common/model/services/services.dart';
import 'package:cli/common/strings/common_strings.dart';
import 'package:cli/services/sentry/model/sentry_project.dart';
import 'package:cli/services/sentry/model/sentry_release.dart';
import 'package:cli/services/sentry/model/source_map.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../test_utils/directory_mock.dart';
import '../../test_utils/file_helper_mock.dart';
import '../../test_utils/file_mock.dart';
import '../../test_utils/firebase_service_mock.dart';
import '../../test_utils/flutter_service_mock.dart';
import '../../test_utils/gcloud_service_mock.dart';
import '../../test_utils/git_service_mock.dart';
import '../../test_utils/matchers.dart';
import '../../test_utils/npm_service_mock.dart';
import '../../test_utils/path_factory_mock.dart';
import '../../test_utils/prompter_mock.dart';
import '../../test_utils/sentry_service_mock.dart';

// ignore_for_file: avoid_redundant_argument_values

void main() {
  const firebaseToken = 'firebaseToken';
  const projectId = 'projectId';
  const googleSignInClientId = 'googleSignInClientId';
  const sentryToken = 'sentryToken';
  const organizationSlug = 'organizationSlug';
  const projectSlug = 'projectSlug';
  const projectDsn = 'projectDsn';
  const releaseName = 'releaseName';
  const tempDirectoryPath = 'tempDirectoryPath';
  const deletingTempDirectory = CommonStrings.deletingTempDirectory;
  const firebaseTarget = DeployConstants.firebaseTarget;
  const tempDirectoryPrefix = DeployConstants.tempDirectoryPrefix;
  const repoURL = DeployConstants.repoURL;

  final paths = Paths(tempDirectoryPath);
  final firebasePath = paths.firebasePath;
  final webAppPath = paths.webAppPath;
  final metricsConfigPath = paths.metricsConfigPath;
  final firebaseFunctionsPath = paths.firebaseFunctionsPath;
  final webSourceMap = SourceMap(
    path: webAppPath,
    extensions: const ['dart'],
  );
  final buildSourceMap = SourceMap(
    path: paths.webAppBuildPath,
    extensions: const ['map', 'js'],
  );
  final sourceMaps = [webSourceMap, buildSourceMap];
  final firebaseConfig = FirebaseConfig(
    authToken: firebaseToken,
    projectId: projectId,
    googleSignInClientId: googleSignInClientId,
  );
  final sentryConfig = SentryConfig(
    authToken: sentryToken,
    organizationSlug: organizationSlug,
    projectSlug: projectSlug,
    projectDsn: projectDsn,
    releaseName: releaseName,
  );
  final updateConfig = UpdateConfig(
    firebaseConfig: firebaseConfig,
    sentryConfig: sentryConfig,
  );
  final sentryProject = SentryProject(
    projectSlug: sentryConfig.projectSlug,
    organizationSlug: sentryConfig.organizationSlug,
  );
  final sentryRelease = SentryRelease(
    name: sentryConfig.releaseName,
    project: sentryProject,
  );
  final sentryWebConfig = SentryWebConfig(
    release: sentryConfig.releaseName,
    dsn: sentryConfig.projectDsn,
    environment: DeployConstants.sentryEnvironment,
  );
  final config = WebMetricsConfig(
    googleSignInClientId: firebaseConfig.googleSignInClientId,
    sentryWebConfig: sentryWebConfig,
  );
  final environmentMap = config.toMap();

  final stateError = StateError('test');
  final failedUpdating = UpdateStrings.failedUpdating(stateError);
  final fileHelper = FileHelperMock();
  final prompter = PrompterMock();
  final pathsFactory = PathsFactory();
  final flutterService = FlutterServiceMock();
  final gcloudService = GCloudServiceMock();
  final npmService = NpmServiceMock();
  final gitService = GitServiceMock();
  final firebaseService = FirebaseServiceMock();
  final sentryService = SentryServiceMock();
  final directory = DirectoryMock();
  final pathsFactoryMock = PathsFactoryMock();
  final file = FileMock();
  final services = Services(
    flutterService: flutterService,
    gcloudService: gcloudService,
    npmService: npmService,
    gitService: gitService,
    firebaseService: firebaseService,
    sentryService: sentryService,
  );
  final updater = Updater(
    services: services,
    fileHelper: fileHelper,
    pathsFactory: pathsFactory,
    prompter: prompter,
  );

  PostExpectation<Directory> whenCreateTempDirectory() {
    return when(fileHelper.createTempDirectory(any, any));
  }

  PostExpectation<bool> whenDirectoryExist({
    Directory withDirectory,
    String withPath,
  }) {
    final currentDirectory = withDirectory ?? directory;
    final currentPath = withPath ?? tempDirectoryPath;

    whenCreateTempDirectory().thenReturn(currentDirectory);
    when(currentDirectory.path).thenReturn(currentPath);

    return when(currentDirectory.existsSync());
  }

  Future<StateError> errorAnswer(Invocation realInvocation) {
    return Future.error(stateError);
  }

  tearDown(() {
    reset(flutterService);
    reset(gcloudService);
    reset(npmService);
    reset(gitService);
    reset(firebaseService);
    reset(sentryService);
    reset(fileHelper);
    reset(directory);
    reset(prompter);
    reset(pathsFactoryMock);
  });

  group("Updater", () {
    test(
      "throws an ArgumentError if the given Services is null",
      () {
        expect(
          () => Updater(
            services: null,
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
            services: services,
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
            services: services,
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
            services: services,
            fileHelper: fileHelper,
            prompter: prompter,
            pathsFactory: null,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      ".update() throws an ArgumentError if the given config is null",
      () {
        expect(
          () => updater.update(null),
          throwsArgumentError,
        );
      },
    );

    test(
      ".update() creates a temporary directory",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verify(fileHelper.createTempDirectory(
          any,
          tempDirectoryPrefix,
        )).called(once);
      },
    );

    test(
      ".update() creates a temporary directory before creating the Paths instance",
      () async {
        final updater = Updater(
          fileHelper: fileHelper,
          pathsFactory: pathsFactoryMock,
          prompter: prompter,
          services: services,
        );

        whenDirectoryExist().thenReturn(true);
        when(pathsFactoryMock.create(tempDirectoryPath)).thenReturn(paths);

        await updater.update(updateConfig);

        verifyInOrder([
          fileHelper.createTempDirectory(any, tempDirectoryPrefix),
          pathsFactoryMock.create(tempDirectoryPath),
        ]);
      },
    );

    test(
      ".update() creates a Paths instance using the given factory",
      () async {
        final updater = Updater(
          fileHelper: fileHelper,
          pathsFactory: pathsFactoryMock,
          prompter: prompter,
          services: services,
        );

        whenDirectoryExist().thenReturn(true);
        when(pathsFactoryMock.create(tempDirectoryPath)).thenReturn(paths);

        await updater.update(updateConfig);

        verify(pathsFactoryMock.create(tempDirectoryPath)).called(once);
      },
    );

    test(
      ".update() creates a Paths instance before cloning the Git repository",
      () async {
        final updater = Updater(
          fileHelper: fileHelper,
          pathsFactory: pathsFactoryMock,
          prompter: prompter,
          services: services,
        );

        whenDirectoryExist().thenReturn(true);
        when(pathsFactoryMock.create(tempDirectoryPath)).thenReturn(paths);

        await updater.update(updateConfig);

        verifyInOrder([
          fileHelper.createTempDirectory(any, tempDirectoryPrefix),
          pathsFactoryMock.create(tempDirectoryPath),
        ]);
      },
    );

    test(
      ".update() clones the Git repository to the temporary directory",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verify(gitService.checkout(repoURL, tempDirectoryPath)).called(once);
      },
    );

    test(
      ".update() informs the user about the failed updating if Git service throws during the checkout process",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(gitService.checkout(
          repoURL,
          tempDirectoryPath,
        )).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(prompter.error(failedUpdating)).called(once);
      },
    );

    test(
      ".update() informs about deleting the temporary directory if Git service throws during the checkout process",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(gitService.checkout(
          repoURL,
          tempDirectoryPath,
        )).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(prompter.info(deletingTempDirectory)).called(once);
      },
    );

    test(
      ".update() deletes the temporary directory if Git service throws during the checkout process",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(gitService.checkout(
          repoURL,
          tempDirectoryPath,
        )).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".update() clones the Git repository before installing the Npm dependencies in the Firebase folder",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verifyInOrder([
          gitService.checkout(repoURL, tempDirectoryPath),
          npmService.installDependencies(firebasePath),
        ]);
      },
    );

    test(
      ".update() clones the Git repository before installing the Npm dependencies in the functions folder",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verifyInOrder([
          gitService.checkout(repoURL, tempDirectoryPath),
          npmService.installDependencies(firebaseFunctionsPath),
        ]);
      },
    );

    test(
      ".update() installs the npm dependencies in the Firebase folder",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verify(npmService.installDependencies(firebasePath)).called(once);
      },
    );

    test(
      ".update() installs the npm dependencies in the functions folder",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verify(npmService.installDependencies(
          firebaseFunctionsPath,
        )).called(once);
      },
    );

    test(
      ".update() informs the user about the failed updating if Npm service throws during the dependencies installing",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(npmService.installDependencies(any)).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(prompter.error(failedUpdating)).called(once);
      },
    );

    test(
      ".update() informs about deleting the temporary directory if Npm service throws during the dependencies installing",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(npmService.installDependencies(any)).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(prompter.info(deletingTempDirectory)).called(once);
      },
    );

    test(
      ".update() deletes the temporary directory if Npm service throws during the dependencies installing",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(npmService.installDependencies(any)).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".update() installs the npm dependencies in the Firebase folder before deploying Firebase components",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verifyInOrder([
          npmService.installDependencies(firebasePath),
          firebaseService.deployFirebase(
            projectId,
            firebasePath,
            firebaseToken,
          ),
        ]);
      },
    );

    test(
      ".update() installs the npm dependencies in the functions folder before deploying Firebase components",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verifyInOrder([
          npmService.installDependencies(firebaseFunctionsPath),
          firebaseService.deployFirebase(
            projectId,
            firebasePath,
            firebaseToken,
          ),
        ]);
      },
    );

    test(
      ".update() builds the Flutter application",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verify(flutterService.build(webAppPath)).called(once);
      },
    );

    test(
      ".update() informs the user about the failed updating if Flutter service throws during the web application building",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(flutterService.build(webAppPath)).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(prompter.error(failedUpdating)).called(once);
      },
    );

    test(
      ".update() informs about deleting the temporary directory if Flutter service throws during the web application building",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(flutterService.build(webAppPath)).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(prompter.info(deletingTempDirectory)).called(once);
      },
    );

    test(
      ".update() deletes the temporary directory if Flutter service throws during the web application building",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(flutterService.build(webAppPath)).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".update() builds the Flutter application before deploying to the hosting",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verifyInOrder([
          flutterService.build(webAppPath),
          firebaseService.deployHosting(
            projectId,
            firebaseTarget,
            webAppPath,
            firebaseToken,
          ),
        ]);
      },
    );

    test(
      ".update() builds the Flutter application before creating Sentry release",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verifyInOrder([
          flutterService.build(webAppPath),
          sentryService.createRelease(sentryRelease, sourceMaps, sentryToken),
        ]);
      },
    );

    test(
      ".update() does not create the Sentry release if the sentry config is null",
      () async {
        final updateConfig = UpdateConfig(
          firebaseConfig: firebaseConfig,
          sentryConfig: null,
        );

        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verifyNever(sentryService.createRelease(any, any));
      },
    );

    test(
      ".update() creates the Sentry release",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verify(sentryService.createRelease(
          sentryRelease,
          sourceMaps,
          sentryToken,
        )).called(once);
      },
    );

    test(
      ".update() informs the user about the failed updating if Sentry service throws during the release creation",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(sentryService.createRelease(
          sentryRelease,
          sourceMaps,
          sentryToken,
        )).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(prompter.error(failedUpdating)).called(once);
      },
    );

    test(
      ".update() informs about deleting the temporary directory if Sentry service throws during the release creation",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(sentryService.createRelease(
          sentryRelease,
          sourceMaps,
        )).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(prompter.info(deletingTempDirectory)).called(once);
      },
    );

    test(
      ".update() deletes the temporary directory if Sentry service throws during the release creation",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(sentryService.createRelease(
          sentryRelease,
          sourceMaps,
        )).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".update() gets the Metrics config file using the given FileHelper",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verify(fileHelper.getFile(metricsConfigPath)).called(once);
      },
    );

    test(
      ".update() informs the user about the failed updating if FileHelper throws during the Metrics config file getting",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(fileHelper.getFile(metricsConfigPath)).thenThrow(stateError);

        await updater.update(updateConfig);

        verify(prompter.error(failedUpdating)).called(once);
      },
    );

    test(
      ".update() informs about deleting the temporary directory if FileHelper throws during the Metrics config file getting",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(fileHelper.getFile(metricsConfigPath)).thenThrow(stateError);

        await updater.update(updateConfig);

        verify(prompter.info(deletingTempDirectory)).called(once);
      },
    );

    test(
      ".update() deletes the temporary directory if FileHelper throws during the Metrics config file getting",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(fileHelper.getFile(metricsConfigPath)).thenThrow(stateError);

        await updater.update(updateConfig);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".update() replaces the environment variables in the Metrics config file without sentry web configuration if the sentry config is null",
      () async {
        final updateConfig = UpdateConfig(
          firebaseConfig: firebaseConfig,
          sentryConfig: null,
        );
        final metricsConfig = WebMetricsConfig(
          googleSignInClientId: firebaseConfig.googleSignInClientId,
          sentryWebConfig: null,
        );
        final expectedEnvironmentMap = metricsConfig.toMap();

        when(fileHelper.getFile(metricsConfigPath)).thenReturn(file);
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verify(fileHelper.replaceEnvironmentVariables(
          file,
          expectedEnvironmentMap,
        )).called(once);
      },
    );

    test(
      ".update() replaces the environment variables in the Metrics config file",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(fileHelper.getFile(metricsConfigPath)).thenReturn(file);

        await updater.update(updateConfig);

        verify(fileHelper.replaceEnvironmentVariables(
          file,
          environmentMap,
        )).called(once);
      },
    );

    test(
      ".update() informs the user about the failed updating if FileHelper throws during replacing variables in the Metrics config file",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(fileHelper.getFile(metricsConfigPath)).thenReturn(file);
        when(fileHelper.replaceEnvironmentVariables(
          file,
          environmentMap,
        )).thenThrow(stateError);

        await updater.update(updateConfig);

        verify(prompter.error(failedUpdating)).called(once);
      },
    );

    test(
      ".update() informs about deleting the temporary directory if FileHelper throws during replacing variables in the Metrics config file",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(fileHelper.getFile(metricsConfigPath)).thenReturn(file);
        when(fileHelper.replaceEnvironmentVariables(
          file,
          environmentMap,
        )).thenThrow(stateError);

        await updater.update(updateConfig);

        verify(prompter.info(deletingTempDirectory)).called(once);
      },
    );

    test(
      ".update() deletes the temporary directory if FileHelper throws during replacing variables in the Metrics config file",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(fileHelper.getFile(metricsConfigPath)).thenReturn(file);
        when(fileHelper.replaceEnvironmentVariables(
          file,
          environmentMap,
        )).thenThrow(stateError);

        await updater.update(updateConfig);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".update() updates the Metrics config file before deploying to the hosting",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(fileHelper.getFile(metricsConfigPath)).thenReturn(file);

        await updater.update(updateConfig);

        verifyInOrder([
          fileHelper.replaceEnvironmentVariables(file, environmentMap),
          firebaseService.deployHosting(
            projectId,
            firebaseTarget,
            webAppPath,
            firebaseToken,
          ),
        ]);
      },
    );

    test(
      ".update() deploys Firebase components to the Firebase",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verify(firebaseService.deployFirebase(
          projectId,
          firebasePath,
          firebaseToken,
        )).called(once);
      },
    );

    test(
      ".update() informs the user about the failed updating if Firebase service throws during the Firebase components deployment",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(firebaseService.deployFirebase(
          projectId,
          firebasePath,
          firebaseToken,
        )).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(prompter.error(failedUpdating)).called(once);
      },
    );

    test(
      ".update() informs about deleting the temporary directory if Firebase service throws during the Firebase components deployment",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(firebaseService.deployFirebase(
          projectId,
          firebasePath,
        )).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(prompter.info(deletingTempDirectory)).called(once);
      },
    );

    test(
      ".update() deletes the temporary directory if Firebase service throws during the Firebase components deployment",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(firebaseService.deployFirebase(
          projectId,
          firebasePath,
        )).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".update() deploys Firebase components before deploying to the hosting",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verifyInOrder([
          firebaseService.deployFirebase(
            projectId,
            firebasePath,
            firebaseToken,
          ),
          firebaseService.deployHosting(
            projectId,
            firebaseTarget,
            webAppPath,
            firebaseToken,
          ),
        ]);
      },
    );

    test(
      ".update() deploys the target to the hosting",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verify(firebaseService.deployHosting(
          projectId,
          firebaseTarget,
          webAppPath,
          firebaseToken,
        )).called(once);
      },
    );

    test(
      ".update() informs the user about the failed updating if Firebase service throws during the Firebase hosting deployment",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(firebaseService.deployHosting(
          projectId,
          firebaseTarget,
          webAppPath,
          firebaseToken,
        )).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(prompter.error(failedUpdating)).called(once);
      },
    );

    test(
      ".update() informs about deleting the temporary directory if Firebase service throws during the Firebase hosting deployment",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(firebaseService.deployHosting(
          projectId,
          firebaseTarget,
          webAppPath,
        )).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(prompter.info(deletingTempDirectory)).called(once);
      },
    );

    test(
      ".update() deletes the temporary directory if Firebase service throws during the Firebase hosting deployment",
      () async {
        whenDirectoryExist().thenReturn(true);
        when(firebaseService.deployHosting(
          projectId,
          firebaseTarget,
          webAppPath,
        )).thenAnswer(errorAnswer);

        await updater.update(updateConfig);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".update() deletes the temporary directory if it exists",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verify(directory.deleteSync(recursive: true)).called(once);
      },
    );

    test(
      ".update() informs about deleting the temporary directory",
      () async {
        whenDirectoryExist().thenReturn(true);

        await updater.update(updateConfig);

        verify(prompter.info(deletingTempDirectory)).called(once);
      },
    );

    test(
      ".update() does not delete the temporary directory if it does not exist",
      () async {
        whenDirectoryExist().thenReturn(false);

        await updater.update(updateConfig);

        verifyNever(directory.delete(recursive: true));
      },
    );

    test(
      ".update() informs about the successful updating if update succeeds",
      () async {
        whenDirectoryExist().thenReturn(false);

        await updater.update(updateConfig);

        verify(prompter.info(UpdateStrings.successfulUpdating)).called(once);
      },
    );
  });
}
