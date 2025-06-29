import 'package:flutter/material.dart';
import '../../models/category.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SubcategoryList extends StatelessWidget {
  final List<Category> subcategories;
  final Category? selectedSubcategory;
  final Function(Category) onSubcategoryTap;
  final Function()? onSeeAllTap;

  const SubcategoryList({
    Key? key,
    required this.subcategories,
    this.selectedSubcategory,
    required this.onSubcategoryTap,
    this.onSeeAllTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).categories,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onSeeAllTap != null)
                TextButton(
                  onPressed: onSeeAllTap,
                  child: Text(
                    AppLocalizations.of(context).seeAll,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: subcategories.length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final subcategory = subcategories[index];
              final isSelected = selectedSubcategory?.id == subcategory.id;

              return GestureDetector(
                onTap: () => onSubcategoryTap(subcategory),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            subcategory.imageUrl ??
                                'https://placehold.co/70x70/4a90e2/ffffff?text=${_getLocalizedName(context, subcategory)[0]}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getLocalizedName(context, subcategory),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getLocalizedName(BuildContext context, Category subcategory) {
    // Get the current locale
    final locale = Localizations.localeOf(context).languageCode;

    // Try to get the name in the current locale, or fall back to English
    return subcategory.name[locale] ?? subcategory.name['en'] ?? 'Unknown';
  }
}
