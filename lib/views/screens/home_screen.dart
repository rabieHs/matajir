import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/store_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../providers/localization_provider.dart';
import '../../constants/app_colors.dart';
// Removed unused import
import '../widgets/custom_drawer.dart';
import '../widgets/ad_carousel.dart';
import '../widgets/category_grid.dart';
import '../widgets/sliver_search_app_bar.dart';
import 'category_detail_screen.dart';
import 'auth/login_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'advertise/advertise_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Location detection is now handled automatically by LocalizationProvider

    // Load favorites when user is logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      final storeController = Provider.of<StoreController>(
        context,
        listen: false,
      );

      if (authController.isLoggedIn) {
        // Check if user is admin and redirect to admin dashboard
        if (authController.isAdmin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/admin');
          });
          return;
        }

        storeController.loadFavoriteStores(authController.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<HomeController, LocalizationProvider, AuthController>(
      builder: (
        context,
        homeController,
        localizationProvider,
        authController,
        child,
      ) {
        final user = authController.currentUser;

        return Scaffold(
          key: _scaffoldKey,
          drawer: CustomDrawer(
            userName: user?.name,
            userEmail: user?.email,
            userImageUrl: user?.profileImageUrl,
            onProfileTap: () {
              Navigator.pop(context);
              if (authController.isLoggedIn) {
                // Navigate to profile screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            onHomeTap: () {
              Navigator.pop(context);
            },
            onFavoritesTap: () {
              Navigator.pop(context);
              // Navigate to favorites screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
            onDashboardTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            },
            onMyAdsTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/my-ads');
            },
            onAdvertiseTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvertiseScreen(),
                ),
              );
            },
            onSettingsTap: () {
              Navigator.pop(context);
              // Navigate to settings screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            onAdminTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin');
            },
            onLogoutTap:
                authController.isLoggedIn
                    ? () {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final logoutMessage =
                          AppLocalizations.of(context).logoutSuccess;

                      Navigator.pop(context);

                      // Use a separate method to handle the async operation
                      _handleLogout(scaffoldMessenger, logoutMessage);
                    }
                    : null,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF673AB7), Color(0xFF311B92)],
              ),
            ),
            child:
                homeController.isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : RefreshIndicator(
                      onRefresh: () async {
                        homeController.refreshData();
                        // Also refresh user profile to get latest admin status
                        await authController.refreshUserProfile();
                      },
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverSearchAppBar(
                            hintText: AppLocalizations.of(context).search,
                            showDrawerIcon: true,
                            onDrawerPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                            onSearchChanged: (query) {
                              homeController.setSearchQuery(query);
                            },
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                AdCarousel(
                                  advertisements: homeController.advertisements,
                                  height: 200,
                                ),
                                const SizedBox(height: 24),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context).categories,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: CategoryGrid(
                                    categories: homeController.categories,
                                    onCategoryTap: (category) {
                                      // Navigate to category detail screen
                                      final categoryController =
                                          Provider.of<CategoryController>(
                                            context,
                                            listen: false,
                                          );
                                      categoryController.selectCategory(
                                        category,
                                      );

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const CategoryDetailScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
          floatingActionButton: _buildChatbotFAB(context),
        );
      },
    );
  }

  Widget _buildChatbotFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, Color(0xFF311B92)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const FaIcon(
          FontAwesomeIcons.robot,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  // Dialog methods moved to DialogUtils class

  Future<void> _handleLogout(
    ScaffoldMessengerState scaffoldMessenger,
    String logoutMessage,
  ) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    await authController.signOut();
    if (mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(logoutMessage), backgroundColor: Colors.green),
      );
    }
  }
}
