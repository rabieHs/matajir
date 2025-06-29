import '../models/category.dart';
import '../models/store.dart';
import '../models/advertisement.dart';

class MockData {
  // Mock Categories with SubCategories
  static List<Category> getCategories() {
    final now = DateTime.now();
    return [
      Category(
        id: '1',
        name: {'en': 'Clothing', 'ar': 'ملابس', 'fr': 'Vêtements'},
        imageUrl:
            'https://images.unsplash.com/photo-1483985988355-763728e1935b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
        gridSize: 2,
        gradientStartColor: '#9C27B0',
        gradientEndColor: '#673AB7',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '2',
        name: {'en': 'Footwear', 'ar': 'أحذية', 'fr': 'Chaussures'},
        imageUrl:
            'https://images.unsplash.com/photo-1549298916-b41d501d3772?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1112&q=80',
        gridSize: 1,
        gradientStartColor: '#F44336',
        gradientEndColor: '#E91E63',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '3',
        name: {'en': 'Accessories', 'ar': 'إكسسوارات', 'fr': 'Accessoires'},
        imageUrl:
            'https://images.unsplash.com/photo-1611085583191-a3b181a88401?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1074&q=80',
        gridSize: 1,
        gradientStartColor: '#3F51B5',
        gradientEndColor: '#2196F3',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '4',
        name: {
          'en': 'Personal Care & Beauty',
          'ar': 'العناية الشخصية والجمال',
          'fr': 'Soins personnels et beauté',
        },
        imageUrl:
            'https://images.unsplash.com/photo-1596462502278-27bfdc403348?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=880&q=80',
        gridSize: 1,
        gradientStartColor: '#009688',
        gradientEndColor: '#4CAF50',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '5',
        name: {
          'en': 'Electronics & Technology',
          'ar': 'الإلكترونيات والتكنولوجيا',
          'fr': 'Électronique et technologie',
        },
        imageUrl:
            'https://images.unsplash.com/photo-1498049794561-7780e7231661?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
        gridSize: 1,
        gradientStartColor: '#FF9800',
        gradientEndColor: '#FF5722',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '6',
        name: {
          'en': 'Mother & Child',
          'ar': 'الأم والطفل',
          'fr': 'Mère et enfant',
        },
        imageUrl:
            'https://images.unsplash.com/photo-1492725764893-90b379c2b6e7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1498&q=80',
        gridSize: 2,
        gradientStartColor: '#795548',
        gradientEndColor: '#607D8B',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '7',
        name: {
          'en': 'Special Needs',
          'ar': 'احتياجات خاصة',
          'fr': 'Besoins spéciaux',
        },
        imageUrl:
            'https://images.unsplash.com/photo-1626271763156-520913751759?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
        gridSize: 1,
        gradientStartColor: '#9C27B0',
        gradientEndColor: '#673AB7',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '8',
        name: {
          'en': 'Home & Kitchen',
          'ar': 'المنزل والمطبخ',
          'fr': 'Maison et cuisine',
        },
        imageUrl:
            'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=958&q=80',
        gridSize: 3,
        gradientStartColor: '#FF9800',
        gradientEndColor: '#FF5722',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '9',
        name: {
          'en': 'Sports & Fitness',
          'ar': 'الرياضة واللياقة البدنية',
          'fr': 'Sports et fitness',
        },
        imageUrl:
            'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80',
        gridSize: 1,
        gradientStartColor: '#F44336',
        gradientEndColor: '#E91E63',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '10',
        name: {
          'en': 'Pets',
          'ar': 'الحيوانات الأليفة',
          'fr': 'Animaux de compagnie',
        },
        imageUrl:
            'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1064&q=80',
        gridSize: 1,
        gradientStartColor: '#3F51B5',
        gradientEndColor: '#2196F3',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '11',
        name: {'en': 'Supermarket', 'ar': 'سوبر ماركت', 'fr': 'Supermarché'},
        imageUrl:
            'https://images.unsplash.com/photo-1542838132-92c53300491e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1074&q=80',
        gridSize: 1,
        gradientStartColor: '#009688',
        gradientEndColor: '#4CAF50',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '12',
        name: {
          'en': 'Books & Hobbies',
          'ar': 'الكتب والهوايات',
          'fr': 'Livres et loisirs',
        },
        imageUrl:
            'https://images.unsplash.com/photo-1526243741027-444d633d7365?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1171&q=80',
        gridSize: 1,
        gradientStartColor: '#795548',
        gradientEndColor: '#607D8B',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '13',
        name: {'en': 'Services', 'ar': 'خدمات', 'fr': 'Services'},
        imageUrl:
            'https://images.unsplash.com/photo-1521791136064-7986c2920216?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1169&q=80',
        gridSize: 1,
        gradientStartColor: '#9C27B0',
        gradientEndColor: '#673AB7',
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '14',
        name: {
          'en': 'Incense & Arabic Perfumes',
          'ar': 'البخور والعطور العربية',
          'fr': 'Encens et parfums arabes',
        },
        imageUrl: 'https://picsum.photos/800/600',
        gridSize: 1,
        gradientStartColor: '#F44336',
        gradientEndColor: '#E91E63',
        createdAt: now,
        updatedAt: now,
      ),

      // Subcategories
      Category(
        id: '101',
        name: {'en': 'Men', 'ar': 'رجال', 'fr': 'Hommes'},
        parentId: '1', // Parent is Clothing
        imageUrl:
            'https://images.unsplash.com/photo-1617137968427-85924c800a22',
        gridSize: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '102',
        name: {'en': 'Women', 'ar': 'نساء', 'fr': 'Femmes'},
        parentId: '1', // Parent is Clothing
        imageUrl:
            'https://images.unsplash.com/photo-1483985988355-763728e1935b',
        gridSize: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '103',
        name: {'en': 'Children', 'ar': 'أطفال', 'fr': 'Enfants'},
        parentId: '1', // Parent is Clothing
        imageUrl:
            'https://images.unsplash.com/photo-1622290291468-a28f7a7dc6a8',
        gridSize: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '201',
        name: {
          'en': 'Men\'s Shoes',
          'ar': 'أحذية رجالية',
          'fr': 'Chaussures pour hommes',
        },
        parentId: '2', // Parent is Footwear
        imageUrl:
            'https://images.unsplash.com/photo-1614252369475-531eba835eb1',
        gridSize: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '202',
        name: {
          'en': 'Women\'s Shoes',
          'ar': 'أحذية نسائية',
          'fr': 'Chaussures pour femmes',
        },
        parentId: '2', // Parent is Footwear
        imageUrl: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2',
        gridSize: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '301',
        name: {'en': 'Watches', 'ar': 'ساعات', 'fr': 'Montres'},
        parentId: '3', // Parent is Accessories
        imageUrl:
            'https://images.unsplash.com/photo-1524805444758-089113d48a6d',
        gridSize: 1,
        createdAt: now,
        updatedAt: now,
      ),
      Category(
        id: '302',
        name: {'en': 'Jewelry', 'ar': 'مجوهرات', 'fr': 'Bijoux'},
        parentId: '3', // Parent is Accessories
        imageUrl:
            'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f',
        gridSize: 1,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  // Mock Stores
  static List<Store> getStores() {
    final now = DateTime.now();
    return [
      Store(
        id: '1',
        ownerId: 'owner1',
        name: 'Fashion Store',
        secondName: 'متجر الأزياء',
        logoUrl: 'https://picsum.photos/200',
        country: 'TN',
        state: 'Tunis',
        city: 'Tunis',
        keywords: 'fashion clothing apparel style dress shoes',
        phoneNumber: '+216 12 345 678',
        email: 'fashion@example.com',
        website: 'https://fashion.example.com',
        socialLinks: {
          'facebook': 'https://facebook.com/fashionstore',
          'instagram': 'https://instagram.com/fashionstore',
        },
        categoryId: '1',
        subcategoryIds: ['101', '102'],
        isVerified: true,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        description: 'A great fashion store with the latest trends.',
      ),
      Store(
        id: '2',
        ownerId: 'owner2',
        name: 'Tech Haven',
        secondName: 'ملاذ التكنولوجيا',
        logoUrl: 'https://picsum.photos/201',
        country: 'TN',
        state: 'Sfax',
        city: 'Sfax',
        keywords: 'electronics gadgets tech computers phones',
        phoneNumber: '+216 98 765 432',
        email: 'tech@example.com',
        website: 'https://tech.example.com',
        socialLinks: {
          'facebook': 'https://facebook.com/techhaven',
          'twitter': 'https://twitter.com/techhaven',
        },
        categoryId: '5',
        subcategoryIds: null,
        isVerified: true,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        description: 'Your one-stop shop for all tech needs.',
      ),
      Store(
        id: '3',
        ownerId: 'owner3',
        name: 'Home Essentials',
        secondName: 'مستلزمات المنزل',
        logoUrl: 'https://picsum.photos/202',
        country: 'TN',
        state: 'Sousse',
        city: 'Sousse',
        keywords: 'home furniture decor kitchen appliances',
        phoneNumber: '+216 55 555 555',
        email: 'home@example.com',
        website: 'https://home.example.com',
        socialLinks: {'instagram': 'https://instagram.com/homeessentials'},
        categoryId: '8',
        subcategoryIds: null,
        isVerified: false,
        isActive: true,
        createdAt: now,
        updatedAt: now,
        description: 'Everything you need for your home.',
      ),
    ];
  }

  // Mock Advertisements
  static List<Advertisement> getAdvertisements() {
    final now = DateTime.now();
    final oneMonthLater = DateTime(now.year, now.month + 1, now.day);

    return [
      Advertisement(
        id: '1',
        userId: 'user1',
        name: 'Summer Sale',
        imageUrl: 'https://picsum.photos/800/400',
        clickUrl: 'https://example.com/summer-sale',
        startsAt: now,
        endsAt: oneMonthLater,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Advertisement(
        id: '2',
        userId: 'user2',
        name: 'New Collection',
        imageUrl: 'https://picsum.photos/801/400',
        clickUrl: 'https://example.com/new-collection',
        startsAt: now,
        endsAt: oneMonthLater,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
      Advertisement(
        id: '3',
        userId: 'user3',
        name: 'Special Offer',
        imageUrl: 'https://picsum.photos/802/400',
        clickUrl: 'https://example.com/special-offer',
        startsAt: now,
        endsAt: oneMonthLater,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
