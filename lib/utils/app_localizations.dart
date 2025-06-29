class AppLocalizations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'En': {
      'categories': 'Categories',
      'search': 'Search...',
      'searchStores': 'Search stores...',
      'seeAll': 'See All',
      'noCategory': 'No category selected',
      'appName': 'Matajir',
    },
    'Fr': {
      'categories': 'Catégories',
      'search': 'Rechercher...',
      'searchStores': 'Rechercher des magasins...',
      'seeAll': 'Voir Tout',
      'noCategory': 'Aucune catégorie sélectionnée',
      'appName': 'Matajir',
    },
    'Ar': {
      'categories': 'الفئات',
      'search': 'بحث...',
      'searchStores': 'البحث عن المتاجر...',
      'seeAll': 'عرض الكل',
      'noCategory': 'لم يتم تحديد فئة',
      'appName': 'متاجر',
    },
  };

  static String translate(String key, String languageCode) {
    if (_localizedValues.containsKey(languageCode) &&
        _localizedValues[languageCode]!.containsKey(key)) {
      return _localizedValues[languageCode]![key]!;
    }
    
    // Fallback to English
    if (_localizedValues['En']!.containsKey(key)) {
      return _localizedValues['En']![key]!;
    }
    
    return key;
  }
}
