import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/localization_provider.dart';
import '../../widgets/custom_drawer.dart';
import '../../../widgets/rtl_back_button.dart';
import 'my_stores_screen.dart';
import 'my_ads_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;

    // Check if user is logged in
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).dashboard),
          backgroundColor: AppColors.primaryColor,
        ),
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).loginRequired,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please login to access the dashboard',
                  style: TextStyle(
                    color: Colors.white.withAlpha(204),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/');
                  },
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
                  child: Text(AppLocalizations.of(context).login),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        userName: user.name ?? 'User',
        userEmail: user.email,
        userImageUrl: user.profileImageUrl,
        onProfileTap: () {
          // Navigate to profile screen
          Navigator.pop(context);
        },
        onHomeTap: () {
          Navigator.pop(context);
          Navigator.of(context).pushNamed('/');
        },
        onMyAdsTap: () {
          Navigator.pop(context);
          // Switch to My Ads tab
          _tabController.animateTo(1);
        },
        onLogoutTap: () async {
          final navigator = Navigator.of(context);
          Navigator.pop(context);
          await authController.signOut();
          if (mounted) {
            navigator.popUntil((route) => route.isFirst);
          }
        },
      ),
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
              // Header with back button
              Consumer<LocalizationProvider>(
                builder: (context, localizationProvider, _) {
                  final isRTL =
                      localizationProvider.locale.languageCode == 'ar';
                  return Container(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        // Back button positioned based on language direction
                        if (!isRTL)
                          RTLBackButton(
                            onPressed: () => Navigator.pop(context),
                          ),

                        // Title
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context).dashboard,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        // Back button for RTL
                        if (isRTL)
                          RTLBackButton(
                            onPressed: () => Navigator.pop(context),
                          ),
                      ],
                    ),
                  );
                },
              ),

              // Tab bar
              Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: AppColors.primaryColor,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.primaryColor,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.store, size: 18),
                          const SizedBox(width: 6),
                          Text(AppLocalizations.of(context).myStores),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.campaign, size: 18),
                          const SizedBox(width: 6),
                          Text(AppLocalizations.of(context).myAds),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [MyStoresScreen(), MyAdsScreen()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
