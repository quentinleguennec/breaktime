import 'package:aebeze/services/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

List<MoodData> moodDataMocked = [
  MoodData(mood: Moods().moods[0], date: DateTime(2018, 12, 2)),
  MoodData(mood: Moods().moods[1], date: DateTime(2018, 12, 3)),
  MoodData(mood: Moods().moods[3], date: DateTime(2018, 12, 4)),
  MoodData(mood: Moods().moods[5], date: DateTime(2018, 12, 5)),
  MoodData(mood: Moods().moods[7], date: DateTime(2018, 12, 6)),
  MoodData(mood: Moods().moods[9], date: DateTime(2018, 12, 7)),
  MoodData(mood: Moods().moods[2], date: DateTime(2018, 12, 8)),
  MoodData(mood: Moods().moods[4], date: DateTime(2018, 12, 9)),
];

class TesterDashboard extends StatelessWidget {
  final Map<String, List<Treatment>> treatments;
  final ValueSetter<Treatment> onTreatmentSelected;

  TesterDashboard(this.treatments, this.onTreatmentSelected);

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
        child: Scaffold(
          body: Text("Work in progress"),
        ),
      );
}
