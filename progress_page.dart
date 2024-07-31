import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  ProgressPageState createState() => ProgressPageState();
}

class ProgressPageState extends State<ProgressPage> {
  late Database workDatabase;
  late Database dietDatabase;

  int totalWorkouts = 0;
  int totalCalories = 0;
  Map<String, dynamic>? heaviestWorkout;

  @override
  void initState() {
    super.initState();
    initializeDatabases();
  }

  Future<void> initializeDatabases() async {
    await initializeWorkoutDatabase();
    await initializeDietDatabase();
    fetchProgressData();
  }

  Future<void> initializeWorkoutDatabase() async {
    workDatabase = await openDatabase(
      join(await getDatabasesPath(), 'workouts.db'),
      version: 1,
    );
  }

  Future<void> initializeDietDatabase() async {
    dietDatabase = await openDatabase(
      join(await getDatabasesPath(), 'diets.db'),
      version: 1,
    );
  }

  Future<void> fetchProgressData() async {
    final List<Map<String, dynamic>> workoutCount = await workDatabase.rawQuery('SELECT COUNT(*) as count FROM workouts');
    final List<Map<String, dynamic>> calorieSum = await dietDatabase.rawQuery('SELECT SUM(calories) as total FROM diets');
    final List<Map<String, dynamic>> maxWeightWorkout = await workDatabase.rawQuery('SELECT * FROM workouts ORDER BY weight DESC LIMIT 1');

    setState(() {
      totalWorkouts = workoutCount.first['count'] ?? 0;
      totalCalories = calorieSum.first['total'] ?? 0;
      heaviestWorkout = maxWeightWorkout.isNotEmpty ? maxWeightWorkout.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Total Workouts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '$totalWorkouts',
              style: const TextStyle(fontSize: 40),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Total Calories Consumed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '$totalCalories',
              style: const TextStyle(fontSize: 40),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Heaviest Workout',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (heaviestWorkout != null)
              Text(
                '${heaviestWorkout!['exercise']} - ${heaviestWorkout!['sets']} sets, ${heaviestWorkout!['reps']} reps, ${heaviestWorkout!['weight']} kg',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              )
            else
              const Text(
                'No workouts recorded',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}