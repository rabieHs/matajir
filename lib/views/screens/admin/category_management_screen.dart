import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../../controllers/admin_controller.dart';
import '../../../constants/app_colors.dart';
import '../../../models/category.dart';
import '../../../utils/error_dialog_utils.dart';
import '../../../services/supabase_service.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();

    // Load categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: const Color(0xFF673AB7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF673AB7), Color(0xFF311B92)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: NeverScrollableScrollPhysics(),
            slivers: [
              // Main content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      // Categories List Card
                      Card(
                        elevation: 8,
                        shadowColor: Colors.black.withAlpha(76),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
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
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withAlpha(26),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.category,
                                      color: Colors.orange,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Categories List',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Categories Content
                              SizedBox(
                                height:
                                    400, // Fixed height for scrollable content
                                child: Consumer<AdminController>(
                                  builder: (context, adminController, child) {
                                    if (adminController.isLoading &&
                                        adminController.categories.isEmpty) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF673AB7),
                                        ),
                                      );
                                    }

                                    if (adminController.error != null &&
                                        adminController.categories.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              adminController.error!,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed:
                                                  () =>
                                                      adminController
                                                          .loadCategories(),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF673AB7,
                                                ),
                                              ),
                                              child: const Text(
                                                'Retry',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    if (adminController.categories.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.category_outlined,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No categories found',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    // Separate main categories and subcategories
                                    final mainCategories =
                                        adminController.categories
                                            .where(
                                              (cat) => cat.parentId == null,
                                            )
                                            .toList();
                                    final subcategories =
                                        adminController.categories
                                            .where(
                                              (cat) => cat.parentId != null,
                                            )
                                            .toList();

                                    return RefreshIndicator(
                                      onRefresh:
                                          () =>
                                              adminController.loadCategories(),
                                      child: ListView(
                                        children: [
                                          // Main Categories Section
                                          if (mainCategories.isNotEmpty) ...[
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF673AB7,
                                                ).withAlpha(26),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Main Categories',
                                                style: TextStyle(
                                                  color: Color(0xFF673AB7),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ...mainCategories.map(
                                              (category) => _buildCategoryCard(
                                                category,
                                                adminController,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                          ],

                                          // Subcategories Section
                                          if (subcategories.isNotEmpty) ...[
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.withAlpha(
                                                  26,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Subcategories',
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ...subcategories.map(
                                              (category) => _buildCategoryCard(
                                                category,
                                                adminController,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    Category category,
    AdminController adminController,
  ) {
    final parentCategory =
        category.parentId != null
            ? adminController.categories.firstWhere(
              (cat) => cat.id == category.parentId,
              orElse:
                  () => Category(
                    id: '',
                    name: {'en': 'Unknown'},
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
            )
            : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              category.isActive ? Colors.grey[300]! : Colors.red.withAlpha(128),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Category Image
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF673AB7).withAlpha(51),
                  ),
                  child:
                      category.imageUrl != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: category.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder:
                                  (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF673AB7),
                                      strokeWidth: 2,
                                    ),
                                  ),
                              errorWidget:
                                  (context, url, error) => const Icon(
                                    Icons.category,
                                    color: Color(0xFF673AB7),
                                  ),
                            ),
                          )
                          : const Icon(
                            Icons.category,
                            color: Color(0xFF673AB7),
                          ),
                ),

                const SizedBox(width: 12),

                // Category Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.getLocalizedName('en'),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!category.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withAlpha(26),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.withAlpha(128),
                                ),
                              ),
                              child: const Text(
                                'INACTIVE',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (parentCategory != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Parent: ${parentCategory.getLocalizedName('en')}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                      if (category.name['ar'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Arabic: ${category.name['ar']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Action Buttons
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected:
                      (value) => _handleCategoryAction(
                        value,
                        category,
                        adminController,
                      ),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text('Edit Category'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: category.isActive ? 'deactivate' : 'activate',
                          child: Row(
                            children: [
                              Icon(
                                category.isActive
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color:
                                    category.isActive
                                        ? Colors.orange
                                        : Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category.isActive ? 'Deactivate' : 'Activate',
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Delete Category'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Category Stats
            Row(
              children: [
                Text(
                  'Grid Size: ${category.gridSize}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const Spacer(),
                Text(
                  'Created: ${_formatDate(category.createdAt)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleCategoryAction(
    String action,
    Category category,
    AdminController adminController,
  ) {
    switch (action) {
      case 'edit':
        _showEditCategoryDialog(category, adminController);
        break;
      case 'activate':
      case 'deactivate':
        _toggleCategoryStatus(category, adminController);
        break;
      case 'delete':
        _showDeleteCategoryDialog(category, adminController);
        break;
    }
  }

  void _showEditCategoryDialog(
    Category category,
    AdminController adminController,
  ) {
    _showCategoryDialog(category: category, adminController: adminController);
  }

  void _showCategoryDialog({
    Category? category,
    AdminController? adminController,
  }) {
    final isEditing = category != null;
    final nameEnController = TextEditingController(
      text: isEditing ? category.getLocalizedName('en') : '',
    );
    final nameArController = TextEditingController(
      text: isEditing ? (category.name['ar'] ?? '') : '',
    );
    int selectedGridSize = isEditing ? category.gridSize : 1;
    String? selectedParentId = isEditing ? category.parentId : null;
    File? selectedImage;
    String? existingImageUrl = isEditing ? category.imageUrl : null;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: Text(
                    isEditing ? 'Edit Category' : 'Add Category',
                    style: const TextStyle(color: Colors.black87),
                  ),
                  contentPadding: const EdgeInsets.all(20),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // English Name
                          TextField(
                            controller: nameEnController,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Name (English)',
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF673AB7),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Arabic Name
                          TextField(
                            controller: nameArController,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Name (Arabic)',
                              labelStyle: TextStyle(color: Colors.grey[600]),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF673AB7),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Image Picker
                          Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[50],
                            ),
                            child:
                                selectedImage != null
                                    ? Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            selectedImage!,
                                            width: double.infinity,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedImage = null;
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    : existingImageUrl != null
                                    ? Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: existingImageUrl!,
                                            width: double.infinity,
                                            height: 120,
                                            fit: BoxFit.cover,
                                            placeholder:
                                                (context, url) => const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Center(
                                                      child: Icon(
                                                        Icons.error,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                existingImageUrl = null;
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                    : InkWell(
                                      onTap: () async {
                                        final ImagePicker picker =
                                            ImagePicker();
                                        final XFile? image = await picker
                                            .pickImage(
                                              source: ImageSource.gallery,
                                              maxWidth: 800,
                                              maxHeight: 800,
                                              imageQuality: 80,
                                            );
                                        if (image != null) {
                                          setState(() {
                                            selectedImage = File(image.path);
                                          });
                                        }
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate_outlined,
                                            size: 40,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Tap to select image',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                          ),

                          const SizedBox(height: 16),

                          // Parent Category
                          Consumer<AdminController>(
                            builder: (context, adminController, child) {
                              final mainCategories =
                                  adminController.categories
                                      .where(
                                        (cat) =>
                                            cat.parentId == null &&
                                            (!isEditing ||
                                                cat.id != category!.id),
                                      )
                                      .toList();

                              return DropdownButtonFormField<String>(
                                value: selectedParentId,
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  labelText: 'Parent Category (optional)',
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFF673AB7),
                                    ),
                                  ),
                                ),
                                dropdownColor: Colors.white,
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text(
                                      'None (Main Category)',
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ),
                                  ...mainCategories.map(
                                    (cat) => DropdownMenuItem<String>(
                                      value: cat.id,
                                      child: Text(
                                        cat.getLocalizedName('en'),
                                        style: const TextStyle(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedParentId = value;
                                  });
                                },
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Grid Size
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Grid Size:',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: List.generate(3, (index) {
                                  final size = index + 1;
                                  return ChoiceChip(
                                    label: Text('$size'),
                                    selected: selectedGridSize == size,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          selectedGridSize = size;
                                        });
                                      }
                                    },
                                    selectedColor: const Color(0xFF673AB7),
                                    labelStyle: TextStyle(
                                      color:
                                          selectedGridSize == size
                                              ? Colors.white
                                              : Colors.grey[600],
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameEnController.text.trim().isEmpty) {
                          ErrorDialogUtils.showErrorDialog(
                            context: context,
                            title: 'Error',
                            message:
                                'Please provide an English name for the category.',
                          );
                          return;
                        }

                        Navigator.of(context).pop();

                        final adminController = Provider.of<AdminController>(
                          context,
                          listen: false,
                        );
                        final name = <String, String>{
                          'en': nameEnController.text.trim(),
                        };

                        if (nameArController.text.trim().isNotEmpty) {
                          name['ar'] = nameArController.text.trim();
                        }

                        bool success;
                        if (isEditing) {
                          success = await adminController.updateCategory(
                            categoryId: category!.id,
                            name: name,
                            parentId: selectedParentId,
                            imageUrl: existingImageUrl,
                            gridSize: selectedGridSize,
                          );
                        } else {
                          success = await adminController.createCategory(
                            name: name,
                            parentId: selectedParentId,
                            imageFile: selectedImage,
                            gridSize: selectedGridSize,
                          );
                        }

                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isEditing
                                    ? 'Category updated successfully'
                                    : 'Category created successfully',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (mounted) {
                          ErrorDialogUtils.showErrorDialog(
                            context: context,
                            title: 'Error',
                            message:
                                adminController.error ??
                                (isEditing
                                    ? 'Failed to update category'
                                    : 'Failed to create category'),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                      ),
                      child: Text(
                        isEditing ? 'Update' : 'Create',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _toggleCategoryStatus(
    Category category,
    AdminController adminController,
  ) async {
    final success = await adminController.updateCategory(
      categoryId: category.id,
      isActive: !category.isActive,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            category.isActive ? 'Category deactivated' : 'Category activated',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ErrorDialogUtils.showErrorDialog(
        context: context,
        title: 'Error',
        message: adminController.error ?? 'Failed to update category status',
      );
    }
  }

  void _showDeleteCategoryDialog(
    Category category,
    AdminController adminController,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'Delete Category',
              style: TextStyle(color: Colors.black87),
            ),
            content: Text(
              'Are you sure you want to permanently delete "${category.getLocalizedName('en')}"? This action cannot be undone.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  final success = await adminController.deleteCategory(
                    categoryId: category.id,
                  );

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Category deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (mounted) {
                    ErrorDialogUtils.showErrorDialog(
                      context: context,
                      title: 'Error',
                      message:
                          adminController.error ?? 'Failed to delete category',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
