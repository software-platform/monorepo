// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:ci_integration/cli/logger/mixin/logger_mixin.dart';
import 'package:ci_integration/client/firestore/firestore.dart';
import 'package:ci_integration/data/deserializer/build_data_deserializer.dart';
import 'package:ci_integration/destination/error/destination_error.dart';
import 'package:ci_integration/integration/interface/destination/client/destination_client.dart';
import 'package:firedart/firedart.dart' as fd;
import 'package:metrics_core/metrics_core.dart';

/// A class that provides methods for interactions between
/// [CiIntegration] and Firestore destination storage.
class FirestoreDestinationClientAdapter
    with LoggerMixin
    implements DestinationClient {
  final Firestore _firestore;

  /// Creates a [FirestoreDestinationClientAdapter] instance
  /// with the given [Firestore] instance.
  ///
  /// Throws an [ArgumentError], if the given [Firestore] instance is `null`.
  FirestoreDestinationClientAdapter(this._firestore) {
    ArgumentError.checkNotNull(_firestore, 'firestore');
  }

  @override
  Future<void> addBuilds(String projectId, List<BuildData> builds) async {
    Map<String, dynamic> buildJson;

    try {
      await _throwIfProjectAbsent(projectId);

      final collection = _firestore.collection('build');

      logger.info('Adding ${builds.length} builds...');
      for (final build in builds) {
        final documentId = '${projectId}_${build.buildNumber}';
        final map = build.copyWith(projectId: projectId).toJson();
        buildJson = map;

        await collection.document(documentId).create(map);
        logger.info('Added build id $documentId.');
      }
    } on fd.FirestoreException catch (error) {
      if (buildJson != null) {
        logger.info('Failed to add build: $buildJson');
        buildJson = null;
      }

      throw DestinationError(message: error.message);
    }
  }

  @override
  Future<BuildData> fetchLastBuild(String projectId) async {
    logger.info('Fetching last build for the project id $projectId...');

    await _throwIfProjectAbsent(projectId);

    final documents = await _firestore
        .collection('build')
        .where('projectId', isEqualTo: projectId)
        .orderBy('startedAt', descending: true)
        .limit(1)
        .getDocuments();

    if (documents.isEmpty) return null;

    final document = documents.first;
    return BuildDataDeserializer.fromJson(document.map, document.id);
  }

  @override
  Future<List<BuildData>> fetchBuildsWithStatus(
    String projectId,
    BuildStatus status,
  ) async {
    logger.info(
      'Fetching builds for the project id $projectId with status $status...',
    );

    ArgumentError.checkNotNull(status, 'status');

    await _throwIfProjectAbsent(projectId);

    try {
      final documents = await _firestore
          .collection('build')
          .where('projectId', isEqualTo: projectId)
          .where('buildStatus', isEqualTo: '$status')
          .getDocuments();

      return documents.map((document) {
        return BuildDataDeserializer.fromJson(document.map, document.id);
      }).toList();
    } on fd.FirestoreException catch (error) {
      throw DestinationError(message: error.message);
    }
  }

  @override
  Future<void> updateBuilds(String projectId, List<BuildData> builds) async {
    logger.info(
      'Updating builds for the project id $projectId...',
    );

    ArgumentError.checkNotNull(builds, 'builds');

    await _throwIfProjectAbsent(projectId);

    final updatedBuilds = builds.map((build) {
      return build.copyWith(projectId: projectId);
    }).toList();

    await _updateBuilds(updatedBuilds);
  }

  /// Updates the builds having the same [BuildData.id] with the given [builds].
  ///
  /// Logs any errors occurred when updating [builds].
  Future<void> _updateBuilds(List<BuildData> builds) {
    final updateFutures = <Future<void>>[];

    for (final build in builds) {
      final buildData = build.toJson();
      final buildId = build.id;

      final reference = _firestore.collection('build').document(buildId);
      final updateFuture = reference
          .update(buildData)
          .catchError((error) => _handleBuildUpdateError(build, error));

      updateFutures.add(updateFuture);
    }

    return Future.wait(updateFutures);
  }

  /// Handles the given [error] occurred during updating the given [build].
  void _handleBuildUpdateError(BuildData build, dynamic error) {
    logger.info(
      'Failed to update the following build ${build.id} with the following error: $error',
    );
  }

  /// Checks if a project with the given [projectId] exists.
  ///
  /// Throws an [ArgumentError] if a project with the given [projectId]
  /// does not exist.
  Future<void> _throwIfProjectAbsent(String projectId) async {
    final projectExists = await _projectExists(projectId);

    if (!projectExists) {
      throw ArgumentError(
        'A project with the given ID $projectId is not found',
      );
    }
  }

  /// Returns `true` if a project with the given [projectId] exists. Otherwise,
  /// returns `false`.
  ///
  /// Throws a [DestinationError] if fetching a project with the given
  /// [projectId] fails.
  Future<bool> _projectExists(String projectId) async {
    try {
      logger.info(
        'Checking a project with the project id $projectId exists...',
      );

      final project = await _firestore.document('projects/$projectId').get();

      return project.exists;
    } on fd.FirestoreException catch (error) {
      throw DestinationError(
        message:
            'Failed to fetch a project with the $projectId id due to the following error: ${error.message}',
      );
    }
  }

  @override
  void dispose() {}
}
