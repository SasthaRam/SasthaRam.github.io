class Recipe {
  final String name;
  final List<String> ingredients;
  final String instructions;
  final String link;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.instructions,
    required this.link,
  });
}

List<Recipe> recipes = [
  Recipe(
    name: "Spaghetti Carbonara",
    ingredients: [
      "spaghetti",
      "eggs",
      "pancetta",
      "pecorino romano cheese",
      "black pepper"
    ],
    instructions:
        "Cook spaghetti until al dente. Fry pancetta until crispy. Whisk eggs, pecorino romano, and black pepper in a bowl. Combine the hot pasta with the egg mixture, tossing quickly to create a creamy sauce. Add crispy pancetta. Serve immediately.",
    link: "https://www.allrecipes.com/recipe/11997/spaghetti-carbonara-ii/",
  ),
  Recipe(
    name: "Chicken Stir-Fry",
    ingredients: ["chicken breast", "broccoli florets", "carrots", "soy sauce", "ginger", "garlic"],
    instructions:
        "Slice chicken into thin strips. Stir-fry chicken with minced garlic and ginger until cooked. Add broccoli florets and sliced carrots. Pour soy sauce over the mixture. Cook until vegetables are tender-crisp. Serve over rice.",
    link: "https://www.bbcgoodfood.com/recipes/easy-chicken-stir-fry",
  ),
  Recipe(
    name: "Avocado Toast",
    ingredients: ["bread", "avocado", "salt", "pepper", "red pepper flakes"],
    instructions:
        "Toast bread to your liking. Mash avocado in a bowl. Season with salt, pepper, and red pepper flakes. Spread avocado on toast. Enjoy immediately.",
    link: "https://www.foodnetwork.com/recipes/food-network-kitchen/basic-avocado-toast-3711979",
  ),
];