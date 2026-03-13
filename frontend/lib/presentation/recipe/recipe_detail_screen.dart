import 'package:flutter/material.dart';
import '../../data/models/recipe_model.dart';
import '../../data/services/recipe_service.dart';
import '../../data/services/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'add_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final favorites = await RecipeService.getFavorites();
      if (mounted) {
        setState(() {
          _isFavorite = favorites.any((r) => r.id == widget.recipe.id);
        });
      }
    } catch (e) {
      print('Error checking favorites: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (_isFavorite) {
        await RecipeService.removeFavorite(widget.recipe.id);
      } else {
        await RecipeService.addFavorite(widget.recipe.id);
      }
      setState(() {
        _isFavorite = !_isFavorite;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(_isFavorite ? 'Favorilere eklendi' : 'Favorilerden çıkarıldı')),
        );
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('İşlem başarısız: $e')),
        );
      }
    }
  }

  void _deleteRecipe() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('Tarifi Sil', style: TextStyle(color: Colors.white)),
        content: const Text('Bu tarifi silmek istediğinize emin misiniz?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      )
    );

    if (confirm == true) {
      try {
        await RecipeService.deleteRecipe(widget.recipe.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarif silindi')));
          // Go back to previous screen
          Navigator.pop(context, true); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      }
    }
  }

  void _showRatingDialog() {
    if (!AuthService.instance.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Puan vermek için giriş yapmalısınız.')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return RatingDialog(
          initialRating: 1.0,
          title: const Text(
            'Tarifi Puanla',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          message: const Text(
            'Bu tarif hakkında ne düşünüyorsunuz?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
          image: const Icon(Icons.star, size: 100, color: Colors.orangeAccent),
          submitButtonText: 'Gönder',
          commentHint: 'İsteğe bağlı yorum',
          onSubmitted: (response) async {
            try {
              final result = await RecipeService.rateRecipe(widget.recipe.id, response.rating);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Puanınız kaydedildi! Sayfayı yenileyin.')),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
              }
            }
          },
        );
      },
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Hızlı Bakış', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.timer, color: Colors.orangeAccent),
                title: Text('${widget.recipe.duration} dk Hazırlık', style: const TextStyle(color: Colors.white)),
              ),
              ListTile(
                leading: const Icon(Icons.restaurant, color: Colors.orangeAccent),
                title: Text('${widget.recipe.servings} Kişilik', style: const TextStyle(color: Colors.white)),
              ),
               ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text('${widget.recipe.rating} Puan', style: const TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: const Color(0xFF1E1E2C),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.recipe.title, style: const TextStyle(shadows: [Shadow(color: Colors.black54, blurRadius: 4)])),
              background: Hero(
                tag: 'recipe_image_${widget.recipe.id}',
                child: Image.network(
                  widget.recipe.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => const ColoredBox(color: Colors.grey),
                ),
              ),
            ),
            actions: [
               IconButton(
                 icon: const Icon(Icons.share, color: Colors.blueAccent),
                 onPressed: () {
                   final String deepLink = 'myrecipeapp://tarifler/${widget.recipe.id}';
                   Share.share(
                     'Bu harika tarife göz atmalısın: ${widget.recipe.title}\n\nMobil uygulamada açmak için bağlantıya tıkla: $deepLink',
                   );
                 },
               ),
               if (AuthService.instance.userId != null && AuthService.instance.userId == widget.recipe.authorId) ...[
                 IconButton(
                   icon: const Icon(Icons.edit, color: Colors.amberAccent),
                   onPressed: () async {
                      // Navigate to AddRecipeScreen passing the recipe to edit it
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRecipeScreen(existingRecipe: widget.recipe),
                        ),
                      );
                      // If editing was successful and returned true, pop so it refreshes via the home screen
                      if (result == true && mounted) {
                         Navigator.pop(context, true);
                      }
                   },
                 ),
                 IconButton(
                   icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                   onPressed: _deleteRecipe,
                 ),
               ],
               IconButton(
                 icon: const Icon(Icons.info_outline),
                 onPressed: _showBottomSheet,
               )
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                           const Icon(Icons.timer, color: Colors.orangeAccent, size: 20),
                           const SizedBox(width: 8),
                           Text('${widget.recipe.duration} dk', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                      Row(
                        children: [
                           const Icon(Icons.person, color: Colors.orangeAccent, size: 20),
                           const SizedBox(width: 8),
                           Text('${widget.recipe.servings} kişi', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                       InkWell(
                        onTap: _showRatingDialog,
                        child: Row(
                          children: [
                             const Icon(Icons.star, color: Colors.amber, size: 20),
                             const SizedBox(width: 8),
                             Text('${widget.recipe.rating.toStringAsFixed(1)} (${widget.recipe.reviews})', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (widget.recipe.authorName != null) ...[
                    Text('Ekleyen: ${widget.recipe.authorName}', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.white54)),
                    const SizedBox(height: 16),
                  ],
                  const Text('Malzemeler', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  ...widget.recipe.ingredients.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.deepOrange),
                        const SizedBox(width: 16),
                        Expanded(child: Text(item, style: const TextStyle(color: Colors.white70, fontSize: 16))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 32),
                  const Text('Yapılışı', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  ...widget.recipe.steps.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('${entry.key + 1}.', style: const TextStyle(color: Colors.deepOrange, fontSize: 18, fontWeight: FontWeight.bold)),
                         const SizedBox(width: 16),
                         Expanded(child: Text(entry.value, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5))),
                      ],
                    ),
                  )),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFavorite ? Colors.grey[800] : Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
                      ),
                       onPressed: _toggleFavorite,
                       icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                       label: Text(_isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle', style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}
