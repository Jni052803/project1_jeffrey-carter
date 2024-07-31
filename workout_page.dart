import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  WorkoutPageState createState() => WorkoutPageState();
}

class WorkoutPageState extends State<WorkoutPage> {
  late Database workDatabase;
  List<Map<String, dynamic>> workouts = [];

  final exerciseController = TextEditingController();
  final setsController = TextEditingController();
  final repsController = TextEditingController();
  final weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    workDatabase = await openDatabase(
      join(await getDatabasesPath(), 'workouts.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE workouts(id INTEGER PRIMARY KEY, exercise TEXT, sets INTEGER, reps INTEGER, weight REAL)",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute("ALTER TABLE workouts ADD COLUMN weight REAL");
        }
      },
      version: 2, // Increment the version number
    );
    fetchWorkouts();
  }

  Future<void> fetchWorkouts() async {
    final List<Map<String, dynamic>> fetchedWorkouts = await workDatabase.query('workouts');
    setState(() {
      workouts = fetchedWorkouts;
    });
  }

  Future<void> addWorkout(String exercise, int sets, int reps, double weight) async {
    await workDatabase.insert('workouts', {
      'exercise': exercise,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    });
    fetchWorkouts();
  }

  Future<void> deleteWorkout(int id) async {
    await workDatabase.delete('workouts', where: 'id = ?', whereArgs: [id]);
    fetchWorkouts();
  }

  Future<void> clearAllWorkouts() async {
    await workDatabase.delete('workouts');
    fetchWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => clearAllWorkouts(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: exerciseController,
              decoration: const InputDecoration(labelText: 'Exercise'),
            ),
            TextFormField(
              controller: setsController,
              decoration: const InputDecoration(labelText: 'Sets'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: repsController,
              decoration: const InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final exercise = exerciseController.text;
                final sets = int.tryParse(setsController.text) ?? 0;
                final reps = int.tryParse(repsController.text) ?? 0;
                final weight = double.tryParse(weightController.text) ?? 0.0;
                addWorkout(exercise, sets, reps, weight);
                exerciseController.clear();
                setsController.clear();
                repsController.clear();
                weightController.clear();
              },
              child: const Text('Add Workout'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: workouts.length,
                itemBuilder: (context, index) {
                  final workout = workouts[index];
                  return ListTile(
                    title: Text('${workout['exercise']} - ${workout['sets']} sets, ${workout['reps']} reps, ${workout['weight']} kg'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteWorkout(workout['id']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}