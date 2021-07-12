// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// A class that holds the strings used within the deployment process.
class DeployStrings {
  static const String setupSentry =
      'Would you like to set up a Sentry for the Metrics project?(y/n): ';

  static String failedDeployment(Object error) => '''
The deployment has failed due to the following error:
$error''';

  static const String successfulDeployment =
      'The deployment has finished successfully!';

  static String deleteProject(String projectId) {
    return '''
    The GCloud project "$projectId" was created during the deployment.
    Consider the following link to the GCloud console of this project:
    https://console.cloud.google.com/home/dashboard?project=$projectId
    
    Would you like to delete the created GCloud project "$projectId"?(y/n): ''';
  }
}
