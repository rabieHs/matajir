import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matajir/constants/app_colors.dart';
import 'package:matajir/controllers/store_controller.dart';
import 'package:matajir/models/store.dart';
import 'package:matajir/services/supabase_service.dart';
import 'package:matajir/services/advertisement_service.dart';

import 'package:matajir/views/screens/dashboard/add_store_screen.dart';
import 'package:matajir/views/screens/advertise/create_ad/ad_creation_base_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TopStoreBoostAdScreen extends StatefulWidget {
  const TopStoreBoostAdScreen({super.key});

  @override
  State<TopStoreBoostAdScreen> createState() => _TopStoreBoostAdScreenState();
}

class _TopStoreBoostAdScreenState extends State<TopStoreBoostAdScreen> {
  Store? _selectedStore;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserStores();
  }

  Future<void> _loadUserStores() async {
    setState(() {
      _isLoading = true;
    });

    final storeController = Provider.of<StoreController>(
      context,
      listen: false,
    );
    // Get the current user from Supabase
    final currentUser = await SupabaseService.instance.getCurrentUser();
    if (currentUser != null) {
      await storeController.loadOwnerStores(currentUser.id);
    } else {
      debugPrint('No user found, cannot load owner stores');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showExistingAdDialog() {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            localizations.existingAdvertisement,
            style: TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            localizations.existingAdMessage(_selectedStore?.name ?? ''),
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                localizations.cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to My Ads section
                Navigator.of(context).pushReplacementNamed('/dashboard');
                // Note: The dashboard will need to switch to My Ads tab
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(localizations.goToMyAds),
            ),
          ],
        );
      },
    );
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
    final storeController = Provider.of<StoreController>(context);
    final userStores = storeController.ownerStores;
    final localizations = AppLocalizations.of(context);

    return AdCreationBaseScreen(
      title: localizations.topStoreBoostAdvertisement,
      adType: 'store_boost',
      storeId: _selectedStore?.id,
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Selection Card
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
                  // Store Selection header
                  _buildSectionHeader(
                    localizations.storeSelection,
                    Icons.store,
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
                                Icons.trending_up,
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
                                    localizations.topStoreBoost,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    localizations.topStoreBoostPrice,
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
                          localizations.topStoreBoostDescription,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Store selection
                  Text(
                    localizations.selectStoreToPromote,
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
                      : userStores.isEmpty
                      ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.store_outlined,
                              color: Colors.grey[500],
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localizations.noStoresFound,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              localizations.createStoreFirst,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const AddStoreScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(localizations.addStore),
                            ),
                          ],
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
                          child: DropdownButton<Store>(
                            value: _selectedStore,
                            dropdownColor: Colors.white,
                            style: const TextStyle(color: Colors.black87),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF673AB7),
                            ),
                            isExpanded: true,
                            hint: Text(
                              localizations.selectStore,
                              style: const TextStyle(color: Colors.black54),
                            ),
                            items:
                                userStores.map((store) {
                                  return DropdownMenuItem<Store>(
                                    value: store,
                                    child: Text(store.name),
                                  );
                                }).toList(),
                            onChanged: (store) {
                              setState(() {
                                _selectedStore = store;
                              });
                            },
                          ),
                        ),
                      ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.storePromotionInfo,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_selectedStore != null &&
                      _selectedStore!.logoUrl != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _selectedStore!.logoUrl!,
                          height: 120,
                          width: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: 120,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey[400],
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      onSubmit: (data) async {
        if (_selectedStore == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.pleaseSelectStore),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Store context and localizations before async operations
        final currentContext = context;
        final currentLocalizations = localizations;

        // Check if user already has an active store boost ad for this store
        final currentUser = await SupabaseService.instance.getCurrentUser();
        if (currentUser == null) {
          if (mounted) {
            ScaffoldMessenger.of(currentContext).showSnackBar(
              SnackBar(
                content: Text(localizations.userNotAuthenticated),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final hasExistingAd = await SupabaseService.instance
            .hasActiveStoreBoostAd(
              userId: currentUser.id,
              storeId: _selectedStore!.id,
            );

        if (hasExistingAd) {
          // Show dialog informing user about existing ad
          if (mounted) {
            _showExistingAdDialog();
          }
          return;
        }

        // Create store boost advertisement using the shared service
        final advertisementService = AdvertisementService();

        final success = await advertisementService
            .createStoreBoostAdvertisement(
              context: currentContext,
              storeName: _selectedStore!.name,
              storeLogoUrl: _selectedStore!.logoUrl ?? '',
              storeWebsite: _selectedStore!.website ?? '',
              durationValue: data['durationValue'],
              durationType: data['durationType'],
              storeId: _selectedStore!.id,
              country: data['country'],
            );

        if (success) {
          debugPrint(
            'Store Boost Ad created successfully for store: ${_selectedStore!.name}',
          );

          if (mounted) {
            // Show success message
            ScaffoldMessenger.of(currentContext).showSnackBar(
              SnackBar(
                content: Text(currentLocalizations.advertisementCreatedSuccess),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );

            // Navigate back after a short delay to show the success message
            Future.delayed(const Duration(milliseconds: 800), () {
              if (mounted) {
                Navigator.pop(currentContext);
              }
            });
          }
        } else {
          // Show error message if creation failed
          if (mounted) {
            ScaffoldMessenger.of(currentContext).showSnackBar(
              SnackBar(
                content: Text(currentLocalizations.failedToCreateAdvertisement),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      },
    );
  }
}
