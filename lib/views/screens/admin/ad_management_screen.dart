import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../controllers/admin_controller.dart';
import '../../../constants/app_colors.dart';
import '../../../models/advertisement.dart';
import '../../../utils/error_dialog_utils.dart';

class AdManagementScreen extends StatefulWidget {
  const AdManagementScreen({Key? key}) : super(key: key);

  @override
  State<AdManagementScreen> createState() => _AdManagementScreenState();
}

class _AdManagementScreenState extends State<AdManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Load advertisements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(
        context,
        listen: false,
      ).loadAdvertisements(refresh: true);
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        Provider.of<AdminController>(
          context,
          listen: false,
        ).loadAdvertisements();
      }
    });

    // Setup search listener
    _searchController.addListener(() {
      if (_searchController.text != _searchQuery) {
        _searchQuery = _searchController.text;
        _debounceSearch();
      }
    });
  }

  void _debounceSearch() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == _searchQuery) {
        Provider.of<AdminController>(context, listen: false).loadAdvertisements(
          refresh: true,
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            slivers: [
              // Header without back button (admin dashboard)
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false, // Remove back button
                title: const Text(
                  'Ad Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                floating: true,
                pinned: false,
              ),

              // Main content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Search Card
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
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              hintText: 'Search advertisements by name...',
                              hintStyle: TextStyle(color: Colors.grey[600]),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[600],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF673AB7),
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Advertisements List Card
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
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withAlpha(26),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.campaign,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Advertisements List',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Ads Content
                              SizedBox(
                                height:
                                    400, // Fixed height for scrollable content
                                child: Consumer<AdminController>(
                                  builder: (context, adminController, child) {
                                    if (adminController.isLoading &&
                                        adminController
                                            .advertisements
                                            .isEmpty) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF673AB7),
                                        ),
                                      );
                                    }

                                    if (adminController.error != null &&
                                        adminController
                                            .advertisements
                                            .isEmpty) {
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
                                                  () => adminController
                                                      .loadAdvertisements(
                                                        refresh: true,
                                                      ),
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

                                    if (adminController
                                        .advertisements
                                        .isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.campaign_outlined,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No advertisements found',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return RefreshIndicator(
                                      onRefresh:
                                          () => adminController
                                              .loadAdvertisements(
                                                refresh: true,
                                              ),
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        itemCount:
                                            adminController
                                                .advertisements
                                                .length +
                                            (adminController.hasMoreAds
                                                ? 1
                                                : 0),
                                        itemBuilder: (context, index) {
                                          if (index >=
                                              adminController
                                                  .advertisements
                                                  .length) {
                                            return const Padding(
                                              padding: EdgeInsets.all(16),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Color(0xFF673AB7),
                                                    ),
                                              ),
                                            );
                                          }

                                          final ad =
                                              adminController
                                                  .advertisements[index];
                                          return _buildAdCard(
                                            ad,
                                            adminController,
                                          );
                                        },
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

  Widget _buildAdCard(Advertisement ad, AdminController adminController) {
    final isExpired = ad.endsAt.isBefore(DateTime.now());
    final isActive = ad.isActive && ad.isPaid && !isExpired;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isActive
                  ? Colors.green.withAlpha(128)
                  : Colors.red.withAlpha(128),
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
                // Ad Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFF673AB7).withAlpha(51),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: ad.imageUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                      errorWidget:
                          (context, url, error) =>
                              const Icon(Icons.image, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Ad Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ad.name,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          _buildStatusChip(ad, isActive, isExpired),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getAdTypeDisplayName(ad.adType),
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      if (ad.country != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Country: ${ad.country}',
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
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected:
                      (value) => _handleAdAction(value, ad, adminController),
                  itemBuilder:
                      (context) => [
                        if (ad.isActive)
                          const PopupMenuItem(
                            value: 'stop',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.stop,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text('Stop Ad'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Delete Ad'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(
                                Icons.open_in_new,
                                color: Colors.blue,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text('View Ad'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Ad Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Date',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              _formatDate(ad.startsAt),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Date',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              _formatDate(ad.endsAt),
                              style: TextStyle(
                                color: isExpired ? Colors.red : Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Status',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.6),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              ad.isPaid ? 'Paid' : 'Unpaid',
                              style: TextStyle(
                                color: ad.isPaid ? Colors.green : Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Created: ${_formatDate(ad.createdAt)}',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(Advertisement ad, bool isActive, bool isExpired) {
    String status;
    Color color;

    if (isExpired) {
      status = 'EXPIRED';
      color = Colors.grey;
    } else if (!ad.isPaid) {
      status = 'UNPAID';
      color = Colors.orange;
    } else if (!ad.isActive) {
      status = 'STOPPED';
      color = Colors.red;
    } else {
      status = 'ACTIVE';
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(128)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getAdTypeDisplayName(String? adType) {
    switch (adType) {
      case 'home_spotlight':
        return 'Home Spotlight';
      case 'category_match':
        return 'Category Match';
      case 'store_boost':
        return 'Store Boost';
      default:
        return 'Unknown';
    }
  }

  void _handleAdAction(
    String action,
    Advertisement ad,
    AdminController adminController,
  ) {
    switch (action) {
      case 'stop':
        _stopAd(ad, adminController);
        break;
      case 'delete':
        _showDeleteAdDialog(ad, adminController);
        break;
      case 'view':
        _viewAd(ad);
        break;
    }
  }

  void _stopAd(Advertisement ad, AdminController adminController) async {
    final success = await adminController.stopAdvertisement(adId: ad.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Advertisement stopped successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ErrorDialogUtils.showErrorDialog(
        context: context,
        title: 'Error',
        message: adminController.error ?? 'Failed to stop advertisement',
      );
    }
  }

  void _showDeleteAdDialog(Advertisement ad, AdminController adminController) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: const Text(
              'Delete Advertisement',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to permanently delete "${ad.name}"? This action cannot be undone.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();

                  final success = await adminController.deleteAdvertisement(
                    adId: ad.id,
                  );

                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Advertisement deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (mounted) {
                    ErrorDialogUtils.showErrorDialog(
                      context: context,
                      title: 'Error',
                      message:
                          adminController.error ??
                          'Failed to delete advertisement',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _viewAd(Advertisement ad) {
    // Open the ad URL in a dialog or external browser
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF2A2A2A),
            title: Text(ad.name, style: const TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ad Image
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: ad.imageUrl,
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                      errorWidget:
                          (context, url, error) => const Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 48,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Click URL: ${ad.clickUrl}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  'Type: ${_getAdTypeDisplayName(ad.adType)}',
                  style: const TextStyle(color: Colors.white70),
                ),
                if (ad.country != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Country: ${ad.country}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
