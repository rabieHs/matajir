import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matajir/controllers/advertisement_controller.dart';
import 'package:matajir/models/advertisement.dart';
import 'package:matajir/services/advertisement_service.dart';
import 'package:matajir/constants/app_colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyAdsScreen extends StatefulWidget {
  const MyAdsScreen({super.key});

  @override
  State<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends State<MyAdsScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserAds();
  }

  Future<void> _loadUserAds() async {
    final adController = Provider.of<AdvertisementController>(
      context,
      listen: false,
    );
    await adController.fetchUserAdvertisements();
  }

  String _getAdStatus(Advertisement ad) {
    final now = DateTime.now();

    if (!ad.isPaid) {
      return 'Waiting Payment';
    } else if (now.isAfter(ad.endsAt)) {
      return 'Finished';
    } else if (now.isBefore(ad.startsAt)) {
      return 'Scheduled';
    } else {
      return 'Active';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Waiting Payment':
        return Colors.orange;
      case 'Finished':
        return Colors.red;
      case 'Scheduled':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _payForAd(Advertisement ad) async {
    final advertisementService = AdvertisementService();

    final success = await advertisementService.processPaymentAndActivateAd(
      context: context,
      advertisementId: ad.id,
      packageId: ad.adType ?? 'home_spotlight',
      duration: _calculateDuration(ad.startsAt, ad.endsAt),
      durationType: 'day',
      adName: ad.name,
    );

    if (success) {
      _loadUserAds(); // Refresh the list
    }
  }

  int _calculateDuration(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  Future<void> _renewAd(Advertisement ad) async {
    // Show duration selection dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _RenewAdDialog(ad: ad),
    );

    if (result != null) {
      final advertisementService = AdvertisementService();

      // Calculate new dates
      final now = DateTime.now();
      final duration = result['duration'] as int;
      final durationType = result['durationType'] as String;
      final durationInDays = durationType == 'week' ? duration * 7 : duration;
      final newEndDate = now.add(Duration(days: durationInDays));

      // Update advertisement with new dates and payment
      final adController = Provider.of<AdvertisementController>(
        context,
        listen: false,
      );
      final success = await adController.updateAdvertisement(
        id: ad.id,
        startsAt: now,
        endsAt: newEndDate,
        isPaid: false,
        paymentStatus: 'pending',
        isActive: true,
      );

      if (success) {
        // Process payment
        await _payForAd(ad);
      }
    }
  }

  Future<void> _stopAd(Advertisement ad) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Stop Advertisement'),
            content: Text('Are you sure you want to stop this advertisement?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Stop'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final adController = Provider.of<AdvertisementController>(
        context,
        listen: false,
      );
      await adController.updateAdvertisement(id: ad.id, isActive: false);
      _loadUserAds();
    }
  }

  Future<void> _editAd(Advertisement ad) async {
    // Navigate to edit screen
    Navigator.pushNamed(
      context,
      '/edit-ad',
      arguments: ad,
    ).then((_) => _loadUserAds());
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Consumer<AdvertisementController>(
        builder: (context, adController, child) {
          if (adController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adController.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${adController.error}'),
                  ElevatedButton(onPressed: _loadUserAds, child: Text('Retry')),
                ],
              ),
            );
          }

          final userAds = adController.userAdvertisements;

          if (userAds.isEmpty) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.scaffoldBackground,
                    AppColors.scaffoldBackgroundEnd,
                  ],
                ),
              ),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(24),
                  elevation: 8,
                  shadowColor: Colors.black.withAlpha(76),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(
                            Icons.campaign_outlined,
                            size: 48,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Advertisements Yet',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Start promoting your business by creating your first advertisement',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                () =>
                                    Navigator.pushNamed(context, '/advertise'),
                            icon: const Icon(Icons.add),
                            label: const Text('Create Your First Ad'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.scaffoldBackground,
                  AppColors.scaffoldBackgroundEnd,
                ],
              ),
            ),
            child: RefreshIndicator(
              onRefresh: _loadUserAds,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: userAds.length,
                itemBuilder: (context, index) {
                  final ad = userAds[index];
                  final status = _getAdStatus(ad);
                  final statusColor = _getStatusColor(status);

                  return _buildAdCard(context, ad, status, statusColor);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildAdCard(
    BuildContext context,
    Advertisement ad,
    String status,
    Color statusColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _editAd(ad),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Ad Image
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
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
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        ad.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.campaign,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Ad details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ad Name and Status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ad.name,
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
                    // Ad Type
                    Row(
                      children: [
                        Icon(
                          _getAdTypeIcon(ad.adType),
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getAdTypeDisplayName(ad.adType),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Country
                    if (ad.country != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ad.country!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    // Dates
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${_formatDate(ad.startsAt)} - ${_formatDate(ad.endsAt)}',
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
                  if (!ad.isPaid)
                    _buildActionButton(
                      icon: Icons.payment,
                      color: Colors.green,
                      onPressed: () => _payForAd(ad),
                    )
                  else if (status == 'Finished')
                    _buildActionButton(
                      icon: Icons.refresh,
                      color: AppColors.primaryColor,
                      onPressed: () => _renewAd(ad),
                    )
                  else if (status == 'Active' || status == 'Scheduled')
                    _buildActionButton(
                      icon: Icons.stop,
                      color: Colors.red,
                      onPressed: () => _stopAd(ad),
                    )
                  else
                    _buildActionButton(
                      icon: Icons.edit,
                      color: AppColors.primaryColor,
                      onPressed: () => _editAd(ad),
                    ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    icon: Icons.more_vert,
                    color: Colors.grey,
                    onPressed: () => _showAdOptions(context, ad),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
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

  IconData _getAdTypeIcon(String? adType) {
    switch (adType) {
      case 'home_spotlight':
        return Icons.star;
      case 'category_match':
        return Icons.category;
      case 'store_boost':
        return Icons.trending_up;
      default:
        return Icons.campaign;
    }
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
        return 'Advertisement';
    }
  }

  void _showAdOptions(BuildContext context, Advertisement ad) {
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
                  ad.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildOptionTile(
                  icon: Icons.edit,
                  title: 'Edit Advertisement',
                  onTap: () {
                    Navigator.pop(context);
                    _editAd(ad);
                  },
                ),
                if (!ad.isPaid)
                  _buildOptionTile(
                    icon: Icons.payment,
                    title: 'Pay Now',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      _payForAd(ad);
                    },
                  ),
                if (_getAdStatus(ad) == 'Finished')
                  _buildOptionTile(
                    icon: Icons.refresh,
                    title: 'Renew Advertisement',
                    color: AppColors.primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      _renewAd(ad);
                    },
                  ),
                if (_getAdStatus(ad) == 'Active' ||
                    _getAdStatus(ad) == 'Scheduled')
                  _buildOptionTile(
                    icon: Icons.stop,
                    title: 'Stop Advertisement',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _stopAd(ad);
                    },
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
    );
  }

  Widget _buildOptionTile({
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
}

class _RenewAdDialog extends StatefulWidget {
  final Advertisement ad;

  const _RenewAdDialog({required this.ad});

  @override
  State<_RenewAdDialog> createState() => _RenewAdDialogState();
}

class _RenewAdDialogState extends State<_RenewAdDialog> {
  int _duration = 1;
  String _durationType = 'week';

  @override
  Widget build(BuildContext context) {
    final advertisementService = AdvertisementService();
    final totalPrice = advertisementService.calculateTotalPrice(
      packageId: widget.ad.adType ?? 'home_spotlight',
      duration: _duration,
      durationType: _durationType,
    );

    return AlertDialog(
      title: Text('Renew Advertisement'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Select renewal period for "${widget.ad.name}"'),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _duration.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _duration = int.tryParse(value) ?? 1;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _durationType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'day', child: Text('Days')),
                    DropdownMenuItem(value: 'week', child: Text('Weeks')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _durationType = value ?? 'week';
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Total Cost: \$${totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed:
              () => Navigator.pop(context, {
                'duration': _duration,
                'durationType': _durationType,
              }),
          child: Text('Renew & Pay'),
        ),
      ],
    );
  }
}
