import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../services/location_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CountryDropdown extends StatefulWidget {
  final String? selectedCountry;
  final Function(String?) onChanged;
  final bool autoDetect;

  const CountryDropdown({
    super.key,
    this.selectedCountry,
    required this.onChanged,
    this.autoDetect = true,
  });

  @override
  State<CountryDropdown> createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  String? _selectedCountry;
  bool _isDetecting = false;

  // Supported countries
  final Map<String, String> _countries = {
    'TN': 'Tunisia',
    'US': 'United States',
    'FR': 'France',
  };

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.selectedCountry;

    if (widget.autoDetect && _selectedCountry == null) {
      _detectUserCountry();
    }
  }

  Future<void> _detectUserCountry() async {
    if (_isDetecting) return;

    setState(() {
      _isDetecting = true;
    });

    try {
      // First try to get from user profile
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      final currentUser = authController.currentUser;

      String? detectedCountry;

      if (currentUser?.country != null && currentUser!.country!.isNotEmpty) {
        detectedCountry = currentUser.country;
      } else {
        // Try to get from location
        final position = await LocationService.getCurrentPosition(context);
        if (position != null) {
          detectedCountry = await LocationService.getCountryFromCoordinates(
            position.latitude,
            position.longitude,
          );
        }
      }

      // Default to Tunisia if detection fails
      detectedCountry ??= 'TN';

      if (mounted && _selectedCountry == null) {
        setState(() {
          _selectedCountry = detectedCountry;
        });
        widget.onChanged(detectedCountry);
      }
    } catch (e) {
      debugPrint('Error detecting country: $e');
      // Default to Tunisia
      if (mounted && _selectedCountry == null) {
        setState(() {
          _selectedCountry = 'TN';
        });
        widget.onChanged('TN');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDetecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.country,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child:
              _isDetecting
                  ? Row(
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        localizations.detectingLocation,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  )
                  : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCountry,
                      dropdownColor: Colors.white,
                      style: const TextStyle(color: Colors.black87),
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF673AB7),
                      ),
                      isExpanded: true,
                      hint: Text(
                        localizations.selectCountry,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      items:
                          _countries.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Row(
                                children: [
                                  _getCountryFlag(entry.key),
                                  const SizedBox(width: 8),
                                  Text(entry.value),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (country) {
                        setState(() {
                          _selectedCountry = country;
                        });
                        widget.onChanged(country);
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _getCountryFlag(String countryCode) {
    switch (countryCode) {
      case 'TN':
        return const Text('🇹🇳', style: TextStyle(fontSize: 20));
      case 'US':
        return const Text('🇺🇸', style: TextStyle(fontSize: 20));
      case 'FR':
        return const Text('🇫🇷', style: TextStyle(fontSize: 20));
      default:
        return const Icon(Icons.flag, size: 20);
    }
  }
}
