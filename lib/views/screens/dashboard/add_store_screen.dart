import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/store_controller.dart';
import '../../../models/store.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/validators.dart';
import '../../../utils/country_state_data.dart';
import '../../../utils/error_dialog_utils.dart';
import '../../../services/supabase_service.dart';
import '../../widgets/custom_text_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddStoreScreen extends StatefulWidget {
  final Store? store; // If provided, we're editing an existing store

  const AddStoreScreen({Key? key, this.store}) : super(key: key);

  @override
  State<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _keywordsController = TextEditingController();
  final _cityController = TextEditingController();

  String? _logoUrl; // URL of the uploaded logo
  XFile? _logoFile; // Temporary file for logo before upload
  List<StoreBanner> _banners = []; // Existing banners
  final List<Map<String, dynamic>> _newBanners =
      []; // New banners to upload: {file: XFile, previewUrl: String}
  // Social media controllers for fixed platforms
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _twitterController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _snapchatController = TextEditingController();
  bool _isLoading = false;
  bool _useCurrentLocation = false;

  // Country and state selection
  String _selectedCountry = '';
  String _selectedState = '';
  String _selectedCity = '';
  String _countryValue = '';
  String _stateValue = '';
  String _cityValue = '';
  String _currentLocale = 'en'; // Default locale

  // Category selection
  String? _selectedCategoryId;
  List<String> _selectedSubcategoryIds = [];
  String _selectedCategoryName = '';
  List<String> _selectedSubcategoryNames = [];

  @override
  void initState() {
    super.initState();

    // Get current user data and locale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillUserData();

      // Get current locale
      final locale = Localizations.localeOf(context).toString();
      setState(() {
        _currentLocale = locale;
      });
    });

    if (widget.store != null) {
      // Populate fields with existing store data
      _nameController.text = widget.store!.name;
      _secondNameController.text = widget.store!.secondName ?? '';
      _descriptionController.text = widget.store!.description ?? '';
      _phoneController.text = widget.store!.phoneNumber ?? '';
      _emailController.text = widget.store!.email ?? '';
      _websiteController.text = widget.store!.website ?? '';
      _keywordsController.text = widget.store!.keywords ?? '';
      _cityController.text = widget.store!.city ?? '';
      _selectedCountry = widget.store!.country ?? '';
      _countryValue = widget.store!.country ?? '';
      _selectedState = widget.store!.state ?? '';
      _stateValue = widget.store!.state ?? '';
      _selectedCity = widget.store!.city ?? '';
      _cityValue = widget.store!.city ?? '';
      _logoUrl = widget.store!.logoUrl;

      if (widget.store!.banners != null) {
        _banners = List.from(widget.store!.banners!);
      }

      // Populate social media controllers from existing store data
      if (widget.store!.socialLinks != null) {
        final socialLinks = widget.store!.socialLinks!;
        _instagramController.text = socialLinks['instagram']?.toString() ?? '';
        _facebookController.text = socialLinks['facebook']?.toString() ?? '';
        _tiktokController.text = socialLinks['tiktok']?.toString() ?? '';
        _twitterController.text = socialLinks['twitter']?.toString() ?? '';
        _youtubeController.text = socialLinks['youtube']?.toString() ?? '';
        _snapchatController.text = socialLinks['snapchat']?.toString() ?? '';
      }
    }
  }

  // Pre-fill user data from current user and load categories
  void _prefillUserData() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final storeController = Provider.of<StoreController>(
      context,
      listen: false,
    );

    // Load categories
    storeController.loadCategories();

    // If editing and category ID is available, load subcategories
    if (widget.store != null && widget.store!.categoryId != null) {
      storeController.loadSubcategories(widget.store!.categoryId!);
      _selectedCategoryId = widget.store!.categoryId;
      _selectedSubcategoryIds = widget.store!.subcategoryIds ?? [];
    }

    // Set default country from the app's current country for new stores
    if (widget.store == null) {
      _selectedCountry = storeController.countryCode;
      _countryValue = storeController.countryCode;
    }

    if (authController.isLoggedIn && authController.currentUser != null) {
      // Only pre-fill if fields are empty (not editing an existing store)
      if (widget.store == null) {
        if (_emailController.text.isEmpty &&
            authController.currentUser!.email != null) {
          setState(() {
            _emailController.text = authController.currentUser!.email!;
          });
        }

        // Note: phone field is not available in the current User model
        // We'll just pre-fill email for now
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _secondNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _keywordsController.dispose();
    _cityController.dispose();
    // Dispose social media controllers
    _instagramController.dispose();
    _facebookController.dispose();
    _tiktokController.dispose();
    _twitterController.dispose();
    _youtubeController.dispose();
    _snapchatController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, show a message
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).locationPermissionDenied,
              ),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
            _useCurrentLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).locationPermissionPermanentlyDenied,
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: AppLocalizations.of(context).openSettings,
              onPressed: () {
                Geolocator.openAppSettings();
              },
            ),
          ),
        );
        setState(() {
          _isLoading = false;
          _useCurrentLocation = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;

        // Get country name from country code
        String countryName = '';
        String countryCode = place.isoCountryCode ?? '';

        // Get country name from country code using our utility class
        if (countryCode.isNotEmpty) {
          countryName = CountryStateData.getCountryName(countryCode);
          if (countryName.isEmpty) {
            // Fallback to country code if not found in our data
            countryName = countryCode;
          }
        }

        // We don't update keywords from location

        // Update the country, state, and city in the SelectState widget
        setState(() {
          _countryValue = countryName;
          _stateValue = place.administrativeArea ?? '';
          _cityValue = place.locality ?? '';
          _cityController.text = place.locality ?? '';

          // Force refresh of the SelectState widget
          _refreshLocationFields(
            countryName,
            place.administrativeArea ?? '',
            place.locality ?? '',
          );
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).locationError),
            backgroundColor: Colors.red,
          ),
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

  // Helper method to refresh the location fields
  void _refreshLocationFields(String country, String state, String city) {
    // This is a workaround to update the SelectState widget
    // We need to find a better way to programmatically set the values

    // Delay to ensure the widget is properly initialized
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        // Force rebuild of the widget
        setState(() {
          _countryValue = country;
          _selectedCountry = country;
          _stateValue = state;
          _selectedState = state;
          _cityValue = city;
          _selectedCity = city;
          _cityController.text = city;
        });
      }
    });
  }

  Future<void> _pickLogo() async {
    try {
      // Pick image from gallery
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      // Store the image file for later upload
      setState(() {
        _logoFile = image;
        // Create a temporary URL for preview
        _logoUrl = null; // Clear any existing URL
      });

      if (mounted) {
        setState(() {
          // Just store the file for preview, we'll use FileImage in the UI
          // No need to upload until save
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Upload logo to storage when saving the store
  Future<String?> _uploadLogo() async {
    if (_logoFile == null) {
      return _logoUrl; // Return existing URL if no new file
    }

    try {
      // Upload image to Supabase storage
      final String? imageUrl = await SupabaseService.instance.uploadStoreImage(
        _logoFile!.path,
        _logoFile!.name,
      );

      return imageUrl;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading logo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _addBanner() async {
    final int maxBanners = 4;
    if (_banners.length + _newBanners.length >= maxBanners) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Maximum $maxBanners banners allowed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      // Pick image from gallery
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) {
        return;
      }

      // Read the file for preview
      final bytes = await image.readAsBytes();

      if (mounted) {
        setState(() {
          // Add to new banners list for later upload
          _newBanners.add({
            'file': image,
            'bytes': bytes,
            'displayOrder': _banners.length + _newBanners.length,
          });
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).bannerAdded),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding banner: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Upload all new banners when saving the store
  Future<List<StoreBanner>> _uploadBanners(String storeId) async {
    List<StoreBanner> uploadedBanners = [];

    try {
      // Upload each new banner
      for (final banner in _newBanners) {
        final XFile imageFile = banner['file'];
        final int displayOrder = banner['displayOrder'];

        // Upload image to Supabase storage
        final String? imageUrl = await SupabaseService.instance
            .uploadStoreImage(imageFile.path, imageFile.name);

        if (imageUrl != null) {
          // Create a new banner object
          final newBanner = StoreBanner(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            storeId: storeId,
            imageUrl: imageUrl,
            displayOrder: displayOrder,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          uploadedBanners.add(newBanner);
        }
      }

      return uploadedBanners;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading banners: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return uploadedBanners;
    }
  }

  void _removeBanner(int index) {
    setState(() {
      _banners.removeAt(index);
      // Update display order for remaining banners
      for (int i = 0; i < _banners.length; i++) {
        _banners[i] = StoreBanner(
          id: _banners[i].id,
          storeId: _banners[i].storeId,
          imageUrl: _banners[i].imageUrl,
          displayOrder: i,
          isActive: _banners[i].isActive,
          createdAt: _banners[i].createdAt,
          updatedAt: DateTime.now(),
        );
      }
    });
  }

  // No longer needed - using fixed social media fields

  // Get the appropriate image provider for the logo
  DecorationImage? _getLogoImage() {
    if (_logoFile != null) {
      // Use file image for preview
      return DecorationImage(
        image: FileImage(File(_logoFile!.path)),
        fit: BoxFit.cover,
      );
    } else if (_logoUrl != null) {
      // Check if it's a network URL or a memory image
      if (_logoUrl!.startsWith('memory://')) {
        // This is a placeholder for a memory image
        // The actual image is displayed using precacheImage in _pickLogo
        return null;
      } else {
        // Use network image
        return DecorationImage(
          image: NetworkImage(_logoUrl!),
          fit: BoxFit.cover,
        );
      }
    }
    return null;
  }

  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final localizations = AppLocalizations.of(context);

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      final storeController = Provider.of<StoreController>(
        context,
        listen: false,
      );

      if (!authController.isLoggedIn || authController.currentUser == null) {
        await ErrorDialogUtils.showErrorDialog(
          context: context,
          title: localizations.error,
          message: localizations.loginRequired,
        );
        return;
      }

      // Upload logo if needed
      String? logoUrl = _logoUrl;
      if (_logoFile != null) {
        setState(() {
          _isLoading = true;
        });
        logoUrl = await _uploadLogo();
        if (logoUrl == null) {
          if (mounted) {
            await ErrorDialogUtils.showErrorDialog(
              context: context,
              title: localizations.error,
              message: 'Failed to upload logo. Please try again.',
            );
          }
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Convert social media controllers to map
      final socialLinksMap = <String, String>{};
      if (_instagramController.text.isNotEmpty) {
        socialLinksMap['instagram'] = _instagramController.text;
      }
      if (_facebookController.text.isNotEmpty) {
        socialLinksMap['facebook'] = _facebookController.text;
      }
      if (_tiktokController.text.isNotEmpty) {
        socialLinksMap['tiktok'] = _tiktokController.text;
      }
      if (_twitterController.text.isNotEmpty) {
        socialLinksMap['twitter'] = _twitterController.text;
      }
      if (_youtubeController.text.isNotEmpty) {
        socialLinksMap['youtube'] = _youtubeController.text;
      }
      if (_snapchatController.text.isNotEmpty) {
        socialLinksMap['snapchat'] = _snapchatController.text;
      }

      if (widget.store == null) {
        // Create new store with a temporary ID
        final String storeId = DateTime.now().millisecondsSinceEpoch.toString();

        // Upload new banners if any
        List<StoreBanner> allBanners = List.from(_banners);
        if (_newBanners.isNotEmpty) {
          final uploadedBanners = await _uploadBanners(storeId);
          allBanners.addAll(uploadedBanners);
        }

        // Create new store
        final newStore = await storeController.createStore(
          ownerId: authController.currentUser!.id,
          name: _nameController.text,
          secondName:
              _secondNameController.text.isNotEmpty
                  ? _secondNameController.text
                  : null,
          description:
              _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : null,
          logoUrl: logoUrl,
          country: _countryValue.isNotEmpty ? _countryValue : _selectedCountry,
          // State field is stored in the model but not sent to the database until the column is added
          state: _stateValue.isNotEmpty ? _stateValue : _selectedState,
          city: _cityValue.isNotEmpty ? _cityValue : _cityController.text,
          keywords:
              _keywordsController.text.isNotEmpty
                  ? _keywordsController.text
                  : null,
          phoneNumber:
              _phoneController.text.isNotEmpty ? _phoneController.text : null,
          email:
              _emailController.text.isNotEmpty ? _emailController.text : null,
          website:
              _websiteController.text.isNotEmpty
                  ? _websiteController.text
                  : null,
          socialLinks: socialLinksMap.isNotEmpty ? socialLinksMap : null,
          categoryId: _selectedCategoryId,
          subcategoryIds: _selectedSubcategoryIds,
          banners: allBanners.isNotEmpty ? allBanners : null,
        );

        if (newStore != null && mounted) {
          // Explicitly refresh owner stores before navigating back
          final storeController = Provider.of<StoreController>(
            context,
            listen: false,
          );
          await storeController.loadOwnerStores(authController.currentUser!.id);

          if (mounted) {
            await ErrorDialogUtils.showSuccessDialog(
              context: context,
              title: localizations.success,
              message: localizations.storeCreated,
              onContinue: () {
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            );
          }
        } else if (mounted) {
          await ErrorDialogUtils.showErrorDialog(
            context: context,
            title: localizations.error,
            message: localizations.storeCreationFailed,
          );
        }
      } else {
        // Upload new banners if any
        List<StoreBanner> allBanners = List.from(_banners);
        if (_newBanners.isNotEmpty) {
          final uploadedBanners = await _uploadBanners(widget.store!.id);
          allBanners.addAll(uploadedBanners);
        }

        // Update existing store
        final updatedStore = Store(
          id: widget.store!.id,
          ownerId: widget.store!.ownerId,
          name: _nameController.text,
          secondName:
              _secondNameController.text.isNotEmpty
                  ? _secondNameController.text
                  : null,
          description:
              _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : null,
          logoUrl: logoUrl,
          country: _countryValue.isNotEmpty ? _countryValue : _selectedCountry,
          // State field is stored in the model but not sent to the database until the column is added
          state: _stateValue.isNotEmpty ? _stateValue : _selectedState,
          city: _cityValue.isNotEmpty ? _cityValue : _cityController.text,
          keywords:
              _keywordsController.text.isNotEmpty
                  ? _keywordsController.text
                  : null,
          phoneNumber:
              _phoneController.text.isNotEmpty ? _phoneController.text : null,
          email:
              _emailController.text.isNotEmpty ? _emailController.text : null,
          website:
              _websiteController.text.isNotEmpty
                  ? _websiteController.text
                  : null,
          socialLinks: socialLinksMap.isNotEmpty ? socialLinksMap : null,
          categoryId: _selectedCategoryId,
          subcategoryIds:
              _selectedSubcategoryIds.isNotEmpty
                  ? _selectedSubcategoryIds
                  : null,
          banners: allBanners.isNotEmpty ? allBanners : null,
          isVerified: widget.store!.isVerified,
          isActive: widget.store!.isActive,
          createdAt: widget.store!.createdAt,
          publishedAt: widget.store!.publishedAt,
          updatedAt: DateTime.now(),
        );

        final success = await storeController.updateStore(updatedStore);

        if (success && mounted) {
          // No need to explicitly call loadOwnerStores here as it's already called in updateStore method
          if (mounted) {
            await ErrorDialogUtils.showSuccessDialog(
              context: context,
              title: localizations.success,
              message: localizations.storeUpdated,
              onContinue: () {
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            );
          }
        } else if (mounted) {
          await ErrorDialogUtils.showErrorDialog(
            context: context,
            title: localizations.error,
            message: localizations.storeUpdateFailed,
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving store: $e');
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isEditing = widget.store != null;

    return Scaffold(
      // No app bar - we'll use a custom back button in the body
      extendBodyBehindAppBar: true,
      appBar: null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF673AB7), Color(0xFF311B92)],
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.only(
              top: 40,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            children: [
              // Custom back button
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),

              // Title
              Center(
                child: Text(
                  isEditing ? localizations.editStore : localizations.addStore,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Store Logo Card
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
                      // Store Logo header
                      _buildSectionHeader(localizations.storeLogo, Icons.photo),
                      const SizedBox(height: 16),

                      Center(
                        child: GestureDetector(
                          onTap: _pickLogo,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                              image: _getLogoImage(),
                            ),
                            child:
                                _logoFile == null && _logoUrl == null
                                    ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 40,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          localizations.tapToUpload,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    )
                                    : Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        const SizedBox.expand(),
                                        // Change button
                                        Container(
                                          margin: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentColor,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            onPressed: _pickLogo,
                                            tooltip: 'Change logo',
                                            constraints: const BoxConstraints(
                                              minWidth: 32,
                                              minHeight: 32,
                                            ),
                                            padding: const EdgeInsets.all(8),
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Recommended size: 400 x 400 pixels',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Store Banners Card
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
                      // Store Banners header
                      _buildSectionHeader(
                        localizations.storeBanners,
                        Icons.collections,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        localizations.storeBannersDescription,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                      const SizedBox(height: 16),

                      if (_banners.isEmpty && _newBanners.isEmpty)
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _addBanner,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: Text(localizations.addBanner),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.buttonPrimary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    _banners.length +
                                    _newBanners.length +
                                    1, // +1 for add button
                                itemBuilder: (context, index) {
                                  final totalBanners =
                                      _banners.length + _newBanners.length;

                                  if (index == totalBanners) {
                                    // Add button at the end
                                    return totalBanners < 4
                                        ? Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: GestureDetector(
                                            onTap: _addBanner,
                                            child: Container(
                                              width: 150,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.grey[300]!,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add_photo_alternate,
                                                    size: 40,
                                                    color: Colors.grey[400],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    localizations.addBanner,
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        : const SizedBox(); // Max 4 banners
                                  }

                                  // Check if this is an existing banner or a new one
                                  if (index < _banners.length) {
                                    // Existing banner
                                    final banner = _banners[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 300,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                                width: 1,
                                              ),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  banner.imageUrl,
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () => _removeBanner(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    // New banner
                                    final newBannerIndex =
                                        index - _banners.length;
                                    final newBanner =
                                        _newBanners[newBannerIndex];
                                    return Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 300,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey[300]!,
                                                width: 1,
                                              ),
                                              image: DecorationImage(
                                                image: FileImage(
                                                  File(
                                                    (newBanner['file'] as XFile)
                                                        .path,
                                                  ),
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _newBanners.removeAt(
                                                    newBannerIndex,
                                                  );
                                                });
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_banners.length + _newBanners.length}/4 ${localizations.banners}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Basic Information Card
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
                      // Basic Information header
                      _buildSectionHeader(
                        localizations.basicInformation,
                        Icons.info,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _nameController,
                        labelText: localizations.storeName,
                        prefixIcon: Icons.store,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations.storeNameRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _secondNameController,
                        labelText: localizations.storeSecondName,
                        prefixIcon: Icons.store,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _descriptionController,
                        labelText: localizations.storeDescription,
                        prefixIcon: Icons.description,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Contact Information Card
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
                      // Contact Information header
                      _buildSectionHeader(
                        localizations.contactInformation,
                        Icons.contact_phone,
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        controller: _phoneController,
                        labelText: localizations.phoneNumber,
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        labelText: localizations.email,
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!Validators.isValidEmail(value)) {
                              return localizations.invalidEmail;
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _websiteController,
                        labelText: localizations.website,
                        prefixIcon: Icons.language,
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!Validators.isValidUrl(value)) {
                              return localizations.invalidWebsite;
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Category Information Card
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
                      // Category Information header
                      _buildSectionHeader(
                        'Category Information',
                        Icons.category,
                      ),
                      const SizedBox(height: 16),

                      _buildCategoryDropdown(context),
                      const SizedBox(height: 16),
                      _buildSubcategoryDropdown(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Location Card
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
                      // Location header
                      _buildSectionHeader(
                        localizations.location,
                        Icons.location_on,
                      ),
                      const SizedBox(height: 16),

                      // Use current location switch
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: SwitchListTile(
                          title: Text(
                            localizations.useCurrentLocation,
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: _useCurrentLocation,
                          onChanged: (value) {
                            setState(() {
                              _useCurrentLocation = value;
                            });
                            if (value) {
                              _getCurrentLocation();
                            }
                          },
                          activeColor: AppColors.accentColor,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Country field with improved styling
                      CustomTextField(
                        labelText: localizations.country,
                        prefixIcon: Icons.public,
                        readOnly: true,
                        controller: TextEditingController(
                          text: _selectedCountry,
                        ),
                        onTap: () {
                          _showCountryPicker(context, localizations);
                        },
                        suffixIcon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // State/Province field with improved styling
                      CustomTextField(
                        labelText: 'State/Province',
                        prefixIcon: Icons.location_city,
                        readOnly: true,
                        controller: TextEditingController(text: _selectedState),
                        onTap: () {
                          if (_selectedCountry.isNotEmpty) {
                            _showStatePicker(context, localizations);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select a country first'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        suffixIcon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // City Text Field with matching style
                      CustomTextField(
                        controller: _cityController,
                        labelText: localizations.city,
                        prefixIcon: Icons.location_on,
                        onChanged: (value) {
                          setState(() {
                            _cityValue = value;
                            _selectedCity = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Keywords field
                      CustomTextField(
                        controller: _keywordsController,
                        labelText: 'Keywords (for search)',
                        prefixIcon: Icons.search,
                        maxLines: 2,
                        hintText:
                            'Enter keywords separated by spaces (e.g., fashion clothing shoes)',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Social Links Card
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
                      // Social Links header
                      _buildSectionHeader(
                        localizations.socialLinks,
                        Icons.link,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        localizations.socialLinksDescription,
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                      const SizedBox(height: 16),

                      // Fixed social media fields with authentic icons
                      _buildSocialMediaField(
                        controller: _instagramController,
                        icon: FontAwesomeIcons.instagram,
                        iconColor: const Color(0xFFE4405F),
                        label: 'Instagram',
                        hint: 'https://instagram.com/yourstore',
                      ),
                      const SizedBox(height: 16),

                      _buildSocialMediaField(
                        controller: _facebookController,
                        icon: FontAwesomeIcons.facebook,
                        iconColor: const Color(0xFF1877F2),
                        label: 'Facebook',
                        hint: 'https://facebook.com/yourstore',
                      ),
                      const SizedBox(height: 16),

                      _buildSocialMediaField(
                        controller: _tiktokController,
                        icon: FontAwesomeIcons.tiktok,
                        iconColor: const Color(0xFF000000),
                        label: 'TikTok',
                        hint: 'https://tiktok.com/@yourstore',
                      ),
                      const SizedBox(height: 16),

                      _buildSocialMediaField(
                        controller: _twitterController,
                        icon: FontAwesomeIcons.twitter,
                        iconColor: const Color(0xFF1DA1F2),
                        label: 'Twitter',
                        hint: 'https://twitter.com/yourstore',
                      ),
                      const SizedBox(height: 16),

                      _buildSocialMediaField(
                        controller: _youtubeController,
                        icon: FontAwesomeIcons.youtube,
                        iconColor: const Color(0xFFFF0000),
                        label: 'YouTube',
                        hint: 'https://youtube.com/c/yourstore',
                      ),
                      const SizedBox(height: 16),

                      _buildSocialMediaField(
                        controller: _snapchatController,
                        icon: FontAwesomeIcons.snapchat,
                        iconColor: const Color(0xFFFFFC00),
                        label: 'Snapchat',
                        hint: 'https://snapchat.com/add/yourstore',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.buttonPrimary.withAlpha(76),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isEditing
                                    ? Icons.update
                                    : Icons.add_circle_outline,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                isEditing
                                    ? localizations.updateStore
                                    : localizations.createStore,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

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

  // Helper method to build social media fields with authentic icons
  Widget _buildSocialMediaField({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.black54),
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: FaIcon(icon, color: iconColor, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: const TextStyle(color: Colors.black87),
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            if (!Validators.isValidUrl(value)) {
              return 'Please enter a valid URL';
            }
          }
          return null;
        },
      ),
    );
  }

  // Build category dropdown
  Widget _buildCategoryDropdown(BuildContext context) {
    final storeController = Provider.of<StoreController>(context);

    // Create a controller for the display text
    final categoryController = TextEditingController(
      text:
          _selectedCategoryId != null && storeController.categories.isNotEmpty
              ? _getCategoryName(_selectedCategoryId!, storeController)
              : '',
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: TextFormField(
        controller: categoryController,
        readOnly: true,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).category,
          labelStyle: const TextStyle(color: Colors.black54),
          prefixIcon: const Icon(Icons.category, color: Color(0xFF673AB7)),
          suffixIcon: const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFF673AB7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onTap: () {
          _showCategoryPicker(context, storeController);
        },
      ),
    );
  }

  // Get category name from ID
  String _getCategoryName(String categoryId, StoreController storeController) {
    try {
      if (storeController.categories.isEmpty) return '';

      final category = storeController.categories.firstWhere(
        (cat) => cat['id'] == categoryId,
        orElse:
            () => {
              'name': {'en': ''},
            },
      );

      return category['name'][_currentLocale] ?? category['name']['en'] ?? '';
    } catch (e) {
      debugPrint('Error getting category name: $e');
      return '';
    }
  }

  // Build subcategory dropdown
  Widget _buildSubcategoryDropdown(BuildContext context) {
    final storeController = Provider.of<StoreController>(context);

    // Create a controller for the display text
    final subcategoryController = TextEditingController(
      text:
          _selectedCategoryId != null &&
                  _selectedSubcategoryIds.isNotEmpty &&
                  storeController.subcategories.isNotEmpty
              ? _getSubcategoryNames(storeController)
              : '',
    );

    // Only enable subcategory selection if a category is selected
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: TextFormField(
        controller: subcategoryController,
        readOnly: true,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).subcategoriesMultiple,
          labelStyle: const TextStyle(color: Colors.black54),
          prefixIcon: const Icon(
            Icons.category_outlined,
            color: Color(0xFF673AB7),
          ),
          suffixIcon: const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFF673AB7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onTap:
            _selectedCategoryId == null
                ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).pleaseSelectCategoryFirst,
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                : () {
                  _showSubcategoryPicker(context, storeController);
                },
      ),
    );
  }

  // Get subcategory names from selected IDs
  String _getSubcategoryNames(StoreController storeController) {
    try {
      if (storeController.subcategories.isEmpty ||
          _selectedSubcategoryIds.isEmpty) {
        return '';
      }

      final names = <String>[];

      for (final id in _selectedSubcategoryIds) {
        try {
          final subcategory = storeController.subcategories.firstWhere(
            (subcat) => subcat['id'] == id,
            orElse:
                () => {
                  'name': {'en': ''},
                },
          );

          final name =
              subcategory['name'][_currentLocale] ??
              subcategory['name']['en'] ??
              '';

          if (name.isNotEmpty) {
            names.add(name);
          }
        } catch (e) {
          debugPrint('Error getting subcategory name for ID $id: $e');
        }
      }

      return names.join(', ');
    } catch (e) {
      debugPrint('Error getting subcategory names: $e');
      return '';
    }
  }

  // Show category picker dialog
  void _showCategoryPicker(
    BuildContext context,
    StoreController storeController,
  ) {
    if (storeController.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noCategoriesAvailable),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).selectCategory),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: storeController.categories.length,
                itemBuilder: (context, index) {
                  final category = storeController.categories[index];
                  final name =
                      category['name'][_currentLocale] ??
                      category['name']['en'] ??
                      'Unknown';

                  return ListTile(
                    title: Text(name),
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = category['id'];
                        _selectedCategoryName = name;
                        _selectedSubcategoryIds = []; // Reset subcategories
                      });

                      // Load subcategories for this category
                      storeController.loadSubcategories(_selectedCategoryId!);

                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),
    );
  }

  // Show subcategory picker dialog with multiple selection
  void _showSubcategoryPicker(
    BuildContext context,
    StoreController storeController,
  ) {
    if (storeController.subcategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noSubcategoriesAvailable),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create a temporary list for selection
    final selectedIds = List<String>.from(_selectedSubcategoryIds);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(AppLocalizations.of(context).selectSubcategories),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 300,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: storeController.subcategories.length,
                            itemBuilder: (context, index) {
                              final subcategory =
                                  storeController.subcategories[index];
                              final subcategoryId = subcategory['id'];
                              final name =
                                  subcategory['name'][_currentLocale] ??
                                  subcategory['name']['en'] ??
                                  'Unknown';
                              final isSelected = selectedIds.contains(
                                subcategoryId,
                              );

                              return CheckboxListTile(
                                title: Text(name),
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setDialogState(() {
                                    if (value == true) {
                                      if (!selectedIds.contains(
                                        subcategoryId,
                                      )) {
                                        selectedIds.add(subcategoryId);
                                      }
                                    } else {
                                      selectedIds.remove(subcategoryId);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedSubcategoryIds = selectedIds;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(AppLocalizations.of(context).save),
                    ),
                  ],
                ),
          ),
    );
  }

  // Show country picker dialog with localized country names
  void _showCountryPicker(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final localizedCountries = CountryStateData.getLocalizedCountries(locale);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(localizations.selectCountry),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: localizedCountries.length,
                itemBuilder: (context, index) {
                  final country = localizedCountries[index];
                  return ListTile(
                    title: Text(country['name']!),
                    onTap: () {
                      setState(() {
                        _selectedCountry = country['name']!;
                        _countryValue = country['name']!;
                        // Reset state and city when country changes
                        _selectedState = '';
                        _stateValue = '';
                        _selectedCity = '';
                        _cityValue = '';
                        _cityController.text = '';
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),
    );
  }

  // Show state picker dialog
  void _showStatePicker(BuildContext context, AppLocalizations localizations) {
    final states = CountryStateData.getStatesForCountry(_selectedCountry);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).selectStateProvince),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: states.length,
                itemBuilder: (context, index) {
                  final state = states[index];
                  return ListTile(
                    title: Text(state),
                    onTap: () {
                      setState(() {
                        _selectedState = state;
                        _stateValue = state;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),
    );
  }
}
