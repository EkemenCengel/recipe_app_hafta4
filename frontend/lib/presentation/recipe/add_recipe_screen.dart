import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/recipe_service.dart';
import '../../data/models/recipe_model.dart';

class AddRecipeScreen extends StatefulWidget {
  final Recipe? existingRecipe;
  const AddRecipeScreen({super.key, this.existingRecipe});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _stepsController = TextEditingController();
  final _durationController = TextEditingController();
  final _servingsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedCategory = 'Ana Yemek';
  final List<String> _categories = ['Çorba', 'Ana Yemek', 'Tatlı', 'Ara Sıcak'];

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRecipe != null) {
      _isEditing = true;
      _titleController.text = widget.existingRecipe!.title;
      _ingredientsController.text = widget.existingRecipe!.ingredients.join(', ');
      _stepsController.text = widget.existingRecipe!.steps.join('\n');
      _durationController.text = widget.existingRecipe!.duration.toString();
      _servingsController.text = widget.existingRecipe!.servings.toString();
      _imageUrlController.text = widget.existingRecipe!.image;
      if (_categories.contains(widget.existingRecipe!.category)) {
        _selectedCategory = widget.existingRecipe!.category;
      }
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final ingredients = _ingredientsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        final steps = _stepsController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

        final recipeData = {
          'title': _titleController.text,
          'category': _selectedCategory,
          'ingredients': ingredients,
          'steps': steps,
          'duration': int.tryParse(_durationController.text) ?? 30,
          'servings': int.tryParse(_servingsController.text) ?? 2,
          if (_imageUrlController.text.isNotEmpty) 'image': _imageUrlController.text,
        };

        if (_isEditing) {
          await RecipeService.updateRecipe(widget.existingRecipe!.id, recipeData);
        } else {
          await RecipeService.createRecipe(recipeData);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditing ? 'Tarif güncellendi!' : 'Tarif eklendi!')));
          context.pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Tarifi Düzenle' : 'Yeni Tarif Ekle', style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_titleController, 'Tarif Adı', Icons.fastfood),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        filled: true,
                        fillColor: Color(0xFF1E1E2C),
                        border: OutlineInputBorder(),
                      ),
                      dropdownColor: const Color(0xFF1E1E2C),
                      style: const TextStyle(color: Colors.white),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_ingredientsController, 'Malzemeler (Virgülle ayırın)', Icons.list, maxLines: 3),
                    const SizedBox(height: 16),
                    _buildTextField(_stepsController, 'Yapılışı (Her adım yeni satır)', Icons.format_list_numbered, maxLines: 4),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_durationController, 'Süre (dk)', Icons.timer, isNumber: true)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(_servingsController, 'Kişi Sayısı', Icons.people, isNumber: true)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_imageUrlController, 'Kapak Fotoğrafı URL (Opsiyonel)', Icons.image),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                        onPressed: _submit,
                        child: Text(_isEditing ? 'Güncelle' : 'Kaydet', style: const TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1E1E2C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) => (value == null || value.isEmpty) && label != 'Kapak Fotoğrafı URL (Opsiyonel)' ? 'Bu alan zorunludur' : null,
    );
  }
}
