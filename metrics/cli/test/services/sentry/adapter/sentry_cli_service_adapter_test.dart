// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/services/sentry/adapter/sentry_cli_service_adapter.dart';
import 'package:cli/services/sentry/cli/sentry_cli.dart';
import 'package:cli/services/sentry/model/sentry_project.dart';
import 'package:cli/services/sentry/model/sentry_release.dart';
import 'package:cli/services/sentry/model/source_map.dart';
import 'package:cli/services/sentry/strings/sentry_strings.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../test_utils/matchers.dart';
import '../../../test_utils/mock/prompter_mock.dart';

// ignore_for_file: avoid_redundant_argument_values

void main() {
  group("SentryCliServiceAdapter", () {
    const path = 'path';
    const extensions = ['js'];
    const releaseName = 'releaseName';
    const organizationSlug = 'organizationSlug';
    const projectSlug = 'projectSlug';
    const enterOrganizationSlug = SentryStrings.enterOrganizationSlug;
    const enterReleaseName = SentryStrings.enterReleaseName;
    const dsn = 'dsn';
    const auth = 'auth';

    final sentryCli = _SentryCliMock();
    final prompter = PrompterMock();
    final sentryService = SentryCliServiceAdapter(sentryCli, prompter);
    final sentryProject = SentryProject(
      organizationSlug: organizationSlug,
      projectSlug: projectSlug,
    );
    final sentryRelease = SentryRelease(
      name: releaseName,
      project: sentryProject,
    );
    final sourceMap = SourceMap(path: path, extensions: extensions);
    final stateError = StateError('test');
    final enterProjectSlug = SentryStrings.enterProjectSlug(organizationSlug);
    final enterDsn = SentryStrings.enterDsn(organizationSlug, projectSlug);

    PostExpectation<String> whenPromptOrganizationSlug() {
      return when(prompter.prompt(enterOrganizationSlug));
    }

    PostExpectation<String> whenPromptProjectSlug({
      String withOrganizationSlug = organizationSlug,
    }) {
      whenPromptOrganizationSlug().thenReturn(withOrganizationSlug);
      return when(prompter.prompt(enterProjectSlug));
    }

    PostExpectation<String> whenPromptReleaseName({
      String withOrganizationSlug = organizationSlug,
      String withProjectSlug = projectSlug,
    }) {
      whenPromptProjectSlug(withOrganizationSlug: withOrganizationSlug)
          .thenReturn(withProjectSlug);
      return when(prompter.prompt(enterReleaseName));
    }

    void checkNoMoreInteractions() {
      verifyNoMoreInteractions(sentryCli);
      verifyNoMoreInteractions(prompter);
    }

    tearDown(() {
      reset(sentryCli);
      reset(prompter);
    });

    test(
      "throws an ArgumentError if the given Sentry CLI is null",
      () {
        expect(
          () => SentryCliServiceAdapter(null, prompter),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given prompter is null",
      () {
        expect(
          () => SentryCliServiceAdapter(sentryCli, null),
          throwsArgumentError,
        );
      },
    );

    test(
      ".login() logs in to the Sentry CLI",
      () async {
        await sentryService.login();

        verify(sentryCli.login()).called(once);
      },
    );

    test(
      ".login() throws if Sentry CLI throws during the logging",
      () {
        when(sentryCli.login()).thenAnswer((_) => Future.error(stateError));

        expect(sentryService.login(), throwsStateError);
      },
    );

    test(
      ".getSentryRelease() prompts the user to enter the organization slug",
      () {
        whenPromptReleaseName().thenReturn(releaseName);

        sentryService.getSentryRelease();

        verify(prompter.prompt(enterOrganizationSlug)).called(once);
      },
    );

    test(
      ".getSentryRelease() throws if prompter throws during the organization slug prompting",
      () {
        whenPromptOrganizationSlug().thenThrow(stateError);

        expect(sentryService.getSentryRelease, throwsStateError);
      },
    );

    test(
      ".getSentryRelease() stops the getting release process if prompter throws during the organization slug prompting",
      () {
        whenPromptOrganizationSlug().thenThrow(stateError);

        expect(
          sentryService.getSentryRelease,
          throwsStateError,
        );

        verify(prompter.prompt(enterOrganizationSlug)).called(once);

        checkNoMoreInteractions();
      },
    );

    test(
      ".getSentryRelease() prompts the user to enter the project slug",
      () {
        whenPromptReleaseName().thenReturn(releaseName);

        sentryService.getSentryRelease();

        verify(prompter.prompt(enterProjectSlug)).called(once);
      },
    );

    test(
      ".getSentryRelease() throws if prompter throws during the project slug prompting",
      () {
        whenPromptProjectSlug().thenThrow(stateError);

        expect(
          sentryService.getSentryRelease,
          throwsStateError,
        );
      },
    );

    test(
      ".getSentryRelease() stops the config prompting process if prompter throws during the project slug prompting",
      () {
        whenPromptProjectSlug().thenThrow(stateError);

        expect(
          sentryService.getSentryRelease,
          throwsStateError,
        );

        verify(prompter.prompt(enterOrganizationSlug)).called(once);
        verify(prompter.prompt(enterProjectSlug)).called(once);

        checkNoMoreInteractions();
      },
    );

    test(
      ".getSentryRelease() prompts the user to enter the release name",
      () {
        whenPromptReleaseName().thenReturn(releaseName);

        sentryService.getSentryRelease();

        verify(prompter.prompt(enterReleaseName)).called(once);
      },
    );

    test(
      ".getSentryRelease() throws if prompter throws during the release name prompting",
      () {
        whenPromptReleaseName().thenThrow(stateError);

        expect(
          sentryService.getSentryRelease,
          throwsStateError,
        );
      },
    );

    test(
      ".createRelease() creates the Sentry release with the given release",
      () async {
        whenPromptReleaseName().thenReturn(releaseName);

        await sentryService.createRelease(sentryRelease, [sourceMap]);

        verify(sentryCli.createRelease(sentryRelease)).called(once);
      },
    );

    test(
      ".createRelease() throws if Sentry CLI throws during the release creation",
      () {
        whenPromptReleaseName().thenReturn(releaseName);
        when(sentryCli.createRelease(any))
            .thenAnswer((_) => Future.error(stateError));

        expect(
          sentryService.createRelease(sentryRelease, [sourceMap]),
          throwsStateError,
        );
      },
    );

    test(
      ".createRelease() stops the release creation process if Sentry CLI throws during the release creation",
      () async {
        whenPromptReleaseName().thenReturn(releaseName);
        when(sentryCli.createRelease(any))
            .thenAnswer((_) => Future.error(stateError));

        await expectLater(
          sentryService.createRelease(sentryRelease, [sourceMap]),
          throwsStateError,
        );

        verify(sentryCli.createRelease(sentryRelease)).called(once);

        checkNoMoreInteractions();
      },
    );

    test(
      ".createRelease() uploads the given source maps to the given release",
      () async {
        whenPromptReleaseName().thenReturn(releaseName);

        await sentryService.createRelease(sentryRelease, [sourceMap]);

        verify(sentryCli.uploadSourceMaps(sentryRelease, sourceMap))
            .called(once);
      },
    );

    test(
      ".createRelease() throws if Sentry CLI throws during the source maps uploading",
      () {
        whenPromptReleaseName().thenReturn(releaseName);
        when(sentryCli.uploadSourceMaps(any, any))
            .thenAnswer((_) => Future.error(stateError));

        expect(
          sentryService.createRelease(sentryRelease, [sourceMap]),
          throwsStateError,
        );
      },
    );

    test(
      ".createRelease() stops the release creation process if Sentry CLI throws during the source maps uploading",
      () async {
        whenPromptReleaseName().thenReturn(releaseName);
        when(sentryCli.uploadSourceMaps(any, any))
            .thenAnswer((_) => Future.error(stateError));

        await expectLater(
          sentryService.createRelease(sentryRelease, [sourceMap]),
          throwsStateError,
        );

        verify(sentryCli.createRelease(sentryRelease)).called(once);
        verify(sentryCli.uploadSourceMaps(sentryRelease, sourceMap))
            .called(once);

        checkNoMoreInteractions();
      },
    );

    test(
      ".createRelease() finalizes the given release",
      () async {
        whenPromptReleaseName().thenReturn(releaseName);

        await sentryService.createRelease(sentryRelease, [sourceMap]);

        verify(sentryCli.finalizeRelease(sentryRelease)).called(once);
      },
    );

    test(
      ".createRelease() throws if Sentry CLI throws during the release finalizing",
      () {
        whenPromptReleaseName().thenReturn(releaseName);
        when(sentryCli.finalizeRelease(any))
            .thenAnswer((_) => Future.error(stateError));

        expect(
          sentryService.createRelease(sentryRelease, [sourceMap]),
          throwsStateError,
        );
      },
    );

    test(
      ".version() shows the version information",
      () async {
        await sentryService.version();

        verify(sentryCli.version()).called(once);
      },
    );

    test(
      ".version() throws if Sentry CLI throws during the version showing",
      () {
        when(sentryCli.version()).thenAnswer((_) => Future.error(stateError));

        expect(sentryService.version(), throwsStateError);
      },
    );

    test(
      ".getProjectDsn() prompts the user to enter the sentry project DSN",
      () {
        sentryService.getProjectDsn(sentryProject);

        verify(prompter.prompt(enterDsn)).called(once);
      },
    );

    test(
      ".getProjectDsn() returns the DSN entered by the user",
      () {
        when(prompter.prompt(enterDsn)).thenReturn(dsn);

        final result = sentryService.getProjectDsn(sentryProject);

        expect(result, equals(dsn));
      },
    );

    test(
      ".getSentryDsn() throws if prompter throws during the DSN prompting",
      () {
        when(prompter.prompt(enterDsn)).thenThrow(stateError);

        expect(
          () => sentryService.getProjectDsn(sentryProject),
          throwsStateError,
        );
      },
    );

    test(
      ".initializeAuth() initializes the authentication for the Sentry CLI",
      () {
        sentryService.initializeAuth(auth);

        verify(sentryCli.setupAuth(auth)).called(once);
      },
    );

    test(
      ".initializeAuth() throws if Sentry CLI throws during the initializing authentication process",
      () {
        when(sentryCli.setupAuth(auth)).thenThrow(stateError);

        expect(
          () => sentryService.initializeAuth(auth),
          throwsStateError,
        );
      },
    );

    test(
      ".resetAuth() resets the authentication for the Sentry CLI",
      () {
        sentryService.resetAuth();

        verify(sentryCli.resetAuth()).called(once);
      },
    );

    test(
      ".resetAuth() throws if Sentry CLI throws during the resetting authentication process",
      () {
        when(sentryCli.resetAuth()).thenThrow(stateError);

        expect(
          () => sentryService.resetAuth(),
          throwsStateError,
        );
      },
    );
  });
}

class _SentryCliMock extends Mock implements SentryCli {}
