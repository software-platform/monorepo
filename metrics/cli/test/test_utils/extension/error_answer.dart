// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:mockito/mockito.dart';

extension ErrorAnswer on PostExpectation {
  void thenAnswerError(Object error) {
    thenAnswer((_) => Future.error(error));
  }
}
