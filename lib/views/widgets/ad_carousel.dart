import 'package:flutter/material.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../models/advertisement.dart';
import '../../constants/app_colors.dart';
import '../../providers/localization_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdCarousel extends StatefulWidget {
  final List<Advertisement> advertisements;
  final double height;
  final Function(int)? onPageChanged;
  final bool autoScroll;
  final int autoScrollDuration;

  const AdCarousel({
    super.key,
    required this.advertisements,
    this.height = 200,
    this.onPageChanged,
    this.autoScroll = true,
    this.autoScrollDuration = 5,
  });

  @override
  State<AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<AdCarousel> {
  int _currentIndex = 0;
  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    if (widget.autoScroll && widget.advertisements.length > 1) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (widget.autoScroll) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(Duration(seconds: widget.autoScrollDuration), (
      timer,
    ) {
      if (_currentIndex < widget.advertisements.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.advertisements.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              if (widget.onPageChanged != null) {
                widget.onPageChanged!(index);
              }
            },
            itemBuilder: (context, index) {
              final ad = widget.advertisements[index];
              final localizations = AppLocalizations.of(context);

              return Consumer<LocalizationProvider>(
                builder: (context, localizationProvider, _) {
                  final isRTL =
                      localizationProvider.currentLocale.languageCode == 'ar';

                  return GestureDetector(
                    onTap: () async {
                      await _launchURL(ad.clickUrl);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.pink[100],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              ad.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.pink[100],
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment:
                                  isRTL
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ad.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign:
                                      isRTL ? TextAlign.right : TextAlign.left,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () async {
                                    await _launchURL(ad.clickUrl);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.accentColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children:
                                        isRTL
                                            ? [
                                              Icon(Icons.arrow_back, size: 16),
                                              const SizedBox(width: 5),
                                              Text(localizations.view),
                                            ]
                                            : [
                                              Text(localizations.view),
                                              const SizedBox(width: 5),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 16,
                                              ),
                                            ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              widget.advertisements.asMap().entries.map((entry) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _currentIndex == entry.key
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
