import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/metrics_theme/model/metrics_table_header_theme_data.dart';
import 'package:test/test.dart';

// https://github.com/software-platform/monorepo/issues/140
// ignore_for_file: prefer_const_constructors

void main() {
  group("MetricsTableHeaderThemeData", () {
    test(
      "creates an instance with a default text style if the parameter is not specified",
      () {
        const themeData = MetricsTableHeaderThemeData();

        expect(themeData.textStyle, isNotNull);
      },
    );

    test("creates an instance with the given values", () {
      final textStyle = TextStyle(color: Colors.red);
      final themeData = MetricsTableHeaderThemeData(textStyle: textStyle);

      expect(themeData.textStyle, equals(textStyle));
    });
  });
}
