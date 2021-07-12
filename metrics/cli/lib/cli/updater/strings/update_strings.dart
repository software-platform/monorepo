// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// A class that holds the strings used within the update process.
class UpdateStrings {
  static String failedUpdating(Object error) => '''
The updating has failed due to the following error:
$error''';

  static const String successfulUpdating =
      'The updating has finished successfully!';
}
