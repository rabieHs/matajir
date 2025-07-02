import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../screens/auth/login_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomDrawer extends StatelessWidget {
  final String? userName;
  final String? userEmail;
  final String? userImageUrl;
  final Function()? onProfileTap;
  final Function()? onHomeTap;
  final Function()? onCategoriesTap;
  final Function()? onFavoritesTap;
  final Function()? onDashboardTap;
  final Function()? onAdvertiseTap;
  final Function()? onMyAdsTap;
  final Function()? onSettingsTap;
  final Function()? onAdminTap;
  final Function()? onLogoutTap;

  const CustomDrawer({
    super.key,
    this.userName,
    this.userEmail,
    this.userImageUrl,
    this.onProfileTap,
    this.onHomeTap,
    this.onCategoriesTap,
    this.onFavoritesTap,
    this.onDashboardTap,
    this.onAdvertiseTap,
    this.onMyAdsTap,
    this.onSettingsTap,
    this.onAdminTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final isLoggedIn = authController.isLoggedIn;
    final isStoreOwner = authController.isStoreOwner;
    final isAdmin = authController.currentUser?.isAdmin ?? false;
    final localizations = AppLocalizations.of(context);

    return Drawer(
      child: Container(
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Profile section
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 16,
              ),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                children: [
                  // Profile avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        isLoggedIn &&
                                userImageUrl != null &&
                                userImageUrl!.isNotEmpty
                            ? NetworkImage(userImageUrl!)
                            : null,
                    child:
                        isLoggedIn &&
                                userImageUrl != null &&
                                userImageUrl!.isNotEmpty
                            ? null
                            : const Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.primaryColor,
                            ),
                  ),
                  const SizedBox(height: 12),
                  // User name or "Profile" text
                  Text(
                    isLoggedIn && userName != null && userName!.isNotEmpty
                        ? userName!
                        : localizations.profile,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // User email (only if logged in)
                  if (isLoggedIn && userEmail != null && userEmail!.isNotEmpty)
                    Text(
                      userEmail!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Profile/Login button
                  InkWell(
                    onTap:
                        isLoggedIn
                            ? onProfileTap
                            : () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isLoggedIn
                            ? localizations.viewProfile
                            : localizations.login,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Common menu items for all users
            _buildDrawerItem(
              icon: Icons.home_outlined,
              title: localizations.home,
              onTap: onHomeTap,
            ),

            // Conditional menu items based on login status and user type
            if (isLoggedIn) ...[
              // For logged-in users
              if (isStoreOwner)
                // For store owners
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: localizations.dashboard,
                  onTap: onDashboardTap,
                ),

              // Admin Dashboard (for admins only)
              if (isAdmin)
                _buildDrawerItem(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Admin Dashboard',
                  onTap: onAdminTap,
                ),

              // Favorites for all logged-in users (both store owners and regular users)
              _buildDrawerItem(
                icon: Icons.favorite_border_outlined,
                title: localizations.favorites,
                onTap: onFavoritesTap,
              ),
            ],

            // Advertise with us (for all users)
            _buildDrawerItem(
              icon: Icons.campaign_outlined,
              title: localizations.advertiseWithUs,
              onTap: onAdvertiseTap,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(color: Colors.white30),
            ),

            // Settings (for all users)
            _buildDrawerItem(
              icon: Icons.settings_outlined,
              title: localizations.settings,
              onTap: onSettingsTap,
            ),

            // Logout (only for logged-in users)
            if (isLoggedIn)
              _buildDrawerItem(
                icon: Icons.logout_outlined,
                title: localizations.logout,
                onTap: onLogoutTap,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: onTap,
        hoverColor: Colors.white.withAlpha(26),
        tileColor: Colors.transparent,
      ),
    );
  }
}
