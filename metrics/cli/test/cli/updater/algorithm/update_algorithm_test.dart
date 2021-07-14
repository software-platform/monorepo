// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/cli/updater/algorithm/update_algorithm.dart';
import 'package:cli/common/constants/deploy_constants.dart';
import 'package:cli/common/model/config/firebase_config.dart';
import 'package:cli/common/model/config/sentry_config.dart';
import 'package:cli/common/model/config/sentry_web_config.dart';
import 'package:cli/common/model/config/update_config.dart';
import 'package:cli/common/model/config/web_metrics_config.dart';
import 'package:cli/common/model/paths/paths.dart';
import 'package:cli/common/model/services/services.dart';
import 'package:cli/services/sentry/model/sentry_project.dart';
import 'package:cli/services/sentry/model/sentry_release.dart';
import 'package:cli/services/sentry/model/source_map.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../test_utils/extension/error_answer.dart';
import '../../../test_utils/matchers.dart';
import '../../../test_utils/mock/file_helper_mock.dart';
import '../../../test_utils/mock/file_mock.dart';
import '../../../test_utils/mock/firebase_service_mock.dart';
import '../../../test_utils/mock/flutter_service_mock.dart';
import '../../../test_utils/mock/gcloud_service_mock.dart';
import '../../../test_utils/mock/git_service_mock.dart';
import '../../../test_utils/mock/npm_service_mock.dart';
import '../../../test_utils/mock/sentry_service_mock.dart';

// ignore_for_file: avoid_redundant_argument_values

void main() {
  group("UpdateAlgorithm", () {
    const repoUrl = DeployConstants.repoUrl;

    final stateError = StateError('test');
    final paths = Paths('root');
    final rootPath = paths.rootPath;
    final firebasePath = paths.firebasePath;
    final functionsPath = paths.firebaseFunctionsPath;
    final webAppPath = paths.webAppPath;
    final metricsConfigPath = paths.metricsConfigPath;

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
      authToken: 'firebaseToken',
      projectId: 'projectId',
      googleSignInClientId: 'googleSignInClientId',
    );
    final sentryConfig = SentryConfig(
      authToken: 'sentryToken',
      organizationSlug: 'organizationSlug',
      projectSlug: 'projectSlug',
      projectDsn: 'projectDsn',
      releaseName: 'releaseName',
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

    final projectId = firebaseConfig.projectId;
    final firebaseAuthToken = firebaseConfig.authToken;
    final sentryAuthToken = sentryConfig.authToken;

    final fileHelper = FileHelperMock();
    final flutterService = FlutterServiceMock();
    final gcloudService = GCloudServiceMock();
    final npmService = NpmServiceMock();
    final gitService = GitServiceMock();
    final firebaseService = FirebaseServiceMock();
    final sentryService = SentryServiceMock();
    final file = FileMock();
    final services = Services(
      flutterService: flutterService,
      gcloudService: gcloudService,
      npmService: npmService,
      gitService: gitService,
      firebaseService: firebaseService,
      sentryService: sentryService,
    );
    final updateAlgorithm = UpdateAlgorithm(
      services: services,
      fileHelper: fileHelper,
    );

    tearDown(() {
      reset(fileHelper);
      reset(flutterService);
      reset(gcloudService);
      reset(npmService);
      reset(gitService);
      reset(firebaseService);
      reset(sentryService);
      reset(file);
    });

    test(
      "throws an ArgumentError if the given Services is null",
      () {
        expect(
          () => UpdateAlgorithm(
            services: null,
            fileHelper: fileHelper,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given FileHelper is null",
      () {
        expect(
          () => UpdateAlgorithm(
            services: services,
            fileHelper: null,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      ".start() throws an ArgumentError if the given config is null",
      () {
        expect(
          updateAlgorithm.start(null, paths),
          throwsArgumentError,
        );
      },
    );

    test(
      ".start() throws an ArgumentError if the given paths is null",
      () {
        expect(
          updateAlgorithm.start(updateConfig, null),
          throwsArgumentError,
        );
      },
    );

    test(
      ".start() clones the Git repository to the root path",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verify(gitService.checkout(repoUrl, rootPath)).called(once);
      },
    );

    test(
      ".start() throws if the Git service throws during the checkout process",
      () {
        when(gitService.checkout(repoUrl, rootPath)).thenAnswerError(
          stateError,
        );

        expect(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );
      },
    );

    test(
      ".start() clones the Git repository before installing the npm dependencies in the Firebase folder",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verifyInOrder([
          gitService.checkout(repoUrl, rootPath),
          npmService.installDependencies(firebasePath),
        ]);
      },
    );

    test(
      ".start() clones the Git repository before installing the npm dependencies in the functions folder",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verifyInOrder([
          gitService.checkout(repoUrl, rootPath),
          npmService.installDependencies(functionsPath),
        ]);
      },
    );

    test(
      ".start() installs the npm dependencies in the Firebase folder",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verify(npmService.installDependencies(firebasePath)).called(once);
      },
    );

    test(
      ".start() installs the npm dependencies in the functions folder",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verify(npmService.installDependencies(functionsPath)).called(once);
      },
    );

    test(
      ".start() throws if the npm service throws during the installing npm dependencies in the Firebase folder",
      () {
        when(npmService.installDependencies(firebasePath)).thenAnswerError(
          stateError,
        );

        expect(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );
      },
    );

    test(
      ".start() throws if the npm service throws during the installing npm dependencies in the functions folder",
      () {
        when(npmService.installDependencies(functionsPath)).thenAnswerError(
          stateError,
        );

        expect(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );
      },
    );

    test(
      ".start() installs the npm dependencies in the Firebase folder before deploying Firebase components",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verifyInOrder([
          npmService.installDependencies(firebasePath),
          firebaseService.deployFirebase(
            projectId,
            firebasePath,
          ),
        ]);
      },
    );

    test(
      ".start() installs the npm dependencies in the functions folder before deploying Firebase components",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verifyInOrder([
          npmService.installDependencies(functionsPath),
          firebaseService.deployFirebase(
            projectId,
            firebasePath,
          ),
        ]);
      },
    );

    test(
      ".start() builds the Flutter application",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verify(flutterService.build(webAppPath)).called(once);
      },
    );

    test(
      ".start() throws if the Flutter service throws during the web application building",
      () {
        when(flutterService.build(webAppPath)).thenAnswerError(stateError);

        expect(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );
      },
    );

    test(
      ".start() builds the Flutter application before creating Sentry release",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verifyInOrder([
          flutterService.build(webAppPath),
          sentryService.createRelease(sentryRelease, sourceMaps),
        ]);
      },
    );

    test(
      ".start() builds the Flutter application before deploying to the hosting",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verifyInOrder([
          flutterService.build(webAppPath),
          firebaseService.deployHosting(
            projectId,
            DeployConstants.firebaseTarget,
            webAppPath,
          ),
        ]);
      },
    );

    test(
      ".start() does not initialize the Sentry service's authentication if the sentry config is null",
      () async {
        final config = UpdateConfig(
          firebaseConfig: firebaseConfig,
          sentryConfig: null,
        );

        await updateAlgorithm.start(config, paths);

        verifyNever(sentryService.initializeAuth(sentryAuthToken));
      },
    );

    test(
      ".start() does not create the Sentry release if the sentry config is null",
      () async {
        final config = UpdateConfig(
          firebaseConfig: firebaseConfig,
          sentryConfig: null,
        );

        await updateAlgorithm.start(config, paths);

        verifyNever(sentryService.createRelease(any, any));
      },
    );

    test(
      ".start() does not reset the Sentry service's authentication if the sentry config is null",
      () async {
        final config = UpdateConfig(
          firebaseConfig: firebaseConfig,
          sentryConfig: null,
        );

        await updateAlgorithm.start(config, paths);

        verifyNever(sentryService.resetAuth());
      },
    );

    test(
      ".start() initializes the Sentry service's authentication",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verify(sentryService.initializeAuth(sentryAuthToken)).called(once);
      },
    );

    test(
      ".start() throws if the Sentry service throws during initializing authentication",
      () {
        when(sentryService.initializeAuth(sentryAuthToken)).thenThrow(
          stateError,
        );

        expect(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );
      },
    );

    test(
      ".start() initializes the Sentry service's authentication before creating Sentry release",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verifyInOrder([
          sentryService.initializeAuth(sentryAuthToken),
          sentryService.createRelease(sentryRelease, sourceMaps),
        ]);
      },
    );

    test(
      ".start() creates the Sentry release",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verify(sentryService.createRelease(
          sentryRelease,
          sourceMaps,
        )).called(once);
      },
    );

    test(
      ".start() throws if the Sentry service throws during Sentry release creation",
      () {
        when(sentryService.createRelease(
          sentryRelease,
          sourceMaps,
        )).thenAnswerError(stateError);

        expect(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );
      },
    );

    test(
      ".start() resets the Sentry service's authentication if the Sentry service throws during release creation",
      () async {
        when(sentryService.createRelease(
          sentryRelease,
          sourceMaps,
        )).thenAnswerError(stateError);

        await expectLater(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );

        verify(sentryService.resetAuth()).called(once);
      },
    );

    test(
      ".start() resets the Sentry service's authentication",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verify(sentryService.resetAuth()).called(once);
      },
    );

    test(
      ".start() throws if the Sentry service throws during resetting authentication",
      () {
        when(sentryService.resetAuth()).thenThrow(stateError);

        expect(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );
      },
    );

    test(
      ".start() gets the Metrics config file using the given FileHelper",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verify(fileHelper.getFile(metricsConfigPath)).called(once);
      },
    );

    test(
      ".start() throws if the FileHelper throws during getting the Metrics config file",
      () {
        when(fileHelper.getFile(metricsConfigPath)).thenThrow(stateError);

        expect(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );
      },
    );

    test(
      ".start() replaces the environment variables in the Metrics config file without sentry web configuration if the sentry config is null",
      () async {
        final config = UpdateConfig(
          firebaseConfig: firebaseConfig,
          sentryConfig: null,
        );
        final metricsConfig = WebMetricsConfig(
          googleSignInClientId: firebaseConfig.googleSignInClientId,
          sentryWebConfig: null,
        );
        final expectedEnvironmentMap = metricsConfig.toMap();

        when(fileHelper.getFile(metricsConfigPath)).thenReturn(file);

        await updateAlgorithm.start(config, paths);

        verify(fileHelper.replaceEnvironmentVariables(
          file,
          expectedEnvironmentMap,
        )).called(once);
      },
    );

    test(
      ".start() replaces the environment variables in the Metrics config file",
      () async {
        final environmentMap = config.toMap();

        when(fileHelper.getFile(metricsConfigPath)).thenReturn(file);

        await updateAlgorithm.start(updateConfig, paths);

        verify(fileHelper.replaceEnvironmentVariables(
          file,
          environmentMap,
        )).called(once);
      },
    );

    test(
      ".start() throws if the FileHelper throws during replacing environment variables in the Metrics config file",
      () {
        final environmentMap = config.toMap();

        when(fileHelper.getFile(metricsConfigPath)).thenReturn(file);
        when(fileHelper.replaceEnvironmentVariables(
          file,
          environmentMap,
        )).thenThrow(stateError);

        expect(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );
      },
    );

    test(
      ".start() updates the Metrics config file before deploying to the hosting",
      () async {
        final environmentMap = config.toMap();

        when(fileHelper.getFile(metricsConfigPath)).thenReturn(file);

        await updateAlgorithm.start(updateConfig, paths);

        verifyInOrder([
          fileHelper.replaceEnvironmentVariables(file, environmentMap),
          firebaseService.deployHosting(
            projectId,
            DeployConstants.firebaseTarget,
            webAppPath,
          ),
        ]);
      },
    );

    test(
      ".start() initializes the Firebase service's authentication",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verify(firebaseService.initializeAuth(firebaseAuthToken)).called(once);
      },
    );

    test(
      ".start() throws if the Firebase service throws during initializing authentication",
      () {
        when(firebaseService.initializeAuth(firebaseAuthToken)).thenThrow(
          stateError,
        );

        expect(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );
      },
    );

    test(
      ".start() initializes the Firebase service's authentication before deploying Firebase components",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verifyInOrder([
          firebaseService.initializeAuth(firebaseAuthToken),
          firebaseService.deployFirebase(
            projectId,
            firebasePath,
          ),
        ]);
      },
    );

    test(
      ".start() initializes the Firebase service's authentication before deploying to the hosting",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verifyInOrder([
          firebaseService.initializeAuth(firebaseAuthToken),
          firebaseService.deployHosting(
            projectId,
            DeployConstants.firebaseTarget,
            webAppPath,
          ),
        ]);
      },
    );

    test(
      ".start() deploys Firebase components to the Firebase",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verify(firebaseService.deployFirebase(
          projectId,
          firebasePath,
        )).called(once);
      },
    );

    test(
      ".start() throws if the Firebase service throws during Firebase components deployment",
      () {
        when(firebaseService.deployFirebase(
          projectId,
          firebasePath,
        )).thenAnswerError(stateError);

        expect(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );
      },
    );

    test(
      ".start() resets the Firebase service's authentication if the Firebase service throws during Firebase components deployment",
      () async {
        when(firebaseService.deployFirebase(
          projectId,
          firebasePath,
        )).thenAnswerError(stateError);

        await expectLater(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );

        verify(firebaseService.resetAuth()).called(once);
      },
    );

    test(
      ".start() deploys Firebase components before deploying to the hosting",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verifyInOrder([
          firebaseService.deployFirebase(
            projectId,
            firebasePath,
          ),
          firebaseService.deployHosting(
            projectId,
            DeployConstants.firebaseTarget,
            webAppPath,
          ),
        ]);
      },
    );

    test(
      ".start() deploys the target to the hosting",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verify(firebaseService.deployHosting(
          projectId,
          DeployConstants.firebaseTarget,
          webAppPath,
        )).called(once);
      },
    );

    test(
      ".start() throws if Firebase service throws during hosting deployment",
      () {
        when(firebaseService.deployHosting(
          projectId,
          DeployConstants.firebaseTarget,
          webAppPath,
        )).thenAnswerError(stateError);

        expect(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );
      },
    );

    test(
      ".start() resets the Firebase service's authentication",
      () async {
        await updateAlgorithm.start(updateConfig, paths);

        verify(firebaseService.resetAuth()).called(once);
      },
    );

    test(
      ".start() throws if the Firebase service throws during resetting authentication",
      () {
        when(firebaseService.resetAuth()).thenThrow(stateError);

        expect(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );
      },
    );

    test(
      ".start() resets the Firebase service's authentication if the Firebase service throws during hosting deployment",
      () async {
        when(firebaseService.deployHosting(
          projectId,
          DeployConstants.firebaseTarget,
          webAppPath,
        )).thenAnswerError(stateError);

        await expectLater(
          updateAlgorithm.start(updateConfig, paths),
          throwsA(stateError),
        );

        verify(firebaseService.resetAuth()).called(once);
      },
    );
  });
}
