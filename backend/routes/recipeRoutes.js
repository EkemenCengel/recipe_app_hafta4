const express = require('express');
const router = express.Router();
const { getRecipes, getRecipeById, createRecipe, deleteRecipe, rateRecipe, updateRecipe } = require('../controllers/recipeController');
const { protect } = require('../middlewares/authMiddleware');

router.get('/', getRecipes);
router.post('/', protect, createRecipe);
router.get('/:id', getRecipeById);
router.put('/:id', protect, updateRecipe);
router.delete('/:id', protect, deleteRecipe);
router.post('/:id/rate', protect, rateRecipe);

module.exports = router;
