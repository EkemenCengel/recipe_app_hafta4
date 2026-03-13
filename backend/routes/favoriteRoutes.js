const express = require('express');
const router = express.Router();
const { addFavorite, getFavorites, removeFavorite } = require('../controllers/favoriteController');
const { protect } = require('../middlewares/authMiddleware');

router.route('/')
  .get(protect, getFavorites);

router.route('/:recipeId')
  .post(protect, addFavorite)
  .delete(protect, removeFavorite);

module.exports = router;
