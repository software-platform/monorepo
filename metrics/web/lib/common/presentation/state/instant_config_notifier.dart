import 'package:flutter/foundation.dart';
import 'package:metrics/common/domain/entities/instant_config.dart';
import 'package:metrics/common/domain/usecases/fetch_instant_config_usecase.dart';
import 'package:metrics/common/domain/usecases/parameters/instant_config_param.dart';
import 'package:metrics/common/presentation/view_models/fps_monitor_instant_config_view_model.dart';
import 'package:metrics/common/presentation/view_models/login_form_instant_config_view_model.dart';
import 'package:metrics/common/presentation/view_models/renderer_display_instant_config_view_model.dart';

/// The [ChangeNotifier] that holds [InstantConfig]'s data.
class InstantConfigNotifier extends ChangeNotifier {
  /// Indicates whether the [InstantConfig] is loading.
  bool _isLoading = true;

  /// A [FetchInstantConfigUseCase] that provides an ability to fetch
  /// the [InstantConfig].
  final FetchInstantConfigUseCase _fetchInstantConfigUseCase;

  /// An [InstantConfig] containing the default configuration values.
  InstantConfig _defaultInstantConfig;

  /// An [InstantConfig] containing the current configuration values.
  InstantConfig _instantConfig;

  /// A view model that holds the [InstantConfig] data for the login form.
  LoginFormInstantConfigViewModel _loginFormInstantConfigViewModel;

  /// A view model that holds the [InstantConfig] data for the FPS monitor.
  FPSMonitorInstantConfigViewModel _fpsMonitorInstantConfigViewModel;

  /// A view model that holds the [InstantConfig] data for the renderer display.
  RendererDisplayInstantConfigViewModel _rendererDisplayInstantConfigViewModel;

  /// Returns `true` if the [InstantConfig] is loading,
  /// otherwise returns `false`.
  bool get isLoading => _isLoading;

  /// A view model that provides the [InstantConfig] data for the login form.
  LoginFormInstantConfigViewModel get loginFormInstantConfigViewModel =>
      _loginFormInstantConfigViewModel;

  /// A view model that provides the [InstantConfig] data for the FPS monitor.
  FPSMonitorInstantConfigViewModel get fpsMonitorInstantConfigViewModel =>
      _fpsMonitorInstantConfigViewModel;

  /// A view model that provides the [InstantConfig] data for the renderer display.
  RendererDisplayInstantConfigViewModel
      get rendererDisplayInstantConfigViewModel =>
          _rendererDisplayInstantConfigViewModel;

  /// Creates an instance of the [InstantConfigNotifier]
  /// with the given [FetchInstantConfigUseCase].
  ///
  /// Throws an [AssertionError] if the given [FetchInstantConfigUseCase]
  /// is `null`.
  InstantConfigNotifier(this._fetchInstantConfigUseCase)
      : assert(_fetchInstantConfigUseCase != null);

  /// Initializes the [InstanceConfig].
  Future<void> initializeInstantConfig() async {
    final params = InstantConfigParam(
      isLoginFormEnabled: _defaultInstantConfig.isLoginFormEnabled,
      isFpsMonitorEnabled: _defaultInstantConfig.isFpsMonitorEnabled,
      isRendererDisplayEnabled: _defaultInstantConfig.isRendererDisplayEnabled,
    );

    final config = await _fetchInstantConfigUseCase(params);

    _instantConfig = config;

    _loginFormInstantConfigViewModel = LoginFormInstantConfigViewModel(
      isEnabled: _instantConfig.isLoginFormEnabled,
    );
    _fpsMonitorInstantConfigViewModel = FPSMonitorInstantConfigViewModel(
      isEnabled: _instantConfig.isFpsMonitorEnabled,
    );
    _rendererDisplayInstantConfigViewModel =
        RendererDisplayInstantConfigViewModel(
      isEnabled: _instantConfig.isRendererDisplayEnabled,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Sets the default [InstantConfig] from the given configuration values.
  ///
  /// Throws an [AssertionError] if one of the required parameters is `null`.
  void setDefaults({
    @required bool isLoginFormEnabled,
    @required bool isFpsMonitorEnabled,
    @required bool isRendererDisplayEnabled,
  }) {
    assert(isLoginFormEnabled != null);
    assert(isFpsMonitorEnabled != null);
    assert(isRendererDisplayEnabled != null);

    _defaultInstantConfig = InstantConfig(
      isLoginFormEnabled: isLoginFormEnabled,
      isFpsMonitorEnabled: isFpsMonitorEnabled,
      isRendererDisplayEnabled: isRendererDisplayEnabled,
    );
  }
}
