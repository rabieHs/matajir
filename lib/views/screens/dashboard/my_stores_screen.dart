import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/store_controller.dart';
import '../../../models/store.dart';
import '../../../constants/app_colors.dart';
import 'add_store_screen.dart';
import 'store_detail_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyStoresScreen extends StatefulWidget {
  const MyStoresScreen({Key? key}) : super(key: key);

  @override
  State<MyStoresScreen> createState() => _MyStoresScreenState();
}

class _MyStoresScreenState extends State<MyStoresScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStores();
    });
  }

  Future<void> _loadStores() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final storeController = Provider.of<StoreController>(
      context,
      listen: false,
    );

    if (authController.isLoggedIn && authController.currentUser != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await storeController.loadOwnerStores(authController.currentUser!.id);
      } catch (e) {
        // Handle error
        debugPrint('Error loading stores: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeController = Provider.of<StoreController>(context);
    final localizations = AppLocalizations.of(context);
    final stores = storeController.ownerStores;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (stores.isEmpty) {
      return _buildEmptyStoresView(context, localizations);
    }

    return RefreshIndicator(
      onRefresh: _loadStores,
      color: AppColors.accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(
              localizations.myStores,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stores.length + 1, // +1 for the add store button
              itemBuilder: (context, index) {
                if (index == stores.length) {
                  // Add store button at the end
                  return _buildAddStoreButton(context, localizations);
                }

                final store = stores[index];
                return _buildStoreCard(context, store, localizations);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStoresView(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store_outlined, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              localizations.noStoresYet,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.createYourFirstStore,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddStoreScreen(),
                  ),
                ).then((_) {
                  // Refresh stores when returning from add screen
                  if (mounted) {
                    _loadStores();
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: Text(localizations.addStore),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCard(
    BuildContext context,
    Store store,
    AppLocalizations localizations,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoreDetailScreen(store: store),
            ),
          ).then((_) {
            // Refresh stores when returning from detail screen
            if (mounted) {
              _loadStores();
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Store logo
              Column(
                spacing: 5,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (store.isVerified ? Colors.green : Colors.orange)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: store.isVerified ? Colors.green : Colors.orange,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      store.isVerified
                          ? localizations.verified
                          : localizations.pending,
                      style: TextStyle(
                        color: store.isVerified ? Colors.green : Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      image:
                          store.logoUrl != null
                              ? DecorationImage(
                                image: NetworkImage(store.logoUrl!),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        store.logoUrl == null
                            ? const Icon(
                              Icons.store,
                              size: 40,
                              color: Colors.grey,
                            )
                            : null,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Store details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Name and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Store Type/Category (if available)
                    if (store.description != null &&
                        store.description!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.business,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              store.description!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    // Location
                    if (store.city != null || store.country != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              [store.city, store.country]
                                  .where((e) => e != null && e.isNotEmpty)
                                  .join(', '),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    // Contact Info
                    if (store.phoneNumber != null &&
                        store.phoneNumber!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              store.phoneNumber!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Action buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStoreActionButton(
                    icon: Icons.edit,
                    color: AppColors.primaryColor,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddStoreScreen(store: store),
                        ),
                      ).then((_) {
                        // Refresh stores when returning from edit screen
                        if (mounted) {
                          _loadStores();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildStoreActionButton(
                    icon: Icons.more_vert,
                    color: Colors.grey,
                    onPressed:
                        () => _showStoreOptions(context, store, localizations),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddStoreButton(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddStoreScreen()),
          ).then((_) {
            // Refresh stores when returning from add screen
            if (mounted) {
              _loadStores();
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.add_circle_outline,
                  size: 40,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.addNewStore,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      localizations.createStoreDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primaryColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        color: color,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showStoreOptions(
    BuildContext context,
    Store store,
    AppLocalizations localizations,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  store.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildStoreOptionTile(
                  icon: Icons.edit,
                  title: localizations.editStore,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddStoreScreen(store: store),
                      ),
                    ).then((_) {
                      if (mounted) {
                        _loadStores();
                      }
                    });
                  },
                ),
                _buildStoreOptionTile(
                  icon: Icons.visibility,
                  title: localizations.viewDetails,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoreDetailScreen(store: store),
                      ),
                    ).then((_) {
                      if (mounted) {
                        _loadStores();
                      }
                    });
                  },
                ),
                _buildStoreOptionTile(
                  icon: Icons.delete,
                  title: localizations.deleteStore,
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, store);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
    );
  }

  Widget _buildStoreOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Store store) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).deleteStore),
            content: Text(
              AppLocalizations.of(context).deleteStoreConfirmation(store.name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).cancel),
              ),
              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  final localizations = AppLocalizations.of(context);
                  navigator.pop();

                  final storeController = Provider.of<StoreController>(
                    context,
                    listen: false,
                  );
                  final success = await storeController.deleteStore(store.id);

                  if (success && mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(localizations.storeDeleted(store.name)),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Refresh the stores list
                    _loadStores();
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(AppLocalizations.of(context).delete),
              ),
            ],
          ),
    );
  }
}
