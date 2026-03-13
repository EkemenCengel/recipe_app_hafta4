const Favorite = require('../models/Favorite');
const Recipe = require('../models/Recipe');

// @desc    Add a recipe to favorites
// @route   POST /api/favorites/:recipeId
// @access  Private
const addFavorite = async (req, res) => {
  try {
    const recipeId = req.params.recipeId;
    const userId = req.user._id;

    // Check if recipe exists
    const recipe = await Recipe.findById(recipeId);
    if (!recipe) {
      return res.status(404).json({ message: 'Recipe not found' });
    }

    // Check if already favorited
    const alreadyFavorited = await Favorite.findOne({ userId, recipeId });
    if (alreadyFavorited) {
      return res.status(400).json({ message: 'Recipe already in favorites' });
    }

    const favorite = await Favorite.create({
      userId,
      recipeId
    });

    res.status(201).json(favorite);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Get user's favorite recipes
// @route   GET /api/favorites
// @access  Private
const getFavorites = async (req, res) => {
  try {
    const favorites = await Favorite.find({ userId: req.user._id }).populate('recipeId');
    res.json(favorites);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// @desc    Remove a recipe from favorites
// @route   DELETE /api/favorites/:recipeId
// @access  Private
const removeFavorite = async (req, res) => {
  try {
    const favorite = await Favorite.findOneAndDelete({
      userId: req.user._id,
      recipeId: req.params.recipeId
    });

    if (favorite) {
      res.json({ message: 'Favorite removed' });
    } else {
      res.status(404).json({ message: 'Favorite not found' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  addFavorite,
  getFavorites,
  removeFavorite
};
