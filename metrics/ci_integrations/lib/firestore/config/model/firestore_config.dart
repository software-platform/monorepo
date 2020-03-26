import 'package:meta/meta.dart';

/// Represents the firestore destination configuration.
class FirestoreConfig {
  /// The firebase project identifier that defines which instance of
  /// firebase used to store loaded metrics.
  final String firebaseProjectId;

  /// The firestore metrics project identifier that defines where to save metrics,
  /// loaded from the CI.
  final String metricsProjectId;

  /// Creates the [FirestoreConfig] with the given [metricsProjectId].
  ///
  /// Throws the [ArgumentError] is the [metricsProjectId]
  /// or [firebaseProjectId] is null.
  FirestoreConfig({
    @required this.firebaseProjectId,
    @required this.metricsProjectId,
  }) {
    ArgumentError.checkNotNull(firebaseProjectId, 'firebaseProjectId');
    ArgumentError.checkNotNull(metricsProjectId, 'metricsProjectId');
  }

  /// Creates [FirestoreConfig] from the decoded JSON object.
  ///
  /// Returns `null` if [json] is `null`.
  factory FirestoreConfig.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return FirestoreConfig(
      firebaseProjectId: json['firebase_project_id'] as String,
      metricsProjectId: json['metrics_project_id'] as String,
    );
  }
}
