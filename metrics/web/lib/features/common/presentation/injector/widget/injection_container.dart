import 'package:flutter/material.dart';
import 'package:metrics/features/auth/data/repositories/firebase_user_repository.dart';
import 'package:metrics/features/auth/domain/usecases/receive_authentication_updates.dart';
import 'package:metrics/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:metrics/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:metrics/features/auth/presentation/state/auth_notifier.dart';
import 'package:metrics/features/common/presentation/metrics_theme/state/theme_notifier.dart';
import 'package:metrics/features/dashboard/data/repositories/firestore_metrics_repository.dart';
import 'package:metrics/features/dashboard/domain/usecases/receive_project_metrics_updates.dart';
import 'package:metrics/features/dashboard/domain/usecases/receive_project_updates.dart';
import 'package:metrics/features/dashboard/presentation/state/project_metrics_notifier.dart';
import 'package:provider/provider.dart';

/// Creates the [ChangeNotifier]s and injects them, using the [MultiProvider] widget.
class InjectionContainer extends StatefulWidget {
  final Widget child;

  const InjectionContainer({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  _InjectionContainerState createState() => _InjectionContainerState();
}

class _InjectionContainerState extends State<InjectionContainer> {
  ReceiveProjectUpdates _receiveProjectUpdates;
  ReceiveProjectMetricsUpdates _receiveProjectMetricsUpdates;
  ReceiveAuthenticationUpdates _receiveAuthUpdates;
  SignInUseCase _signInUseCase;
  SignOutUseCase _signOutUseCase;

  @override
  void initState() {
    final _metricsRepository = FirestoreMetricsRepository();
    final _userRepository = FirebaseUserRepository();

    _receiveProjectUpdates = ReceiveProjectUpdates(_metricsRepository);
    _receiveProjectMetricsUpdates =
        ReceiveProjectMetricsUpdates(_metricsRepository);
    _receiveAuthUpdates = ReceiveAuthenticationUpdates(_userRepository);
    _signInUseCase = SignInUseCase(_userRepository);
    _signOutUseCase = SignOutUseCase(_userRepository);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProjectMetricsNotifier>(
          create: (_) => ProjectMetricsNotifier(
            _receiveProjectUpdates,
            _receiveProjectMetricsUpdates,
          ),
        ),
        ChangeNotifierProvider<AuthNotifier>(
          create: (_) => AuthNotifier(
            _receiveAuthUpdates,
            _signInUseCase,
            _signOutUseCase,
          ),
        ),
        ChangeNotifierProvider<ThemeNotifier>(create: (_) => ThemeNotifier())
      ],
      child: widget.child,
    );
  }

  @override
  void dispose() {
    Provider.of<ProjectMetricsNotifier>(context, listen: false).dispose();
    Provider.of<AuthNotifier>(context, listen: false).dispose();
    super.dispose();
  }
}
