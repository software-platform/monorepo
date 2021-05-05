// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:firebase_functions_interop/firebase_functions_interop.dart';
import 'package:metrics_core/metrics_core.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../lib/main.dart';
import '../lib/mappers/build_day_status_field_name_mapper.dart';

void main() {
  group(("onBuildAddedHandler"), () {
    const buildDaysCollectionName = 'build_days';
    const tasksCollectionName = 'tasks';
    const projectId = 'projectId';
    const durationInMilliseconds = 123;
    final startedAt = DateTime.now();
    final startedAtUtc = _getUtcDate(startedAt);
    final buildStatus = BuildStatus.successful;

    final build = {
      'duration': durationInMilliseconds,
      'projectId': projectId,
      'buildStatus': buildStatus.toString(),
      'startedAt': Timestamp.fromDateTime(startedAt),
      'url': 'url',
      'workflowName': 'workflowName',
    };

    final mapper = BuildDayStatusFieldNameMapper();
    final buildDayStatusFieldName = mapper.map(buildStatus);

    final expectedBuildDayData = {
      'projectId': projectId,
      buildDayStatusFieldName: 1,
      'successfulBuildsDuration': durationInMilliseconds,
      'day': Timestamp.fromDateTime(startedAtUtc),
    };

    final exception = Exception('test');
    final expectedCreatedTask = {
      'code': 'build_days_created',
      'data': build,
      'context': exception.toString(),
      'createdAt': Timestamp.fromDateTime(startedAtUtc),
    };

    final firestoreMock = FirestoreMock();
    final collectionReferenceMock = CollectionReferenceMock();
    final documentReferenceMock = DocumentReferenceMock();
    final documentSnapshotMock = DocumentSnapshotMock();

    PostExpectation<Firestore> whenFirestore() {
      return when(documentSnapshotMock.firestore);
    }

    PostExpectation<CollectionReference> whenCollection(String withName) {
      whenFirestore().thenReturn(firestoreMock);

      return when(firestoreMock.collection(withName));
    }

    PostExpectation<DocumentReference> whenDocument({
      String withCollectionName,
    }) {
      whenCollection(withCollectionName).thenReturn(collectionReferenceMock);

      return when(collectionReferenceMock.document(any));
    }

    PostExpectation<Future<void>> whenSetDocumentData({
      String withCollectionName,
    }) {
      whenDocument(
        withCollectionName: withCollectionName,
      ).thenReturn(documentReferenceMock);

      return when(documentReferenceMock.setData(any, any));
    }

    PostExpectation whenSnapshotData() {
      return when(documentSnapshotMock.data);
    }

    tearDown(() {
      reset(documentSnapshotMock);
      reset(firestoreMock);
      reset(collectionReferenceMock);
      reset(documentReferenceMock);
    });

    test(
      "does not increment the successful builds duration if the build document snapshot's duration is null",
      () async {
        whenDocument(withCollectionName: buildDaysCollectionName)
            .thenReturn(documentReferenceMock);

        final buildWithoutDuration = BuildData(
          projectId: projectId,
          startedAt: startedAtUtc,
          buildStatus: buildStatus,
        );

        final buildJson = buildWithoutDuration.toJson();
        buildJson['startedAt'] = Timestamp.fromDateTime(buildJson['startedAt']);

        whenSnapshotData().thenReturn(DocumentData.fromMap(buildJson));

        await onBuildAddedHandler(documentSnapshotMock, null);

        final documentDataMatcher = predicate<DocumentData>((data) {
          final operand =
              data.getNestedData('successfulBuildsDuration').getInt('operand');

          return operand == 0;
        });

        verify(
          documentReferenceMock.setData(argThat(documentDataMatcher), any),
        ).called(1);
      },
    );

    test(
      "does not increment the successful builds duration if the build's status is not successful",
      () async {
        whenDocument(withCollectionName: buildDaysCollectionName)
            .thenReturn(documentReferenceMock);

        final unknownBuild = BuildData(
          projectId: projectId,
          startedAt: startedAtUtc,
          buildStatus: BuildStatus.unknown,
          duration: Duration(milliseconds: 100),
        );

        final buildJson = unknownBuild.toJson();
        buildJson['startedAt'] = Timestamp.fromDateTime(buildJson['startedAt']);

        whenSnapshotData().thenReturn(DocumentData.fromMap(buildJson));

        await onBuildAddedHandler(documentSnapshotMock, null);

        final documentDataMatcher = predicate<DocumentData>((data) {
          final operand =
              data.getNestedData('successfulBuildsDuration').getInt('operand');
          return operand == 0;
        });

        verify(
          documentReferenceMock.setData(argThat(documentDataMatcher), any),
        ).called(1);
      },
    );

    test(
      "uses a composite document id for the build days collection",
      () async {
        whenDocument(withCollectionName: buildDaysCollectionName)
            .thenReturn(documentReferenceMock);
        whenSnapshotData().thenReturn(DocumentData.fromMap(build));

        await onBuildAddedHandler(documentSnapshotMock, null);

        final documentId =
            '${projectId}_${startedAtUtc.millisecondsSinceEpoch}';

        verify(collectionReferenceMock.document(documentId)).called(1);
      },
    );

    test(
      "trims the time part of the build's started at parameter and converts it to UTC",
      () async {
        whenDocument(withCollectionName: buildDaysCollectionName)
            .thenReturn(documentReferenceMock);
        whenSnapshotData().thenReturn(DocumentData.fromMap(build));
        final expectedDate = startedAtUtc.millisecondsSinceEpoch;

        await onBuildAddedHandler(documentSnapshotMock, null);

        expect(
          verify(collectionReferenceMock.document(captureAny)).captured.single,
          contains(expectedDate.toString()),
        );
      },
    );

    test(
      "creates a build days document with project id equals to the build document snapshot's project id",
      () async {
        whenDocument(withCollectionName: buildDaysCollectionName)
            .thenReturn(documentReferenceMock);
        whenSnapshotData().thenReturn(DocumentData.fromMap(build));

        await onBuildAddedHandler(documentSnapshotMock, null);

        final projectIdMatcher = predicate<DocumentData>((data) =>
            data.getString('projectId') == expectedBuildDayData['projectId']);

        verify(
          documentReferenceMock.setData(
            argThat(projectIdMatcher),
            any,
          ),
        ).called(1);
      },
    );

    test(
      "creates a build days document with build day status field count equals to the build document snapshot's status field count",
      () async {
        whenDocument(withCollectionName: buildDaysCollectionName)
            .thenReturn(documentReferenceMock);
        whenSnapshotData().thenReturn(DocumentData.fromMap(build));

        await onBuildAddedHandler(documentSnapshotMock, null);

        final countMatcher = predicate<DocumentData>((data) {
          final count =
              data.getNestedData(buildDayStatusFieldName).getInt('operand');
          return count == expectedBuildDayData[buildDayStatusFieldName];
        });

        verify(
          documentReferenceMock.setData(
            argThat(countMatcher),
            any,
          ),
        ).called(1);
      },
    );

    test(
      "creates a build days document with successful builds duration equals to the build document snapshot's duration if the build is successful",
      () async {
        whenDocument(withCollectionName: buildDaysCollectionName)
            .thenReturn(documentReferenceMock);
        whenSnapshotData().thenReturn(DocumentData.fromMap(build));

        await onBuildAddedHandler(documentSnapshotMock, null);

        final durationMatcher = predicate<DocumentData>((data) {
          final duration =
              data.getNestedData('successfulBuildsDuration').getInt('operand');
          return duration == expectedBuildDayData['successfulBuildsDuration'];
        });

        verify(
          documentReferenceMock.setData(
            argThat(durationMatcher),
            any,
          ),
        ).called(1);
      },
    );

    test(
      "creates a build days document with day equals to the build document snapshot's day",
      () async {
        whenDocument(withCollectionName: buildDaysCollectionName)
            .thenReturn(documentReferenceMock);
        whenSnapshotData().thenReturn(DocumentData.fromMap(build));

        await onBuildAddedHandler(documentSnapshotMock, null);

        final dayMatcher = predicate<DocumentData>((data) {
          return data.getTimestamp('day') == expectedBuildDayData['day'];
        });

        verify(
          documentReferenceMock.setData(
            argThat(dayMatcher),
            any,
          ),
        ).called(1);
      },
    );

    test(
      "does not create a task document if the build day data set successfully",
      () async {
        whenDocument(withCollectionName: buildDaysCollectionName)
            .thenReturn(documentReferenceMock);
        whenSnapshotData().thenReturn(DocumentData.fromMap(build));

        await onBuildAddedHandler(documentSnapshotMock, null);

        verifyNever(firestoreMock.collection(tasksCollectionName));
      },
    );

    test(
      "creates a task document with code equals to the given one if setting the build day's document data fails",
      () async {
        final _taskCollectionReferenceMock = CollectionReferenceMock();

        whenSetDocumentData(withCollectionName: buildDaysCollectionName)
            .thenAnswer((_) => Future.error(Exception('test')));

        when(firestoreMock.collection(tasksCollectionName))
            .thenReturn(_taskCollectionReferenceMock);
        when(_taskCollectionReferenceMock.add(any))
            .thenAnswer((_) => Future.value());

        whenSnapshotData().thenReturn(DocumentData.fromMap(build));

        await onBuildAddedHandler(documentSnapshotMock, null);

        final codeMatcher = predicate<DocumentData>(
          (data) => data.getString('code') == expectedCreatedTask['code'],
        );

        verify(_taskCollectionReferenceMock.add(argThat(codeMatcher)))
            .called(1);
      },
    );

    test(
      "creates a task document with data equals to the build data if setting the build day's document data fails",
      () async {
        final _taskCollectionReferenceMock = CollectionReferenceMock();

        whenSetDocumentData(withCollectionName: buildDaysCollectionName)
            .thenAnswer((_) => Future.error(Exception('test')));

        when(firestoreMock.collection(tasksCollectionName))
            .thenReturn(_taskCollectionReferenceMock);
        when(_taskCollectionReferenceMock.add(any))
            .thenAnswer((_) => Future.value());

        whenSnapshotData().thenReturn(DocumentData.fromMap(build));

        await onBuildAddedHandler(documentSnapshotMock, null);

        final dataMatcher = predicate<DocumentData>((data) {
          return MapEquality().equals(
            data.getNestedData('data').toMap(),
            expectedCreatedTask['data'],
          );
        });

        verify(_taskCollectionReferenceMock.add(argThat(dataMatcher)))
            .called(1);
      },
    );

    test(
      "creates a task document with context equals to the error if setting the build day's document data fails",
      () async {
        final _taskCollectionReferenceMock = CollectionReferenceMock();

        whenSetDocumentData(withCollectionName: buildDaysCollectionName)
            .thenAnswer((_) => Future.error(Exception('test')));

        when(firestoreMock.collection(tasksCollectionName))
            .thenReturn(_taskCollectionReferenceMock);
        when(_taskCollectionReferenceMock.add(any))
            .thenAnswer((_) => Future.value());

        whenSnapshotData().thenReturn(DocumentData.fromMap(build));

        await onBuildAddedHandler(documentSnapshotMock, null);

        final contextMatcher = predicate<DocumentData>(
          (data) => data.getString('context') == expectedCreatedTask['context'],
        );

        verify(_taskCollectionReferenceMock.add(
          argThat(contextMatcher),
        )).called(1);
      },
    );

    test(
      "creates a task document with created at equals to the build's startedAt if setting the build day's document data fails",
      () async {
        final _taskCollectionReferenceMock = CollectionReferenceMock();

        whenSetDocumentData(withCollectionName: buildDaysCollectionName)
            .thenAnswer((_) => Future.error(Exception('test')));

        when(firestoreMock.collection(tasksCollectionName))
            .thenReturn(_taskCollectionReferenceMock);
        when(_taskCollectionReferenceMock.add(any))
            .thenAnswer((_) => Future.value());

        whenSnapshotData().thenReturn(DocumentData.fromMap(build));

        await onBuildAddedHandler(documentSnapshotMock, null);

        final createdAtMatcher = predicate<DocumentData>((data) {
          return data.getTimestamp('createdAt') ==
              expectedCreatedTask['createdAt'];
        });

        verify(_taskCollectionReferenceMock.add(
          argThat(createdAtMatcher),
        )).called(1);
      },
    );
  });
}

//// Returns a [DateTime] representing the date in the UTC timezone created
/// from the given [dateTime].
DateTime _getUtcDate(DateTime dateTime) => dateTime.toUtc().date;

class FirestoreMock extends Mock implements Firestore {}

class CollectionReferenceMock extends Mock implements CollectionReference {}

class DocumentReferenceMock extends Mock implements DocumentReference {}

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {}
