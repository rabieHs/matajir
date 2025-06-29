import 'package:flutter/material.dart';
import 'package:matajir/constants/app_colors.dart';
import 'package:matajir/models/category.dart';
import 'package:matajir/services/supabase_service.dart';
import 'package:matajir/views/screens/advertise/create_ad/ad_creation_base_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryMatchAdScreen extends StatefulWidget {
  const CategoryMatchAdScreen({super.key});

  @override
  State<CategoryMatchAdScreen> createState() => _CategoryMatchAdScreenState();
}

class _CategoryMatchAdScreenState extends State<CategoryMatchAdScreen> {
  Category? _selectedCategory;
  Category? _selectedSubcategory;
  List<Category> _categories = [];
  List<Category> _subcategories = [];
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
      // Fetch categories from Supabase
      final categoriesData = await SupabaseService.instance.getCategories();

      setState(() {
        // Convert the raw data to Category objects
        _categories =
            categoriesData.map((data) => Category.fromJson(data)).toList();
        _isLoading = false;
      });

      debugPrint('Loaded ${_categories.length} categories');
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCategoryChanged(Category? category) {
    setState(() {
      _selectedCategory = category;
      _selectedSubcategory = null;
      _subcategories = [];

      if (category != null) {
        _isLoading = true;

        // Fetch subcategories from Supabase
        SupabaseService.instance
            .getSubcategories(category.id)
            .then((subcategoriesData) {
              setState(() {
                // Convert the raw data to Category objects
                _subcategories =
                    subcategoriesData
                        .map((data) => Category.fromJson(data))
                        .toList();
                _isLoading = false;
              });

              debugPrint(
                'Loaded ${_subcategories.length} subcategories for category ${category.id}',
              );
            })
            .catchError((e) {
              debugPrint('Error loading subcategories: $e');
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

    return AdCreationBaseScreen(
      title: localizations.categoryMatchAdvertisement,
      adType: 'category_match',
      categoryId: _selectedCategory?.id,
      subcategoryId: _selectedSubcategory?.id,
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
                    localizations.categorySelection,
                    Icons.category,
                  ),
                  const SizedBox(height: 16),

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
                                  Text(
                                    localizations.categoryMatch,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    localizations.categoryMatchPrice,
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
                        Text(
                          localizations.categoryMatchDescription,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Category dropdown
                  Text(
                    localizations.selectCategory,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Category>(
                        value: _selectedCategory,
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black87),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFF673AB7),
                        ),
                        isExpanded: true,
                        hint: Text(
                          localizations.selectCategory,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        items:
                            _categories.map((category) {
                              return DropdownMenuItem<Category>(
                                value: category,
                                child: Text(category.name['en'] ?? 'Unknown'),
                              );
                            }).toList(),
                        onChanged: _onCategoryChanged,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subcategory dropdown
                  Text(
                    localizations.selectSubcategory,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                      : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Category>(
                            value: _selectedSubcategory,
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Colors.black87),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF673AB7),
                            ),
                            isExpanded: true,
                            hint: Text(
                              _selectedCategory == null
                                  ? localizations.selectCategoryFirst
                                  : localizations.selectSubcategory,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            items:
                                _subcategories.map((subcategory) {
                                  return DropdownMenuItem<Category>(
                                    value: subcategory,
                                    child: Text(
                                      subcategory.name['en'] ?? 'Unknown',
                                    ),
                                  );
                                }).toList(),
                            onChanged:
                                _selectedCategory == null
                                    ? null
                                    : (subcategory) {
                                      setState(() {
                                        _selectedSubcategory = subcategory;
                                      });
                                    },
                          ),
                        ),
                      ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.recommendedImageSize('800 x 400 pixels'),
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
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
            SnackBar(
              content: Text(localizations.pleaseSelectCategory),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // The shared service handles everything now
        // This callback is called after successful creation and payment
        debugPrint('Category Match Ad created successfully: $data');
      },
    );
  }
}
