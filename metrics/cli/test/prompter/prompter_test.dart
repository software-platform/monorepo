// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/prompter/prompter.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../test_utils/matchers.dart';
import '../test_utils/mock/prompt_writer_mock.dart';

void main() {
  group("Prompter", () {
    const promptText = 'promptText';
    const errorText = 'errorText';
    const confirmInput = 'yes';
    final promptWriter = PromptWriterMock();
    final prompter = Prompter(promptWriter);

    tearDown(() {
      reset(promptWriter);
    });

    test(
      "throws an ArgumentError if the given prompt writer is null",
      () {
        expect(() => Prompter(null), throwsArgumentError);
      },
    );

    test(
      ".info() displays the given text",
      () {
        prompter.info(promptText);

        verify(promptWriter.info(promptText)).called(once);
      },
    );

    test(
      ".error() displays the given error",
      () {
        prompter.error(errorText);

        verify(promptWriter.error(errorText)).called(once);
      },
    );

    test(
      ".error() does nothing if the given error is null",
      () {
        prompter.error(null);

        verifyNever(promptWriter.error(errorText));
      },
    );

    test(
      ".prompt() requests an input from the user with the given description text",
      () {
        prompter.prompt(promptText);

        verify(promptWriter.prompt(promptText)).called(once);
      },
    );

    test(
      ".prompt() returns an input from the user",
      () {
        const answer = 'userAnswer';

        when(promptWriter.prompt(promptText)).thenReturn(answer);
        final result = prompter.prompt(promptText);

        expect(result, equals(answer));
      },
    );

    test(
      ".promptConfirm() requests a confirmation input from the user with the given description text",
      () {
        prompter.promptConfirm(promptText, confirmInput: confirmInput);

        verify(
          promptWriter.promptConfirm(promptText, confirmInput),
        ).called(once);
      },
    );

    test(
      ".promptConfirm() returns a confirmation result",
      () {
        const confirmInput = 'yes';

        when(
          promptWriter.promptConfirm(promptText, confirmInput),
        ).thenReturn(true);

        final result = prompter.promptConfirm(
          promptText,
          confirmInput: confirmInput,
        );

        expect(result, isTrue);
      },
    );

    test(
      ".promptConfirm() applies a default confirm input if it's not specified",
      () {
        prompter.promptConfirm(promptText);

        verify(
          promptWriter.promptConfirm(promptText, argThat(isNotNull)),
        ).called(once);
      },
    );
  });
}
