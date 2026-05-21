import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app/number_practice_app.dart';
part 'features/number_practice/domain/game_settings.dart';
part 'features/number_practice/domain/high_scores.dart';
part 'features/number_practice/data/game_settings_store.dart';
part 'features/number_practice/data/high_score_store.dart';
part 'features/number_practice/presentation/screens/home_screen.dart';
part 'features/number_practice/presentation/screens/settings_screen.dart';
part 'features/number_practice/presentation/screens/practice_screen.dart';
part 'features/number_practice/presentation/screens/speed_run_screen.dart';
part 'features/number_practice/presentation/screens/speed_run_results_screen.dart';
part 'features/number_practice/presentation/widgets/game_widgets.dart';

void main() {
  runApp(const NumberPracticeApp());
}
