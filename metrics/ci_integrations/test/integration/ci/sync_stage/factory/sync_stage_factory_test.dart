// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'dart:collection';

import 'package:ci_integration/integration/ci/sync_stage/builds/in_progress_builds_sync_stage.dart';
import 'package:ci_integration/integration/ci/sync_stage/builds/new_builds_sync_stage.dart';
import 'package:ci_integration/integration/ci/sync_stage/factory/sync_stages_factory.dart';
import 'package:ci_integration/integration/ci/sync_stage/sync_stage.dart';
import 'package:test/test.dart';

import '../../test_utils/stub/destination_client_stub.dart';
import '../../test_utils/stub/source_client_stub.dart';

void main() {
  group("SyncStageFactory", () {
    final sourceClient = SourceClientStub();
    final destinationClient = DestinationClientStub();

    final stagesFactory = SyncStageFactory(
      sourceClient: sourceClient,
      destinationClient: destinationClient,
    );

    test(
      "throws an ArgumentError if the given source client is null",
      () {
        expect(
          () => SyncStageFactory(
            sourceClient: null,
            destinationClient: destinationClient,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given destination client is null",
      () {
        expect(
          () => SyncStageFactory(
            sourceClient: sourceClient,
            destinationClient: null,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      ".create() returns an unmodifiable list",
      () {
        final stages = stagesFactory.create();

        expect(stages, isA<UnmodifiableListView>());
      },
    );

    test(
      ".create() returns a list of sync stages with the given source and destination clients",
      () {
        final stages = stagesFactory.create();

        final syncStagePredicate = predicate<SyncStage>((stage) {
          return stage.sourceClient == sourceClient &&
              stage.destinationClient == destinationClient;
        });

        expect(stages, everyElement(syncStagePredicate));
      },
    );

    test(
      ".create() returns a list of sync stages in the correct order",
      () {
        final inProgressBuildsStageMatcher = isA<InProgressBuildsSyncStage>();
        final newBuildsStageMatcher = isA<NewBuildsSyncStage>();

        final expectedStages = [
          inProgressBuildsStageMatcher,
          newBuildsStageMatcher,
        ];

        final stages = stagesFactory.create();

        expect(stages, hasLength(expectedStages.length));
        expect(stages, containsAllInOrder(expectedStages));
      },
    );
  });
}
