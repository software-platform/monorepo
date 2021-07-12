// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/cli/updater/strings/update_strings.dart';
import 'package:test/test.dart';

void main() {
  group("UpdateStrings", () {
    test(
      ".failedUpdating() returns a text that contains the error message",
      () {
        const errorMessage = 'errorMessage';

        final error = Exception(errorMessage);

        expect(
          UpdateStrings.failedUpdating(error),
          contains(errorMessage),
        );
      },
    );
  });
}
