// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli/cli/deployer/strings/deploy_strings.dart';
import 'package:cli/common/constants/deploy_constants.dart';
import 'package:cli/common/model/config/sentry_web_config.dart';
import 'package:cli/common/model/config/web_metrics_config.dart';
import 'package:cli/common/model/paths/factory/paths_factory.dart';
import 'package:cli/common/model/paths/paths.dart';
import 'package:cli/common/model/services/services.dart';
import 'package:cli/common/strings/common_strings.dart';
import 'package:cli/prompter/prompter.dart';
import 'package:cli/services/firebase/firebase_service.dart';
import 'package:cli/services/flutter/flutter_service.dart';
import 'package:cli/services/gcloud/gcloud_service.dart';
import 'package:cli/services/git/git_service.dart';
import 'package:cli/services/npm/npm_service.dart';
import 'package:cli/services/sentry/model/sentry_release.dart';
import 'package:cli/services/sentry/model/source_map.dart';
import 'package:cli/services/sentry/sentry_service.dart';
import 'package:cli/util/file/file_helper.dart';

/// A class providing method for deploying the Metrics Web Application.
class Deployer {
  /// A service that provides methods for working with Flutter.
  final FlutterService _flutterService;

  /// A service that provides methods for working with GCloud.
  final GCloudService _gcloudService;

  /// A service that provides methods for working with Npm.
  final NpmService _npmService;

  /// A class that provides methods for working with the Git.
  final GitService _gitService;

  /// A class that provides methods for working with the Firebase.
  final FirebaseService _firebaseService;

  /// A class that provides methods for working with the Sentry.
  final SentryService _sentryService;

  /// A class that provides methods for working with the file system.
  final FileHelper _fileHelper;

  /// A [Prompter] class this deployer uses to interact with a user.
  final Prompter _prompter;

  /// A [PathsFactory] class uses to create the [Paths].
  final PathsFactory _pathsFactory;

  /// Creates a new instance of the [Deployer] with the given services.
  ///
  /// Throws an [ArgumentError] if the given [services] is `null`.
  /// Throws an [ArgumentError] if the given [Services.flutterService] is `null`.
  /// Throws an [ArgumentError] if the given [Services.gcloudService] is `null`.
  /// Throws an [ArgumentError] if the given [Services.npmService] is `null`.
  /// Throws an [ArgumentError] if the given [Services.gitService] is `null`.
  /// Throws an [ArgumentError] if the given [Services.firebaseService] is `null`.
  /// Throws an [ArgumentError] if the given [Services.sentryService] is `null`.
  /// Throws an [ArgumentError] if the given [fileHelper] is `null`.
  /// Throws an [ArgumentError] if the given [prompter] is `null`.
  /// Throws an [ArgumentError] if the given [pathsFactory] is `null`.
  Deployer({
    Services services,
    FileHelper fileHelper,
    Prompter prompter,
    PathsFactory pathsFactory,
  })  : _flutterService = services?.flutterService,
        _gcloudService = services?.gcloudService,
        _npmService = services?.npmService,
        _gitService = services?.gitService,
        _firebaseService = services?.firebaseService,
        _sentryService = services?.sentryService,
        _fileHelper = fileHelper,
        _prompter = prompter,
        _pathsFactory = pathsFactory {
    ArgumentError.checkNotNull(services, 'services');
    ArgumentError.checkNotNull(_flutterService, 'flutterService');
    ArgumentError.checkNotNull(_gcloudService, 'gcloudService');
    ArgumentError.checkNotNull(_npmService, 'npmService');
    ArgumentError.checkNotNull(_gitService, 'gitService');
    ArgumentError.checkNotNull(_firebaseService, 'firebaseService');
    ArgumentError.checkNotNull(_sentryService, 'sentryService');
    ArgumentError.checkNotNull(_fileHelper, 'fileHelper');
    ArgumentError.checkNotNull(_prompter, 'prompter');
    ArgumentError.checkNotNull(_pathsFactory, 'pathsFactory');
  }

  /// Deploys the Metrics Web Application.
  Future<void> deploy() async {
    await _loginToServices();

    final projectId = await _gcloudService.createProject();

    final tempDirectory = _createTempDirectory();
    final paths = _pathsFactory.create(tempDirectory.path);

    bool isDeploymentSuccessful = true;

    try {
      await _gcloudService.addFirebase(projectId);

      _gcloudService.configureProjectOrganization(projectId);
      await _firebaseService.createWebApp(projectId);

      await _gitService.checkout(DeployConstants.repoUrl, paths.rootPath);
      await _installNpmDependencies(
        paths.firebasePath,
        paths.firebaseFunctionsPath,
      );
      await _flutterService.build(paths.webAppPath);
      await _firebaseService.upgradeBillingPlan(projectId);
      await _firebaseService.enableAnalytics(projectId);
      await _firebaseService.initializeFirestoreData(projectId);

      final googleClientId = await _firebaseService.configureAuthProviders(
        projectId,
      );
      final sentryWebConfig = await _setupSentry(
        paths.webAppPath,
        paths.webAppBuildPath,
      );

      final metricsConfig = WebMetricsConfig(
        googleSignInClientId: googleClientId,
        sentryWebConfig: sentryWebConfig,
      );

      _applyMetricsConfig(metricsConfig, paths.metricsConfigPath);
      await _deployToFirebase(
        projectId,
        paths.firebasePath,
        paths.webAppPath,
      );

      await _gcloudService.configureOAuthOrigins(projectId);
    } catch (error) {
      isDeploymentSuccessful = false;

      _prompter.error(DeployStrings.failedDeployment(error));

      await _deleteProject(projectId);
    } finally {
      if (isDeploymentSuccessful) {
        _prompter.info(DeployStrings.successfulDeployment);
      }

      _prompter.info(CommonStrings.deletingTempDirectory);
      _deleteDirectory(tempDirectory);
    }
  }

  /// Logins to the necessary services.
  Future<void> _loginToServices() async {
    await _gcloudService.login();
    _gcloudService.acceptTermsOfService();

    await _firebaseService.login();
    _firebaseService.acceptTermsOfService();
  }

  /// Installs npm dependencies within the given [firebasePath] and
  /// the [functionsPath].
  Future<void> _installNpmDependencies(
    String firebasePath,
    String functionsPath,
  ) async {
    await _npmService.installDependencies(firebasePath);
    await _npmService.installDependencies(functionsPath);
  }

  /// Sets up a Sentry for the application under deployment within
  /// the given [webPath] and the [buildWebPath].
  Future<SentryWebConfig> _setupSentry(
    String webPath,
    String buildWebPath,
  ) async {
    final shouldSetupSentry = _prompter.promptConfirm(
      DeployStrings.setupSentry,
    );

    if (!shouldSetupSentry) return null;

    await _sentryService.login();

    final release = await _createSentryRelease(webPath, buildWebPath);
    final dsn = _sentryService.getProjectDsn(release.project);

    return SentryWebConfig(
      release: release.name,
      dsn: dsn,
      environment: DeployConstants.sentryEnvironment,
    );
  }

  /// Creates a new Sentry release within the [webPath] and the [buildWebPath].
  Future<SentryRelease> _createSentryRelease(
    String webPath,
    String buildWebPath,
  ) async {
    final release = _sentryService.getSentryRelease();
    final webSourceMap = SourceMap(
      path: webPath,
      extensions: const ['dart'],
    );
    final buildSourceMap = SourceMap(
      path: buildWebPath,
      extensions: const ['map', 'js'],
    );

    await _sentryService.createRelease(release, [webSourceMap, buildSourceMap]);

    return release;
  }

  /// Deploys Firebase components and application to the Firebase project
  /// with the given [projectId] within the given [firebasePath] and
  /// the [webPath].
  Future<void> _deployToFirebase(
    String projectId,
    String firebasePath,
    String webPath,
  ) async {
    await _firebaseService.deployFirebase(
      projectId,
      firebasePath,
    );
    await _firebaseService.deployHosting(
      projectId,
      DeployConstants.firebaseTarget,
      webPath,
    );
  }

  /// Applies the given [config] to the Metrics configuration file within
  /// the given [metricsConfigPath].
  void _applyMetricsConfig(WebMetricsConfig config, String metricsConfigPath) {
    final configFile = _fileHelper.getFile(metricsConfigPath);

    _fileHelper.replaceEnvironmentVariables(configFile, config.toMap());
  }

  /// Deletes the project with the given [projectId].
  ///
  /// Asks the user if delete a GCloud project created during deployment
  /// identified by the given [projectId] before deleting.
  ///
  /// Delegates deleting the project to the [GCloudService.deleteProject].
  Future<void> _deleteProject(String projectId) async {
    final deleteProject = _prompter.promptConfirm(
      DeployStrings.deleteProject(projectId),
    );

    if (deleteProject) {
      await _gcloudService.deleteProject(projectId);
    }
  }

  /// Creates a temporary directory in the current working directory.
  Directory _createTempDirectory() {
    final directory = Directory.current;

    return _fileHelper.createTempDirectory(
      directory,
      DeployConstants.tempDirectoryPrefix,
    );
  }

  /// Deletes the given [directory].
  void _deleteDirectory(Directory directory) {
    final directoryExist = directory.existsSync();

    if (!directoryExist) return;

    directory.deleteSync(recursive: true);
  }
}
