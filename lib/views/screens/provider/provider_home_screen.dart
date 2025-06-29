import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../constants/app_colors.dart';
import '../../widgets/custom_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProvideHomeScreen extends StatefulWidget {
  const ProvideHomeScreen({Key? key}) : super(key: key);

  @override
  State<ProvideHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProvideHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        userName: user?.name ?? 'Provider',
        userEmail: user?.email ?? '',
        userImageUrl: user?.profileImageUrl,
        onProfileTap: () {
          // Navigate to profile screen
          Navigator.pop(context);
        },
        onHomeTap: () {
          setState(() {
            _selectedIndex = 0;
          });
          Navigator.pop(context);
        },
        onCategoriesTap: () {
          setState(() {
            _selectedIndex = 1;
          });
          Navigator.pop(context);
        },
        onFavoritesTap: () {
          setState(() {
            _selectedIndex = 2;
          });
          Navigator.pop(context);
        },
        onMyAdsTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/my-ads');
        },
        onSettingsTap: () {
          setState(() {
            _selectedIndex = 3;
          });
          Navigator.pop(context);
        },
        onLogoutTap: () async {
          Navigator.pop(context);
          await authController.signOut();
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF673AB7), Color(0xFF311B92)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _getScreenTitle(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          user?.profileImageUrl != null
                              ? NetworkImage(user!.profileImageUrl!)
                              : null,
                      child:
                          user?.profileImageUrl == null
                              ? const Icon(
                                Icons.person,
                                color: AppColors.primaryColor,
                              )
                              : null,
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(child: _getSelectedScreen()),

              // Bottom navigation
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppColors.primaryColor,
                  unselectedItemColor: Colors.grey,
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.dashboard_outlined),
                      activeIcon: const Icon(Icons.dashboard),
                      label: AppLocalizations.of(context)!.dashboard,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.store_outlined),
                      activeIcon: const Icon(Icons.store),
                      label: AppLocalizations.of(context)!.stores,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.shopping_bag_outlined),
                      activeIcon: const Icon(Icons.shopping_bag),
                      label: AppLocalizations.of(context)!.orders,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.analytics_outlined),
                      activeIcon: const Icon(Icons.analytics),
                      label: AppLocalizations.of(context)!.analytics,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getScreenTitle() {
    switch (_selectedIndex) {
      case 0:
        return AppLocalizations.of(context)!.dashboard;
      case 1:
        return AppLocalizations.of(context)!.myStores;
      case 2:
        return AppLocalizations.of(context)!.orders;
      case 3:
        return AppLocalizations.of(context)!.analytics;
      default:
        return AppLocalizations.of(context)!.dashboard;
    }
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardScreen();
      case 1:
        return _buildStoresScreen();
      case 2:
        return _buildOrdersScreen();
      case 3:
        return _buildAnalyticsScreen();
      default:
        return _buildDashboardScreen();
    }
  }

  Widget _buildDashboardScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.dashboard, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.dashboard,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome to your provider dashboard',
            style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStoresScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.store, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.myStores,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your stores here',
            style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to add store screen
            },
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addStore),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.orders,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your orders here',
            style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.analytics, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.analytics,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'View your analytics here',
            style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
