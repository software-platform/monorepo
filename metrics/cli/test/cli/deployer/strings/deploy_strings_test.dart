// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/cli/deployer/strings/deploy_strings.dart';
import 'package:test/test.dart';

void main() {
  group("DeployStrings", () {
    test(
      ".failedDeployment() returns a text that contains the given error message",
      () {
        const errorMessage = 'errorMessage';

        final error = Exception(errorMessage);

        expect(
          DeployStrings.failedDeployment(error),
          contains(errorMessage),
        );
      },
    );

    test(
      ".deleteProject() returns a text that contains the given project id",
      () {
        const projectId = 'projectId';

        expect(
          DeployStrings.deleteProject(projectId),
          contains(projectId),
        );
      },
    );
  });
}
