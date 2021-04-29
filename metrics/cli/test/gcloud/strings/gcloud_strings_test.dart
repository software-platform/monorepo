// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/gcloud/strings/gcloud_strings.dart';
import 'package:test/test.dart';

void main() {
  group('GCloudStrings', () {
    const projectId = 'projectId';

    test(
      ".configureOauth() returns a message that contains the given project id",
      () {
        expect(
          GCloudStrings.configureOauth(projectId),
          contains(projectId),
        );
      },
    );
  });
}
