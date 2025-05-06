import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'RecipeReturn.dart';

class SavedRecipesPage extends StatefulWidget {
  final Function(String) onUnsave;

  const SavedRecipesPage({super.key, required this.onUnsave});

  @override
  _SavedRecipesPageState createState() => _SavedRecipesPageState();
}

class _SavedRecipesPageState extends State<SavedRecipesPage> {
  List<Map<String, dynamic>> _localSavedRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadSavedRecipes();
  }

  Future<void> _loadSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRecipesJson = prefs.getStringList('savedRecipes');
    if (savedRecipesJson != null) {
      try {
        setState(() {
          _localSavedRecipes = savedRecipesJson.map((json) {
            try {
              return jsonDecode(json) as Map<String, dynamic>;
            } catch (e) {
              print("Error decoding JSON: $e, for string: $json");
              return <String, dynamic>{}; // Return an empty map on error
            }
          }).toList();
        });
      } catch (e) {
        print("Error loading saved recipes: $e");
        setState(() {
          _localSavedRecipes = [];
        });
      }
    }
  }

  Future<void> _unsaveRecipe(String recipeName) async {
    final prefs = await SharedPreferences.getInstance();
    _localSavedRecipes.removeWhere((recipe) => recipe['name'] == recipeName);
    final savedRecipesJson =
        _localSavedRecipes.map((r) => jsonEncode(r)).toList();
    await prefs.setStringList('savedRecipes', savedRecipesJson);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe unsaved.')),
    );
    widget.onUnsave(recipeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Recipes"),
        backgroundColor: Colors.brown[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _localSavedRecipes.isEmpty
            ? const Center(
                child: Text("No recipes saved yet.",
                    style: TextStyle(fontSize: 18)),
              )
            : ListView.builder(
                itemCount: _localSavedRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = _localSavedRecipes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Text(
                        recipe["name"] ?? "Unnamed Recipe",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          "Prep Time: ${recipe["prepTime"] ?? "Unknown"}, Cook Time: ${recipe["cookTime"] ?? "Unknown"}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _unsaveRecipe(recipe["name"]);
                        },
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ingredients: ${recipe["ingredients"] is List ? (recipe["ingredients"] as List).cast<String>().join(", ") : "Not available"}",
                              ),
                              const SizedBox(height: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Instructions:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: (recipe["instructions"] is List
                                            ? (recipe["instructions"] as List)
                                                .cast<String>()
                                            : [])
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int number = entry.key + 1;
                                      String instruction = entry.value;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4.0),
                                        child: Text(
                                          '$number. $instruction',
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
