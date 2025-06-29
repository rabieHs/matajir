import 'package:flutter/material.dart';
import 'package:matajir/constants/app_colors.dart';
import 'package:matajir/models/advertisement.dart';
import 'package:matajir/models/category.dart';
import 'package:matajir/services/supabase_service.dart';
import 'package:matajir/views/screens/advertise/edit_ad/ad_edit_base_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditCategoryMatchAdScreen extends StatefulWidget {
  final Advertisement advertisement;

  const EditCategoryMatchAdScreen({super.key, required this.advertisement});

  @override
  State<EditCategoryMatchAdScreen> createState() =>
      _EditCategoryMatchAdScreenState();
}

class _EditCategoryMatchAdScreenState extends State<EditCategoryMatchAdScreen> {
  List<Category> _categories = [];
  List<Category> _subcategories = [];
  Category? _selectedCategory;
  Category? _selectedSubcategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categoriesData = await SupabaseService.instance.getCategories();
      setState(() {
        _categories =
            categoriesData.map((data) => Category.fromJson(data)).toList();
      });

      // If advertisement has category/subcategory, load them
      if (widget.advertisement.categoryId != null) {
        // Find and set the selected category
        _selectedCategory = _categories.firstWhere(
          (cat) => cat.id == widget.advertisement.categoryId,
          orElse: () => _categories.first,
        );

        // Load subcategories for the selected category
        if (_selectedCategory != null) {
          await _loadSubcategories(_selectedCategory!.id);

          // Set selected subcategory if exists
          if (widget.advertisement.subcategoryId != null) {
            try {
              _selectedSubcategory = _subcategories.firstWhere(
                (subcat) => subcat.id == widget.advertisement.subcategoryId,
              );
            } catch (e) {
              _selectedSubcategory =
                  _subcategories.isNotEmpty ? _subcategories.first : null;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSubcategories(String categoryId) async {
    try {
      final subcategoriesData = await SupabaseService.instance.getSubcategories(
        categoryId,
      );
      setState(() {
        _subcategories =
            subcategoriesData.map((data) => Category.fromJson(data)).toList();
      });
    } catch (e) {
      debugPrint('Error loading subcategories: $e');
    }
  }

  void _onCategoryChanged(Category? category) {
    setState(() {
      _selectedCategory = category;
      _selectedSubcategory = null;
      _subcategories = [];

      if (category != null) {
        _isLoading = true;
        _loadSubcategories(category.id).then((_) {
          setState(() {
            _isLoading = false;
          });
        });
      }
    });
  }

  // Helper method to build section headers with icons
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF673AB7)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF673AB7),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AdEditBaseScreen(
      title: 'Edit ${localizations.categoryMatchAdvertisement}',
      advertisement: widget.advertisement,
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Selection Card
          Card(
            elevation: 8,
            shadowColor: Colors.black.withAlpha(76),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Selection header
                  _buildSectionHeader(
                    localizations.categorySelection ?? 'Category Selection',
                    Icons.category,
                  ),
                  const SizedBox(height: 20),

                  // Category Dropdown
                  DropdownButtonFormField<Category>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText:
                          localizations.selectCategory ?? 'Select Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items:
                        _categories.map((category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Text(category.getLocalizedName('en')),
                          );
                        }).toList(),
                    onChanged: _onCategoryChanged,
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Subcategory Dropdown
                  DropdownButtonFormField<Category>(
                    value: _selectedSubcategory,
                    decoration: InputDecoration(
                      labelText: 'Select Subcategory',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.subdirectory_arrow_right),
                    ),
                    items:
                        _subcategories.map((subcategory) {
                          return DropdownMenuItem<Category>(
                            value: subcategory,
                            child: Text(subcategory.getLocalizedName('en')),
                          );
                        }).toList(),
                    onChanged: (Category? value) {
                      setState(() {
                        _selectedSubcategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null && _subcategories.isNotEmpty) {
                        return 'Please select a subcategory';
                      }
                      return null;
                    },
                  ),

                  if (_isLoading) ...[
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                  ],

                  const SizedBox(height: 20),

                  // Package info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.category,
                                color: AppColors.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Category Match',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$15/week',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.accentColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your ad will appear in the selected category and subcategory pages.',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.recommendedImageSize(
                            '800 x 400 pixels',
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      onSubmit: (data) {
        if (_selectedCategory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a category'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // The edit functionality is handled by the base screen
        debugPrint('Category Match Ad updated successfully: $data');
      },
    );
  }
}
