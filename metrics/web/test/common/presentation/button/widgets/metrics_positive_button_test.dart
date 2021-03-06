// Use of this source code is governed by the Apache License, Version 2.0 
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/common/presentation/button/theme/attention_level/metrics_button_attention_level.dart';
import 'package:metrics/common/presentation/button/theme/style/metrics_button_style.dart';
import 'package:metrics/common/presentation/button/widgets/metrics_positive_button.dart';

void main() {
  group("MetricsPositiveButton", () {
    test(
      ".selectStyle() returns a positive style of the given attention level",
      () {
        const button = MetricsPositiveButton(label: 'Label');
        const metricsButtonAttentionLevel = MetricsButtonAttentionLevel(
          positive: MetricsButtonStyle(color: Colors.green),
          neutral: MetricsButtonStyle(color: Colors.yellow),
          negative: MetricsButtonStyle(color: Colors.red),
          inactive: MetricsButtonStyle(color: Colors.grey),
        );

        final style = button.selectStyle(metricsButtonAttentionLevel);

        expect(style, equals(metricsButtonAttentionLevel.positive));
      },
    );
  });
}
