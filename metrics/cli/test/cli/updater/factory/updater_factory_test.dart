// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/cli/updater/factory/updater_factory.dart';
import 'package:cli/cli/updater/updater.dart';
import 'package:cli/common/model/services/services.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../test_utils/matchers.dart';
import '../../../test_utils/mock/firebase_service_mock.dart';
import '../../../test_utils/mock/flutter_service_mock.dart';
import '../../../test_utils/mock/gcloud_service_mock.dart';
import '../../../test_utils/mock/git_service_mock.dart';
import '../../../test_utils/mock/npm_service_mock.dart';
import '../../../test_utils/mock/sentry_service_mock.dart';
import '../../../test_utils/mock/services_factory_mock.dart';

void main() {
  group("UpdaterFactory", () {
    final servicesFactory = ServicesFactoryMock();
    final updaterFactory = UpdaterFactory(servicesFactory);
    final gcloudService = GCloudServiceMock();
    final flutterService = FlutterServiceMock();
    final gitService = GitServiceMock();
    final npmService = NpmServiceMock();
    final firebaseService = FirebaseServiceMock();
    final sentryService = SentryServiceMock();
    final services = Services(
      flutterService: flutterService,
      gcloudService: gcloudService,
      gitService: gitService,
      npmService: npmService,
      firebaseService: firebaseService,
      sentryService: sentryService,
    );

    tearDown(() {
      reset(servicesFactory);
      reset(gcloudService);
      reset(flutterService);
      reset(gitService);
      reset(npmService);
      reset(firebaseService);
      reset(sentryService);
    });

    PostExpectation<Services> whenCreateServices() {
      return when(servicesFactory.create());
    }

    test(
      "throws an ArgumentError if the given services factory is null",
      () {
        expect(
          () => UpdaterFactory(null),
          throwsArgumentError,
        );
      },
    );

    test(
      ".create() creates a Services instance using the given services factory",
      () {
        whenCreateServices().thenReturn(services);

        updaterFactory.create();

        verify(servicesFactory.create()).called(once);
      },
    );

    test(
      ".create() successfully creates an Updater instance",
      () {
        whenCreateServices().thenReturn(services);

        final updater = updaterFactory.create();

        expect(updater, isA<Updater>());
      },
    );
  });
}
