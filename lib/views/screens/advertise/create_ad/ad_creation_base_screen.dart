import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matajir/constants/app_colors.dart';
import 'package:matajir/controllers/advertisement_controller.dart';
import 'package:matajir/services/advertisement_service.dart';
import 'package:matajir/views/widgets/country_dropdown.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdCreationBaseScreen extends StatefulWidget {
  final String title;
  final String adType;
  final Widget customContent;
  final Function(Map<String, dynamic> data) onSubmit;
  final String? categoryId;
  final String? subcategoryId;
  final String? storeId;

  const AdCreationBaseScreen({
    super.key,
    required this.title,
    required this.adType,
    required this.customContent,
    required this.onSubmit,
    this.categoryId,
    this.subcategoryId,
    this.storeId,
  });

  @override
  State<AdCreationBaseScreen> createState() => _AdCreationBaseScreenState();
}

class _AdCreationBaseScreenState extends State<AdCreationBaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clickUrlController = TextEditingController();
  File? _selectedImage;
  String? _imageUrl;
  int _durationValue = 1;
  String _durationType = 'week';
  String? _selectedCountry;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _clickUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final adController = Provider.of<AdvertisementController>(
      context,
      listen: false,
    );
    final imageFile = await adController.pickImageFromGallery();

    if (imageFile != null) {
      setState(() {
        _selectedImage = imageFile;
        _imageUrl = null; // Clear any previous URL
      });
    }
  }

  // Helper method to get image decoration
  DecorationImage? _getImageDecoration() {
    if (_selectedImage != null) {
      return DecorationImage(
        image: FileImage(_selectedImage!),
        fit: BoxFit.cover,
      );
    } else if (_imageUrl != null) {
      return DecorationImage(
        image: NetworkImage(_imageUrl!),
        fit: BoxFit.cover,
      );
    }
    return null;
  }

  Future<void> _submitForm() async {
    final localizations = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    // For store boost ads, we might use the store logo instead of uploaded image
    if (widget.adType == 'store_boost') {
      // Set loading state for store boost ads too
      setState(() {
        _isLoading = true;
      });

      try {
        // Let the onSubmit callback handle validation and processing
        final Map<String, dynamic> adData = {
          'name': _nameController.text,
          'clickUrl': _clickUrlController.text,
          'adType': widget.adType,
          'categoryId': widget.categoryId,
          'subcategoryId': widget.subcategoryId,
          'storeId': widget.storeId,
          'country': _selectedCountry,
          'durationValue': _durationValue,
          'durationType': _durationType,
        };

        await widget.onSubmit(adData);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
      return;
    }

    // For other ad types, require image upload
    if (_selectedImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.pleaseSelectImage)),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the shared advertisement service
      final advertisementService = AdvertisementService();

      final success = await advertisementService.createAndPayForAdvertisement(
        context: context,
        name: _nameController.text,
        imageFile: _selectedImage!,
        clickUrl: _clickUrlController.text,
        durationValue: _durationValue,
        durationType: _durationType,
        adType: widget.adType,
        categoryId: widget.categoryId,
        subcategoryId: widget.subcategoryId,
        storeId: widget.storeId,
        country: _selectedCountry,
      );

      if (success && mounted) {
        // Prepare data for callback
        final Map<String, dynamic> adData = {
          'name': _nameController.text,
          'clickUrl': _clickUrlController.text,
          'adType': widget.adType,
          'categoryId': widget.categoryId,
          'subcategoryId': widget.subcategoryId,
          'storeId': widget.storeId,
        };

        // Call the onSubmit callback
        widget.onSubmit(adData);

        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
          child: Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: [
                // Sliver App Bar with animated back button and title
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  pinned: true,
                  floating: true,
                  snap: false,
                  expandedHeight: 120.0,
                  collapsedHeight: 60.0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: LayoutBuilder(
                    builder: (
                      BuildContext context,
                      BoxConstraints constraints,
                    ) {
                      // Calculate the percentage of expansion (1.0 = fully expanded, 0.0 = collapsed)
                      final double expandRatio =
                          ((constraints.maxHeight - 60.0) / (120.0 - 60.0))
                              .clamp(0.0, 1.0);

                      return FlexibleSpaceBar(
                        background: Stack(
                          children: [
                            // Back button that fades out when scrolling
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 8,
                              left: 16.0,
                              child: Opacity(
                                opacity: expandRatio,
                                child: GestureDetector(
                                  onTap:
                                      expandRatio > 0.5
                                          ? () {
                                            Navigator.pop(context);
                                          }
                                          : null,
                                  child: Container(
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
                                      color: Color(0xFF673AB7),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Title in the center when collapsed
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 16,
                              left: 0,
                              right: 0,
                              child: Opacity(
                                opacity: 1.0 - expandRatio,
                                child: Center(
                                  child: Text(
                                    widget.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Main content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title when expanded
                        Center(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Image Selection Card (hidden for store boost)
                        if (widget.adType != 'store_boost')
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
                                  // Image Selection header
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.image,
                                        size: 20,
                                        color: Color(0xFF673AB7),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        localizations.advertisementImage,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF673AB7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    localizations.recommendedImageSize(
                                      '1200 x 400 pixels',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Image picker
                                  GestureDetector(
                                    onTap: _isLoading ? null : _pickImage,
                                    child: Container(
                                      width: double.infinity,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                        image: _getImageDecoration(),
                                      ),
                                      child:
                                          _isLoading
                                              ? const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                              : _selectedImage == null &&
                                                  _imageUrl == null
                                              ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.add_photo_alternate,
                                                    size: 40,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    localizations
                                                        .tapToUploadImage,
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                    margin:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.accentColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                      onPressed: _pickImage,
                                                      tooltip:
                                                          localizations
                                                              .changeImage,
                                                      constraints:
                                                          const BoxConstraints(
                                                            minWidth: 32,
                                                            minHeight: 32,
                                                          ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
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

                        // Advertisement Details Card (hidden for store boost)
                        if (widget.adType != 'store_boost') ...[
                          const SizedBox(height: 20),
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
                                  // Details header
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.description,
                                        size: 20,
                                        color: Color(0xFF673AB7),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        localizations.advertisementDetails,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF673AB7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Ad name field
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: _nameController,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                      decoration: InputDecoration(
                                        labelText:
                                            localizations.advertisementName,
                                        labelStyle: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                        hintText:
                                            localizations
                                                .enterAdvertisementName,
                                        hintStyle: const TextStyle(
                                          color: Colors.black38,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return localizations
                                              .thisFieldRequired;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Click URL field
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: TextFormField(
                                      controller: _clickUrlController,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: localizations.clickUrl,
                                        labelStyle: const TextStyle(
                                          color: Colors.black54,
                                        ),
                                        hintText: localizations.enterClickUrl,
                                        hintStyle: const TextStyle(
                                          color: Colors.black38,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return localizations
                                              .thisFieldRequired;
                                        }
                                        if (!Uri.parse(value).isAbsolute) {
                                          return localizations.invalidUrl;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        // Country Selection Card
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
                                // Country header
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.public,
                                      size: 20,
                                      color: Color(0xFF673AB7),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      localizations.country,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF673AB7),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Country dropdown
                                CountryDropdown(
                                  selectedCountry: _selectedCountry,
                                  onChanged: (country) {
                                    setState(() {
                                      _selectedCountry = country;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Duration Card
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
                                // Duration header
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.timer,
                                      size: 20,
                                      color: Color(0xFF673AB7),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      localizations.duration,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF673AB7),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Duration selection
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            value: _durationValue,
                                            dropdownColor: Colors.white,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                            ),
                                            icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: Color(0xFF673AB7),
                                            ),
                                            items:
                                                List.generate(
                                                      4,
                                                      (index) => index + 1,
                                                    )
                                                    .map(
                                                      (value) =>
                                                          DropdownMenuItem<int>(
                                                            value: value,
                                                            child: Text(
                                                              value.toString(),
                                                            ),
                                                          ),
                                                    )
                                                    .toList(),
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  _durationValue = value;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _durationType,
                                            dropdownColor: Colors.white,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                            ),
                                            icon: const Icon(
                                              Icons.arrow_drop_down,
                                              color: Color(0xFF673AB7),
                                            ),
                                            items: [
                                              DropdownMenuItem<String>(
                                                value: 'day',
                                                child: Text(localizations.day),
                                              ),
                                              DropdownMenuItem<String>(
                                                value: 'week',
                                                child: Text(localizations.week),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  _durationType = value;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Custom content
                        widget.customContent,

                        const SizedBox(height: 32),

                        // Submit button
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
                            onPressed: _isLoading ? null : _submitForm,
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.add_circle_outline,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          localizations.createAdvertisement,
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
                      ],
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
