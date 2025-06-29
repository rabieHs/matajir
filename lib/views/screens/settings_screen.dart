import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../providers/localization_provider.dart';
import '../../constants/app_colors.dart';
import '../../widgets/rtl_back_button.dart';
import 'support_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Consumer<LocalizationProvider>(
                  builder: (context, localizationProvider, _) {
                    final isRTL =
                        localizationProvider.currentLocale.languageCode == 'ar';

                    return Row(
                      children: [
                        if (!isRTL) ...[
                          RTLBackButton(
                            backgroundColor: Colors.white,
                            iconColor: AppColors.primaryColor,
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: Text(
                            localizations.settings,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: isRTL ? TextAlign.right : TextAlign.left,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        if (isRTL) ...[
                          const SizedBox(width: 16),
                          RTLBackButton(
                            backgroundColor: Colors.white,
                            iconColor: AppColors.primaryColor,
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      // Language Section
                      _buildSettingsCard(
                        icon: Icons.language_outlined,
                        title: localizations.language,
                        subtitle: _getLanguageName(
                          localizationProvider.currentLocale.languageCode,
                          localizations,
                        ),
                        child: DropdownButton<String>(
                          value:
                              localizationProvider.currentLocale.languageCode,
                          underline: const SizedBox(),
                          items: [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(localizations.english),
                            ),
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text(localizations.arabic),
                            ),
                            DropdownMenuItem(
                              value: 'fr',
                              child: Text(localizations.french),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              localizationProvider.setLocale(Locale(value));
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Privacy Policy Section
                      _buildSettingsCard(
                        icon: Icons.privacy_tip_outlined,
                        title: localizations.privacyPolicy,
                        subtitle:
                            'Read our privacy policy and data usage terms',
                        onTap: () => _showPrivacyPolicy(context),
                      ),

                      const SizedBox(height: 16),

                      // About Us Section
                      _buildSettingsCard(
                        icon: Icons.info_outline,
                        title: localizations.aboutUs,
                        subtitle: 'Learn more about Matajir and our mission',
                        onTap: () => _showAboutUs(context),
                      ),

                      const SizedBox(height: 16),

                      // Help Section
                      _buildSettingsCard(
                        icon: Icons.help_outline,
                        title: localizations.help,
                        subtitle: 'Get help and contact our support team',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SupportScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // Version info
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.apps,
                                color: AppColors.primaryColor,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Matajir',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Version 1.0.0',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
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

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? child,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (child != null) ...[
              const SizedBox(width: 8),
              child,
            ] else if (onTap != null)
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String languageCode, AppLocalizations localizations) {
    switch (languageCode) {
      case 'ar':
        return localizations.arabic;
      case 'fr':
        return localizations.french;
      case 'en':
      default:
        return localizations.english;
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.privacyPolicy),
            content: SingleChildScrollView(
              child: Text(
                'Privacy Policy\n\nAt Matajir, we are committed to protecting your privacy and ensuring the security of your personal information.\n\nInformation We Collect:\n• Personal information you provide when creating an account\n• Store and product information for business accounts\n• Usage data to improve our services\n\nHow We Use Your Information:\n• To provide and maintain our services\n• To process transactions and manage your account\n• To communicate with you about our services\n• To improve our platform and user experience\n\nData Security:\nWe implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.\n\nContact Us:\nIf you have any questions about this Privacy Policy, please contact us at privacy@matajir.com',
                style: const TextStyle(height: 1.5),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.close),
              ),
            ],
          ),
    );
  }

  void _showAboutUs(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.aboutUs),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.store,
                    color: AppColors.primaryColor,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'About Matajir\n\nMatajir is a comprehensive marketplace platform that connects store owners with customers across multiple regions.\n\nOur Mission:\nTo empower local businesses by providing them with the tools and platform they need to reach more customers and grow their business.\n\nWhat We Offer:\n• Easy store creation and management\n• Powerful advertising tools\n• Multi-language support\n• Secure payment processing\n• Customer analytics and insights\n\nOur Vision:\nTo become the leading marketplace platform that bridges the gap between local businesses and their communities, fostering economic growth and creating opportunities for everyone.\n\nContact Information:\nEmail: info@matajir.com\nPhone: +216 12 345 678\nWebsite: www.matajir.com',
                    style: const TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.close),
              ),
            ],
          ),
    );
  }
}
