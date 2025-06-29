import 'package:flutter/material.dart';
import 'package:matajir/constants/app_colors.dart';
import 'package:matajir/views/screens/advertise/create_ad/ad_creation_base_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeSpotlightAdScreen extends StatelessWidget {
  const HomeSpotlightAdScreen({super.key});

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

    return AdCreationBaseScreen(
      title: localizations.homeSpotlightAdvertisement,
      adType: 'home_spotlight',
      customContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Home Spotlight Details Card
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
                  // Home Spotlight header
                  _buildSectionHeader(
                    localizations.homeSpotlightDetails,
                    Icons.home,
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
                                Icons.home,
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
                                    localizations.homeSpotlight,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    localizations.homeSpotlightPrice,
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
                          localizations.homeSpotlightDescription,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          localizations.recommendedImageSize(
                            '1200 x 400 pixels',
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
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
        // The shared service handles everything now
        // This callback is called after successful creation and payment
        debugPrint('Home Spotlight Ad created successfully: $data');
      },
    );
  }
}
