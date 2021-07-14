// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/services/firebase/adapter/firebase_cli_service_adapter.dart';
import 'package:cli/services/firebase/cli/firebase_cli.dart';
import 'package:cli/services/firebase/strings/firebase_strings.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../test_utils/matchers.dart';
import '../../../test_utils/mock/prompter_mock.dart';

// ignore_for_file: avoid_redundant_argument_values

void main() {
  group("FirebaseCliServiceAdapter", () {
    const projectId = 'projectId';
    const workingDirectory = 'workingDirectory';
    const target = 'target';
    const clientId = 'clientId';
    const auth = 'auth';

    final firebaseCli = _FirebaseCliMock();
    final prompter = PrompterMock();
    final firebaseService = FirebaseCliServiceAdapter(firebaseCli, prompter);
    final stateError = StateError('test');

    tearDown(() {
      reset(firebaseCli);
      reset(prompter);
    });

    test(
      "throws an ArgumentError if the given Firebase CLI is null",
      () {
        expect(
          () => FirebaseCliServiceAdapter(null, prompter),
          throwsArgumentError,
        );
      },
    );

    test(
      "throws an ArgumentError if the given prompter is null",
      () {
        expect(
          () => FirebaseCliServiceAdapter(firebaseCli, null),
          throwsArgumentError,
        );
      },
    );

    test(
      ".login() logs in to the Firebase CLI",
      () async {
        await firebaseService.login();

        verify(firebaseCli.login()).called(once);
      },
    );

    test(
      ".login() throws if Firebase CLI throws during the login process",
      () {
        when(firebaseCli.login()).thenAnswer((_) => Future.error(stateError));

        expect(firebaseService.login(), throwsStateError);
      },
    );

    test(
      ".createWebApp() adds the Firebase capabilities to the Gcloud project with the given project id",
      () async {
        await firebaseService.createWebApp(projectId);

        verify(firebaseCli.addFirebase(projectId)).called(once);
      },
    );

    test(
      ".createWebApp() throws if Firebase CLI throws during the Firebase capabilities adding",
      () {
        when(firebaseCli.addFirebase(projectId)).thenAnswer(
          (_) => Future.error(stateError),
        );

        expect(firebaseService.createWebApp(projectId), throwsStateError);
      },
    );

    test(
      ".createWebApp() stops the Firebase web app creation process if Firebase CLI throws during the Firestore capabilities adding",
      () async {
        when(firebaseCli.addFirebase(projectId)).thenAnswer(
          (_) => Future.error(stateError),
        );

        await expectLater(
          firebaseService.createWebApp(projectId),
          throwsStateError,
        );

        verify(firebaseCli.addFirebase(projectId)).called(once);
        verifyNoMoreInteractions(firebaseCli);
      },
    );

    test(
      ".createWebApp() creates the Firebase web app with the given name within the project with the given projectId",
      () async {
        await firebaseService.createWebApp(projectId);

        verify(firebaseCli.createWebApp(projectId, projectId)).called(once);
      },
    );

    test(
      ".createWebApp() throws if Firebase CLI throws during the Firebase web app creation",
      () {
        when(firebaseCli.createWebApp(projectId, projectId)).thenAnswer(
          (_) => Future.error(stateError),
        );

        expect(firebaseService.createWebApp(projectId), throwsStateError);
      },
    );

    test(
      ".deployFirebase() sets the default Firebase project with the given project id in the given working directory",
      () async {
        await firebaseService.deployFirebase(projectId, workingDirectory);

        verify(firebaseCli.setFirebaseProject(projectId, workingDirectory))
            .called(once);
      },
    );

    test(
      ".deployFirebase() throws if Firebase CLI throws during the default Firebase project setting",
      () {
        when(firebaseCli.setFirebaseProject(projectId, workingDirectory))
            .thenAnswer((_) => Future.error(stateError));

        expect(
          firebaseService.deployFirebase(projectId, workingDirectory),
          throwsStateError,
        );
      },
    );

    test(
      ".deployFirebase() stops the Firebase deployment process if Firebase CLI throws during the default Firebase project setting",
      () async {
        when(firebaseCli.setFirebaseProject(projectId, workingDirectory))
            .thenAnswer((_) => Future.error(stateError));

        await expectLater(
          firebaseService.deployFirebase(projectId, workingDirectory),
          throwsStateError,
        );

        verify(firebaseCli.setFirebaseProject(projectId, workingDirectory))
            .called(once);
        verifyNoMoreInteractions(firebaseCli);
      },
    );

    test(
      ".deployFirebase() deploys the Firestore from the given working directory",
      () async {
        await firebaseService.deployFirebase(projectId, workingDirectory);

        verify(firebaseCli.deployFirestore(workingDirectory)).called(once);
      },
    );

    test(
      ".deployFirebase() throws if Firebase CLI throws during the Firestore deployment",
      () {
        when(firebaseCli.deployFirestore(workingDirectory)).thenAnswer(
          (_) => Future.error(stateError),
        );

        expect(
          firebaseService.deployFirebase(projectId, workingDirectory),
          throwsStateError,
        );
      },
    );

    test(
      ".deployFirebase() stops the Firebase deployment process if Firebase CLI throws during the Firestore deployment",
      () async {
        when(firebaseCli.deployFirestore(workingDirectory)).thenAnswer(
          (_) => Future.error(stateError),
        );

        await expectLater(
          firebaseService.deployFirebase(projectId, workingDirectory),
          throwsStateError,
        );

        verify(firebaseCli.setFirebaseProject(projectId, workingDirectory))
            .called(once);
        verify(firebaseCli.deployFirestore(workingDirectory)).called(once);
        verifyNoMoreInteractions(firebaseCli);
      },
    );

    test(
      ".deployFirebase() deploys the functions from the given working directory",
      () async {
        await firebaseService.deployFirebase(projectId, workingDirectory);

        verify(firebaseCli.deployFunctions(workingDirectory)).called(once);
      },
    );

    test(
      ".deployFirebase() throws if Firebase CLI throws during the functions deployment",
      () {
        when(firebaseCli.deployFunctions(workingDirectory)).thenAnswer(
          (_) => Future.error(stateError),
        );

        expect(
          firebaseService.deployFirebase(projectId, workingDirectory),
          throwsStateError,
        );
      },
    );

    test(
      ".deployHosting() sets the default Firebase project with the given project id in the given working directory",
      () async {
        await firebaseService.deployHosting(
          projectId,
          target,
          workingDirectory,
        );

        verify(firebaseCli.setFirebaseProject(projectId, workingDirectory))
            .called(once);
      },
    );

    test(
      ".deployHosting() throws if Firebase CLI throws during the default Firebase project setting",
      () {
        when(firebaseCli.setFirebaseProject(projectId, workingDirectory))
            .thenAnswer((_) => Future.error(stateError));

        expect(
          firebaseService.deployHosting(projectId, target, workingDirectory),
          throwsStateError,
        );
      },
    );

    test(
      ".deployHosting() stops the hosting deployment process if Firebase CLI throws during the default Firebase project setting",
      () async {
        when(firebaseCli.setFirebaseProject(projectId, workingDirectory))
            .thenAnswer((_) => Future.error(stateError));

        await expectLater(
          firebaseService.deployHosting(projectId, target, workingDirectory),
          throwsStateError,
        );

        verify(firebaseCli.setFirebaseProject(projectId, workingDirectory))
            .called(once);
        verifyNoMoreInteractions(firebaseCli);
      },
    );

    test(
      ".deployHosting() clears the target in the given working directory by the given target name",
      () async {
        await firebaseService.deployHosting(
          projectId,
          target,
          workingDirectory,
        );

        verify(firebaseCli.clearTarget(target, workingDirectory)).called(once);
      },
    );

    test(
      ".deployHosting() throws if Firebase CLI throws during the target clearing",
      () {
        when(firebaseCli.clearTarget(target, workingDirectory))
            .thenAnswer((_) => Future.error(stateError));

        expect(
          firebaseService.deployHosting(projectId, target, workingDirectory),
          throwsStateError,
        );
      },
    );

    test(
      ".deployHosting() stops the hosting deployment process if Firebase CLI throws during the target clearing",
      () async {
        when(firebaseCli.clearTarget(target, workingDirectory))
            .thenAnswer((_) => Future.error(stateError));

        await expectLater(
          firebaseService.deployHosting(projectId, target, workingDirectory),
          throwsStateError,
        );

        verify(firebaseCli.setFirebaseProject(projectId, workingDirectory))
            .called(once);
        verify(firebaseCli.clearTarget(target, workingDirectory)).called(once);
        verifyNoMoreInteractions(firebaseCli);
      },
    );

    test(
      ".deployHosting() associates the Firebase target with the given hosting name in the given working directory",
      () async {
        await firebaseService.deployHosting(
          projectId,
          target,
          workingDirectory,
        );

        verify(firebaseCli.applyTarget(projectId, target, workingDirectory))
            .called(once);
      },
    );

    test(
      ".deployHosting() throws if Firebase CLI throws during the target applying",
      () {
        when(firebaseCli.applyTarget(projectId, target, workingDirectory))
            .thenAnswer((_) => Future.error(stateError));

        expect(
          firebaseService.deployHosting(projectId, target, workingDirectory),
          throwsStateError,
        );
      },
    );

    test(
      ".deployHosting() stops the hosting deployment process if Firebase CLI throws during the target applying",
      () async {
        when(firebaseCli.applyTarget(projectId, target, workingDirectory))
            .thenAnswer((_) => Future.error(stateError));

        await expectLater(
          firebaseService.deployHosting(projectId, target, workingDirectory),
          throwsStateError,
        );

        verify(firebaseCli.setFirebaseProject(projectId, workingDirectory))
            .called(once);
        verify(firebaseCli.clearTarget(target, workingDirectory)).called(once);
        verify(firebaseCli.applyTarget(projectId, target, workingDirectory))
            .called(once);
        verifyNoMoreInteractions(firebaseCli);
      },
    );

    test(
      ".deployHosting() deploys a project's target from the given working directory to the Firebase hosting.",
      () async {
        await firebaseService.deployHosting(
          projectId,
          target,
          workingDirectory,
        );

        verify(firebaseCli.deployHosting(target, workingDirectory))
            .called(once);
      },
    );

    test(
      ".deployHosting() throws if Firebase CLI throws during the project's target deployment",
      () {
        when(firebaseCli.deployHosting(target, workingDirectory))
            .thenAnswer((_) => Future.error(stateError));

        expect(
          firebaseService.deployHosting(projectId, target, workingDirectory),
          throwsStateError,
        );
      },
    );

    test(
      ".version() shows the version information",
      () async {
        await firebaseService.version();

        verify(firebaseCli.version()).called(once);
      },
    );

    test(
      ".version() throws if Firebase CLI throws during the version showing",
      () {
        when(firebaseCli.version()).thenAnswer((_) => Future.error(stateError));

        expect(firebaseService.version(), throwsStateError);
      },
    );

    test(
      ".configureAuthProviders() prompts the user to configure the authentication providers",
      () {
        firebaseService.configureAuthProviders(projectId);

        verify(prompter.prompt(FirebaseStrings.configureAuthProviders(
          projectId,
        ))).called(once);
      },
    );

    test(
      ".configureAuthProviders() returns the Google sign client id entered by the user",
      () {
        when(prompter.prompt(FirebaseStrings.configureAuthProviders(projectId)))
            .thenReturn(clientId);

        final result = firebaseService.configureAuthProviders(projectId);

        expect(result, equals(clientId));
      },
    );

    test(
      ".configureAuthProviders() throws if prompter throws during the authentication providers configuring",
      () {
        when(prompter.prompt(FirebaseStrings.configureAuthProviders(projectId)))
            .thenThrow(stateError);

        expect(
          () => firebaseService.configureAuthProviders(projectId),
          throwsStateError,
        );
      },
    );

    test(
      ".enableAnalytics() prompts the user to configure the Analytics service",
      () {
        firebaseService.enableAnalytics(projectId);

        verify(prompter.prompt(FirebaseStrings.enableAnalytics(projectId)))
            .called(once);
      },
    );

    test(
      ".enableAnalytics() throws if prompter throws during the Analytics service config prompting",
      () {
        when(prompter.prompt(FirebaseStrings.enableAnalytics(projectId)))
            .thenThrow(stateError);

        expect(
          () => firebaseService.enableAnalytics(projectId),
          throwsStateError,
        );
      },
    );

    test(
      ".initializeFirestoreData() prompts the user to configure the initial Firestore data",
      () {
        firebaseService.initializeFirestoreData(projectId);

        verify(prompter.prompt(FirebaseStrings.initializeData(projectId)))
            .called(once);
      },
    );

    test(
      ".initializeFirestoreData() throws if prompter throws during the initial Firestore data prompting",
      () {
        when(prompter.prompt(FirebaseStrings.initializeData(projectId)))
            .thenThrow(stateError);

        expect(
          () => firebaseService.initializeFirestoreData(projectId),
          throwsStateError,
        );
      },
    );

    test(
      ".upgradeBillingPlan() prompts the user to upgrade the billing plan",
      () {
        firebaseService.upgradeBillingPlan(projectId);

        verify(prompter.prompt(FirebaseStrings.upgradeBillingPlan(projectId)))
            .called(once);
      },
    );

    test(
      ".upgradeBillingPlan() throws if prompter throws during the billing plan prompting",
      () {
        when(prompter.prompt(FirebaseStrings.upgradeBillingPlan(projectId)))
            .thenThrow(stateError);

        expect(
          () => firebaseService.upgradeBillingPlan(projectId),
          throwsStateError,
        );
      },
    );

    test(
      ".acceptTermsOfService() prompts the user to accept the terms of the Firebase service",
      () {
        firebaseService.acceptTermsOfService();

        verify(prompter.prompt(FirebaseStrings.acceptTerms)).called(once);
      },
    );

    test(
      ".acceptTermsOfService() throws if prompter throws during the terms prompting",
      () {
        when(prompter.prompt(FirebaseStrings.acceptTerms))
            .thenThrow(stateError);

        expect(
          () => firebaseService.acceptTermsOfService(),
          throwsStateError,
        );
      },
    );

    test(
      ".initializeAuth() initializes the authentication for the Firebase CLI",
      () {
        firebaseService.initializeAuth(auth);

        verify(firebaseCli.setupAuth(auth)).called(once);
      },
    );

    test(
      ".initializeAuth() throws if Firebase CLI throws during the initializing authentication process",
      () {
        when(firebaseCli.setupAuth(auth)).thenThrow(stateError);

        expect(
          () => firebaseService.initializeAuth(auth),
          throwsStateError,
        );
      },
    );

    test(
      ".resetAuth() resets the authentication for the Firebase CLI",
      () {
        firebaseService.resetAuth();

        verify(firebaseCli.resetAuth()).called(once);
      },
    );

    test(
      ".resetAuth() throws if Firebase CLI throws during the resetting authentication process",
      () {
        when(firebaseCli.resetAuth()).thenThrow(stateError);

        expect(
          () => firebaseService.resetAuth(),
          throwsStateError,
        );
      },
    );
  });
}

class _FirebaseCliMock extends Mock implements FirebaseCli {}
