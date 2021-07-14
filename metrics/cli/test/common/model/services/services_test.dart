// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/common/model/services/services.dart';
import 'package:test/test.dart';

import '../../../test_utils/mock/firebase_service_mock.dart';
import '../../../test_utils/mock/flutter_service_mock.dart';
import '../../../test_utils/mock/gcloud_service_mock.dart';
import '../../../test_utils/mock/git_service_mock.dart';
import '../../../test_utils/mock/npm_service_mock.dart';
import '../../../test_utils/mock/sentry_service_mock.dart';

// ignore_for_file: avoid_redundant_argument_values

void main() {
  group("Services", () {
    final flutterService = FlutterServiceMock();
    final gcloudService = GCloudServiceMock();
    final npmService = NpmServiceMock();
    final gitService = GitServiceMock();
    final firebaseService = FirebaseServiceMock();
    final sentryService = SentryServiceMock();

    test(
      "throws an ArgumentError if the given Flutter service is null",
      () {
        expect(
          () => Services(
            flutterService: null,
            gcloudService: gcloudService,
            npmService: npmService,
            gitService: gitService,
            firebaseService: firebaseService,
            sentryService: sentryService,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given GCloud service is null",
      () {
        expect(
          () => Services(
            flutterService: flutterService,
            gcloudService: null,
            npmService: npmService,
            gitService: gitService,
            firebaseService: firebaseService,
            sentryService: sentryService,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given Npm service is null",
      () {
        expect(
          () => Services(
            flutterService: flutterService,
            gcloudService: gcloudService,
            npmService: null,
            gitService: gitService,
            firebaseService: firebaseService,
            sentryService: sentryService,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given Git service is null",
      () {
        expect(
          () => Services(
            flutterService: flutterService,
            gcloudService: gcloudService,
            npmService: npmService,
            gitService: null,
            firebaseService: firebaseService,
            sentryService: sentryService,
          ),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given Firebase service is null",
      () {
        expect(
          () => Services(
            flutterService: flutterService,
            gcloudService: gcloudService,
            npmService: npmService,
            gitService: gitService,
            firebaseService: null,
            sentryService: sentryService,
          ),
          throwsArgumentError,
        );
      },
    );

    test("throws an ArgumentError if the given Sentry service is null", () {
      expect(
        () => Services(
          flutterService: flutterService,
          gcloudService: gcloudService,
          npmService: npmService,
          gitService: gitService,
          firebaseService: firebaseService,
          sentryService: null,
        ),
        throwsArgumentError,
      );
    });

    test(
      "creates an instance with the given parameters",
      () {
        final services = Services(
            flutterService: flutterService,
            gcloudService: gcloudService,
            gitService: gitService,
            npmService: npmService,
            firebaseService: firebaseService,
            sentryService: sentryService);

        expect(services.flutterService, equals(flutterService));
        expect(services.gcloudService, equals(gcloudService));
        expect(services.gitService, equals(gitService));
        expect(services.npmService, equals(npmService));
        expect(services.firebaseService, equals(firebaseService));
        expect(services.sentryService, equals(sentryService));
      },
    );
  });
}
