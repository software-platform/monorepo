import 'package:flutter/cupertino.dart';
import 'package:mockito/mockito.dart';
import 'package:metrics/features/auth/presentation/state/auth_notifier.dart';

/// Mock implementation of the [AuthNotifier].
class AuthNotifierMock extends Mock
    with ChangeNotifier
    implements AuthNotifier {}
