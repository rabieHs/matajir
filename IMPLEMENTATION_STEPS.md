# Complete Advertisement System Implementation Steps

## Step 1: Database Schema Updates

Run the SQL script to update your database schema:

```sql
-- Update advertisements table to match the current structure and add missing fields
-- Based on the current table structure shown in the image

-- Add missing fields to advertisements table
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS country TEXT;
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS ad_type TEXT NOT NULL DEFAULT 'home_spotlight';
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS category_id UUID REFERENCES categories(id);
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS subcategory_id UUID REFERENCES categories(id);
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS store_id UUID REFERENCES stores(id);
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS payment_id UUID REFERENCES payments(id);
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS is_paid BOOLEAN DEFAULT FALSE;
ALTER TABLE advertisements ADD COLUMN IF NOT EXISTS payment_status TEXT;

-- Update stores table to add promotion fields if they don't exist
ALTER TABLE stores ADD COLUMN IF NOT EXISTS is_promoted BOOLEAN DEFAULT FALSE;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS promotion_starts_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS promotion_ends_at TIMESTAMP WITH TIME ZONE;
ALTER TABLE stores ADD COLUMN IF NOT EXISTS subcategory_ids TEXT; -- JSON array as text for subcategory IDs

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_advertisements_country ON advertisements(country);
CREATE INDEX IF NOT EXISTS idx_advertisements_ad_type ON advertisements(ad_type);
CREATE INDEX IF NOT EXISTS idx_advertisements_category_id ON advertisements(category_id);
CREATE INDEX IF NOT EXISTS idx_advertisements_subcategory_id ON advertisements(subcategory_id);
CREATE INDEX IF NOT EXISTS idx_advertisements_store_id ON advertisements(store_id);
CREATE INDEX IF NOT EXISTS idx_advertisements_is_paid ON advertisements(is_paid);
CREATE INDEX IF NOT EXISTS idx_advertisements_payment_status ON advertisements(payment_status);
CREATE INDEX IF NOT EXISTS idx_advertisements_dates ON advertisements(starts_at, ends_at);

CREATE INDEX IF NOT EXISTS idx_stores_is_promoted ON stores(is_promoted);
CREATE INDEX IF NOT EXISTS idx_stores_promotion_dates ON stores(promotion_starts_at, promotion_ends_at);
CREATE INDEX IF NOT EXISTS idx_stores_country ON stores(country);
CREATE INDEX IF NOT EXISTS idx_stores_category_id ON stores(category_id);
```

## Step 2: Update Store Model

Update the Store model to include promotion fields:

```dart
// In lib/models/store.dart - Add these fields to the Store class:
final bool isPromoted;
final DateTime? promotionStartsAt;
final DateTime? promotionEndsAt;

// Update the fromJson method to include:
isPromoted: json['is_promoted'] ?? false,
promotionStartsAt: json['promotion_starts_at'] != null 
    ? DateTime.parse(json['promotion_starts_at']) 
    : null,
promotionEndsAt: json['promotion_ends_at'] != null 
    ? DateTime.parse(json['promotion_ends_at']) 
    : null,

// Update the toJson method to include:
'is_promoted': isPromoted,
'promotion_starts_at': promotionStartsAt?.toIso8601String(),
'promotion_ends_at': promotionEndsAt?.toIso8601String(),
```

## Step 3: Add Navigation Route for My Ads Screen

Add the route to your main app routing:

```dart
// In your main app routes
'/my-ads': (context) => const MyAdsScreen(),
```

## Step 4: Add My Ads Button to Dashboard

Add a button in your user dashboard to navigate to My Ads:

```dart
ElevatedButton.icon(
  onPressed: () => Navigator.pushNamed(context, '/my-ads'),
  icon: const Icon(Icons.campaign),
  label: const Text('My Advertisements'),
),
```

## Step 5: Create Home Screen Promoted Stores Widget

Create a widget to display promoted stores on the home screen:

```dart
// lib/widgets/promoted_stores_widget.dart
class PromotedStoresWidget extends StatefulWidget {
  final String? categoryId;
  final String? country;
  
  const PromotedStoresWidget({
    super.key,
    this.categoryId,
    this.country,
  });

  @override
  State<PromotedStoresWidget> createState() => _PromotedStoresWidgetState();
}

class _PromotedStoresWidgetState extends State<PromotedStoresWidget> {
  List<Store> promotedStores = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPromotedStores();
  }

  Future<void> _loadPromotedStores() async {
    final storeController = Provider.of<StoreController>(context, listen: false);
    final stores = await storeController.fetchPromotedStores(
      categoryId: widget.categoryId,
      country: widget.country,
      limit: 3,
    );
    
    setState(() {
      promotedStores = stores;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (promotedStores.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                'Promoted Stores',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: promotedStores.length,
            itemBuilder: (context, index) {
              final store = promotedStores[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store logo with promoted badge
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              store.logoUrl ?? '',
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.store),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'PROMOTED',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              store.description ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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
}
```

## Step 6: Update Home Screen to Show Promoted Stores

Add the promoted stores widget to your home screen:

```dart
// In your home screen widget
PromotedStoresWidget(
  categoryId: selectedCategoryId,
  country: userCountry,
),
```

## Step 7: Update Category/Subcategory Screens

Update your category and subcategory screens to show both promoted stores and category-specific ads:

```dart
// In category screen
class CategoryStoresScreen extends StatefulWidget {
  final String categoryId;
  final String? subcategoryId;
  
  // ... existing code
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Promoted stores section
          PromotedStoresWidget(
            categoryId: widget.categoryId,
            country: userCountry,
          ),
          
          // Category-specific advertisements
          FutureBuilder<List<Advertisement>>(
            future: _loadCategoryAds(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return _buildAdsSection(snapshot.data!);
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Regular stores
          Expanded(
            child: _buildStoresList(),
          ),
        ],
      ),
    );
  }
  
  Future<List<Advertisement>> _loadCategoryAds() async {
    final adController = Provider.of<AdvertisementController>(context, listen: false);
    return await adController.fetchAdvertisementsByCategory(
      categoryId: widget.categoryId,
      subcategoryId: widget.subcategoryId,
      country: userCountry,
    );
  }
}
```

## Step 8: Testing Flow

### Test the Complete Flow:

1. **Create Store**:
   - Register as store owner
   - Create a store with logo
   - Verify store appears in database

2. **Create Advertisements**:
   - Create Home Spotlight ad → should appear on home screen
   - Create Category Match ad → should appear in specific category
   - Create Top Store Boost ad → store should be promoted

3. **Payment Flow**:
   - All ads start with `isPaid: false`
   - After payment simulation, `isPaid: true` and `startsAt` set to payment date
   - Top Store Boost ads update store promotion status

4. **My Ads Dashboard**:
   - View all user's ads with status
   - Pay for unpaid ads
   - Renew expired ads
   - Stop active ads
   - Edit ad content

5. **Display Logic**:
   - Home screen shows promoted stores and home_spotlight ads
   - Category screens show promoted stores + category_match ads for that category
   - Only paid and active ads are displayed
   - Country filtering works correctly

### Expected Results:

- **Home Screen**: Shows promoted stores (top 3) + home_spotlight ads
- **Category Screen**: Shows promoted stores for that category + category_match ads
- **Store Promotion**: Top store boost ads make stores appear with "PROMOTED" badge
- **My Ads**: Complete management interface for user's advertisements
- **Payment Flow**: Proper status updates and date management

## Step 9: Production Checklist

Before going live:

1. **Enable Real Stripe Payments**:
   - Change `if (true)` to `if (false)` in AdvertisementService
   - Configure Stripe keys
   - Test payment flow

2. **Database Optimization**:
   - Run the schema update SQL
   - Verify all indexes are created
   - Test query performance

3. **Error Handling**:
   - Add proper error logging
   - Handle edge cases
   - Add retry mechanisms

4. **UI Polish**:
   - Add loading states
   - Improve error messages
   - Add confirmation dialogs

This implementation provides a complete advertisement system with proper database schema, shared services, user dashboard, store promotion, and category-based filtering as requested.
