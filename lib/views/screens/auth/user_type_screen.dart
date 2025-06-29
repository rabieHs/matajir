import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';

import '../../../constants/app_colors.dart';
import '../dashboard/dashboard_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserTypeScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String? phoneNumber;

  const UserTypeScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.password,
    this.phoneNumber,
  }) : super(key: key);

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  bool _isStoreOwner = false;

  Future<void> _register() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final success = await authController.signUp(
      email: widget.email,
      password: widget.password,
      name: widget.name,
      phoneNumber: widget.phoneNumber,
      isStoreOwner: _isStoreOwner,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).registerSuccess),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate based on user selection
      if (_isStoreOwner) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      } else {
        // For regular user, just go back to the main app flow
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.errorMessage ??
                AppLocalizations.of(context).errorOccurred,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
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
                        Icons.arrow_back,
                        color: AppColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                Text(
                  AppLocalizations.of(context).selectUserType,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 48),

                // Client option
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isStoreOwner = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          !_isStoreOwner
                              ? Colors.white
                              : Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            !_isStoreOwner
                                ? AppColors.primaryColor
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person,
                          size: 64,
                          color:
                              !_isStoreOwner
                                  ? AppColors.primaryColor
                                  : Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).client,
                          style: TextStyle(
                            color:
                                !_isStoreOwner
                                    ? AppColors.primaryColor
                                    : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).clientDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                !_isStoreOwner
                                    ? Colors.black54
                                    : Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Dashboard User option
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isStoreOwner = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          _isStoreOwner
                              ? Colors.white
                              : Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            _isStoreOwner
                                ? AppColors.primaryColor
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.dashboard,
                          size: 64,
                          color:
                              _isStoreOwner
                                  ? AppColors.primaryColor
                                  : Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).dashboard,
                          style: TextStyle(
                            color:
                                _isStoreOwner
                                    ? AppColors.primaryColor
                                    : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).providerDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                _isStoreOwner ? Colors.black54 : Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Register button
                ElevatedButton(
                  onPressed: authController.isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      authController.isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                          )
                          : Text(
                            AppLocalizations.of(context).register,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
}
