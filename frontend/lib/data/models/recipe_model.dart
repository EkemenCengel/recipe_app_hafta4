class Recipe {
  final String id;
  final String title;
  final String category;
  final List<String> ingredients;
  final List<String> steps;
  final int duration;
  final int servings;
  final String image;
  final double rating;
  final int reviews;
  final String? authorId;
  final String? authorName;

  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.duration,
    required this.servings,
    required this.image,
    required this.rating,
    required this.reviews,
    this.authorId,
    this.authorName,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    String? authorId;
    String? authorName;

    if (json['author'] != null) {
      if (json['author'] is Map) {
        authorId = json['author']['_id'];
        authorName = json['author']['name'];
      } else {
        authorId = json['author'].toString();
      }
    }

    return Recipe(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: List<String>.from(json['steps'] ?? []),
      duration: json['duration'] ?? 0,
      servings: json['servings'] ?? 0,
      image: json['image'] ?? '',
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) ?? 0.0 : 0.0,
      reviews: json['reviews'] ?? 0,
      authorId: authorId,
      authorName: authorName,
    );
  }
}
