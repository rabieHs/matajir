import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../controllers/auth_controller.dart';
import '../../providers/localization_provider.dart';
import '../../constants/app_colors.dart';
import '../../widgets/rtl_back_button.dart';
import '../widgets/custom_text_field.dart';
import '../../utils/error_dialog_utils.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  bool _isStoreOwner = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser;

    if (user != null) {
      _nameController.text = user.name ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _emailController.text = user.email;
      _isStoreOwner = user.isStoreOwner;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialogUtils.showErrorDialog(
          context: context,
          title: AppLocalizations.of(context).error,
          message: 'Failed to pick image: $e',
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authController = Provider.of<AuthController>(context, listen: false);
    final localizations = AppLocalizations.of(context);

    try {
      // TODO: Upload image to storage if selected
      String? profileImageUrl;
      if (_selectedImage != null) {
        // For now, we'll skip image upload
        // In a real app, you'd upload to Supabase Storage or another service
        profileImageUrl = null;
      }

      final success = await authController.updateProfile(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        profileImageUrl: profileImageUrl,
        isStoreOwner: _isStoreOwner,
      );

      if (success && mounted) {
        await ErrorDialogUtils.showSuccessDialog(
          context: context,
          title: localizations.success,
          message: localizations.profileUpdatedSuccessfully,
        );
      } else if (mounted) {
        await ErrorDialogUtils.showErrorDialog(
          context: context,
          title: localizations.error,
          message: authController.errorMessage ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      if (mounted) {
        await ErrorDialogUtils.showErrorDialog(
          context: context,
          title: localizations.error,
          message: 'An unexpected error occurred: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAccount() async {
    final localizations = AppLocalizations.of(context);

    final confirmed = await ErrorDialogUtils.showConfirmationDialog(
      context: context,
      title: localizations.deleteAccount,
      message: localizations.deleteAccountConfirmation,
      confirmButtonText: localizations.deleteAccount,
      confirmButtonColor: Colors.red,
    );

    if (confirmed && mounted) {
      // TODO: Implement account deletion
      await ErrorDialogUtils.showErrorDialog(
        context: context,
        title: localizations.featureNotAvailable,
        message: localizations.accountDeletionNotImplemented,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            localizations.profile,
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
                            Icons.person,
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Profile Picture Section
                          _buildProfilePictureSection(),
                          const SizedBox(height: 32),

                          // Form Fields
                          CustomTextField(
                            controller: _nameController,
                            labelText: localizations.fullName,
                            prefixIcon: Icons.person,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return localizations.pleaseEnterYourName;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          CustomTextField(
                            controller: _emailController,
                            labelText: localizations.email,
                            prefixIcon: Icons.email,
                            enabled: false, // Email cannot be changed
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return localizations.pleaseEnterYourEmail;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          CustomTextField(
                            controller: _phoneController,
                            labelText: localizations.phoneNumber,
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return localizations.pleaseEnterYourPhoneNumber;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Store Owner Toggle
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.05,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.store,
                                  color: AppColors.primaryColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localizations.storeOwner,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                      Text(
                                        localizations.storeOwnerDescription,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: _isStoreOwner,
                                  onChanged: (value) {
                                    setState(() {
                                      _isStoreOwner = value;
                                    });
                                  },
                                  activeColor: AppColors.primaryColor,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Update Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text(
                                        localizations.updateProfile,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Danger Zone
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_outlined,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      localizations.dangerZone,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  localizations.dangerZoneDescription,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _deleteAccount,
                                    icon: const Icon(Icons.delete_forever),
                                    label: Text(localizations.deleteAccount),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser;
    final localizations = AppLocalizations.of(context);

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColor, width: 3),
              ),
              child: ClipOval(
                child:
                    _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : user?.profileImageUrl != null
                        ? CachedNetworkImage(
                          imageUrl: user!.profileImageUrl!,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                              ),
                        )
                        : Container(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColors.primaryColor,
                          ),
                        ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          localizations.tapToChangePhoto,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
