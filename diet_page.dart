
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  DietPageState createState() => DietPageState();
}

class DietPageState extends State<DietPage> {
  // ignore: non_constant_identifier_names
  late Database diet_database;

  List<Map<String, dynamic>> dietPlans = [];

  final mealController = TextEditingController();
  final caloriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    diet_database = await openDatabase(
      join(await getDatabasesPath(), 'diets.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE diets(id INTEGER PRIMARY KEY, meal TEXT, calories INTEGER)",
        );
      },
      version: 1,
    );
    fetchDietPlans();
  }

  Future<void> fetchDietPlans() async {
    final List<Map<String, dynamic>> fetchedDiets = await diet_database.query('diets');
    setState(() {
      dietPlans = fetchedDiets;
    });
  }

  Future<void> addDietPlan(String meal, int calories) async {
    await diet_database.insert('diets', {
      'meal': meal,
      'calories': calories,
    });
    fetchDietPlans();
  }

  Future<void> deleteDietPlan(int id) async {
    await diet_database.delete('diets', where: 'id = ?', whereArgs: [id]);
    fetchDietPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: mealController,
              decoration: const InputDecoration(labelText: 'Meal'),
            ),
            TextFormField(
              controller: caloriesController,
              decoration: const InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final meal = mealController.text;
                final calories = int.tryParse(caloriesController.text) ?? 0;
                addDietPlan(meal, calories);
                mealController.clear();
                caloriesController.clear();
              },
              child: const Text('Add Diet Plan'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: dietPlans.length,
                itemBuilder: (context, index) {
                  final dietPlan = dietPlans[index];
                  return ListTile(
                    title: Text('${dietPlan['meal']} - Calories: ${dietPlan['calories']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteDietPlan(dietPlan['id']),
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