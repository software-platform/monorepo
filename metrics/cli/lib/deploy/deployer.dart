// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/cli/firebase/firebase_command.dart';
import 'package:cli/common/model/services.dart';
import 'package:cli/deploy/constants/deploy_constants.dart';
import 'package:cli/flutter/service/flutter_service.dart';
import 'package:cli/gcloud/service/gcloud_service.dart';
import 'package:cli/git/service/git_service.dart';
import 'package:cli/helper/file_helper.dart';
import 'package:cli/npm/service/npm_service.dart';

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

  /// A class that provides methods for working with the file system.
  final FileHelper _fileHelper;

  /// A class that provides methods for working with the Firebase.
  final FirebaseCommand _firebaseCommand;

  /// Creates a new instance of the [Deployer] with the given services.
  ///
  /// Throws an [ArgumentError] if the given [Services.flutterService] is `null`.
  /// Throws an [ArgumentError] if the given [Services.gcloudService] is `null`.
  /// Throws an [ArgumentError] if the given [Services.npmService] is `null`.
  /// Throws an [ArgumentError] if the given [Services.gitService] is `null`.
  /// Throws an [ArgumentError] if the given [firebaseCommand] is `null`.
  /// Throws an [ArgumentError] if the given [fileHelper] is `null`.
  Deployer({
    Services services,
    FirebaseCommand firebaseCommand,
    FileHelper fileHelper,
  })  :
        _flutterService = services?.flutterService,
        _gcloudService = services?.gcloudService,
        _npmService = services?.npmService,
        _gitService = services?.gitService,
        _firebaseCommand = firebaseCommand,
        _fileHelper = fileHelper {
    ArgumentError.checkNotNull(_flutterService, 'flutterService');
    ArgumentError.checkNotNull(_gcloudService, 'gcloudService');
    ArgumentError.checkNotNull(_npmService, 'npmService');
    ArgumentError.checkNotNull(_gitService, 'gitService');
    ArgumentError.checkNotNull(_firebaseCommand, 'firebaseCommand');
    ArgumentError.checkNotNull(_fileHelper, 'fileHelper');
  }

  /// Deploys the Metrics Web Application.
  Future<void> deploy() async {
    await _gcloudService.login();

    final projectId = await _gcloudService.createProject();
    final firebaseToken = await _firebaseCommand.login();

    await _firebaseCommand.addFirebase(projectId, firebaseToken);
    await _firebaseCommand.createWebApp(projectId, firebaseToken);
    await _gitService.checkout(
      DeployConstants.repoURL,
      DeployConstants.tempDir,
    );
    await _npmService.installDependencies(DeployConstants.firebasePath);
    await _npmService.installDependencies(
      DeployConstants.firebaseFunctionsPath,
    );
    await _flutterService.build(DeployConstants.webPath);
    await _firebaseCommand.setFirebaseProject(
      projectId,
      DeployConstants.webPath,
      firebaseToken,
    );
    await _firebaseCommand.applyTarget(
      projectId,
      DeployConstants.firebaseTarget,
      DeployConstants.webPath,
      firebaseToken,
    );
    await _firebaseCommand.deployHosting(
      DeployConstants.firebaseTarget,
      DeployConstants.webPath,
      firebaseToken,
    );

    final tempDirectory = _fileHelper.getDirectory(DeployConstants.tempDir);
    await tempDirectory.delete(recursive: true);
  }
}
