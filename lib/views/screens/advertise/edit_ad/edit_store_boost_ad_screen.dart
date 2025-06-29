import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matajir/constants/app_colors.dart';
import 'package:matajir/controllers/store_controller.dart';
import 'package:matajir/models/advertisement.dart';
import 'package:matajir/models/store.dart';
import 'package:matajir/services/supabase_service.dart';
import 'package:matajir/views/screens/advertise/edit_ad/ad_edit_base_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditStoreBoostAdScreen extends StatefulWidget {
  final Advertisement advertisement;

  const EditStoreBoostAdScreen({super.key, required this.advertisement});

  @override
  State<EditStoreBoostAdScreen> createState() => _EditStoreBoostAdScreenState();
}

class _EditStoreBoostAdScreenState extends State<EditStoreBoostAdScreen> {
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

      // Set the selected store based on the advertisement's store ID
      if (widget.advertisement.storeId != null) {
        try {
          _selectedStore = storeController.ownerStores.firstWhere(
            (store) => store.id == widget.advertisement.storeId,
          );
        } catch (e) {
          _selectedStore =
              storeController.ownerStores.isNotEmpty
                  ? storeController.ownerStores.first
                  : null;
        }
      }
    } else {
      debugPrint('No user found, cannot load owner stores');
    }

    setState(() {
      _isLoading = false;
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
      title: 'Edit ${localizations.topStoreBoostAdvertisement}',
      advertisement: widget.advertisement,
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
                    localizations.storeSelection ?? 'Store Selection',
                    Icons.store,
                  ),
                  const SizedBox(height: 20),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Consumer<StoreController>(
                      builder: (context, storeController, child) {
                        final stores = storeController.ownerStores;

                        if (stores.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.store_outlined,
                                  size: 48,
                                  color: Colors.orange[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  localizations.noStoresFound ??
                                      'No stores found',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'You need to add a store first to create a store boost advertisement.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/add-store');
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Store'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Store Selection Dropdown
                            DropdownButtonFormField<Store>(
                              value: _selectedStore,
                              decoration: InputDecoration(
                                labelText: 'Select Store',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.store),
                              ),
                              items:
                                  stores.map((store) {
                                    return DropdownMenuItem<Store>(
                                      value: store,
                                      child: Row(
                                        children: [
                                          // Store logo
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.grey[200],
                                            ),
                                            child:
                                                store.logoUrl != null &&
                                                        store
                                                            .logoUrl!
                                                            .isNotEmpty
                                                    ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Image.network(
                                                        store.logoUrl!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return const Icon(
                                                            Icons.store,
                                                            color: Colors.grey,
                                                          );
                                                        },
                                                      ),
                                                    )
                                                    : const Icon(
                                                      Icons.store,
                                                      color: Colors.grey,
                                                    ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  store.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (store.description != null)
                                                  Text(
                                                    store.description!,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (Store? value) {
                                setState(() {
                                  _selectedStore = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a store';
                                }
                                return null;
                              },
                            ),

                            if (_selectedStore != null) ...[
                              const SizedBox(height: 20),

                              // Selected Store Preview
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Row(
                                  children: [
                                    // Store logo
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                      child:
                                          _selectedStore!.logoUrl != null &&
                                                  _selectedStore!
                                                      .logoUrl!
                                                      .isNotEmpty
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.network(
                                                  _selectedStore!.logoUrl!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Icon(
                                                      Icons.store,
                                                      color: Colors.grey,
                                                      size: 30,
                                                    );
                                                  },
                                                ),
                                              )
                                              : const Icon(
                                                Icons.store,
                                                color: Colors.grey,
                                                size: 30,
                                              ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedStore!.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (_selectedStore!.description !=
                                              null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              _selectedStore!.description!,
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                          if (_selectedStore!.website !=
                                              null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              _selectedStore!.website!,
                                              style: TextStyle(
                                                color: Colors.blue[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),

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
                                Icons.store,
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
                                    'Top Store Boost',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$25/week',
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
                          'Your store will be promoted and appear at the top of category listings.',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
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
        if (_selectedStore == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a store'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // The edit functionality is handled by the base screen
        debugPrint('Store Boost Ad updated successfully: $data');
      },
    );
  }
}
