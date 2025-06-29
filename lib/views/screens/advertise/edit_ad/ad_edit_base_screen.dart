import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matajir/constants/app_colors.dart';
import 'package:matajir/controllers/advertisement_controller.dart';
import 'package:matajir/models/advertisement.dart';
import 'package:matajir/utils/error_dialog_utils.dart';
import 'package:matajir/views/widgets/country_dropdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdEditBaseScreen extends StatefulWidget {
  final String title;
  final Advertisement advertisement;
  final Widget customContent;
  final Function(Map<String, dynamic> data) onSubmit;

  const AdEditBaseScreen({
    super.key,
    required this.title,
    required this.advertisement,
    required this.customContent,
    required this.onSubmit,
  });

  @override
  State<AdEditBaseScreen> createState() => _AdEditBaseScreenState();
}

class _AdEditBaseScreenState extends State<AdEditBaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _clickUrlController = TextEditingController();
  File? _selectedImage;
  String? _selectedCountry;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate fields with existing data
    _nameController.text = widget.advertisement.name;
    _clickUrlController.text = widget.advertisement.clickUrl ?? '';
    _selectedCountry = widget.advertisement.country;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _clickUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final adController = Provider.of<AdvertisementController>(
        context,
        listen: false,
      );

      // Prepare update data
      Map<String, dynamic> updateData = {
        'name': _nameController.text,
        'clickUrl': _clickUrlController.text,
        'country': _selectedCountry,
      };

      // If new image is selected, upload it first
      String? newImageUrl;
      if (_selectedImage != null) {
        // Upload new image
        newImageUrl = await adController.uploadAdvertisementImage(
          _selectedImage!,
        );
        if (newImageUrl != null) {
          updateData['imageUrl'] = newImageUrl;
        }
      }

      // Update advertisement
      final success = await adController.updateAdvertisement(
        id: widget.advertisement.id,
        name: updateData['name'],
        imageUrl: newImageUrl,
        clickUrl: updateData['clickUrl'],
        // Note: dates are not updated in edit mode
      );

      if (success && mounted) {
        // Call the onSubmit callback
        widget.onSubmit(updateData);

        final localizations = AppLocalizations.of(context);

        // Show success message
        await ErrorDialogUtils.showSuccessDialog(
          context: context,
          title: localizations.success,
          message: 'Advertisement updated successfully',
          onContinue: () {
            if (mounted) {
              Navigator.pop(context);
            }
          },
        );
      } else if (mounted) {
        final localizations = AppLocalizations.of(context);
        await ErrorDialogUtils.showErrorDialog(
          context: context,
          title: localizations.error,
          message: 'Failed to update advertisement. Please try again.',
        );
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context);
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Custom content (ad type specific)
                  widget.customContent,

                  const SizedBox(height: 24),

                  // Advertisement Details Card
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
                          // Advertisement Details header
                          Row(
                            children: [
                              const Icon(
                                Icons.edit,
                                size: 20,
                                color: Color(0xFF673AB7),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Advertisement Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF673AB7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Advertisement Name
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Advertisement Name',
                              hintText: 'Enter advertisement name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.campaign),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter advertisement name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          // Click URL
                          TextFormField(
                            controller: _clickUrlController,
                            decoration: InputDecoration(
                              labelText: 'Click URL',
                              hintText: 'Enter click URL (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.link),
                            ),
                            keyboardType: TextInputType.url,
                          ),

                          const SizedBox(height: 16),

                          // Country Selection
                          CountryDropdown(
                            selectedCountry: _selectedCountry,
                            onChanged: (country) {
                              setState(() {
                                _selectedCountry = country;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          // Current Image and Upload Section
                          const Text(
                            'Advertisement Image',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Current Image Display
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child:
                                  _selectedImage != null
                                      ? Stack(
                                        children: [
                                          Image.file(
                                            _selectedImage!,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.accentColor,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                onPressed: _pickImage,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 32,
                                                      minHeight: 32,
                                                    ),
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                      : widget.advertisement.imageUrl.isNotEmpty
                                      ? Stack(
                                        children: [
                                          Image.network(
                                            widget.advertisement.imageUrl,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                          ),
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.accentColor,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                onPressed: _pickImage,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 32,
                                                      minHeight: 32,
                                                    ),
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                      : InkWell(
                                        onTap: _pickImage,
                                        child: Container(
                                          color: Colors.grey[100],
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate,
                                                size: 48,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Tap to select new image',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Note about dates
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.blue[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Note: Advertisement dates cannot be changed. Current period: ${_formatDate(widget.advertisement.startsAt)} - ${_formatDate(widget.advertisement.endsAt)}',
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontSize: 12,
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

                  const SizedBox(height: 32),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'Update Advertisement',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
