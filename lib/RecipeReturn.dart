import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'SavedRecipesPage.dart';


class RecipeFinderPage extends StatefulWidget {
  const RecipeFinderPage({super.key});

  @override
  _RecipeFinderPageState createState() => _RecipeFinderPageState();
}

class _RecipeFinderPageState extends State<RecipeFinderPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = false;
  String? errorMessage;
  List<String> _savedRecipeNames = [];
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
        _localSavedRecipes = savedRecipesJson
            .map((json) => jsonDecode(json) as Map<String, dynamic>)
            .toList();
        _savedRecipeNames = _localSavedRecipes
            .map((recipe) => recipe['name'] as String)
            .toList();
      } catch (e) {
        print("Error loading saved recipes: $e");
        _localSavedRecipes = [];
        _savedRecipeNames = [];
        // Consider showing a message to the user here, but not with an alert dialog.
        //  ScaffoldMessenger.of(context).showSnackBar(
        //    SnackBar(content: Text('Failed to load saved recipes.')),
        //  );
      }

      setState(() {});
    } else {
      setState(() {
        _localSavedRecipes = [];
        _savedRecipeNames = [];
      });
    }
  }

  Future<void> _saveRecipe(Map<String, dynamic> recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final savedRecipesJson = prefs.getStringList('savedRecipes') ?? [];
    savedRecipesJson.add(jsonEncode(recipe));
    await prefs.setStringList('savedRecipes', savedRecipesJson);
    _loadSavedRecipes();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe saved!')),
    );
  }

  Future<void> _unsaveRecipe(String recipeName) async {
    final prefs = await SharedPreferences.getInstance();
    final savedRecipesJson = prefs.getStringList('savedRecipes') ?? [];
    savedRecipesJson.removeWhere((json) {
      final Map<String, dynamic> recipe = jsonDecode(json);
      return recipe['name'] == recipeName;
    });
    await prefs.setStringList('savedRecipes', savedRecipesJson);
    _loadSavedRecipes();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe unsaved.')),
    );
  }

  Future<void> fetchRecipes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      recipes = [];
    });

    const String apiKey =
        "AIzaSyD0qgc0wC55xid0NiSpoQCrGPicCfwNlck"; // IMPORTANT: Replace with your actual API key!
    final Uri url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');

    String prompt;
    if (_searchController.text.isNotEmpty) {
      prompt =
          "Give me 4 easy and common recipes that include ${_searchController.text}. Include recipe name, prep time, cook time, ingredients, and instructions.  Format each ingredient on a new line.  Separate the recipe name, prep time, cook time, ingredients, and instructions with clear labels like 'Recipe Name:', 'Prep Time:', 'Cook Time:', 'Ingredients:', and 'Instructions:'.  For the instructions, provide each step as plain text without any numbers or bullet points.  Do not use any markdown or asterisks.";
    } else {
      prompt =
          "Give me 4 general popular and easy recipes. Include recipe name, prep time, cook time, ingredients, and instructions. Format each ingredient on a new line.  Separate the recipe name, prep time, cook time, ingredients, and instructions with clear labels like 'Recipe Name:', 'Prep Time:', 'Cook Time:', 'Ingredients:', and 'Instructions:'. Do not use any markdown or asterisks.";
    }

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "contents": [
            {
              "parts": [
                {
                  "text": prompt,
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String textResponse =
            data["candidates"]?[0]["content"]["parts"]?[0]["text"] ?? "";

        List<Map<String, dynamic>> parsedRecipes = _parseRecipes(textResponse);

        setState(() {
          recipes = parsedRecipes;
        });
      } else {
        setState(() {
          errorMessage = "Failed to fetch recipes. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "An error occurred: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _parseRecipes(String responseText) {
    List<Map<String, dynamic>> parsedRecipes = [];
    List<String> recipeSections = responseText.split("Recipe Name:");

    for (String section in recipeSections.sublist(1)) {
      List<String> lines = section.split("\n");
      String name = "";
      String prepTime = "Unknown";
      String cookTime = "Unknown";
      List<String> ingredients = [];
      List<String> instructions = [];

      bool isParsingIngredients = false;
      bool isParsingInstructions = false;

      for (String line in lines) {
        line = line.trim();
        line = line.replaceAll('*', '');

        if (line.isEmpty) continue;

        if (name.isEmpty) {
          name = line;
          continue;
        }

        if (line.toLowerCase().startsWith("prep time:")) {
          prepTime = line.substring("prep time:".length).trim();
          isParsingIngredients = false;
          isParsingInstructions = false;
        } else if (line.toLowerCase().startsWith("cook time:")) {
          cookTime = line.substring("cook time:".length).trim();
          isParsingIngredients = false;
          isParsingInstructions = false;
        } else if (line.toLowerCase().startsWith("ingredients:")) {
          isParsingIngredients = true;
          isParsingInstructions = false;
          continue;
        } else if (line.toLowerCase().startsWith("instructions:")) {
          isParsingIngredients = false;
          isParsingInstructions = true;
          continue;
        } else if (isParsingIngredients) {
          ingredients.add(line);
        } else if (isParsingInstructions) {
          instructions.add(line);
        }
      }

      parsedRecipes.add({
        "name": name,
        "prepTime": prepTime,
        "cookTime": cookTime,
        "ingredients": ingredients.isEmpty ? ["Not available"] : ingredients,
        "instructions": instructions.isEmpty ? ["Not available"] : instructions,
        "expanded": false,
      });
    }

    return parsedRecipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Finder"),
        backgroundColor: Colors.brown[700],
        actions: [
          TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SavedRecipesPage(
                  onUnsave: _unsaveRecipe,
                ),
              ),
            );
          },
          child: const Text(
            "Saved Recipes",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter ingredients (separate with a comma):",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "e.g., eggs, flour, sugar",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: fetchRecipes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Search Recipes",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  final isSaved = _savedRecipeNames.contains(recipe['name']);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Text(
                        recipe["name"],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          "Prep Time: ${recipe["prepTime"]}, Cook Time: ${recipe["cookTime"]}"),
                      trailing: IconButton(
                        icon: Icon(
                            isSaved ? Icons.bookmark : Icons.bookmark_border),
                        onPressed: () {
                          if (isSaved) {
                            _unsaveRecipe(recipe['name']);
                          } else {
                            _saveRecipe(recipe);
                          }
                        },
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Ingredients: ${recipe["ingredients"].join(", ")}"),
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
                                    children:
                                        (recipe["instructions"] as List<String>)
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
          ],
        ),
      ),
    );
  }
}
