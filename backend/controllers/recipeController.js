const Recipe = require('../models/Recipe');

// @desc    Fetch all recipes (with optional category filter)
// @route   GET /api/recipes
// @access  Public
const getRecipes = async (req, res) => {
  try {
    const { category } = req.query;
    let query = {};
    
    if (category) {
      query.category = category;
    }

    const recipes = await Recipe.find(query).populate('author', 'name');
    res.json(recipes);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Fetch single recipe
// @route   GET /api/recipes/:id
// @access  Public
const getRecipeById = async (req, res) => {
  try {
    const recipe = await Recipe.findById(req.params.id).populate('author', 'name');

    if (recipe) {
      res.json(recipe);
    } else {
      res.status(404).json({ message: 'Recipe not found' });
    }
  } catch (error) {
    if (error.kind === 'ObjectId') {
      return res.status(404).json({ message: 'Recipe not found' });
    }
    res.status(500).json({ message: error.message });
  }
};

// @desc    Create a recipe
// @route   POST /api/recipes
// @access  Private
const createRecipe = async (req, res) => {
  try {
    const { title, category, ingredients, steps, duration, servings, image } = req.body;

    const recipe = new Recipe({
      title,
      category,
      ingredients,
      steps,
      duration,
      servings,
      image: image || 'https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&q=80&w=400',
      author: req.user._id, // Assign the logged-in user as author
    });

    const savedRecipe = await recipe.save();
    res.status(201).json(savedRecipe);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Delete a recipe
// @route   DELETE /api/recipes/:id
// @access  Private
const deleteRecipe = async (req, res) => {
  try {
    const recipe = await Recipe.findById(req.params.id);

    if (!recipe) {
      return res.status(404).json({ message: 'Recipe not found' });
    }

    // Check if the user is the author
    if (recipe.author && recipe.author.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized to delete this recipe' });
    }

    await recipe.deleteOne();
    res.json({ message: 'Recipe removed successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Rate a recipe
// @route   POST /api/recipes/:id/rate
// @access  Private
const rateRecipe = async (req, res) => {
  try {
    const { score } = req.body;
    const recipeId = req.params.id;
    const userId = req.user._id;

    if (score < 1 || score > 5) {
       return res.status(400).json({ message: 'Score must be between 1 and 5' });
    }

    const recipe = await Recipe.findById(recipeId);

    if (!recipe) {
      return res.status(404).json({ message: 'Recipe not found' });
    }

    // Check if user already rated
    const existingRatingIndex = recipe.ratings.findIndex(r => r.user.toString() === userId.toString());
    
    if (existingRatingIndex >= 0) {
      // Update existing rating
      recipe.ratings[existingRatingIndex].score = score;
    } else {
      // Add new rating
      recipe.ratings.push({ user: userId, score });
    }

    // Calculate new average
    const totalScore = recipe.ratings.reduce((acc, curr) => acc + curr.score, 0);
    recipe.rating = totalScore / recipe.ratings.length;
    recipe.reviews = recipe.ratings.length;

    await recipe.save();
    
    res.json({ 
      message: 'Rating updated', 
      rating: recipe.rating, 
      reviews: recipe.reviews 
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Update a recipe
// @route   PUT /api/recipes/:id
// @access  Private
const updateRecipe = async (req, res) => {
  try {
    const { title, category, ingredients, steps, duration, servings, image } = req.body;
    let recipe = await Recipe.findById(req.params.id);

    if (!recipe) {
      return res.status(404).json({ message: 'Recipe not found' });
    }

    // Check if the user is the author
    if (recipe.author && recipe.author.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Not authorized to update this recipe' });
    }

    recipe.title = title || recipe.title;
    recipe.category = category || recipe.category;
    recipe.ingredients = ingredients || recipe.ingredients;
    recipe.steps = steps || recipe.steps;
    recipe.duration = duration || recipe.duration;
    recipe.servings = servings || recipe.servings;
    if (image) recipe.image = image;

    const updatedRecipe = await recipe.save();
    res.json(updatedRecipe);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getRecipes,
  getRecipeById,
  createRecipe,
  deleteRecipe,
  rateRecipe,
  updateRecipe
};
